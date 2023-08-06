#!/usr/bin/env bash

# sync-repo.sh <project> <arch> <repoid>
# This script will make the appropriate calls to reposync to update the specified repo and arch.
# You will need to have a .repo configuration file in the reposdir specified in this script.

# Brent Kolasinski
# b@brentk.io
# 2023-08-05

timestamp=$(date --iso-8601=seconds)
project=$1
arch=$2
repoid=$3

reposync_home=""
mirror_path=""
repo_dest=$mirror_path

# DNF parameters
reposdir_configs="$reposync_home/repos.d/"
setopt="--setopt=reposdir=$reposdir_configs"
reposync_opts="--download-metadata --delete --norepopath"
reposync_repoid="${project}_${repoid}"

# Text color deifinitions
t_red='\033[01;31m'
t_cyan='\033[01;36m'
t_green='\033[01;32m'
t_reset='\033[00;00m'

# Error Functions
function unsupported_arch {
    local arch=$1
    local repoid=$2
    local project=$3

    echo -e "${t_red}ERROR:${t_reset} Unsupported architecture ${t_cyan}$arch${t_reset}"\
	    "for repo ${t_cyan}$repoid${t_reset} in ${t_cyan}$project${t_reset}"
    exit 1
}

function unsupported_repoid {
    local repoid=$1
    local project=$2

    echo -e "${t_red}ERROR:${t_reset} Unsupported repoid ${t_cyan}$repoid${t_reset} for ${t_cyan}$project${t_reset}."
    echo "If you don't think this is an error, please ensure you have the repoid in the repo"
    echo "config path, and have added the hander to this script."
    exit 2
}

function unsupported_project {
    local project=$1

    echo -e "${t_red}ERROR:${t_reset} Unsupported project ${t_cyan}$project${t_reset}."
    echo "If you don't think this is an error, please ensure you have the project defined"
    echo "in the repo config path, and have added the handler to this script."
    exit 3
}


# Let's get through this ugly beast of figuring out if we support the options passed in.
# This is essentially our error handler for the user's input, as this will bomb with an
# error message if the user put something in we are not expecting.

case $project in
    centos-stream-9)
        repo_dest="$repo_dest/centos-stream"
        
	case $repoid in
            baseos)
		repo_dest="$repo_dest/9-stream/BaseOS"
                
		case $arch in 
                    x86_64)
                        repo_dest="$repo_dest/x86_64"
			;;
		    aarch64)
                        repo_dest="$repo_dest/aarch64"
			;;
		    *)
		        unsupported_arch $arch $repoid $project
			;;
		esac
		
		repo_dest="$repo_dest/os/"
		;;
            appstream)
                repo_dest="$repo_dest/9-stream/AppStream"
                
		case $arch in
                    x86_64)
                        repo_dest="$repo_dest/x86_64"
			;;
		    aarch64)
		        repo_dest="$repo_dest/aarch64"
			;;
		    *)
			unsupported_arch $arch $repoid $project
			;;
		esac

		repo_dest="$repo_dest/os"
		;;
	    extras-common)
	        repo_dest="$repo_dest/SIGs/9-stream/extras"

		case $arch in 
		    x86_64)
			repo_dest="$repo_dest/x86_64"
			;;
		    aarch64)
			repo_dest="$repo_dest/aarch64"
			;;
		    *)
			unsupported_arch $arch $repoid $project
			;;
                esac
	        
		repo_dest="$repo_dest/extras-common"
		;;
                    
            *)
		unsupported_repoid $repoid $project
		;;
        esac
        ;;

    epel)
        repo_dest="$repo_dest/epel"

	case $repoid in
	    epel-9)
		repo_dest="$repo_dest/9/Everything"

		case $arch in
		    x86_64)
			repo_dest="$repo_dest/x86_64"
			;;
		    aarch64)
                        repo_dest="$repo_dest/aarch64"
			;;
		    *)
			unsupported_arch $arch $repoid $project
			;;
		esac
		;;
	    epel-next-9)
		repo_dest="$repo_dest/next/9/Everything"

		case $arch in
		    x86_64)
			repo_dest="$repo_dest/x86_64"
			;;
		    aarch64)
			repo_dest="$repo_dest/aarch64"
			;;
		    *)
			unsupported_arch $arch $repoid $project
			;;
		esac
		;;
	    *)
		unsupported_repoid $repoid $project
		;;
	esac
	;;
    *)
	unsupported_project $project
	;;
esac
	
#echo "Download Path: $repo_dest"

# We made it, we now have a target of what we are syncing with, which comes down to a project::repo::cpu_arch
# Let's commence syncing.


echo -e "${t_green}START:${t_reset} Syncing ${t_cyan}$reposync_repoid${t_reset} for architecture ${t_cyan}$arch${t_reset}."
dnf reposync $setopt --repoid=$reposync_repoid --forcearch=$arch $reposync_opts --download-path=$repo_dest

dnf_return=$?
if [ $dnf_return -eq 0 ]; then
    echo $timestamp > ${repo_dest}/LOCAL_TIMESTAMP.txt
    echo -e "${t_green}DONE:${t_reset} Finished syncing ${t_cyan}$reposync_repoid${t_reset} for architecture ${t_cyan}$arch${t_reset}."
else
    echo -e "${t_red}ERROR:${t_reset} Sync was interrupted and did not complete!"
fi


