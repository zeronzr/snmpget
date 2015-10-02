#!/usr/bin/env bash

#Any issue blame felipea@

checkRequirements () {

clear

echo ******* Welcome to TORMatic  *******
echo This script will install the net-snmp packages and get the Serial Number
echo and the MAC Address of the specified Switch.
echo
echo Hit Enter to continue...
read enter

linux=$(uname -a | grep "Ubuntu")
osl=${linux: -5}
mac=$(uname -a | grep "Darwin")
osm=${mac: -5}
ifconfig eth0 192.168.0.5 netmask 255.255.255.0

if [ "Darwin" == "$osm" ]; then

  echo "Not ready yet."

elif [ "Linux" == "$osl" ]; then

pkg_ok=$(dpkg-query -W --showformat='${Status}\n' snmp | grep "install ok installed")
echo Checking for SNMP package...

  if [ "" == "$pkg_ok" ]; then
    echo "SNMP not found. Setting up SNMP package. Require elevation."
    sudo apt-get --force-yes --yes install snmp
    ./download-mibs
  else
    echo "SNMP Already Installed."
    initiation
  fi

fi

}

initiation () {

echo -n "Type the Switch IP Address: "
read ip

cisco=$(snmpwalk -v 2c -c public $ip .1.3.6.1.2.1.1.1.0 | grep "Cisco IOS")
echo ${cisco: +31} | awk '{print $1;}' > ios
ios=`cat ios`
echo $ios
fastpath=$(snmpwalk -v 2c -c public $ip .1.3.6.1.2.1.1.1.0 | grep "Linux")
echo ${fastpath: +31} | awk '{print $1;}' > linux
linux=`cat linux`
almach=$(snmpwalk -v 2c -c public $ip .1.3.6.1.2.1.1.1.0 | grep "almach")
echo ${almach: +31} | awk '{print $1;}' > almachos
almachos=`cat almachos`

if [ "Cisco" == "$ios" ]; then
  ciscoSN=$(snmpwalk -v 2c -c public $ip .1.3.6.1.2.1.47.1.1.1.1.11 | grep "FDO")
  ciscoMAC=$(snmpwalk -v 2c -c public $ip 1.3.6.1.2.1.4.22.1.2 | grep "$ip")
  echo ${ciscoMAC: +55} | tr " " - > ciscoMAC
  echo ${ciscoSN: +44} | sed s/\"//g > ciscoSN
  ciscoMAC=`cat ciscoMAC`
  ciscoSN=`cat ciscoSN`
  echo 1,2,3,4 > cisco.csv
  echo SN,$ciscoSN,MAC,$ciscoMAC >> cisco.csv
elif [ "Linux" == "$linux" ]; then
  fastpathSN=$(snmpwalk -v 2c -c public $ip .1.3.6.1.2.1.47.1.1.1.1.11 | grep "24D" > fastpathSN)
  fastpathMAC=$(snmpwalk -v 2c -c public $ip .1.3.6.1.2.1.67.1.2.1.1.2.0)
elif [ "almach" == "$almachos" ]; then
  almachSN=$(snmpwalk -v 2c -c public $ip .1.3.6.1.4.1.40310.1.4.1.0 | grep "QTFC")
  almachMAC=$(snmpwalk -v 2c -c public $ip 1.3.6.1.2.1.4.22.1.2)
fi

}

checkRequirements
