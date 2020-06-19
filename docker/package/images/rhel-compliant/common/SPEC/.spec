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

%install
/bin/rm -rf %{buildroot}
/bin/mkdir -p %{buildroot}
/bin/cp -a * %{buildroot}

%files
%defattr(-,root,root,-)
%attr(0755,root,root) /usr/local/bin/%{name}
%clean
%{__rm} -rf $RPM_BUILD_ROOT