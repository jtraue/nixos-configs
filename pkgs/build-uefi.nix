{ pkgs, ... }:
pkgs.writeShellScriptBin "build-uefi" ''
  set -eu

  supernova_dir="/home/jtraue/workspace/supernova-core"
  supernova_obj_dir="$supernova_dir"/build
  supernova_tftp_dir="/var/lib/tftpboot/files/"

  kickstart_dir="/home/jtraue/workspace/kickstart"
  kickstart_obj_dir="$kickstart_dir"/build
  kickstart_tftp_dir="/var/lib/tftpboot/kickstart/"

  build_targets="build-default"

  build()
  {
      cd $supernova_dir
      tup $build_targets/src
      tup $build_targets/contrib/NOVA

      hv_bin_dir=$build_targets/contrib/NOVA/src
      objcopy -Oelf32-i386 $hv_bin_dir/hypervisor-x86_64 $hv_bin_dir/hypervisor32
      cd -

      cd $kickstart_dir
      tup $build_targets/
      cd -
  }

  sync_build()
  {
      rsync -vazcp --delete --exclude "*.*" --exclude coverage --exclude Makefile $supernova_obj_dir* $supernova_tftp_dir/
      rsync -vazcp --delete --exclude "*.o" --exclude coverage --exclude Makefile $kickstart_obj_dir* $kickstart_tftp_dir/
  }

  for arg in $@; do

  if [ "$arg" == "all" ]; then
      echo "Build..."
      build
      echo "Sync..."
      sync_build
      exit
  fi

  if [ "$arg" == "build" ]; then
      echo "Build..."
      build
  fi

  if [ "$arg" == "sync" ]; then
      echo "Sync..."
      sync_build
  fi

  done
''
