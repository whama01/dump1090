#!/bin/bash
#
# Name:
#   dump100_create_kafka_load_spec
#
# Description:
#
#----------------------------------------------------------------------------
# Create the load_specs
#----------------------------------------------------------------------------

h_vertica_dist=/opt/vertica
h_vertica_kafka_bin_dir=${h_vertica_dist}/packages/kafka/bin


${h_vertica_kafka_bin_dir}/vkconfig load-spec --update  --dbhost localhost --dbport 5433 --username dbadmin --password '' --config-schema dump1090Scheduler --load-spec dump1090_load_spec --filters "filter KafkaInsertDelimiters(delimiter=E'\n')" --load-method 'TRICKLE' --parser DELIMITED --parser-parameters "DELIMITER E','"

exit 0

#----------------------------------------------------------------------------
# End of script
#---------------------------------------------------------------------------
