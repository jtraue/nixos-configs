{ pkgs, ... }:
pkgs.writeShellScriptBin "build" ''
  set -eu
  BUILD_HOST="xps"
  PROJECT_SRC_DIR="/home/jtraue/workspace/supernova-core"
  PROJECT_OBJ_DIR="/home/jtraue/workspace/supernova-core/build"
  TFTP_DIR="/var/lib/tftpboot/files/"

  IPADDR="10.0.0.187" # lewisburg2
  USE_AMT="false"

  if [ "$USE_AMT" == "" ]; then
      USE_AMT="true"
  fi

  if [ "$USE_IP" != "" ]; then
      IPADDR="$USE_IP"
  fi

  BUILD_TARGETS="build-default"
  if [ "$USE_BUILD_TARGETS" != "" ]; then
      BUILD_TARGETS="$USE_BUILD_TARGETS"
  fi

  XML1='
  <p:RequestPowerStateChange_INPUT xmlns:p="http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_PowerManagementService">
    <p:PowerState>'
  XML2='</p:PowerState>
    <p:ManagedElement xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing"
                      xmlns:wsman="http://schemas.dmtf.org/wbem/wsman/1/wsman.xsd">
      <wsa:Address>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:Address>
      <wsa:ReferenceParameters>
        <wsman:ResourceURI>http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ComputerSystem</wsman:ResourceURI>
        <wsman:SelectorSet>
          <wsman:Selector Name="CreationClassName">CIM_ComputerSystem</wsman:Selector>
          <wsman:Selector Name="Name">ManagedSystem</wsman:Selector>
        </wsman:SelectorSet>
      </wsa:ReferenceParameters>
    </p:ManagedElement>
  </p:RequestPowerStateChange_INPUT>
  '

  WSMAN_PORT=16992
  export AMT_PASSWORD=Password123!

  # Check for AMT version
  major_version=0
  if [ "$USE_AMT" == "true" ]; then
      #amt_version=$(amttool $IPADDR info 2>&1 | grep version | awk '{print $NF}')
      amt_version="11.0"
      major_version=$(echo $amt_version | awk -F'.' '{print $1}')
  #    status=$(wsman enumerate 'http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_AssociatedPowerManagementService' -h $IPADDR -P $WSMAN_PORT -u admin -p $AMT_PASSWORD -v -V -o -j utf-8 | grep "h:PowerState" | awk -F [\<\>] '{print $3}')
  #    echo "Machine has status $status"
  fi

  vdev_build()
  {
      #ssh $BUILD_HOST "cd $PROJECT_SRC_DIR && make -sj16 ARCH=x86_64"
      #ssh $BUILD_HOST "bash --login -c 'cd $PROJECT_SRC_DIR && tup $BUILD_TARGETS'"
      cd $PROJECT_SRC_DIR
      tup $BUILD_TARGETS
      #docker run -it --rm --privileged -v /Users/parthy/Work/git/supernova-core:/home/user/supernova-core --tmpfs /tmp supernova-dev-container \
      #    bash -c 'cd supernova-core && tup'
      if [ "$?" != "0" ]; then
          cd -
          exit $?
      fi
      cd -
  }

  sync_build()
  {
      rsync -vazcp --delete --exclude "*.*" --exclude coverage --exclude Makefile $PROJECT_OBJ_DIR* $TFTP_DIR/
      if [ "$?" != "0" ]; then
          exit $?
      fi
  }

  reset_ipmi()
  {
      status=$(ipmitool -H $IPADDR -U ADMIN -P ADMIN power status)
      if [ "$status" == "Chassis Power is off" ]; then
          ipmitool -H $IPADDR -U ADMIN -P ADMIN power on
      else
          ipmitool -H $IPADDR -U ADMIN -P ADMIN power reset
      fi
      if [ "$?" != "0" ]; then
          exit $?
      fi
  }

  poweron_ipmi()
  {
      ipmitool -H $IPADDR -U ADMIN -P ADMIN power on
      if [ "$?" != "0" ]; then
          exit $?
      fi
  }

  poweroff_ipmi()
  {
      ipmitool -H $IPADDR -U ADMIN -P ADMIN power off
      if [ "$?" != "0" ]; then
          exit $?
      fi
  }

  command_amt()
  {
      echo $XML1$1$XML2 | wsman invoke -a RequestPowerStateChange \
                      "http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_PowerManagementService" \
                      --port $WSMAN_PORT -h $IPADDR --username admin -p $AMT_PASSWORD -V -v -J - > /dev/null
  }

  reset_amt()
  {
      if [ "$major_version" -gt "8" ]; then
          status=$(wsman enumerate 'http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_AssociatedPowerManagementService' -h $IPADDR -P $WSMAN_PORT -u admin -p $AMT_PASSWORD -v -V -o -j utf-8 | grep "h:PowerState" | awk -F [\<\>] '{print $3}')
          if [ "$status" == "8" ]; then
              command_amt 2
          else
              command_amt 10
          fi
      else
          amttool $IPADDR_AMT reset
      fi

      if [ "$?" != "0" ]; then
          exit $?
      fi
  }

  poweron_amt()
  {
      if [ "$major_version" -gt "8" ]; then
          command_amt 2
      else
          amttool $IPADDR_AMT powerup
      fi

      if [ "$?" != "0" ]; then
          exit $?
      fi
  }

  poweroff_amt()
  {
      if [ "$major_version" -ge "8" ]; then
          command_amt 8
      else
          amttool $IPADDR_AMT powerdown
      fi

      if [ "$?" != "0" ]; then
          exit $?
      fi
  }

  for arg in $@; do

  if [ "$arg" == "all" ]; then
      echo "Build..."
      vdev_build
      echo "Sync..."
      sync_build
      echo "Reset..."
      reset_ipmi
      exit
  fi

  if [ "$arg" == "reset" ]; then
      echo "Reset..."
      if [ "$USE_AMT" == "true" ]; then
          reset_amt
      else
          reset_ipmi
      fi
  fi

  if [ "$arg" == "on" ]; then
      echo "Power on..."
      if [ "$USE_AMT" == "true" ]; then
          poweron_amt
      else
          poweron_ipmi
      fi
  fi

  if [ "$arg" == "off" ]; then
      echo "Power off..."
      if [ "$USE_AMT" == "true" ]; then
          poweroff_amt
      else
          poweroff_ipmi
      fi
  fi

  if [ "$arg" == "amt" ]; then
      echo "Reset AMT..."
      reset_amt
  fi

  if [ "$arg" == "build" ]; then
      echo "Build..."
      vdev_build
  fi

  if [ "$arg" == "sync" ]; then
      echo "Sync..."
      sync_build
  fi

  done

''
