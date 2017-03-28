#!/bin/bash
#
# Name:
#   dump100_create_kafka_microbatch
#
# Description:
#
#----------------------------------------------------------------------------
# Create the microbatch
#----------------------------------------------------------------------------

h_vertica_dist=/opt/vertica
h_vertica_kafka_bin_dir=${h_vertica_dist}/packages/kafka/bin

${h_vertica_kafka_bin_dir}/vkconfig microbatch --create  --dbhost localhost --dbport 5433 --username dbadmin --password '' --config-schema dump1090Scheduler --target-schema dump1090_kafka --target-table  dump1090_id --load-spec dump1090_load_spec --add-source-cluster pennardpi_cluster --add-source dump1090_id --microbatch dump1090_id --rejection-schema dump1090_kafka --rejection-table dump1090_id_rej

${h_vertica_kafka_bin_dir}/vkconfig microbatch --create  --dbhost localhost --dbport 5433 --username dbadmin --password '' --config-schema dump1090Scheduler --target-schema dump1090_kafka --target-table  dump1090_air --load-spec dump1090_load_spec --add-source-cluster pennardpi_cluster --add-source dump1090_air --microbatch dump1090_air --rejection-schema dump1090_kafka --rejection-table dump1090_air_rej

${h_vertica_kafka_bin_dir}/vkconfig microbatch --create  --dbhost localhost --dbport 5433 --username dbadmin --password '' --config-schema dump1090Scheduler --target-schema dump1090_kafka --target-table  dump1090_sta --load-spec dump1090_load_spec --add-source-cluster pennardpi_cluster --add-source dump1090_sta --microbatch dump1090_sta --rejection-schema dump1090_kafka --rejection-table dump1090_sta_rej

${h_vertica_kafka_bin_dir}/vkconfig microbatch --create  --dbhost localhost --dbport 5433 --username dbadmin --password '' --config-schema dump1090Scheduler --target-schema dump1090_kafka --target-table  dump1090_msg_1 --load-spec dump1090_load_spec --add-source-cluster pennardpi_cluster --add-source dump1090_msg_1 --microbatch dump1090_msg_1 --rejection-schema dump1090_kafka --rejection-table dump1090_msg_1_rej

${h_vertica_kafka_bin_dir}/vkconfig microbatch --create  --dbhost localhost --dbport 5433 --username dbadmin --password '' --config-schema dump1090Scheduler --target-schema dump1090_kafka --target-table  dump1090_msg_2 --load-spec dump1090_load_spec --add-source-cluster pennardpi_cluster --add-source dump1090_msg_2 --microbatch dump1090_msg_2 --rejection-schema dump1090_kafka --rejection-table dump1090_msg_2_rej

${h_vertica_kafka_bin_dir}/vkconfig microbatch --create  --dbhost localhost --dbport 5433 --username dbadmin --password '' --config-schema dump1090Scheduler --target-schema dump1090_kafka --target-table  dump1090_msg_3 --load-spec dump1090_load_spec --add-source-cluster pennardpi_cluster --add-source dump1090_msg_3 --microbatch dump1090_msg_3 --rejection-schema dump1090_kafka --rejection-table dump1090_msg_3_rej

${h_vertica_kafka_bin_dir}/vkconfig microbatch --create  --dbhost localhost --dbport 5433 --username dbadmin --password '' --config-schema dump1090Scheduler --target-schema dump1090_kafka --target-table  dump1090_msg_4 --load-spec dump1090_load_spec --add-source-cluster pennardpi_cluster --add-source dump1090_msg_4 --microbatch dump1090_msg_4 --rejection-schema dump1090_kafka --rejection-table dump1090_msg_4_rej

${h_vertica_kafka_bin_dir}/vkconfig microbatch --create  --dbhost localhost --dbport 5433 --username dbadmin --password '' --config-schema dump1090Scheduler --target-schema dump1090_kafka --target-table  dump1090_msg_5 --load-spec dump1090_load_spec --add-source-cluster pennardpi_cluster --add-source dump1090_msg_5 --microbatch dump1090_msg_5 --rejection-schema dump1090_kafka --rejection-table dump1090_msg_5_rej

${h_vertica_kafka_bin_dir}/vkconfig microbatch --create  --dbhost localhost --dbport 5433 --username dbadmin --password '' --config-schema dump1090Scheduler --target-schema dump1090_kafka --target-table  dump1090_msg_6 --load-spec dump1090_load_spec --add-source-cluster pennardpi_cluster --add-source dump1090_msg_6 --microbatch dump1090_msg_6 --rejection-schema dump1090_kafka --rejection-table dump1090_msg_6_rej

${h_vertica_kafka_bin_dir}/vkconfig microbatch --create  --dbhost localhost --dbport 5433 --username dbadmin --password '' --config-schema dump1090Scheduler --target-schema dump1090_kafka --target-table  dump1090_msg_8 --load-spec dump1090_load_spec --add-source-cluster pennardpi_cluster --add-source dump1090_msg_8 --microbatch dump1090_msg_8 --rejection-schema dump1090_kafka --rejection-table dump1090_msg_8_rej


exit 0

#----------------------------------------------------------------------------
# End of script
#---------------------------------------------------------------------------
