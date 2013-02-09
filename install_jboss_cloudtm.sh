#!/bin/bash
set -x
set -e

yum install bc -y

git clone https://github.com/openshift/origin-server.git
cart="openshift-origin-cartridge-jbossas-7-cloudtm"
openshift_cartridges_dir="origin-server/cartridges"

echo "Installing JBoss 7"
pushd /opt
rm -rf jboss-as-7.1.1.Final.tar.gz > /dev/null 2>&1
rm -rf jboss-as-7.1.1.Final/ > /dev/null 2>&1
wget http://download.jboss.org/jbossas/7.1/jboss-as-7.1.1.Final/jboss-as-7.1.1.Final.tar.gz
tar xvzf jboss-as-7.1.1.Final.tar.gz jboss-as-7.1.1.Final/
ln -s /opt/jboss-as-7.1.1.Final /etc/alternatives/jbossas-7
ln -s /usr/share/maven /etc/alternatives/maven-3.0
popd

echo "Creating the cartridge"

cp "$openshift_cartridges_dir"/openshift-origin-cartridge-abstract/abstract-jboss ./abstract-jboss
cp "$openshift_cartridges_dir"/openshift-origin-cartridge-abstract/abstract ./abstract 

mkdir -p ./"$cart"/info/connection-hooks/
mkdir -p ./"$cart"/info/data/

cp abstract/info/hooks/add-module "$cart"/info/hooks/add-module
cp abstract/info/hooks/info "$cart"/info/hooks/info
cp abstract/info/hooks/reload "$cart"/info/hooks/reload
cp abstract/info/hooks/remove-module "$cart"/info/hooks/remove-module
cp abstract/info/hooks/restart "$cart"/info/hooks/restart
cp abstract/info/hooks/start "$cart"/info/hooks/start
cp abstract/info/hooks/stop "$cart"/info/hooks/stop
cp abstract/info/hooks/update-namespace "$cart"/info/hooks/update-namespace
cp abstract/info/hooks/deploy-httpd-proxy "$cart"/info/hooks/deploy-httpd-proxy
cp abstract/info/hooks/remove-httpd-proxy "$cart"/info/hooks/remove-httpd-proxy
cp abstract/info/hooks/status "$cart"/info/hooks/status
cp abstract/info/hooks/tidy "$cart"/info/hooks/tidy
cp abstract/info/hooks/move "$cart"/info/hooks/move
cp abstract/info/hooks/system-messages "$cart"/info/hooks/system-messages
cp abstract/info/connection-hooks/publish-gear-endpoint "$cart"/info/connection-hooks/publish-gear-endpoint
cp abstract/info/connection-hooks/publish-http-url "$cart"/info/connection-hooks/publish-http-url
cp abstract/info/connection-hooks/set-db-connection-info "$cart"/info/connection-hooks/set-db-connection-info
cp abstract/info/connection-hooks/set-nosql-db-connection-info "$cart"/info/connection-hooks/set-nosql-db-connection-info
cp abstract/info/bin/sync_gears.sh "$cart"/info/bin/sync_gears.sh
cp abstract/info/bin/restore_tar.sh "$cart"/info/bin/restore_tar.sh
cp abstract-jboss/info/bin/app_ctl.sh "$cart"/info/bin/app_ctl.sh
cp abstract-jboss/info/bin/app_ctl_impl.sh "$cart"/info/bin/app_ctl_impl.sh
cp abstract-jboss/info/bin/deploy_httpd_proxy.sh "$cart"/info/bin/deploy_httpd_proxy.sh
cp abstract-jboss/info/bin/deploy.sh "$cart"/info/bin/deploy.sh
cp abstract-jboss/info/connection-hooks/publish_jboss_cluster "$cart"/info/connection-hooks/publish_jboss_cluster
cp abstract-jboss/info/connection-hooks/publish_jboss_remoting "$cart"/info/connection-hooks/publish_jboss_remoting
cp abstract-jboss/info/connection-hooks/set_jboss_cluster "$cart"/info/connection-hooks/set_jboss_cluster
cp abstract-jboss/info/connection-hooks/set_jboss_remoting "$cart"/info/connection-hooks/set_jboss_remoting
cp abstract-jboss/info/data/mysql.tar "$cart"/info/data/mysql.tar
cp abstract-jboss/info/hooks/deconfigure "$cart"/info/hooks/deconfigure
cp abstract-jboss/info/hooks/threaddump "$cart"/info/hooks/threaddump
#cp abstract-jboss/info/hooks/configure "$cart"/info/hooks/configure


echo "Installing the cartridge"
cp "$cart" /usr/libexec/openshift/cartridges/.

echo "Clearing cache"
pushd ~
cd /var/www/openshift/broker
bundle exec rake tmp:clear
popd

echo "+------+"
echo "| Done |"
echo "+------+"
