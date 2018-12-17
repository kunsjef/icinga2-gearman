#!/bin/bash

# Icinga2 gearman check script
# ------------------------------------------------------
#    version         gearman_check.sh 0.2
#    author          Thomas Vadahl
#    copyright       Copyright (c) Thomas Vadahl
#    license         GNU General Public License
# ------------------------------------------------------
# Description:
# The point of this script is to add Icinga2 check jobs to a gearman job server
# queue. The expected answer is the normal check result from any Icinga/Nagios 
# check PLUS the exitstatus. 
#
# Example of Icinga2 CheckCommand:
# object CheckCommand "check_hostname_cpu" {
#   import "plugin-check-command"
#   command = PluginDir + "/gearman_check.sh check_snmp -C xxx -o cpmCPUTotal5minRev.2 -u % -w :70 -c :80 -l CPU_RSP0 -H hostname"

gearman="/usr/bin/gearman"
host="10.0.0.1"      # Change this to your gearman job server
port="4730"          # Gearman job server port name. Default is 4730
func="test"          # The function or queue name
command="$@"         # The full check command

output=`$gearman -h $host -p $port -f $func "${command}"`

gearman_exitstatus=$?

if [[ $gearman_exitstatus != 0 ]]; then
  echo $output
  echo "UNKNOWN - Gearman problems..."
  exit 3
else
  check_exitstatus=$(echo $output | awk -F";" '{print $NF}')
  check_output=$(echo $output | rev | cut -d";" -f2- | rev)
  echo $check_output
  exit $check_exitstatus
fi
