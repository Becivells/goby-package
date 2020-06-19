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
 sed -i "s/GOBY_USER/${GUSER}/g" /etc/systemd/system/multi-user.target.wants/goby-api.service
 sed -i "s/GOBY_PASSWD/${GPASSWD}/g" /etc/systemd/system/multi-user.target.wants/goby-api.service
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

%attr(0755,root,root) /opt/goby-api/goby-cmd-linux
/opt/goby-api/exploits/system/
/opt/goby-api/exploits/user/
/etc/rsyslog.d/goby-api.conf
/etc/logrotate.d/goby-api
/etc/systemd/system/multi-user.target.wants/goby-api.service
%config(noreplace) /opt/goby-api/postgres_user_pass.dict
%config(noreplace) /opt/goby-api/smb_user_pass.dict
%config(noreplace) /opt/goby-api/tomcat_user_pass.dict
%config(noreplace) /opt/goby-api/ftp_user_pass.dict
%config(noreplace) /opt/goby-api/mysql_user_pass.dict
%config(noreplace) /opt/goby-api/rdp_user_pass.dict
%config(noreplace) /opt/goby-api/ssh_user_pass.dict
%config(noreplace) /opt/goby-api/user_pass.dict
%clean
%{__rm} -rf $RPM_BUILD_ROOT