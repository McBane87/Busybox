
Mode=$1
Target=$2

if [[ $1 == "" || $2 == "" ]]; then
	echo "Error: Usage -> bb_helper.sh [rmsyms/mksyms] [Target-Dir]"
	exit 1
fi

if [[ $Mode == "rmsyms" ]]; then
	busybox ls -l $Target 2>/dev/null | busybox grep "\->.*busybox" >/dev/null 2>/dev/null
	
	if [[ $? -eq 0 ]]; then
		busybox mount -o rw,remount /system
		busybox find $Target -type l | \
		busybox xargs -I {} busybox sh -c ' \
		busybox ls -l {} | busybox grep "\->.*busybox" >/dev/null; \
		if [[ $? -eq 0 ]]; then \
			rm {}; \
		fi'
		exit 0
	else
		echo "No existing Busybox Symlinks found in $Target"
		exit 0
	fi
elif [[ $Mode == "mksyms" ]]; then
	if [[ -x $Target/busybox ]]; then
		busybox mount -o rw,remount /system
		for sym in $($Target/busybox --list); do
			if [[ "$sym" == "" || "$sym" == "su" ]]; then
					continue;
			fi
			busybox ln -sf $Target/busybox $Target/$sym
		done
		exit 0
	else
		echo "Error: No busybox found in $Target"
		exit 1
	fi
else
	echo "Error: Usage -> bb_helper.sh [rmsyms/mksyms] [Target-Dir]"
	exit 1
fi
