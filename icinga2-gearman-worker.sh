#!/bin/bash

# Icinga2 gearman worker
# ------------------------------------------------------
#    version         icinga2-gearman-worker.sh 0.4
#    author          Thomas Vadahl
#    copyright       Copyright (c) Thomas Vadahl
#    license         GNU General Public License
# ------------------------------------------------------
# Description:
# The point of this script is to join a gearman job server queue and perform
# checks for Icinga2. The expected result is the normal check result from any
# Icinga/Nagios chec PLUS the exitstatus. This exitstatus needs to be read by
# the gearman_check.sh script.
#
# Run like this:
# gearman -w -h <gearman_job_server_hostname> -p <port> -f <queue-name> xargs ./icinga2-gearman-worker.sh
#
# Example:
# gearman -w -h 10.0.0.1 -p 4730 -f icinga2 xargs ./icinga2-gearman-worker.sh

path="/usr/lib/nagios/plugins"
command="$@"

run=$(${path}/${command})
exit_status=$?

echo "${run};${exit_status}"
