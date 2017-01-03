#!/bin/bash
#
# Name:
#   dump100_create_kafka_target
#
# Description:
#
#----------------------------------------------------------------------------
# Create the targets
#----------------------------------------------------------------------------

h_vertica_dist=/opt/vertica
h_vertica_kafka_bin_dir=${h_vertica_dist}/packages/kafka/bin

${h_vertica_kafka_bin_dir}/vkconfig target --create  --dbhost localhost --dbport 5433 --username dbadmin --password '' --config-schema dump1090Scheduler --target-schema dump1090_kafka --target-table  dump1090_id 

${h_vertica_kafka_bin_dir}/vkconfig target --create  --dbhost localhost --dbport 5433 --username dbadmin --password '' --config-schema dump1090Scheduler --target-schema dump1090_kafka --target-table  dump1090_air 

${h_vertica_kafka_bin_dir}/vkconfig target --create  --dbhost localhost --dbport 5433 --username dbadmin --password '' --config-schema dump1090Scheduler --target-schema dump1090_kafka --target-table  dump1090_sta 

${h_vertica_kafka_bin_dir}/vkconfig target --create  --dbhost localhost --dbport 5433 --username dbadmin --password '' --config-schema dump1090Scheduler --target-schema dump1090_kafka --target-table  dump1090_msg_1 

${h_vertica_kafka_bin_dir}/vkconfig target --create  --dbhost localhost --dbport 5433 --username dbadmin --password '' --config-schema dump1090Scheduler --target-schema dump1090_kafka --target-table  dump1090_msg_2 

${h_vertica_kafka_bin_dir}/vkconfig target --create  --dbhost localhost --dbport 5433 --username dbadmin --password '' --config-schema dump1090Scheduler --target-schema dump1090_kafka --target-table  dump1090_msg_3 

${h_vertica_kafka_bin_dir}/vkconfig target --create  --dbhost localhost --dbport 5433 --username dbadmin --password '' --config-schema dump1090Scheduler --target-schema dump1090_kafka --target-table  dump1090_msg_4 

${h_vertica_kafka_bin_dir}/vkconfig target --create  --dbhost localhost --dbport 5433 --username dbadmin --password '' --config-schema dump1090Scheduler --target-schema dump1090_kafka --target-table  dump1090_msg_5 

${h_vertica_kafka_bin_dir}/vkconfig target --create  --dbhost localhost --dbport 5433 --username dbadmin --password '' --config-schema dump1090Scheduler --target-schema dump1090_kafka --target-table  dump1090_msg_6 

${h_vertica_kafka_bin_dir}/vkconfig target --create  --dbhost localhost --dbport 5433 --username dbadmin --password '' --config-schema dump1090Scheduler --target-schema dump1090_kafka --target-table  dump1090_msg_8 



exit 0

#----------------------------------------------------------------------------
# End of script
#---------------------------------------------------------------------------
