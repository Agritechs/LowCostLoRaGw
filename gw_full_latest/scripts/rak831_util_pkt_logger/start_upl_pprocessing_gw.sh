#!/bin/bash
(
if [ $# -eq 0 ] 
then 
        sleep 1
else
        #wait until the RPI starts
        sleep 100       
fi

cd /home/pi/lora_gateway
cp /opt/ttn-gateway/packet_forwarder/lora_pkt_fwd/*.json .

#create the gw id so that a newly installed gateway is always configured with a correct id
/home/pi/lora_gateway/scripts/create_gwid.sh

SERVICE="util_pkt_logger"
MAX_RETRY=8
MIN_RUN_TIME=120
PID_CHECK_PERIOD=20
BACKOFF_RETRY_TIME=15

retry=1
run_time=0

while [ $retry -lt $MAX_RETRY ]
do

        run_time=0
        
        echo "Launching util_pkt_logger: retry = $retry" >&2
        
        # Reset iC880a PIN
        SX1301_RESET_BCM_PIN=17
        echo "$SX1301_RESET_BCM_PIN"  > /sys/class/gpio/export
        echo "out" > /sys/class/gpio/gpio$SX1301_RESET_BCM_PIN/direction
        echo "0"   > /sys/class/gpio/gpio$SX1301_RESET_BCM_PIN/value
        sleep 0.1
        echo "1"   > /sys/class/gpio/gpio$SX1301_RESET_BCM_PIN/value
        sleep 0.1
        echo "0"   > /sys/class/gpio/gpio$SX1301_RESET_BCM_PIN/value
        sleep 0.1
        echo "$SX1301_RESET_BCM_PIN" > /sys/class/gpio/unexport
        sleep 3

        /opt/ttn-gateway/lora_gateway/util_pkt_logger/util_pkt_logger | python util_pkt_logger_formatter.py | python post_processing_gw.py | python log_gw.py &
        sleep 10
        
        #if the radio concentrator has failed to start then the while loop will not run
        while pgrep -x "$SERVICE" >/dev/null: ; do
                sleep $PID_CHECK_PERIOD
                
                if [ $run_time -lt $MIN_RUN_TIME ]; then
                	run_time=$[$run_time + $PID_CHECK_PERIOD]
                fi	
                
                if [ $run_time -ge $MIN_RUN_TIME ]; then
                        #if util_pkt_logger has been running for more than MIN_RUN_TIME then we reset retry
                        #because the radio concentrator has successfully started at least once for a while
                        retry=1
                fi
        done
        
        echo "util_pkt_logger not running for some reason" >&2
        echo "trying to restart" >&2
        sleep 2
        
        kill $(ps aux | grep -e post_processing -e log_gw -e util_pkt_logger | awk '{print $2}') >&2
        
        sleep_time=$[$BACKOFF_RETRY_TIME * $retry]
        echo "retry=$retry. Will retry in $sleep_time seconds" >&2
        sleep $sleep_time
        
        retry=$[$retry + 1]
done
echo "Maximum retries. Exiting" >&2
exit 0
) &