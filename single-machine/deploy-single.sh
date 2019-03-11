#!/usr/bin/env bash
set -eu

lgtm_bundle="$1"

>&2 echo "Expanding cluster config..."
java -jar "$lgtm_bundle/lgtm/lgtm-config-gen.jar" --input "$lgtm_bundle/../state/lgtm-cluster-config.yml" --output "$lgtm_bundle/generated/" --overwrite generate

>&2 echo "Stopping any existing LGTM installation..."
if command -v lgtm-down > /dev/null; then
	sudo lgtm-down;
fi

>&2 echo "Installing LGTM packages..."
LGTM_DONT_START=true DEBIAN_FRONTEND=noninteractive sudo --preserve-env "$lgtm_bundle/generated/localhost/install-machine.sh"

>&2 echo "Starting core services..."
sudo lgtm-up --core-only

>&2 echo "Initializing LGTM..."
sudo lgtm-upgrade --action CREATE --if-not-exists --config "/etc/lgtm/config.json"
sudo lgtm-upgrade --action CONFIGURE --config "/etc/lgtm/config.json"
sudo lgtm-upgrade --action FULL --schema-only
sudo lgtm-upgrade --action INITIALIZE --core "$lgtm_bundle"/lgtm/odasa-*.zip
sudo lgtm-upgrade --action VALIDATE
sudo lgtm-upgrade --action FULL
sudo lgtm-upgrade --action CHECK

>&2 echo "Starting LGTM..."
sudo lgtm-up
