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
