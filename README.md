# icinga2-gearman
Icinga2 with Gearman workers

## Purpose
We have 3000+ hosts and 17000+ services in our Icinga2 installation. Most checks are done every 5 minutes, but we also have a lot of checks that needs to be executed more often like every minute. Due to a bug in Icinga2 (_The Zone object 'worker' has more than two endpoints. Due to a known issue this type of configuration is strongly discouraged and may cause Icinga to use excessive amounts of CPU time._) we need to have more than two satellites, or workers as we call them.

This scales really bad for two reasons. The obvious one is the bug described above. More than two workers (satellites) adds excessive CPU time. The other reason is that the Icinga2 cluster divides workloads *evenly* across all workers. If you have 4 workers with different hardware, your slowest server will have 25% of the total workload if you don't dedicate checks to specific servers (which is a bad idea in case that server has a problem).

I really liked the mod-gearman-tools for Icinga1 where all the workers ran gearman. You could add and remove workers as you saw fit, and the hardware config could be totally different. Each worker just does how much he _can_ of the workload.

So what I wanted to to, was to put gearman into play also for Icinga2.

*NOTE: This is not tested in a production environment. Everything here is dev/lab stuff. Proceed at your own risk!*

## Quick and dirty howto

![Image](PoC_Diagram.png "diagram")

So what I want to do is to offload all the work from the Icinga2 workers (satellites), and move that workload down to gearman workers. I still want to have two Icinga2 workers for redundancy, but the only task these two servers have is to add jobs to the gearman job server and present the results back to the master Icinga2 server.

The checks in icinga2 needs to be rewritten so that they start with "gearman_check.sh <original full check>". Example:

```
object CheckCommand "check_hostname_cpu" {
   import "plugin-check-command"
   command = PluginDir + "/gearman_check.sh check_snmp -C xxx -o cpmCPUTotal5minRev.2 -u % -w :70 -c :80 -l CPU_RSP0 -H hostname"
```

This will add the check-job to the gearman job server queue. This script (gearman_check.sh) is the only check-script you need to have in the /usr/lib/nagios/plugins directory on the Icinga2 workers.

The Gearman workers will run the other script (icinga2_gearman_worker.sh) to join the two gearman worker queues, and they need to have the full range of check scripts in the /usr/lib/nagios/plugins directory. In theory you can add as many gearman workers as you want.

## Status
The project is up and running in our lab. There is not a whole lot of workload, but still everything works exactly as planned.

## TODO
* Make background services from the icinga2_gearman_worker.sh script
* Add more tuning and tweaking for workers (max number of jobs, etc)
* Stress-test and see how everything is holding up
* Use in production...?
