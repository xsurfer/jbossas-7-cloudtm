#!/bin/bash

source "/etc/openshift/node.conf"
source ${CARTRIDGE_BASE_PATH}/abstract/info/lib/util

load_resource_limits_conf

application="$1"
uuid="$2"
IP="$3"

setup_app_dir_vars
setup_user_vars

CLOUDTM_DIR=`echo $APP_HOME/jbossas-7-cloudtm/cloudtm | tr -s /`
[ -d "$CLOUDTM_DIR" ]  ||   CLOUDTM_DIR=`echo $APP_HOME/$application | tr -s /`

# Following not useful for the purposes of this script 
#. $APP_HOME/.env/OPENSHIFT_INTERNAL_IP
#. $APP_HOME/.env/OPENSHIFT_GEAR_UUID

cat <<EOF > "$CLOUDTM_DIR/conf/csvReporter.cfg.template"
#---------------------------------------------------------------------
#
# Example configuration for a possible monitor application.  
# For more information call Pedro Ruivo
#
#---------------------------------------------------------------------

#in seconds
reporter.updateInterval=1

reporter.logging.level=TRACE
reporter.logging.file=log.out

reporter.output_file=/tmp/csv/report.csv
reporter.memory_units=GB
#reporter.custom_attr=eu.cloudtm.reporter.customattributes.CommitLatency,eu.cloudtm.reporter.customattributes.RadargunWorkload
reporter.resource_manager=eu.cloudtm.reporter.manager.jmx.JmxResourceManager

reporter.smoothing.enable=false
reporter.smoothing.alpha=0.2
reporter.smoothing.attr=Throughput

reporter.ispn.sum_attr=NumPuts
#Throughput,WriteThroughput,ReadThroughput
reporter.ispn.avg_attr=

#only one resource manager is enable at time (see reporter.resource_manager)
#WPM resource manager
reporter.resource.wpm.cache_name=CloudTM

#JMX resource manager
reporter.resource.jmx.username=
reporter.resource.jmx.password=
reporter.resource.jmx.collectors=eu.cloudtm.reporter.manager.jmx.collector.InfinispanJmxCollector

#ispn jmx collector
reporter.resource.jmx.ispn_jmx.domain=org.infinispan
reporter.resource.jmx.ispn_jmx.cache_name=prova
reporter.resource.jmx.ispn_jmx.components=LockManager,Transactions

#radargun jmx collector
#reporter.resource.jmx.radar_jmx.domain=org.radargun
#reporter.resource.jmx.radar_jmx.components=TpccBenchmark,BenchmarkStage
reporter.ips=
EOF

cp $CLOUDTM_DIR/conf/csvReporter.cfg.template $CLOUDTM_DIR/conf/csvReporter.cfg
chown $uuid $CLOUDTM_DIR/conf/csvReporter.cfg

