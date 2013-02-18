#!/bin/bash
set -x
set -e

yum install bc -y

#rm -rf origin-server > /dev/null 2>&1
#git clone https://github.com/openshift/origin-server.git
#git checkout stage-2.0.22

cart="openshift-origin-cartridge-jbossas-7-cloudtm"
openshift_cartridges_dir="origin-server/cartridges"

echo "Installing JBoss 7"
echo "------------------"

pushd /opt
#rm -rf jboss-as-7.1.1.Final.tar.gz > /dev/null 2>&1
#rm -rf jboss-as-7.1.1.Final/ > /dev/null 2>&1
#wget http://download.jboss.org/jbossas/7.1/jboss-as-7.1.1.Final/jboss-as-7.1.1.Final.tar.gz
#tar xvzf jboss-as-7.1.1.Final.tar.gz jboss-as-7.1.1.Final/
#ln -s /opt/jboss-as-7.1.1.Final /etc/alternatives/jbossas-7 > /dev/null 2>&1
#ln -s /usr/local/apache-maven/apache-maven-3.0.4 /etc/alternatives/maven-3.0 > /dev/null 2>&1
popd

echo "Creating the cartridge"
echo "----------------------"
rm -rf ./build > /dev/null 2>&1
mkdir -p ./build
cp $cart build/. -r

rm -rf abstract-jboss > /dev/null 2>&1
rm -rf abstract > /dev/null 2>&1
cp "$openshift_cartridges_dir"/openshift-origin-cartridge-abstract/abstract-jboss . -r
cp "$openshift_cartridges_dir"/openshift-origin-cartridge-abstract/abstract . -r

mkdir -p ./build/"$cart"/info/connection-hooks/
mkdir -p ./build/"$cart"/info/data/

cp abstract/info/hooks/add-module build/"$cart"/info/hooks/add-module
cp abstract/info/hooks/info build/"$cart"/info/hooks/info
cp abstract/info/hooks/reload build/"$cart"/info/hooks/reload
cp abstract/info/hooks/remove-module build/"$cart"/info/hooks/remove-module
cp abstract/info/hooks/restart build/"$cart"/info/hooks/restart
cp abstract/info/hooks/start build/"$cart"/info/hooks/start
cp abstract/info/hooks/stop build/"$cart"/info/hooks/stop
cp abstract/info/hooks/update-namespace build/"$cart"/info/hooks/update-namespace
cp abstract/info/hooks/deploy-httpd-proxy build/"$cart"/info/hooks/deploy-httpd-proxy
cp abstract/info/hooks/remove-httpd-proxy build/"$cart"/info/hooks/remove-httpd-proxy
cp abstract/info/hooks/status build/"$cart"/info/hooks/status
cp abstract/info/hooks/tidy build/"$cart"/info/hooks/tidy
cp abstract/info/hooks/move build/"$cart"/info/hooks/move
cp abstract/info/hooks/system-messages build/"$cart"/info/hooks/system-messages
cp abstract/info/connection-hooks/publish-gear-endpoint build/"$cart"/info/connection-hooks/publish-gear-endpoint
cp abstract/info/connection-hooks/publish-http-url build/"$cart"/info/connection-hooks/publish-http-url
cp abstract/info/connection-hooks/set-db-connection-info build/"$cart"/info/connection-hooks/set-db-connection-info
cp abstract/info/connection-hooks/set-nosql-db-connection-info build/"$cart"/info/connection-hooks/set-nosql-db-connection-info
cp abstract/info/bin/sync_gears.sh build/"$cart"/info/bin/sync_gears.sh
cp abstract/info/bin/restore_tar.sh build/"$cart"/info/bin/restore_tar.sh
#cp abstract-jboss/info/bin/app_ctl.sh build/"$cart"/info/bin/app_ctl.sh
#cp abstract-jboss/info/bin/app_ctl_impl.sh build/"$cart"/info/bin/app_ctl_impl.sh
cp abstract-jboss/info/bin/deploy_httpd_proxy.sh build/"$cart"/info/bin/deploy_httpd_proxy.sh
cp abstract-jboss/info/bin/deploy.sh build/"$cart"/info/bin/deploy.sh
cp abstract-jboss/info/connection-hooks/publish_jboss_cluster build/"$cart"/info/connection-hooks/publish_jboss_cluster
cp abstract-jboss/info/connection-hooks/publish_jboss_remoting build/"$cart"/info/connection-hooks/publish_jboss_remoting
cp abstract-jboss/info/connection-hooks/set_jboss_cluster build/"$cart"/info/connection-hooks/set_jboss_cluster
cp abstract-jboss/info/connection-hooks/set_jboss_remoting build/"$cart"/info/connection-hooks/set_jboss_remoting
cp abstract-jboss/info/data/mysql.tar build/"$cart"/info/data/mysql.tar
cp abstract-jboss/info/hooks/deconfigure build/"$cart"/info/hooks/deconfigure
cp abstract-jboss/info/hooks/threaddump build/"$cart"/info/hooks/threaddump
#cp abstract-jboss/info/hooks/configure build/"$cart"/info/hooks/configure


echo "Installing the cartridge"
echo "------------------------"

rm -rf /usr/libexec/openshift/cartridges/jbossas-7-cloudtm > /dev/null 2>&1
mv build/"$cart" build/jbossas-7-cloudtm
cp build/jbossas-7-cloudtm /usr/libexec/openshift/cartridges/. -r

echo "Clearing cache"
echo "--------------"

pushd ~
cd /var/www/openshift/broker
bundle exec rake tmp:clear
popd

echo "+------+"
echo "| Done |"
echo "+------+"
