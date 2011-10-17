#!/bin/sh -x

version=0.9.4
urllist="
compiz-0.9.4!http://releases.compiz.org/0.9.4/compiz-core-0.9.4.tar.bz2
libcompizconfig-0.9.4!http://releases.compiz.org/0.9.4/compiz-libcompizconfig-0.9.4.tar.bz2
compiz-fusion-plugins-main-0.9.4!http://releases.compiz.org/0.9.4/compiz-plugins-main-0.9.4.tar.bz2
compiz-fusion-plugins-extra-0.9.4!http://releases.compiz.org/0.9.4/compiz-plugins-extra-0.9.4.tar.bz2
compiz-fusion-plugins-unsupported-0.9.4!http://releases.compiz.org/0.9.4/compiz-plugins-unsupported-0.9.4.tar.bz2
compizconfig-backend-gconf-0.9.4!http://releases.compiz.org/0.9.4/compiz-compizconfig-backend-gconf-0.9.4.tar.bz2
#compizconfig-backend-kconfig-0.9.4!http://releases.compiz.org/0.9.4/compiz-compizconfig-backend-kconfig4-0.9.4.tar.bz2
compizconfig-python-0.9.4!http://releases.compiz.org/0.9.4/compiz-compizconfig-python-0.9.4.tar.bz2
ccsm-0.9.4!http://releases.compiz.org/0.9.4/compiz-ccsm-0.9.4.tar.bz2
emerald-0.9.4!http://git.compiz.org/fusion/decorators/emerald/snapshot/emerald-0.9.4.tar.bz2
"

workdir=`pwd`
tempdir=/tmp/INSTALL.$$

prepare_debian_package () {
    cd ${workdir}
    if [ ! -e releases/${compiz_archive} ]
    then
        mkdir -p releases
        cd releases
        wget ${compiz_siteurl} || exit 1
    fi

    rm -fr ${tempdir}
    mkdir -p ${tempdir}
    cd ${tempdir}

    tar jxf ${workdir}/releases/${compiz_archive}
    compiz_dirname=`ls | head -n 1`
    if [ ${compiz_dirname} != ${debian_dirname} ]
    then
        mv ${compiz_dirname} ${debian_dirname}
    fi
    tar zcf ${debian_archive} ${debian_dirname}

    mkdir -p ${workdir}/${debian_dirname}
    cd ${workdir}/${debian_dirname}
    mv ${tempdir}/${debian_archive} .
    tar zxf ${debian_archive}

    rm -fr ${tempdir}
}

for debian_compiz in `echo $urllist`
do
    if echo ${debian_compiz} | grep -Eq '^#'
    then
        continue
    fi

    debian_dirname=`echo ${debian_compiz} | awk -F! '{print $1}'`
    compiz_siteurl=`echo ${debian_compiz} | awk -F! '{print $2}'`
    compiz_archive=`basename ${compiz_siteurl}`
    debian_archive=`echo ${debian_dirname} | sed 's/-0/_0/'`.orig.tar.gz
    
    if [ ! -e ${debian_dirname}/${debian_archive} ]    
    then
        prepare_debian_package
    fi

    cd ${workdir}/${debian_dirname}/${debian_dirname}
    debuild -us -uc -j || exit 1

    sudo dpkg -i ../*.deb
done

cd ${workdir}
sudo dpkg -i */*.deb
sudo dpkg --purge compiz-kde
