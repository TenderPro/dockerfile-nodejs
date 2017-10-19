#!/bin/bash

# strict mode http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# Run command via uid of current user ($FLAG owner)
root=$PWD
FLAG=$root/Makefile

# Create user if none
if [[ "$APPUSER" ]]; then
  grep -qe "^$APPUSER:" /etc/passwd || useradd -m -r -s /bin/bash -Gwww-data -gusers -gsudo $APPUSER
fi

# Change user id to FLAG owner's uid
FLAG_UID=$(stat -c '%u' $FLAG)
if [[ "$FLAG_UID" ]] && [[ $FLAG_UID != $(id -u $APPUSER) ]]; then
  if [[ "$FLAG_UID" != "0" ]] ; then
    echo "Set uid $FLAG_UID for user $APPUSER"
    usermod -u $FLAG_UID $APPUSER
  fi
  echo "chown $APPUSER /home/app/"
  chown -R $APPUSER /home/app
fi

export PATH=/usr/lib/node_modules/.bin:$PATH
export NODE_PATH=/usr/lib/node_modules

# Add link to global modules
[ -L $root/web_loaders ] || ln -s /usr/lib/node_modules $root/web_loaders

echo "Run main shell.."
gosu $APPUSER $@
