#!/bin/bash -e

source "/etc/openshift/node.conf"
source ${CARTRIDGE_BASE_PATH}/abstract/info/lib/util

# Import Environment Variables
for f in ~/.env/*; do . $f; done

cartridge_type=$(get_cartridge_name_from_path)
cartridge_cloudtm="cloudtm"
if ! [ $# -eq 1 ]
then
    echo "Usage: \$0 [start|restart|graceful|graceful-stop|stop]"
    exit 1
fi

CART_DIR=$OPENSHIFT_HOMEDIR/$cartridge_type

APP_CLOUDTM=${CART_DIR}/"$cartridge_cloudtm"
#APP_CLOUDTM_TMP_DIR="$APP_CLOUDTM"/tmp
APP_CLOUDTM_BIN_DIR="$APP_CLOUDTM"/bin
#APP_CLOUDTM_RUN_DIR="$APP_CLOUDTM"/run

MONITOR_PID_FILE="$APP_CLOUDTM"/run/monitor.pid
MONITOR_CFG_FILE="$APP_CLOUDTM"/conf/csvReporter.cfg
MONITOR_LOG_FILE="$APP_CLOUDTM"/log/monitor.log

validate_run_as_user

#. app_ctl_pre.sh

function isrunning() {
    if [ -f "$MONITOR_PID_FILE" ]; then
      monitorpid=$(cat $MONITOR_PID_FILE);
      if /bin/ps --pid $monitorpid 1>&2 >/dev/null;
      then
        return 0
      fi
    fi
    # not running
    return 1
}

#function wait_to_start() {
#   ep=$(grep "listen stats" $OPENSHIFT_HOMEDIR/${HAPROXY_CART}/conf/haproxy.cfg | sed 's#listen\s*stats\s*\(.*\)#\1#')
#   i=0
#   while ( ! curl "http://$ep/haproxy-status/;csv" &> /dev/null )  && [ $i -lt 10 ]; do
#       sleep 1
#       i=$(($i + 1))
#   done
#
#   if [ $i -ge 10 ]; then
#      echo "`date`: HAProxy status check - max retries ($i) exceeded" 1>&2
#   fi
#}


function _start_monitor_service() {
	if isrunning; then
		echo "WPMonitor already running" 1>&2
	else
#		java -cp .:/usr/libexec/stickshift/cartridges/embedded/haproxy-1.4/info/bin/WpmCsvReporter.jar eu.cloudtm.reporter.CsvReporter \
#			csvReporter.cfg > $MONITOR_LOG_FILE 2>&1 &

		java -cp .:"$APP_CLOUDTM_BIN_DIR"/WPMonitor.jar eu.cloudtm.reporter.CsvReporter $MONITOR_CFG_FILE  > $MONITOR_LOG_FILE 2>&1 &
		PROCESS_ID=$!
		echo $PORCESS_ID > $MONITOR_PID_FILE;
	fi
}


function _stop_monitor_service() {
#    src_user_hook pre_stop_${CARTRIDGE_TYPE}
#    set_app_state stopped
#    _stop_haproxy_ctld_daemon
    [ -f $MONITOR_PID ]  &&  pid=$( /bin/cat "${MONITOR_PID}" )
    if `ps -p $pid > /dev/null 2>&1`; then
        /bin/kill $pid
        ret=$?
        if [ $ret -eq 0 ]; then
            TIMEOUT="$STOPTIMEOUT"
            while [ $TIMEOUT -gt 0 ] && [ -f "$MONITOR_PID" ]; do
                /bin/kill -0 "$pid" >/dev/null 2>&1 || break
                sleep .5
                let TIMEOUT=${TIMEOUT}-1
            done
        fi
    else
        if `pgrep -x WPMonitor > /dev/null 2>&1`
        then
            echo "Warning: WPMonitor process exists without a pid file.  Use force-stop to kill." 1>&2
        else
            echo "WPMonitor already stopped" 1>&2
        fi
    fi
#    run_user_hook post_stop_${CARTRIDGE_TYPE}
}

function _restart_monitor_service() {
    _stop_monitor_service || pkill WPMonitor || :
    _start_monitor_service
}

#function _reload_monitor_service() {
#    [ -n "$1" ]  &&  zopts="-sf $1"
#    src_user_hook pre_start_${CARTRIDGE_TYPE}
#    ping_server_gears
#    /usr/sbin/haproxy -f $OPENSHIFT_HOMEDIR/${HAPROXY_CART}/conf/haproxy.cfg ${zopts} > /dev/null 2>&1
#    run_user_hook post_start_${CARTRIDGE_TYPE}
#}

#function _reload_service() {
#    [ -f $MONITOR_PID ]  &&  zpid=$( /bin/cat "${MONITOR_PID}" )
#    i=0
#    while (! _reload_haproxy_service "$zpid" )  && [ $i -lt 60 ]; do
#        sleep 2
#        i=$(($i + 1))
#        echo "`date`: Retrying HAProxy service reload - attempt #$((i+1)) ... "
#    done

#    wait_to_start
#}


function _send_client_result() {
    # Only sent client result if call done at the cartridge level.
    [ "$CARTRIDGE_TYPE" = "$HAPROXY_CART" ]  &&  client_result "$@"
    return 0
}

function start() {
    _start_monitor_service
    isrunning  &&  _send_client_result "WPMonitor instance is started"
}

function stop() {
    _stop_monitor_service
    isrunning  ||  _send_client_result "WPMonitor instance is stopped"
}

function restart() {
    _restart_monitor_service
    isrunning  &&  _send_client_result "WPMonitor HAProxy instance"
}

#function reload() {
#    if ! isrunning; then
#       _start_monitor_service
#    else
#       echo "`date`: Reloading WPMonitor service " 1>&2
#       _reload_service
#       _start_haproxy_ctld_daemon
#    fi
#    isrunning  &&  _send_client_result "Reloaded WPMonitor instance"
#}

#function cond_reload() {
#    if isrunning; then
#        echo "`date`: Conditionally reloading WPMonitor service " 1>&2
#        _reload_service
#        _start_haproxy_ctld_daemon
#        isrunning  &&  _send_client_result "Conditionally reloaded WPMonitor"
#    fi
#}

function force_stop() {
    pkill WPMonitor
    isrunning  ||  _send_client_result "Force stopped WPMonitor instance"
}

function status() {
    if isrunning; then
        _send_client_result "WPMonitor instance is running"
    else
        _send_client_result "WPMonitor instance is stopped"
    fi
    print_user_running_processes `id -u`
}


#
# main():
#

# And then on the haproxy and haproxy_ctld.
case "$1" in
    start)               start       ;;
    graceful-stop|stop)  stop        ;;
    restart)             restart     ;;
#    graceful|reload)     reload      ;;
#    cond-reload)         cond_reload ;;
    force-stop)          force_stop  ;;
    status)              status      ;;
esac

