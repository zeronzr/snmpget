#!/usr/bin/env bash

#Any issue blame felipea@

checkRequirements () {
os="Linux"

if [ "$os" == "Linux" ]; then

pkg_ok=$(dpkg-query -W --showformat='${Status}\n' snmp | grep "install ok installed")
echo Checking for SNMP package...

  if [ "" == "$pkg_ok" ]; then
    echo "SNMP not found. Setting up SNMP package. Require elevation."
    sudo apt-get --force-yes --yes install snmp
  else 
    echo "SNMP Already Installed."
  fi

fi

}

checkRequirements

exit $?
