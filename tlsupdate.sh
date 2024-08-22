#!/bin/bash

IPMI_PORT=443
RACADM_BINARY=/opt/dell/srvadmin/bin/idracadm7
RACADM_COMMAND="${RACADM_BINARY} -r ${IPMI_HOSTNAME} -u ${IPMI_USER} -p ${IPMI_PASSWORD}"

if [ ! -x ${RACADM_BINARY} ]; then echo "${RACADM_BINARY} doesn't have execute permissions" && exit 1; fi

if [[ -z ${IPMI_HOSTNAME} || -z ${IPMI_USER} || -z ${IPMI_PASSWORD} || -z ${IPMI_PORT} ]]; then echo "Missing one or more environment variables" && exit 1; fi

if [[ ! -f /run/secrets/idrac/tls.crt || ! -f /run/secrets/idrac/tls.key ]]; then echo "TLS certificate or key missing" && exit 1; fi

openssl s_client -showcerts -verify 5 -connect ${IPMI_HOSTNAME}:${IPMI_PORT} < /dev/null | sed --quiet '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /tmp/live-tls.crt

if cmp -s /tmp/live-tls.crt /run/secrets/idrac/tls.crt; then
    echo "Certificates match, nothing to do."
    exit 0
else
    echo "Certificate mismatch, beginning certificate replacement process."
    ${RACADM_COMMAND} sslkeyupload -t 1 -f /run/secrets/idrac/tls.key
    ${RACADM_COMMAND} sslcertupload -t 1 -f /run/secrets/idrac/tls.crt
    echo "Triggering iDRAC reset..."
    ${RACADM_COMMAND} racreset
    exit 0
fi

