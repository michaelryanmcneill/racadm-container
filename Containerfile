FROM registry.access.redhat.com/ubi9/ubi

## @note LEGACY crypto policy is required because Dell signs OMSA packages with a SHA-1 key. More details on RHEL 9 deprecating SHA-1 for signing by default here: https://www.redhat.com/en/blog/rhel-security-sha-1-package-signatures-distrusted-rhel-9

RUN rm -rf /etc/rhsm-host \
    && curl -s https://linux.dell.com/repo/hardware/dsu/copygpgkeys.sh | bash \
    && curl -o /tmp/bootstrap.cgi https://linux.dell.com/repo/hardware/dsu/bootstrap.cgi \
    && sed -i 's/IMPORT_GPG_CONFIRMATION="na"/IMPORT_GPG_CONFIRMATION="no"/' /tmp/bootstrap.cgi \
    && bash /tmp/bootstrap.cgi \
    && update-crypto-policies --set LEGACY \
    && dnf -y update \
    && dnf -y install openssl openssl-devel pciutils wget OpenIPMI \
    && dnf -y install srvadmin-idracadm7.x86_64 \
    && dnf -y clean all \
    && update-crypto-policies --set DEFAULT \
    && rm /tmp/bootstrap.cgi \
    && ln -s /run/secrets/rhsm /etc/rhsm-host

COPY command.sh /command.sh
ENTRYPOINT ["/command.sh"]