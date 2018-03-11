#
# Regular cron jobs for the snow package
#
0 4	* * *	root	[ -x /usr/bin/snow_maintenance ] && /usr/bin/snow_maintenance
