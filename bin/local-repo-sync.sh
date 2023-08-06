#!/usr/bin/env bash

# local-repo-sync.sh
# This script cycles through a list of all supported mirror I want to locally mirror on
# the local network, and syncs them. It depends on repo-sync.sh to do that actual
# syncing. This script is a wrapper around repo-sync.sh.

# Brent Kolasinski
# b@brentk.io
# 2023-08-05

reposync_script=""

# Projects and repos to sync
projects=("centos-stream-9" "epel")
arches=("x86_64" "aarch64")

# Specific project repos to sync
centos_stream_9_repos=("baseos" "appstream" "extras-common")
epel_repos=("epel-9" "epel-next-9")

for project in "${projects[@]}"; do
    for arch in "${arches[@]}"; do
	if [[ $project == "centos-stream-9" ]]; then
	    for repoid in "${centos_stream_9_repos[@]}"; do
                $reposync_script $project $arch $repoid
	    done
	elif [[ $project == "epel" ]]; then
	    for repoid in "${epel_repos[@]}"; do
		$reposync_script $project $arch $repoid
	    done
	else
	    echo "Something went really wrong, you shouldn't see this."
	    exit 1
	fi
    done
done
	    
