#!/usr/bin/env bash
set -eu

if [[ $# -ne 1 ]]; then
	echo "Usage: $0 <lgtm bundle directory>"
	exit 1
fi

lgtm_bundle="$1"

>&2 echo "Expanding cluster config..."
java -jar "$lgtm_bundle/lgtm/lgtm-config-gen.jar" --input "$lgtm_bundle/../state/lgtm-cluster-config.yml" --output "$lgtm_bundle/generated/" --overwrite generate

>&2 echo "Stop LGTM on all hosts..."
for host_directory in "$lgtm_bundle/generated/"*; do
	host=$(basename "$host_directory")
	>&2 echo "Stopping LGTM on $host..."
	ssh "$host" -- "if command -v lgtm-down > /dev/null; then sudo lgtm-down; fi" < /dev/null
done

>&2 echo "Install on each host..."
for host_directory in "$lgtm_bundle/generated/"*; do
	host=$(basename "$host_directory")
	>&2 echo "Copying to $host..."
	temp_dir=$(ssh "$host" -- mktemp --directory --suffix "-lgtm-deployment")
	remove_temp() {
		ssh "$host" -- rm -rf "$temp_dir"
	}
	trap remove_temp ERR
	rsync --recursive --archive --compress --progress --include "generated/$host/" --exclude "generated/*/" --exclude "lgtm/odasa-*.zip" "$lgtm_bundle/" "$host:$temp_dir"
	>&2 echo "Installing on $host..."
	ssh "$host" -- LGTM_DONT_START=true DEBIAN_FRONTEND=noninteractive sudo --preserve-env "$temp_dir/generated/$host/install-machine.sh" < /dev/null
	trap - ERR
	remove_temp
done

>&2 echo "Starting core services..."
for host_directory in "$lgtm_bundle/generated/"*; do
	host=$(basename "$host_directory")
	>&2 echo "Starting core services on $host..."
	ssh "$host" -- sudo lgtm-up --core-only
done

>&2 echo "Initializing LGTM..."
for host_directory in "$lgtm_bundle/generated/"*; do
	while read -r package; do
		if [ "$package" = "lgtm-upgrade" ]; then
			host=$(basename "$host_directory")
			>&2 echo "Using host $host as coordinator..."
			temp_dir=$(ssh "$host" -- mktemp --directory --suffix "-lgtm-deployment")
			remove_temp() {
				ssh "$host" -- rm -rf "$temp_dir"
			}
			trap remove_temp ERR
			rsync --recursive --archive --compress --progress --include "*/" --include "lgtm/odasa-*.zip" --exclude "*" "$lgtm_bundle/" "$host:$temp_dir"
			ssh "$host" -- sudo lgtm-upgrade --action CREATE --if-not-exists --config "/etc/lgtm/config.json" < /dev/null
			ssh "$host" -- sudo lgtm-upgrade --action CONFIGURE --config "/etc/lgtm/config.json" < /dev/null
			ssh "$host" -- sudo lgtm-upgrade --action FULL --schema-only < /dev/null
			ssh "$host" -- sudo lgtm-upgrade --action INITIALIZE < /dev/null
			ssh "$host" -- sudo lgtm-upgrade --action VALIDATE < /dev/null
			ssh "$host" -- sudo lgtm-upgrade --action FULL < /dev/null
			ssh "$host" -- sudo lgtm-upgrade --action CHECK < /dev/null
			trap - ERR
			remove_temp
		fi
	done < "$host_directory/packages.txt"
done

>&2 echo "Starting LGTM..."
for host_directory in "$lgtm_bundle/generated/"*; do
	host=$(basename "$host_directory")
	>&2 echo "Starting LGTM on $host..."
	ssh "$host" -- sudo lgtm-up
done
