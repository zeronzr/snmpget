#!/usr/bin/env bash

#Any issue blame felipea@

checkRequirements () {

clear

echo ******* Welcome to TORMatic  *******
echo This script will install the net-snmp packages and get the Serial Number
echo and the MAC Address of the specified Switch.
echo
echo Hit Enter to continue...

linux=$(uname -a | grep "Ubuntu")
mac=$(uname -a | grep "Darwin")

if [ "Darwin" == "$mac" ]; then

  echo "Not ready yet."

elif [ "Linux" == "$linux" ]; then

pkg_ok=$(dpkg-query -W --showformat='${Status}\n' snmp | grep "install ok installed")
echo Checking for SNMP package...

  if [ "" == "$pkg_ok" ]; then
    echo "SNMP not found. Setting up SNMP package. Require elevation."
    sudo apt-get --force-yes --yes install snmp
    ./download-mibs
  else
    echo "SNMP Already Installed."
  fi

fi

}

initiation () {

snmptranslate -IR -Td IF-MIB::linkDown > compareTranslate

echo -n "Type the Switch IP Address: "
read ip

cisco=$(snmpwalk -v 2c -c public %ipaddress% SNMPv2-MIB::sysDescr.0 | grep "Cisco IOS")
fastpath=$(snmpwalk -v 2c -c public %ipaddress% SNMPv2-MIB::sysDescr.0 | grep "Linux")
almach=$(snmpwalk -v 2c -c public %ipaddress% SNMPv2-MIB::sysDescr.0 | grep "almach")

if [ "Cisco IOS" == "$cisco" ]; then
  snmpwalk -v 2c -c public $ip SNMPv2-SMI::mib-2.47.1.1.1.1.11 | grep "FDO"
  snmpwalk -v 2c -c public $ip ipNetToMediaPhysAddress | grep "%ipaddress%"
elif [ "Linux" == "$fastpath"  ]; then
  snmpwalk -v 2c -c public $ip SNMPv2-SMI::mib-2.47.1.1.1.1.11 | grep "24D"
  snmpwalk -v 2c -c public $ip SNMPv2-SMI::mib-2.67.1.2.1.1.2.0
elif [ "almach" == "$almach" ]; then
  snmpwalk -v 2c -c public %ipaddress% SNMPv2-SMI::enterprises.40310.1.4.1.0 | grep "QTFC"
  snmpwalk -v 2c -c public %ipaddress% ipNetToMediaPhysAddress
fi

}

checkRequirements

exit $?
