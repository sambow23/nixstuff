#!/bin/bash

echo "Matching sensors to hwmon paths:"

# Function to find hwmon path for a given sensor name
find_hwmon_path() {
    local sensor_name=$1
    for hwmon in /sys/class/hwmon/hwmon*; do
        if [ -f "$hwmon/name" ]; then
            if [ "$(cat $hwmon/name)" == "$sensor_name" ]; then
                echo $hwmon
                return
            fi
        fi
    done
    echo "Not found"
}

# Core temperatures (coretemp)
coretemp_path=$(find_hwmon_path "coretemp")
if [ "$coretemp_path" != "Not found" ]; then
    echo "Core temperatures (coretemp):"
    echo "  Path: $coretemp_path"
    for temp in $coretemp_path/temp*_input; do
        label=$(cat ${temp%_input}_label 2>/dev/null || echo "Unlabeled")
        value=$(awk '{print $1/1000}' $temp)
        echo "  $label: ${value}°C"
    done
else
    echo "Core temperatures (coretemp): Not found"
fi

# Dell SMM
dell_smm_path=$(find_hwmon_path "dell_smm")
if [ "$dell_smm_path" != "Not found" ]; then
    echo -e "\nDell SMM sensors:"
    echo "  Path: $dell_smm_path"
    for temp in $dell_smm_path/temp*_input; do
        label=$(cat ${temp%_input}_label 2>/dev/null || echo "Temp ${temp##*/}")
        value=$(awk '{print $1/1000}' $temp)
        echo "  $label: ${value}°C"
    done
    for fan in $dell_smm_path/fan*_input; do
        label=$(cat ${fan%_input}_label 2>/dev/null || echo "Fan ${fan##*/}")
        value=$(cat $fan)
        echo "  $label: ${value} RPM"
    done
else
    echo "Dell SMM sensors: Not found"
fi

# PCH temperature
pch_path=$(find_hwmon_path "pch_cannonlake")
if [ "$pch_path" != "Not found" ]; then
    echo -e "\nPCH temperature:"
    echo "  Path: $pch_path"
    temp_value=$(awk '{print $1/1000}' $pch_path/temp1_input)
    echo "  Temp: ${temp_value}°C"
else
    echo "PCH temperature: Not found"
fi

# NVMe temperature
nvme_path=$(find_hwmon_path "nvme")
if [ "$nvme_path" != "Not found" ]; then
    echo -e "\nNVMe temperature:"
    echo "  Path: $nvme_path"
    for temp in $nvme_path/temp*_input; do
        label=$(cat ${temp%_input}_label 2>/dev/null || echo "Temp ${temp##*/}")
        value=$(awk '{print $1/1000}' $temp)
        echo "  $label: ${value}°C"
    done
else
    echo "NVMe temperature: Not found"
fi

# Wireless adapter temperature
iwlwifi_path=$(find_hwmon_path "iwlwifi")
if [ "$iwlwifi_path" != "Not found" ]; then
    echo -e "\nWireless adapter temperature:"
    echo "  Path: $iwlwifi_path"
    temp_value=$(awk '{print $1/1000}' $iwlwifi_path/temp1_input)
    echo "  Temp: ${temp_value}°C"
else
    echo "Wireless adapter temperature: Not found"
fi

# Battery (if applicable)
hidpp_path=$(find_hwmon_path "hidpp_battery")
if [ "$hidpp_path" != "Not found" ]; then
    echo -e "\nBattery sensor:"
    echo "  Path: $hidpp_path"
    voltage=$(awk '{print $1/1000000}' $hidpp_path/in0_input)
    echo "  Voltage: ${voltage}V"
else
    echo "Battery sensor: Not found"
fi

echo -e "\nNote: Some sensors might not be available depending on your hardware configuration."
