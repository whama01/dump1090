#!/bin/bash
#
# Name:
#   dump100_create_kafka_source
#
# Description:
#
#----------------------------------------------------------------------------
# Create the sources
#----------------------------------------------------------------------------

h_vertica_dist=/opt/vertica
h_vertica_kafka_bin_dir=${h_vertica_dist}/packages/kafka/bin

${h_vertica_kafka_bin_dir}/vkconfig source --create --cluster pennardpi_cluster --dbhost localhost --dbport 5433 --username dbadmin --password '' --config-schema dump1090Scheduler --source dump1090_id --partitions 1

${h_vertica_kafka_bin_dir}/vkconfig source --create --cluster pennardpi_cluster --dbhost localhost --dbport 5433 --username dbadmin --password '' --config-schema dump1090Scheduler --source dump1090_air --partitions 1

${h_vertica_kafka_bin_dir}/vkconfig source --create --cluster pennardpi_cluster --dbhost localhost --dbport 5433 --username dbadmin --password '' --config-schema dump1090Scheduler --source dump1090_sta --partitions 1

${h_vertica_kafka_bin_dir}/vkconfig source --create --cluster pennardpi_cluster --dbhost localhost --dbport 5433 --username dbadmin --password '' --config-schema dump1090Scheduler --source dump1090_msg_1 --partitions 1

${h_vertica_kafka_bin_dir}/vkconfig source --create --cluster pennardpi_cluster --dbhost localhost --dbport 5433 --username dbadmin --password '' --config-schema dump1090Scheduler --source dump1090_msg_2 --partitions 1

${h_vertica_kafka_bin_dir}/vkconfig source --create --cluster pennardpi_cluster --dbhost localhost --dbport 5433 --username dbadmin --password '' --config-schema dump1090Scheduler --source dump1090_msg_3 --partitions 1

${h_vertica_kafka_bin_dir}/vkconfig source --create --cluster pennardpi_cluster --dbhost localhost --dbport 5433 --username dbadmin --password '' --config-schema dump1090Scheduler --source dump1090_msg_4 --partitions 1

${h_vertica_kafka_bin_dir}/vkconfig source --create --cluster pennardpi_cluster --dbhost localhost --dbport 5433 --username dbadmin --password '' --config-schema dump1090Scheduler --source dump1090_msg_5 --partitions 1

${h_vertica_kafka_bin_dir}/vkconfig source --create --cluster pennardpi_cluster --dbhost localhost --dbport 5433 --username dbadmin --password '' --config-schema dump1090Scheduler --source dump1090_msg_6 --partitions 1

${h_vertica_kafka_bin_dir}/vkconfig source --create --cluster pennardpi_cluster --dbhost localhost --dbport 5433 --username dbadmin --password '' --config-schema dump1090Scheduler --source dump1090_msg_8 --partitions 1

exit 0

#----------------------------------------------------------------------------
# End of script
#---------------------------------------------------------------------------
