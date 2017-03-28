#!/bin/bash
#
# Name:
#   dump100_launch_kafka_scheduler.sh
#
# Description:
#   Launches the dump1090 kafka scheduler
#----------------------------------------------------------------------------

h_vertica_dist=/opt/vertica
h_vertica_kafka_bin_dir=${h_vertica_dist}/packages/kafka/bin


nohup ${h_vertica_kafka_bin_dir}/vkconfig launch --instance-name dump1090_scheduler --dbhost 'localhost' --dbport '5433' --username 'dbadmin' --password '' --config-schema 'dump1090Scheduler' &

echo "Background PID:"
echo $!

exit 0

#----------------------------------------------------------------------------
# End of script
#---------------------------------------------------------------------------
