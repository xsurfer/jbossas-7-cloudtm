#!/bin/bash
set -x
set -e

cd ~
yum install bc -y
git clone https://github.com/openshift/origin-server.git

pushd /opt
wget http://download.jboss.org/jbossas/7.1/jboss-as-7.1.1.Final/jboss-as-7.1.1.Final.tar.gz
tar xvzf jboss-as-7.1.1.Final.tar.gz jboss-as-7.1.1.Final/
ln -s /opt/jboss-as-7.1.1.Final /etc/alternatives/jbossas-7
popd

cp origin-server/cartridges/openshift-origin-cartridge-jbossas-7/ /usr/libexec/openshift/cartridges/jbossas-7/ -R
cp origin-server/cartridges/openshift-origin-cartridge-abstract/abstract-jboss/ /usr/libexec/openshift/cartridges/. -R

pushd /usr/libexec/openshift/cartridges/jbossas-7
mkdir -p ./info/connection-hooks/
mkdir -p ./info/data/

cp /usr/libexec/openshift/cartridges/abstract/info/hooks/add-module /usr/libexec/openshift/cartridges/jbossas-7/info/hooks/add-module
cp /usr/libexec/openshift/cartridges/abstract/info/hooks/info /usr/libexec/openshift/cartridges/jbossas-7/info/hooks/info
cp /usr/libexec/openshift/cartridges/abstract/info/hooks/reload /usr/libexec/openshift/cartridges/jbossas-7/info/hooks/reload
cp /usr/libexec/openshift/cartridges/abstract/info/hooks/remove-module /usr/libexec/openshift/cartridges/jbossas-7/info/hooks/remove-module
cp /usr/libexec/openshift/cartridges/abstract/info/hooks/restart /usr/libexec/openshift/cartridges/jbossas-7/info/hooks/restart
cp /usr/libexec/openshift/cartridges/abstract/info/hooks/start /usr/libexec/openshift/cartridges/jbossas-7/info/hooks/start
cp /usr/libexec/openshift/cartridges/abstract/info/hooks/stop /usr/libexec/openshift/cartridges/jbossas-7/info/hooks/stop
cp /usr/libexec/openshift/cartridges/abstract/info/hooks/update-namespace /usr/libexec/openshift/cartridges/jbossas-7/info/hooks/update-namespace
cp /usr/libexec/openshift/cartridges/abstract/info/hooks/deploy-httpd-proxy /usr/libexec/openshift/cartridges/jbossas-7/info/hooks/deploy-httpd-proxy
cp /usr/libexec/openshift/cartridges/abstract/info/hooks/remove-httpd-proxy /usr/libexec/openshift/cartridges/jbossas-7/info/hooks/remove-httpd-proxy
cp /usr/libexec/openshift/cartridges/abstract/info/hooks/status /usr/libexec/openshift/cartridges/jbossas-7/info/hooks/status
cp /usr/libexec/openshift/cartridges/abstract/info/hooks/tidy /usr/libexec/openshift/cartridges/jbossas-7/info/hooks/tidy
cp /usr/libexec/openshift/cartridges/abstract/info/hooks/move /usr/libexec/openshift/cartridges/jbossas-7/info/hooks/move
cp /usr/libexec/openshift/cartridges/abstract/info/hooks/system-messages /usr/libexec/openshift/cartridges/jbossas-7/info/hooks/system-messages
cp /usr/libexec/openshift/cartridges/abstract/info/connection-hooks/publish-gear-endpoint /usr/libexec/openshift/cartridges/jbossas-7/info/connection-hooks/publish-gear-endpoint
cp /usr/libexec/openshift/cartridges/abstract/info/connection-hooks/publish-http-url /usr/libexec/openshift/cartridges/jbossas-7/info/connection-hooks/publish-http-url
cp /usr/libexec/openshift/cartridges/abstract/info/connection-hooks/set-db-connection-info /usr/libexec/openshift/cartridges/jbossas-7/info/connection-hooks/set-db-connection-info
cp /usr/libexec/openshift/cartridges/abstract/info/connection-hooks/set-nosql-db-connection-info /usr/libexec/openshift/cartridges/jbossas-7/info/connection-hooks/set-nosql-db-connection-info
cp /usr/libexec/openshift/cartridges/abstract/info/bin/sync_gears.sh /usr/libexec/openshift/cartridges/jbossas-7/info/bin/sync_gears.sh
cp /usr/libexec/openshift/cartridges/abstract/info/bin/restore_tar.sh /usr/libexec/openshift/cartridges/jbossas-7/info/bin/restore_tar.sh
cp /usr/libexec/openshift/cartridges/abstract-jboss/info/bin/app_ctl.sh /usr/libexec/openshift/cartridges/jbossas-7/info/bin/app_ctl.sh
cp /usr/libexec/openshift/cartridges/abstract-jboss/info/bin/app_ctl_impl.sh /usr/libexec/openshift/cartridges/jbossas-7/info/bin/app_ctl_impl.sh
cp /usr/libexec/openshift/cartridges/abstract-jboss/info/bin/deploy_httpd_proxy.sh /usr/libexec/openshift/cartridges/jbossas-7/info/bin/deploy_httpd_proxy.sh
cp /usr/libexec/openshift/cartridges/abstract-jboss/info/bin/deploy.sh /usr/libexec/openshift/cartridges/jbossas-7/info/bin/deploy.sh
cp /usr/libexec/openshift/cartridges/abstract-jboss/info/connection-hooks/publish_jboss_cluster /usr/libexec/openshift/cartridges/jbossas-7/info/connection-hooks/publish_jboss_cluster
cp /usr/libexec/openshift/cartridges/abstract-jboss/info/connection-hooks/publish_jboss_remoting /usr/libexec/openshift/cartridges/jbossas-7/info/connection-hooks/publish_jboss_remoting
cp /usr/libexec/openshift/cartridges/abstract-jboss/info/connection-hooks/set_jboss_cluster /usr/libexec/openshift/cartridges/jbossas-7/info/connection-hooks/set_jboss_cluster
cp /usr/libexec/openshift/cartridges/abstract-jboss/info/connection-hooks/set_jboss_remoting /usr/libexec/openshift/cartridges/jbossas-7/info/connection-hooks/set_jboss_remoting
cp /usr/libexec/openshift/cartridges/abstract-jboss/info/data/mysql.tar /usr/libexec/openshift/cartridges/jbossas-7/info/data/mysql.tar
cp /usr/libexec/openshift/cartridges/abstract-jboss/info/hooks/deconfigure /usr/libexec/openshift/cartridges/jbossas-7/info/hooks/deconfigure
cp /usr/libexec/openshift/cartridges/abstract-jboss/info/hooks/threaddump /usr/libexec/openshift/cartridges/jbossas-7/info/hooks/threaddump
#cp /usr/libexec/openshift/cartridges/abstract-jboss/info/hooks/configure /usr/libexec/openshift/cartridges/jbossas-7/info/hooks/configure
ln -s /usr/share/maven /etc/alternatives/maven-3.0
popd

pushd ~
cd /var/www/openshift/broker
bundle exec rake tmp:clear
popd

