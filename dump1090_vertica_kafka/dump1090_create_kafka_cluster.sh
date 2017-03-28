#!/bin/bash
#
# Name:
#   dump100_create_kafka_cluster.sh
#
# Description:
#
#----------------------------------------------------------------------------
# Create the cluster
#----------------------------------------------------------------------------

h_vertica_dist=/opt/vertica
h_vertica_kafka_bin_dir=${h_vertica_dist}/packages/kafka/bin

${h_vertica_kafka_bin_dir}/vkconfig cluster --create --cluster pennardpi_cluster --hosts pennardpi10:9092 --dbhost localhost --dbport 5433 --username dbadmin --config-schema dump1090Scheduler 

exit 0

#----------------------------------------------------------------------------
# End of script
#---------------------------------------------------------------------------
