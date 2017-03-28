#!/bin/bash
#
#----------------------------------------------------------------------------
#
# Name:
#   dump1090_visualize.sh
#
# Description:
#   This script is part of the DUMP1090 demo application.
#
#   The purpose of this script is to control the starting and stopping of
#   the visualization component of the DUMP1090 demo.
#
#   Although the individual components that make up the DUMP1090 demo can be
#   manually run, you are strongly advised not to.
#
# History:
#   1.0 14-Sep-2015 (mark.whalley@hpe.com)
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

   MESSAGELOG "Initiated"

   h_control_dir="./control"

   if [ ! -d $h_control_dir ]
   then
      h_error_message="Unable to locate the $h_control_dir directory"
      MESSAGELOG $h_error_message
      printf "%s\n" $h_error_message
      exit 1
   fi


   h_www_dir="./www"

   if [ ! -d $h_www_dir ]
   then
      h_error_message="Unable to locate the $h_www_dir directory"
      MESSAGELOG $h_error_message
      printf "%s\n" $h_error_message
      exit 1
   fi

   h_visualizer_pid_file=$h_control_dir"/dump1090_visualizer_pid"

   h_dump1090_visualizer="/tmp/dump1090_visualize.$h_pid"

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




START_VISUALIZER()
{
#----------------------------------------------------------------------------
# First check to see if the visualizer is already running
# TBC
#----------------------------------------------------------------------------

   if [ -f $h_visualizer_pid_file ]
   then
      h_visualizer_pid=`cat $h_visualizer_pid_file`

      if [ ! -z "$h_visualizer_pid" ]
      then
         h_pid_command=`ps --no-headers -p $h_visualizer_pid`

         if [ ! -z "$h_pid_command" ]
         then

            MESSAGELOG "It looks as though the visualizer is already running on PID" $h_visualizer_pid

            return 0

         else

            MESSAGELOG "Although there is a PID of $h_visualizer_pid, it does not appear to be running"

         fi

      fi

   fi






   echo "   
      h_sql_script="/tmp/dump1090_visualize.sql.$$"
      h_sql_output="/tmp/dump1090_visualize.output.$$"
     
      while true
      do
      
      echo \"  
      
            select
             date_trunc('minute',max(msg_gen_ts))             as end_time,
             date_trunc('minute',max(msg_gen_ts) - interval '$h_clv_time_slice_number $h_clv_time_slice_units')  as start_time
           from
             ${h_clv_schema}.dump1090_msg_5
           \p\g
      
           \" > \$h_sql_script
      
      vsql -txf \$h_sql_script > \$h_sql_output
      
      h_end_time=\`cat \$h_sql_output | grep \"end_time\" | awk -F\"|\" '{print \$2}'\`
      
      h_start_time=\`cat \$h_sql_output | grep \"start_time\" | awk -F\"|\" '{print \$2}'\`

      ./bin/dump1090_build_map --schema ${h_clv_schema} --test 1 --start_time \"\$h_start_time\" --end_time \"\$h_end_time\" --www_dir ${h_www_dir}

      sleep $h_clv_sleep
      
      
      done"                                                             >  $h_dump1090_visualizer


   chmod 755                                                               $h_dump1090_visualizer


   nohup sh -c "$h_dump1090_visualizer" 1>>$h_logfile 2>&1 &



   h_visualizer_pid=$!

   MESSAGELOG "Started a new visualizer on PID: " $h_visualizer_pid

   echo $h_visualizer_pid > $h_visualizer_pid_file


   return 0

}


PRINT_USAGE()
{
    printf "%s\n" "Usage:"
    printf "%s\n" "  $h_prog_name"

    printf "%s\n" "   --action             {start|stop}"
    printf "%s\n" "   --logfile            {DUMP1090 log file}"
    printf "%s\n" "   --schema             {schema}"
    printf "%s\n" "   --time_slice_number  {time slice number}"
    printf "%s\n" "   --time_slice_units   {time slice units}"
    printf "%s\n" "   --verbose            {Y|N}"
    printf "%s\n" "   --sleep              {number of seconds to sleep between re-runs}"

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

   --schema)
      shift
      h_clv_schema=$1
      ;;

   --time_slice_number)
      shift
      h_clv_time_slice_number=$1
      ;;

   --time_slice_units)
      shift
      h_clv_time_slice_units=$1
      ;;

   --verbose)
      shift
      h_clv_verbose=$1
      ;;

   --sleep)
      shift
      h_clv_sleep=$1
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

   if [ -z "$h_clv_time_slice_number" ]
   then
      h_error_message="Time slice number name not defined"
      MESSAGELOG $h_error_message
      printf "%s\n" $h_error_message
      PRINT_USAGE
      exit 1
   fi

   if [ -z "$h_clv_schema" ]
   then
      h_error_message="Database schema name not defined"
      MESSAGELOG $h_error_message
      printf "%s\n" $h_error_message
      PRINT_USAGE
      exit 1
   fi

   if [ -z "$h_clv_time_slice_units" ]
   then
      h_error_message="Time slice units not defined"
      MESSAGELOG $h_error_message
      printf "%s\n" $h_error_message
      PRINT_USAGE
      exit 1
   fi


   if [ -z "$h_clv_verbose" ]
   then
      h_error_message="Verbose flag not defined"
      MESSAGELOG $h_error_message
      printf "%s\n" $h_error_message
      PRINT_USAGE
      exit 1
   fi

   if [ -z "$h_clv_sleep" ]
   then
      h_error_message="Sleep time not defined"
      MESSAGELOG $h_error_message
      printf "%s\n" $h_error_message
      PRINT_USAGE
      exit 1
   fi

#----------------------------------------------------------------------------
# OK, lets do stuff
#----------------------------------------------------------------------------

INITIALIZE

case $h_clv_action in

  "start")  
      START_VISUALIZER
      ;;

  "stop")  
      STOP_VISUALIZER
      ;;

esac

#----------------------------------------------------------------------------
# End of script
#---------------------------------------------------------------------------
