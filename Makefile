# auto rpm

export BINARY=goby-api
export CURVER?=1.17.160
export RELEASE=2
export GITREPO=https://github.com/gobysec/Goby/
export SUMMARY="a sec tools"

.PHONY: all
all: rhel7 rhel8 kali2

.PHONY: fast
fast:
	docker-compose up
	docker-compose rm -f

.PHONY: rhel7
rhel7: packages/${BINARY}-${CURVER}-${RELEASE}.el7.x86_64.rpm

.PHONY: rhel8
rhel8: packages/${BINARY}-${CURVER}-${RELEASE}.el8.x86_64.rpm

.PHONY: kali2
kali2: packages/${BINARY}-${CURVER}-${RELEASE}.kali2-amd64.deb

packages/${BINARY}-${CURVER}-${RELEASE}.el7.x86_64.rpm:
	docker-compose up centos7_build
	docker-compose rm -f

packages/${BINARY}-${CURVER}-${RELEASE}.el8.x86_64.rpm:
	docker-compose up centos8_build
	docker-compose rm -f

packages/${BINARY}-${CURVER}-${RELEASE}.kali2-amd64.deb:
	docker-compose up kali2_build
	docker-compose rm -f