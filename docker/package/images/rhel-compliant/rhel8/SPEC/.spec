%define debug_package %{nil}
Name: %{name}
Version: %{version}
Release:	%{RELEASE}%{?dist}
Summary: %{SUMMARY}

Group:  Development/Tools
License: GPL
URL: %{gitrepo}
Source0: %{name}-%{version}.tar.gz

BuildRoot: %{_tmppath}/%{name}-%{main_version}-%{main_release}-root
%description
%{SUMMARY}

%prep
%setup -q
%post
PASSFILE="/opt/goby-api/.gobypasswd"
 if [ ! -f "${PASSFILE}" ]; then
       GUSER=`cat /dev/urandom | head -1 | md5sum | head -c 6`
       GPASSWD=`cat /dev/urandom | head -1 | md5sum | head -c 16`
       echo "${GUSER}:${GPASSWD}">${PASSFILE}
       echo "create passwd file ${PASSFILE}"
 else
      GUSER=`cut -d : -f 1 ${PASSFILE}`
      GPASSWD=`cut -d : -f 2 ${PASSFILE}`
 fi
 sed -i "s/GOBY_USER/${GUSER}/g" /lib/systemd/system/goby-api.service
 sed -i "s/GOBY_PASSWD/${GPASSWD}/g" /lib/systemd/system/goby-api.service
setcap cap_net_raw,cap_net_admin=eip /opt/goby-api/golib/goby-cmd-linux
touch /opt/goby-api/.dingtoken
systemctl restart rsyslog
systemctl daemon-reload

%preun
systemctl disable goby-api
systemctl stop goby-api

%install
/bin/rm -rf %{buildroot}
/bin/mkdir -p %{buildroot}
/bin/cp -a * %{buildroot}

%files
%defattr(-,root,root,-)
/etc/rsyslog.d/goby-api.conf
/etc/logrotate.d/goby-api
/lib/systemd/system/goby-api.service
%defattr(-,nobody,nobody,-)
%attr(-,nobody,nobody) /opt/goby-api/golib/
%attr(0755,root,root) /opt/goby-api/golib/goby-cmd-linux
%attr(0755,root,root) /opt/goby-api/gobytip.sh
%config(noreplace) /opt/goby-api/golib/postgres_user_pass.dict
%config(noreplace) /opt/goby-api/golib/smb_user_pass.dict
%config(noreplace) /opt/goby-api/golib/tomcat_user_pass.dict
%config(noreplace) /opt/goby-api/golib/ftp_user_pass.dict
%config(noreplace) /opt/goby-api/golib/mysql_user_pass.dict
%config(noreplace) /opt/goby-api/golib/rdp_user_pass.dict
%config(noreplace) /opt/goby-api/golib/ssh_user_pass.dict
%config(noreplace) /opt/goby-api/golib/user_pass.dict
/opt/goby-api/golib/exploits/system/
/opt/goby-api/golib/exploits/user/
%clean
%{__rm} -rf $RPM_BUILD_ROOT