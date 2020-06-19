#!/bin/bash
set -eu

echo "==> Build environment:"
env

if [ ! ${BINARY} ];then
    echo "${BINARY} not find"
    exit 0;
fi
if [ ! ${GITREPO} ];then
    echo "${GITREPO} not find"
    exit 0;
fi

if [ ! ${CURVER} ];then
    echo "${CURVER} not find"
    exit 0;
fi

echo "==> Dirty patching to ensure OS deps are installed"

if [[ ! -f "/bin/rpmbuild" ]] ;
then
    echo "==> Installing dependancies for RHEL compliant version 7"
    yum  install -y rpm-build || true
fi

echo "==> Cleaning"
# Delete package if exists
rm -f /opt/package/package/* || true
# Cleanup relic directories from a previously failed build
rm -fr /root/.pki /root/rpmbuild/{BUILDROOT,RPMS,SRPMS,BUILD,SOURCES,tmp}  || true

# Clean and build dependancies and source
echo "==> Building"
cd /opt/package

# Prepare package files and build RPM
cd /tmp/
echo "==> Packaging"

# make dir 生成资源文件
#kdir -p /tmp/${BINARY}/{usr/bin/,etc/,usr/lib/systemd/system/}
#cp /opt/package/release/${BINARY}.${OS}-${ARCH}-${CURVER} /tmp/${BINARY}/usr/bin/${BINARY}
#cp -a /opt/package/${BINARY}.yaml /tmp/${BINARY}/etc/
#cp -a /opt/services/*  /tmp/${BINARY}/usr/lib/systemd/system/
cp -a /opt/package/source /tmp/source

# 删除.gitignore
rm -f /tmp/source/.gitignore
mv /tmp/source "/tmp/${BINARY}-${CURVER}"
tar czvf "${BINARY}-${CURVER}.tar.gz" ${BINARY}-${CURVER}
mkdir -p /root/rpmbuild/{RPMS,SRPMS,BUILD,SOURCES,SPECS,tmp}

# source 移动资源文件到 SOURCES
mv "/tmp/${BINARY}-${CURVER}.tar.gz" /root/rpmbuild/SOURCES

# 拷贝SPEC 文件
cp /opt/SPEC/.spec  /root/rpmbuild/SPECS/

## 执行RPM构建过程
cd /root/rpmbuild && rpmbuild -ba SPECS/.spec --define "version ${CURVER}"  --define "name ${BINARY}" --define "gitrepo ${GITREPO}"  --define "SUMMARY ${SUMMARY}" --define "RELEASE ${RELEASE}" --define "arch ${ARCH}"

# 移动生成的包
mv /root/rpmbuild/RPMS/x86_64/* /packages/
mv /root/rpmbuild/SRPMS/*  /packages/
# Cleanup current build
rm -fr /root/.pki /root/rpmbuild/{BUILDROOT,RPMS,SRPMS,BUILD,SOURCES,SPECS,tmp}
