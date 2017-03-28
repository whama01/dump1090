#!/bin/bash
#
#----------------------------------------------------------------------------
#
# Name:
#   dump1090_stream_kafka.sh
#
# Description:
#   This script is part of the DUMP1090 demo application.
#
#   The purpose of this script is to control the starting and stopping of
#   the DataFlow stream KAFKA object.
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

   MESSAGELOG "Initiated"

   h_dataflow_workflow_dir="./dataflow_workflow"

   if [ ! -d $h_dataflow_workflow_dir ]
   then
      h_error_message="Unable to locate the $h_dataflow_workflow_dir directory"
      MESSAGELOG $h_error_message
      printf "%s\n" $h_error_message
      exit 1
   fi


   h_dataflow_stream_kafka=$h_dataflow_workflow_dir"/dump1090_stream_kafka.zip"

   if [ ! -f $h_dataflow_stream_kafka ]
   then
      h_error_message="Unable to locate the $h_dataflow_stream_kafka script"
      MESSAGELOG $h_error_message
      printf "%s\n" $h_error_message
      exit 1
   fi


   h_control_dir="./control"

   if [ ! -d $h_control_dir ]
   then
      h_error_message="Unable to locate the $h_control_dir directory"
      MESSAGELOG $h_error_message
      printf "%s\n" $h_error_message
      exit 1
   fi

   h_dataflow_stream_kafka_pid_file=$h_control_dir"/dump1090_dataflow_stream_kafka_pid"


   return 0

}

function MESSAGELOG
{
   h_message=$*


   h_reported_message=`date +"%d/%m/%Y %H:%M:%S"`
   h_reported_message=$h_reported_message" - ""$h_prog_name"" - ""$h_message"

   echo $h_reported_message >> $h_logfile

   if [ "$h_clv_verbose" = "Y" ]
   then
      echo $h_reported_message
   fi

   return 0
}




START_DF_STREAM_KAFKA()
{
#----------------------------------------------------------------------------
# First check to see if the DataFlow stream KAFKA is already running
# TBC
#----------------------------------------------------------------------------

   if [ -f $h_dataflow_stream_kafka_pid_file ]
   then

      h_dataflow_stream_kafka_pid=`cat $h_dataflow_stream_kafka_pid_file`

      if [ ! -z "$h_dataflow_stream_kafka_pid" ]
      then
         h_pid_command=`ps --no-headers -p $h_dataflow_stream_kafka_pid`

         if [ ! -z "$h_pid_command" ]
         then

            MESSAGELOG "It looks as though the DataFlow stream KAFKA is already running on PID" $h_dataflow_stream_kafka_pid

            return 0

         else

            MESSAGELOG "Although there is a PID of $h_dataflow_stream_kafka_pid, it does not appear to be running"

         fi

      fi

   fi


   nohup sh -c "knime -nosplash -reset -nosave -workflowFile=$h_dataflow_stream_kafka -application org.knime.product.KNIME_BATCH_APPLICATION" 1>>$h_logfile 2>&1 &

   h_dataflow_stream_kafka_pid=$!

   MESSAGELOG "Started a new DataFlow Stream KAFKA on PID: " $h_dataflow_stream_kafka_pid

   echo $h_dataflow_stream_kafka_pid > $h_dataflow_stream_kafka_pid_file

echo "DataFlow Stream Kafka running on PID: " $h_dataflow_stream_kafka_pid


   return 0

}


PRINT_USAGE()
{
    printf "%s\n" "Usage:"
    printf "%s\n" "  $h_prog_name"

    printf "%s\n" "   action             {start|stop}"
    printf "%s\n" "   logfile            {DUMP1090 log file}"
    printf "%s\n" "   verbose            {Y|N}"

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

   --action)
      shift
      h_clv_action=$1
      ;;

   --logfile)
      shift
      h_logfile=$1
      ;;

   --verbose)
      shift
      h_clv_verbose=$1
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

   if [ -z "$h_logfile" ]
   then
      printf "%s\n" "Log file not defined"
      PRINT_USAGE
      exit 1
   fi

   if [ -z "$h_clv_verbose" ]
   then
      printf "%s\n" "Verbose not defined"
      PRINT_USAGE
      exit 1
   fi


#----------------------------------------------------------------------------
# OK, lets do stuff
#----------------------------------------------------------------------------

INITIALIZE

case $h_clv_action in

  "start")  
      START_DF_STREAM_KAFKA
      ;;

  "stop")  
      STOP_DF_STREAM_KAFKA
      ;;

esac

#----------------------------------------------------------------------------
# End of script
#---------------------------------------------------------------------------
