#!/bin/bash
#
#----------------------------------------------------------------------------
#
# Name:
#   dump1090_demo.sh
#
# Description:
#   This is the main controlling component of the DUMP1090 demo application.
#
#   Although the individual components that make up the DUMP1090 demo can be
#   manually run, you are strongly advised not to.
#
# History:
#   1.0 14-Sep-2015 (mark.whalley@actian.com)
#       Created from a Post-It note definition
#
#
#----------------------------------------------------------------------------
h_prog_name=`basename ${0}`
h_prog_version=v1.0
#----------------------------------------------------------------------------

INITIALIZE()
{

   h_pid=$$

   h_dump1090_parameter_file="./dump1090_parameters.txt"

   if [ ! -f $h_dump1090_parameter_file ]
   then
      printf "%s\n" "Unable to locate the $h_dump1090_parameter_file file"
      exit 1
   fi

   h_logfile_dir="./log"

   if [ ! -d $h_logfile_dir ]
   then
      printf "%s\n" "Unable to locate the $h_logfile_dir directory"
      exit 1
   fi


   h_logfile=$h_logfile_dir"/dump1090_log."$h_pid

   MESSAGELOG "========"
   MESSAGELOG "DUMP1090"
   MESSAGELOG "========"


   h_bin_dir="./bin"

   if [ ! -d $h_bin_dir ]
   then
      h_error_message="Unable to locate the $h_bin_dir directory"
      MESSAGELOG $h_error_message
      printf "%s\n" $h_error_message
      exit 1
   fi


   h_kafka_producer=$h_bin_dir"/dump1090_kafka_producer.sh"

   if [ ! -f $h_kafka_producer ]
   then
      h_error_message="Unable to locate the $h_kafka_producer script"
      MESSAGELOG $h_error_message
      printf "%s\n" $h_error_message
      exit 1
   fi



   h_dataflow_stream_kafka=$h_bin_dir"/dump1090_stream_kafka.sh"

   if [ ! -f $h_dataflow_stream_kafka ]
   then
      h_error_message="Unable to locate the $h_dataflow_stream_kafka script"
      MESSAGELOG $h_error_message
      printf "%s\n" $h_error_message
      exit 1
   fi


   h_dataflow_read_kafka_write_ingres=$h_bin_dir"/dump1090_read_kafka_write_ingres.sh"

   if [ ! -f $h_dataflow_read_kafka_write_ingres ]
   then
      h_error_message="Unable to locate the $h_dataflow_read_kafka_write_ingres script"
      MESSAGELOG $h_error_message
      printf "%s\n" $h_error_message
      exit 1
   fi


   h_visualize=$h_bin_dir"/dump1090_visualize.sh"

   if [ ! -f $h_visualize ]
   then
      h_error_message="Unable to locate the $h_visualize script"
      MESSAGELOG $h_error_message
      printf "%s\n" $h_error_message
      exit 1
   fi


   return 0

}

function MESSAGELOG
{
   h_message=$*

   h_reported_message=`date +"%d/%m/%Y %H:%M:%S"`
   h_reported_message=$h_reported_message" - ""$h_prog_name"" - ""$h_message"

   echo $h_reported_message >> $h_logfile

   if [ "$h_DUMP1090_VERBOSE" = "Y" ]
   then
      echo $h_reported_message
   fi

   return 0
}


READ_PARAMATER_FILE()
{

   h_DUMP1090_BASE_DIR=`grep ^DUMP1090_BASE_DIR $h_dump1090_parameter_file | awk '{print $2}'`
   h_DUMP1090_TMP_DIR=`grep ^DUMP1090_TMP_DIR $h_dump1090_parameter_file | awk '{print $2}'`
   h_DUMP1090_LOG=`grep ^DUMP1090_LOG $h_dump1090_parameter_file | awk '{print $2}'`
   h_DUMP1090_USER=`grep ^DUMP1090_USER $h_dump1090_parameter_file | awk '{print $2}'`
   h_DUMP1090_RPI_IP=`grep ^DUMP1090_RPI_IP $h_dump1090_parameter_file | awk '{print $2}'`
   h_DUMP1090_RPI_PORT=`grep ^DUMP1090_RPI_PORT $h_dump1090_parameter_file | awk '{print $2}'`
   h_DUMP1090_KAFKA_BROKER_IP=`grep ^DUMP1090_KAFKA_BROKER_IP $h_dump1090_parameter_file | awk '{print $2}'`
   h_DUMP1090_KAFKA_BROKER_PORT=`grep ^DUMP1090_KAFKA_BROKER_PORT $h_dump1090_parameter_file | awk '{print $2}'`
   h_DUMP1090_KAFKA_TOPIC=`grep ^DUMP1090_KAFKA_TOPIC $h_dump1090_parameter_file | awk '{print $2}'`
   h_DUMP1090_II_SYSTEM=`grep ^DUMP1090_II_SYSTEM $h_dump1090_parameter_file | awk '{print $2}'`
   h_DUMP1090_IVH=`grep ^DUMP1090_IVH $h_dump1090_parameter_file | awk '{print $2}'`
   h_DUMP1090_DATABASE=`grep ^DUMP1090_DATABASE $h_dump1090_parameter_file | awk '{print $2}'`
   h_DUMP1090_SQL_TIME_SLICE_NUMBER=`grep ^DUMP1090_SQL_TIME_SLICE_NUMBER $h_dump1090_parameter_file | awk '{print $2}'`
   h_DUMP1090_SQL_TIME_SLICE_UNITS=`grep ^DUMP1090_SQL_TIME_SLICE_UNITS $h_dump1090_parameter_file | awk '{print $2}'`
   h_DUMP1090_VERBOSE=`grep ^DUMP1090_VERBOSE $h_dump1090_parameter_file | awk '{print $2}'`

# -----------------------------------------------------------------------------
# TBC: Validate parameter file values
# -----------------------------------------------------------------------------

   MESSAGELOG ""
   MESSAGELOG "Parameters read from $h_dump1090_parameter_file"
   MESSAGELOG ""

   MESSAGELOG "DUMP1090_BASE_DIR....................." $h_DUMP1090_BASE_DIR
   MESSAGELOG "DUMP1090_TMP_DIR......................" $h_DUMP1090_TMP_DIR
   MESSAGELOG "DUMP1090_LOG.........................." $h_DUMP1090_LOG
   MESSAGELOG "DUMP1090_USER........................." $h_DUMP1090_USER
   MESSAGELOG "DUMP1090_RPI_IP......................." $h_DUMP1090_RPI_IP
   MESSAGELOG "DUMP1090_RPI_PORT....................." $h_DUMP1090_RPI_PORT
   MESSAGELOG "DUMP1090_KAFKA_BROKER_IP.............." $h_DUMP1090_KAFKA_BROKER_IP
   MESSAGELOG "DUMP1090_KAFKA_BROKER_PORT............" $h_DUMP1090_KAFKA_BROKER_PORT
   MESSAGELOG "DUMP1090_KAFKA_TOPIC.................." $h_DUMP1090_KAFKA_TOPIC
   MESSAGELOG "DUMP1090_II_SYSTEM...................." $h_DUMP1090_II_SYSTEM
   MESSAGELOG "DUMP1090_IVH.........................." $h_DUMP1090_IVH
   MESSAGELOG "DUMP1090_DATABASE....................." $h_DUMP1090_DATABASE
   MESSAGELOG "DUMP1090_SQL_TIME_SLICE_NUMBER........" $h_DUMP1090_SQL_TIME_SLICE_NUMBER
   MESSAGELOG "DUMP1090_SQL_TIME_SLICE_UNITS........." $h_DUMP1090_SQL_TIME_SLICE_UNITS
   MESSAGELOG "DUMP1090_VERBOSE......................" $h_DUMP1090_VERBOSE
   MESSAGELOG ""

   return 0

}


KAFKA_PRODUCER()
{

   MESSAGELOG Starting function KAFKA_PRODUCER

   h_kafka_producer_action=$1

   MESSAGELOG Calling $h_kafka_producer

   $h_kafka_producer --action $h_kafka_producer_action --logfile $h_logfile --kafka_broker_ip $h_DUMP1090_KAFKA_BROKER_IP --kafka_broker_port $h_DUMP1090_KAFKA_BROKER_PORT --kafka_topic $h_DUMP1090_KAFKA_TOPIC --rpi_ip $h_DUMP1090_RPI_IP --rpi_port $h_DUMP1090_RPI_PORT --verbose $h_DUMP1090_VERBOSE

   MESSAGELOG Completed function KAFKA_PRODUCER
   MESSAGELOG ""


   return 0
}


DATAFLOW_STREAM_KAFKA()
{

   MESSAGELOG Starting function DATAFLOW_STREAM_KAFKA

   h_dataflow_stream_kafka_action=$1

   MESSAGELOG Calling $h_dataflow_stream_kafka

   $h_dataflow_stream_kafka --action $h_dataflow_stream_kafka_action --logfile $h_logfile --verbose $h_DUMP1090_VERBOSE

   MESSAGELOG Completed function DATAFLOW_STREAM_KAFKA
   MESSAGELOG 

   return 0
}


DATAFLOW_READ_KAFKA_WRITE_INGRES()
{

   MESSAGELOG Starting function DATAFLOW_READ_KAFKA_WRITE_INGRES

   h_dataflow_read_kafka_write_ingres_action=$1

   MESSAGELOG Calling $h_dataflow_stream_kafka

   $h_dataflow_read_kafka_write_ingres --action $h_dataflow_read_kafka_write_ingres_action --logfile $h_logfile --verbose $h_DUMP1090_VERBOSE

   MESSAGELOG Completed function DATAFLOW_READ_KAFKA_WRITE_INGRES
   MESSAGELOG 

   return 0
}



VISUALIZE()
{

   MESSAGELOG Starting function VISUALIZE

   h_visualize_action=$1

   MESSAGELOG Calling $h_visualize

   $h_visualize --action $h_visualize_action --logfile $h_logfile --verbose $h_DUMP1090_VERBOSE --ii_system $h_DUMP1090_II_SYSTEM --database $h_DUMP1090_DATABASE --time_slice_number $h_DUMP1090_SQL_TIME_SLICE_NUMBER --time_slice_units $h_DUMP1090_SQL_TIME_SLICE_UNITS

   MESSAGELOG Completed function VISUALIZE
   MESSAGELOG 

   return 0
}


START_DUMP1090()
{

   MESSAGELOG Starting function START_DUMP1090

   READ_PARAMATER_FILE

   KAFKA_PRODUCER start

   DATAFLOW_STREAM_KAFKA start

   DATAFLOW_READ_KAFKA_WRITE_INGRES start

   VISUALIZE start

   MESSAGELOG Completed function START_DUMP1090
   MESSAGELOG

   return 0

}


PRINT_USAGE()
{
    printf "%s\n" "Usage:"
    printf "%s\n" "  $h_prog_name"

    printf "%s\n" "   start    (to start the DUMP1090 demo)"
    printf "%s\n" "   stop     (to stop the DUMP1090 demo)"

}





#----------------------------------------------------------------------------
# main program
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# Process Command Line Variables (clv)
#----------------------------------------------------------------------------

while [ -n "$1" ]
do
   case "$1" in

   start)
      h_clv_action="start"
      ;;

   stop)
      h_clv_action="stop"
      ;;

    *)
       printf "%s\n" "Invalid parameter: $1"
       PRINT_USAGE
       exit 1
       ;;

   esac

   shift

done



#----------------------------------------------------------------------------
# Validate CLV
#----------------------------------------------------------------------------

   if [ -z "$h_clv_action" ]
   then
      printf "%s\n" "Action not defined"
      PRINT_USAGE
      exit 1
   fi

#----------------------------------------------------------------------------
# OK, lets do stuff
#----------------------------------------------------------------------------

INITIALIZE

case $h_clv_action in

  "start")  
      while true
      do

         START_DUMP1090

         MESSAGELOG ""
         MESSAGELOG "Sleeping for 60 seconds before checking if everything is still running"
         MESSAGELOG ""

         sleep 60

      done
      ;;

  "stop")  
      STOP_DUMP1090
      ;;

esac

#----------------------------------------------------------------------------
# End of script
#---------------------------------------------------------------------------
