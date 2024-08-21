FROM registry.access.redhat.com/ubi9/ubi

RUN curl -o /tmp/bootstrap.cgi https://linux.dell.com/repo/hardware/dsu/bootstrap.cgi \
    && sed -i 's/IMPORT_GPG_CONFIRMATION="na"/IMPORT_GPG_CONFIRMATION="yes"/' /tmp/bootstrap.cgi \
    && bash /tmp/bootstrap.cgi \
    && yum -y update \
    && yum -y install openssl openssl-devel pciutils wget \
    && yum -y install srvadmin-idracadm7.x86_64 \
    && yum -y clean all \
    && rm /tmp/bootstrap.cgi

COPY command.sh /command.sh
ENTRYPOINT ["/command.sh"]
    