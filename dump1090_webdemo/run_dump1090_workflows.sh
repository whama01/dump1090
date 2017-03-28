#!/bin/sh
set -x

## This script sets up dataflow workflows for the streaming demo. It goes into the workflows and adjusts the configuration 
## files to updates hosts/ports etc.
## This script should be used before running the workflows so that they are up to date with the necessary cluster parameters 


## EXECUTION of the workflows

# Run the Kafka stream workflow in the background
nohup knime -nosplash -reset -nosave -workflowFile=/home/actian/projects/dump1090/dump1090_ingres/dump1090_stream_kafka.zip -application org.knime.product.KNIME_BATCH_APPLICATION >> /tmp/StreamKafka.out 2>&1 &
streamKafkaWorkflowPid=$!

# Wait a bit
sleep 10

# Next, run the Schedule Time Windows workflow in the background which will launch a sub-workflow.
# To ensure a durable operation, we run this in a loop and restart the application in case it exits

terminate=0
while [ $terminate -eq 0 ]
do
    nohup knime -nosplash -reset -nosave -workflowFile=/home/actian/projects/dump1090/dump1090_ingres/dump1090_read_kafka_write_ingres.zip -application org.knime.product.KNIME_BATCH_APPLICATION >> /tmp/ScheduleWindows.out 2>&1 &
    processPid=$!

    # Sleep for 5 seconds and check if the background process went away
    processAlive=1
    while [ $processAlive -eq 1 ] && [ $terminate -eq 0 ]
    do
        sleep 5

        # Check if process is alive
        kill -0 $processPid
        if [ $? -ne 0 ]; then
            processAlive=0
        fi

        # Check if we have been asked to shutdown
        if [ -f "$TERMINATE_SIGNAL_FILE" ]; then
            terminate=1
        fi

    done

    if [ $terminate -ne 1 ]; then

        # We broke out because we detected than the main workflow went away for unknown reasons, restart
        echo "Detected an application fail, restarting to maintain operation" 

    else

        echo "Terminating the workflows .."

        # We broke out because we have been asked to terminate - Terminate the main app 
        # descendants and then the main app
        pkill -P $processPid
        kill -9 $processPid

        # Terminate the streaming kafka workflow children and then the main process
        pkill -P $streamKafkaWorkflowPid
        kill -9 $streamKafkaWorkflowPid

    fi

done

# Cleanup
rm -f $TERMINATE_SIGNAL_FILE

exit 0
