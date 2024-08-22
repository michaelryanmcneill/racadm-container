#!/bin/bash

MAX_TEMP=77
GOOD_MSG="(II) Dell Fan Control"

IPMI_BINARY=/usr/bin/ipmitool
IPMI_PASSWORD_FILE=/run/secrets/idrac/token
IPMI_COMMAND="${IPMI_BINARY} -H ${IPMI_HOST} -I lanplus -U ${IPMI_USER} -E"

if [ ! -x ${IPMI_BINARY} ]; then echo "${IPMI_BINARY} doesn't have execute permissions" && exit 1; fi

if [[ -z ${IPMI_HOST} || -z ${IPMI_USER} || -z ${IPMI_PASSWORD} ]]; then echo "Missing one or more environment variables" && exit 1; fi

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

exit $RETVAL