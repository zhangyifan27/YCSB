#!/bin/sh

# first compile the package
mvn -pl site.ycsb:kudu-binding -am clean package

# get the version of ycsb
version=YCSB-`ls kudu/target/kudu-binding* | awk -F'binding-' '{print $2}' | awk -F'.jar' '{print $1}'`

# copy files
pkg_dir=kudu-$version
rm -rf $pkg_dir &>/dev/null
mkdir $pkg_dir
cp -v kudu/target/*.jar $pkg_dir
cp -v core/target/*.jar $pkg_dir
mkdir -p $pkg_dir/dependency
cp -v -R kudu/target/dependency/* $pkg_dir/dependency

cp -v workloads/workload_kudu $pkg_dir/

tar cfz $pkg_dir.tar.gz $pkg_dir

# modify the package config
pack_template=""
if [ -n "$MINOS_CONFIG_FILE" ]; then
    pack_template=`dirname $MINOS_CONFIG_FILE`/xiaomi-config/package/kudu.yaml
fi

ycsb_dir=`pwd`
if [ -f $pack_template ]; then
    echo "Modifying $pack_template ..."
    sed -i "/^artifact:/c artifact: \"kudu\"" $pack_template
    sed -i "/^version:/c version: \"$version\"" $pack_template
    sed -i "/^build:/c build: \"\.\/pack_ycsb_kudu.sh\"" $pack_template
    sed -i "/^source:/c source: \"$ycsb_dir\"" $pack_template
fi
