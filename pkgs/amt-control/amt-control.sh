#!/usr/bin/env bash

set -e -u

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
amt_version="11.0"
major_version=$(echo $amt_version | awk -F'.' '{print $1}')

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
      amttool $IPADDR reset
  fi

  if [ "$?" != "0" ]; then
      exit $?
  fi
}

info_amt()
{
  wsman identify -h $IPADDR -P $WSMAN_PORT -u admin -p $AMT_PASSWORD

  if [ "$?" != "0" ]; then
      exit $?
  fi
}

term_amt()
{
  amtterm -u admin -p $AMT_PASSWORD $IPADDR $WSMAN_PORT

  if [ "$?" != "0" ]; then
      exit $?
  fi
}

poweron_amt()
{
  if [ "$major_version" -gt "8" ]; then
      command_amt 2
  else
      amttool $IPADDR powerup
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
      amttool $IPADDR powerdown
  fi

  if [ "$?" != "0" ]; then
      exit $?
  fi
}

# Keep in mind: power on will only work if the machine has an IP
# which means it has to be turned on once before.
# This is too error prone for me - disabled 'on' option.
if [ ! $# -eq 2 ]; then
  echo "Usage: amt_control <ip> reset|off|info|term"
  exit 1
fi

IPADDR=$1
AMT_PASSWORD=Password123!

if [ "$2" == "reset" ]; then
  reset_amt
fi
if [ "$2" == "info" ]; then
  info_amt
fi
if [ "$2" == "off" ]; then
  poweroff_amt
fi

if [ "$2" == "term" ]; then
  term_amt
fi
