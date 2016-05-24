#!/bin/bash
# 2015-Mar-18 Updated to latest Kafka stable: 0.8.2.1
set -e
set -u

version=0.9.0.1
scala_version=2.11

name=kafka
description="Apache Kafka is a distributed publish-subscribe messaging system."
url="https://kafka.apache.org/"
arch="all"
section="misc"
license="Apache Software License 2.0"
package_version="-1"
bin_package="kafka_${scala_version}-${version}.tgz"
bin_download_url="http://apache.ip-connect.vn.ua/kafka/${version}/${bin_package}"
origdir="$(pwd)"

#_ MAIN _#
rm -rf ${name}*.deb
if [[ ! -f "${bin_package}" ]]; then
  wget -c ${bin_download_url}
fi
mkdir -p tmp && pushd tmp
rm -rf kafka
mkdir -p kafka
cd kafka
mkdir -p build/usr/lib/kafka
mkdir -p build/etc/default
mkdir -p build/etc/init
mkdir -p build/etc/kafka
mkdir -p build/var/lib/kafka
mkdir -p build/var/log/kafka

cp ${origdir}/kafka.default build/etc/default/kafka
cp ${origdir}/kafka.upstart.conf build/etc/init/kafka.conf

tar zxf ${origdir}/${bin_package}
cd kafka_${scala_version}-${version}

sed -i 's/\/tmp\/kafka-logs/\/var\/lib\/kafka/g' config/server.properties
mv config/log4j.properties config/server.properties ../build/etc/kafka
mv * ../build/usr/lib/kafka
cd ../build

fpm -t deb \
    -n ${name} \
    -v ${version}${package_version} \
    --description "${description}" \
    --url="{$url}" \
    -a ${arch} \
    --category ${section} \
    --vendor "" \
    --license "${license}" \
    -m "${USER}@localhost" \
    --prefix=/ \
    --after-install ${origdir}/kafka.postinst \
    -s dir \
    -- .
mv kafka*.deb ${origdir}
popd
