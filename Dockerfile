FROM registry.centos.org/centos/centos:centos7

RUN yum install -y wget perl openssl-devel
RUN wget -q -O - http://linux.dell.com/repo/hardware/latest/bootstrap.cgi | bash

RUN yum install -y srvadmin-idracadm7

ENTRYPOINT ["/opt/dell/srvadmin/bin/idracadm7"]
