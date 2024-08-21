FROM registry.access.redhat.com/ubi9/ubi

RUN curl -s https://linux.dell.com/repo/hardware/dsu/copygpgkeys.sh | bash \
    && curl -o /tmp/bootstrap.cgi https://linux.dell.com/repo/hardware/dsu/bootstrap.cgi \
    && sed -i 's/IMPORT_GPG_CONFIRMATION="na"/IMPORT_GPG_CONFIRMATION="no"/' /tmp/bootstrap.cgi \
    && bash /tmp/bootstrap.cgi \
    && dnf -y update \
    && dnf -y install openssl openssl-devel pciutils wget \
    && dnf -y install srvadmin-idracadm7.x86_64 \
    && dnf -y clean all \
    && rm /tmp/bootstrap.cgi

COPY command.sh /command.sh
ENTRYPOINT ["/command.sh"]
    