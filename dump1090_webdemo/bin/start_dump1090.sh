#!/bin/sh

# Step 3: Launch the DataFlow streaming workflow that will read the messages from a topic in Kafka,
# process the data and store it into Ingres

nohup ./run_dump1090_workflows.sh 1>>/tmp/dump1090_ingres.log.$$ 2>&1 &
processPid=$!
echo "Launched DataFlow workflow application PID: $processPid"
