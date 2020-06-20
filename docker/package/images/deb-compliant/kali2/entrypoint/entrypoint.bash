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

mkdir /opt/debpkg/
cp -a /opt/package/source/* /opt/debpkg/
cp -a /opt/DEBIAN /opt/debpkg/
chmod 755  /opt/debpkg/DEBIAN/{postinst,preinst,prerm,postrm}
sed -i "s/Package_VAR/${BINARY}/g" /opt/debpkg/DEBIAN/control
sed -i "s/Version_VAR/${CURVER}/g" /opt/debpkg/DEBIAN/control
sed -i "s/Architecture_VAR/${ARCH}/g" /opt/debpkg/DEBIAN/control
sed -i "s/Description_VAR/${SUMMARY}/g" /opt/debpkg/DEBIAN/control
# 删除.gitignore
rm -f /opt/debpkg/source/.gitignore

dpkg -b /opt/debpkg/ /tmp/${BINARY}-${CURVER}-${RELEASE}.${OS}-${ARCH}.deb


# 移动生成的包
mv /tmp/${BINARY}-${CURVER}-${RELEASE}.${OS}-${ARCH}.deb /packages/
