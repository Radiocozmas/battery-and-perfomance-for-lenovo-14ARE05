#!/bin/bash

while :
do
clear



if [ "x$(id -u)" != 'x0' ]; then
  echo 'Error: this script can only be executed by root'
  exit 1
fi

if [ -e /proc/acpi/call ] || sudo modprobe acpi_call ; then
  acpi -i
  acpi -a
  else echo -e "You need to install acpi_call kernel module"; exit 1
fi
echo
       echo "-----------------------------"
echo '\_SB.PCI0.LPC0.EC0.BTSG' | tee /proc/acpi/call > /dev/null
calldata=$(tr -d '\0' < /proc/acpi/call)
if [ $calldata == 0x0called ] ; then
       echo "| Battery Conservation OFF  |"
  else echo "| Battery Conservation ON   |";
fi
echo "-----------------------------"
echo '\_SB.PCI0.LPC0.EC0.FCGM' | tee /proc/acpi/call > /dev/null
calldata=$(tr -d '\0' < /proc/acpi/call)
if [ $calldata == 0x0called ] ; then
       echo "|     Rapid Charge OFF      |"
  else echo "|     Rapid Charge ON       |";
fi

echo "-----------------------------"
echo '\_SB.PCI0.LPC0.EC0.STMD' | tee /proc/acpi/call > /dev/null
calldata=$(tr -d '\0' < /proc/acpi/call)
if [ $calldata == 0x1called ] ; then
       echo "|    Intelligent Cooling    |"
  else
        echo '\_SB.PCI0.LPC0.EC0.QTMD' | tee /proc/acpi/call > /dev/null
            calldata=$(tr -d '\0' < /proc/acpi/call)
            if [ $calldata == 0x0called ] ; then
       echo "|   Extreme Performance     |";
              else
       echo "|      Battery Saving       |";
            fi
fi

function charger() {
case "$1" in
    "BattConservOn") echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x03' | tee /proc/acpi/call > /dev/null ;;
    "BattConservOff") echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x05' | tee /proc/acpi/call > /dev/null ;;
    "RapidChargeOn") echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x07' | tee /proc/acpi/call > /dev/null ;;
    "RapidChargeOff") echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x08' | tee /proc/acpi/call > /dev/null ;;
    "IntelliCool") echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x000FB001' | tee /proc/acpi/call > /dev/null;;
    "ExtremePerf") echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x0012B001' | tee /proc/acpi/call > /dev/null;;
    "BatterySafe") echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x0013B001' | tee /proc/acpi/call > /dev/null;;
    "Exit") exit 0;;
    *) echo -e "\nERROR: \"$1\" is a bad command!\n\nSCRIPT USE:\n\t$(basename "$(readlink -nf "$0")") command\nAVALIABLE COMMANDS:\n\batProtect, batFull, RapidCahargeOn, RapidChargeOff, IntelliCool, ExtremePerf, BatterySafe" ;;
esac
}

if [ -z "$1" ]; then
echo "-----------------------------"
echo
echo "-----------------------------"
echo "1. Enable \"Battery Conservation Mode\" 60% battery maximum. Use this if you always AC plug in"
echo "2. Enable \"Battery Full Charge Mode\" 100% battery maximum."
echo "-----------------------------"
echo "3. Enable \"Rapid Charge\""
echo "4. Disable \"Rapid Charge\""
echo "-----------------------------"
echo "  \"Power Smart Settings\" "
echo "5. Set to \"Intelligent Cooling\" "
echo "6. Set to \"Performance mode\""
echo "7. Set to \"Battery Saving\""
echo "-----------------------------"
echo "8. Exit"
echo "-----------------------------"
echo -n "Choose an action: "

while true; do
  read -r menu
  case "$menu" in
    1) charger BattConservOn; break ;;
    2) charger BattConservOff; break ;;
    3) charger RapidChargeOn; break ;;
    4) charger RapidChargeOff; break ;;
    5) charger IntelliCool; break ;;
    6) charger ExtremePerf; break ;;
    7) charger BatterySafe; break ;;
    8) charger Exit; break ;;
    *) echo "ERROR: \"$menu\" is invalid option. Enter the correct one:" ;;
  esac

done

fi
charger "$1"

done

