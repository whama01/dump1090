#!/bin/bash
#
# Name:
#   dump100_create_kafka_scheduler.sh
#
# Description:
#   Creates the dump1090 kafka scheduler
#----------------------------------------------------------------------------

h_vertica_dist=/opt/vertica
h_vertica_kafka_bin_dir=${h_vertica_dist}/packages/kafka/bin


${h_vertica_kafka_bin_dir}/vkconfig scheduler --add --dbhost 'localhost' --dbport '5433' --username 'dbadmin' --password '' --config-schema 'dump1090Scheduler' --resource-pool 'kafka_default_pool' --frame-duration '00:00:10' --config-refresh '00:05:00' --new-source-policy 'FAIR'  --operator 'dbadmin'

exit 0

#----------------------------------------------------------------------------
# End of script
#---------------------------------------------------------------------------
