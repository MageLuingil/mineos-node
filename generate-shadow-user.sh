#!/bin/bash
set -eo pipefail

add_shadow_user() {
	# Create local shadow database file if it doesn't already exist
	if [[ ! -f shadow ]]; then
		touch shadow
		chmod 640 shadow
	fi
	
	# Verify shadow database is writable
	if [[ ! -w shadow ]]; then
		echo >&2 "Permission denied: shadow is not writable"
	fi
	
	read -p "Username: " user
	
	local salt="$(tr -dc A-Za-z0-9 </dev/urandom | head -c 2)"
	local pass="$(openssl passwd -6 -salt $salt)"
	local changed="$(($(date --utc --date "$1" +%s)/86400))"
	
	local passwd="$user:$pass:$changed:0:99999:7:::"
	
	# Delete existing (if any) and append
	sed -i "/^$user/ d" shadow
	echo "$passwd" >> shadow
}

add_shadow_user
