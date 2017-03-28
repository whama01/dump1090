# This script is used for stopping a running demo

# This function takes filename as an argument and waits in a loop for the file to get removed
wait_for_file_to_be_removed()
{
    file=$1
    while [ -f $file ]
    do
        sleep 1
    done
}

DF_TERMINATE_SIGNAL_FILE="dataflow_workflows/STOP"
TWITTER_TERMINATE_SIGNAL_FILE="twittergenerator/STOP"

echo -n "Stopping the DataFlow streaming workflow .."
touch $DF_TERMINATE_SIGNAL_FILE
wait_for_file_to_be_removed $DF_TERMINATE_SIGNAL_FILE
echo "done"

echo -n "Stopping the Twitter application .."
touch $TWITTER_TERMINATE_SIGNAL_FILE
wait_for_file_to_be_removed $TWITTER_TERMINATE_SIGNAL_FILE
echo "done"
