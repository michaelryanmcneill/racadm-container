#!/bin/bash

MAX_TEMP=77
GOOD_MSG="(II) Dell Fan Control"

IPMI_PASSWORD_FILE=/run/secrets/idrac/token
IPMI_COMMAND="/usr/bin/ipmitool -H ${IPMI_HOST} -I lanplus -U ${IPMI_USER} -f ${IPMI_PASSWORD_FILE}"

[ -x ${IPMI_BINARY} ] || exit 1

[ -x ${IPMI_PASSWORD_FILE} ] || exit 1

RETVAL=0

CUR_TEMP=$(${IPMI_COMMAND} -c sdr type Temperature | grep '^Temp,' | cut -d',' -f2 | sort -un | tail -1)

if [ ${CUR_TEMP} -ge ${MAX_TEMP} ]; then
	# Set to auto mode
	${IPMI_COMMAND} raw 0x30 0x30 0x01 0x01 > /dev/null 2>&1
    GOOD_MSG="(!) High Temperature: ( ${CUR_TEMP}C >= ${MAX_TEMP}C ), reverting to automatic fan control"
else
	# Set to manual mode
	${IPMI_COMMAND} raw 0x30 0x30 0x01 0x00 > /dev/null 2>&1
	# Set to 1440rpm
	${IPMI_COMMAND} raw 0x30 0x30 0x02 0x01 0x19 > /dev/null 2>&1
    GOOD_MSG="(✓) Temperature OK: ( ${CUR_TEMP}C < ${MAX_TEMP}C ), setting fans to manual fan control (1440rpm)"
fi

RETVAL=$(($? + $RETVAL))

echo "$(date '+%Y%m%d%H%M%S') $(check)"

exit $RETVAL