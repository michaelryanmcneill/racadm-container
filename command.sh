#!/usr/bin/env bash
set -eoE pipefail

usage() {
	echo "${@}"
	echo "Usage: ${0} [-v] [-d] [-r] [-b] -h idrac-hostname -u user -p password -i iso-url" 1>&2
	exit 1
}

dracversion() {
	/opt/dell/srvadmin/bin/idracadm7 --nocertwarn -r ${HOST} -u ${USER} -p ${PASSWORD} get idrac.Info.ServerGen | grep ServerGen | cut -d "=" -f2 | sed 's/G//'
	exit 0
}

runcommand() {
	/opt/dell/srvadmin/bin/idracadm7 --nocertwarn -r ${HOST} -u ${USER} -p ${PASSWORD} $COMMAND
	exit 0
}
clearvd() {
	echo '******* Initializing virtual disk to ensure clean boot to ISO *******'
	/opt/dell/srvadmin/bin/idracadm7 --nocertwarn -h ${HOST} -u ${USER} -p ${PASSWORD} storage init:Disk.Virtual.0:RAID.Integrated.1-1 -speed fast
	/opt/dell/srvadmin/bin/idracadm7 --nocertwarn -h ${HOST} -u ${USER} -p ${PASSWORD} jobqueue create RAID.Integrated.1-1 -s TIME_NOW
}
if [[ $# -lt 7 ]]; then
	usage "Insufficient number of parameters"
fi

while getopts vdrb:h:u:p:i: option; do
	case "${option}" in
	v)
		VERSION="TRUE"
		;;
	d)
		DELETE="TRUE"
		;;

	r)
		REBOOT="TRUE"
		;;

	b)
		SETBOOT="TRUE"
		;;

	h)
		HOST=${OPTARG}
		;;

	u)
		USER=${OPTARG}
		;;
	p)
		PASSWORD=${OPTARG}
		;;
	i)
		ISO_URL=${OPTARG}
		;;
	c)
		COMMAND=${OPTARG}
		;;

	*)
		usage
		;;
	esac
done
shift $((OPTIND - 1))

if [ ${VERSION} ]; then
	dracversion
fi

if [ ${COMMAND} ]; then
	runcommand
fi

echo HOST = ${HOST}
echo USER = ${USER}
echo PASSWORD = ${PASSWORD}
echo ISO_URL = ${ISO_URL}

if [ ${DELETE} ]; then
	clearvd
	# Move on to mounting the ISO
fi

if ! curl --output /dev/null --silent --head --fail "${ISO_URL}"; then
	usage "******* ISO does not exist in the provided url: ${ISO_URL}"
fi

echo '******* Disconnecting existing image *******'
/opt/dell/srvadmin/bin/idracadm7 --nocertwarn -r ${HOST} -u ${USER} -p ${PASSWORD} remoteimage -d

echo "******* Attaching remote ISO ${ISO_URL} to virtual media *******"
/opt/dell/srvadmin/bin/idracadm7 --nocertwarn -r ${HOST} -u ${USER} -p ${PASSWORD} remoteimage -c -l ${ISO_URL}

if ! /opt/dell/srvadmin/bin/idracadm7 --nocertwarn -r ${HOST} -u ${USER} -p ${PASSWORD} remoteimage -s | grep ${ISO_URL}; then
	usage 'ISO was not configured correctly'
else
	echo "******* ${ISO_URL} Mounted successfully *******"
fi

if [ ${SETBOOT} ]; then
	echo '******* Setting idrac to boot once from the attached iso *******'
	/opt/dell/srvadmin/bin/idracadm7 --nocertwarn -r ${HOST} -u ${USER} -p ${PASSWORD} set iDRAC.VirtualMedia.BootOnce 1
	/opt/dell/srvadmin/bin/idracadm7 --nocertwarn -r ${HOST} -u ${USER} -p ${PASSWORD} set iDRAC.ServerBoot.FirstBootDevice VCD-DVD
fi

if [ ${REBOOT} ]; then
	echo '******* Rebooting the server *******'
	/opt/dell/srvadmin/bin/idracadm7 --nocertwarn -r ${HOST} -u ${USER} -p ${PASSWORD} serveraction powercycle
fi

echo '******* Done *******'
