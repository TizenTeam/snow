export NO_UPNP=1

default: all
	sync

%: src/Makefile
	${MAKE} -C ${<D} -f ${CURDIR}/$<  $@
