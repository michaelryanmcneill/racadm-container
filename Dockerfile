FROM centos

COPY bootstrap.cgi /tmp/

RUN yum -y update \
 && yum -y install openssl openssl-devel pciutils wget \
 && bash /tmp/bootstrap.cgi \
 && yum install -y srvadmin-idracadm7.x86_64 -y \
 && yum -y clean all

COPY command.sh /command.sh
ENTRYPOINT ["/command.sh"]
