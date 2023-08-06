# dnf-reposync-wrapper
This is a set of DNF reposync wrappers to make synchronizing repositories easier. They are a series of shell scripts that makes it possible to read in repository data from the non-default location in the OS, and allows the repos to sync other distributions and architectures that are not part of the hosting system.


## Things to change before you get started

  - sync-repo.sh
    - `$reposync_home`: This is where the scripts bin and repos.d directories will live; where this script was git cloned to.
    - `$mirror_path`: Change this to root of your hosting mirror.
      - For example, if I am syncing centos to something under mirror.0x626b.com/pub/centos-stream (resolving to `/usr/local/nginx/html/pub/centos-stream`), this should be set to `/usr/local/nginx/html/pub`.

  - local-repo-sync.sh
    - `$reposync_script`: Path to the sync-repo.sh script.
    - `$projects`: List of projects you wish to sync. By default this is set to centos-stream-9 and epel.
    - `$arches`: List of CPU architectures you wish to sync. By default this is set to x86_64 and aarch64.
## Directory Structure
The sync wrappers rely on a few important directories in this project:

  - bin/ : Contains all executable scripts

    - local-repo-sync.sh : Wrapper around sync-repo.sh. This is very much customized to my environment, but it allows 
      you to specify the scope that you would like to synchronize for a repository. Specifically, it loops over a set
      of Projects::Repos::Architectures to call sync-repo with. The definitions for the repoid's themselves are spec'd
      in the yum .repo files in the local `repos.d/`.

    - sync-repo.sh : This is the script that does all the sync'ing, and makes the calls to `dnf reposync`. Error handling
      is done in this script, and it will bomb if you pass it in a project/repoid/architecture that it doesn't already
      know about. We handle this here because different repos will have different directory structure conventions
      (see EPEL vs Fedora vs CentOS Stream), and this script needs to know this when constructing the download path.

  - repos.d/ : Contains all repos for sync'ing. Specified in standard yum[dnf].repo format, that you'd find in 
    `/etc/yum.repos.d/`


## Specifying repositories
Repositories are specified in the standard way you'd find in `/etc/yum.repos.d/`. However, to make sure we have control
over what we are synchronizing, we have to be mindful of variables spec'd in the repo file.

## Repository Metadata
This script makes use of the DNF `--download-metadata` switch. We create repositories without needed to make a subsequent 
call to `createrepo_c` to rebuild the repository database. Since we download the ENTIRE repository, there is no need to 
rebuild repository metadata, because we aren't stripping out any packages from what is avaiable in our sync target. 

### Note on repo variables
My repository files have striped out the `$releasever` variable, and replaced it with the specific release we want to sync.
This is to prevent the dnf `--setopt=` parameter from overriding what we want sync'd, especially if someone specifies this
in their /etc/yum.conf file.

### Repository Naming
We do not want to use the default names that are generally specified in default repo files that ship with the os. These
usually look like `[baseos]` or `[appstream]`. These are not granular enough ids for us to sync with, because we could be 
synchronizing multiple distrobutions that have a `[baseos]` repository. 

We have to add the release version of the repository into the repo id. For example, if we were syncing baseos for centos-
stream-9, the repositories repoid would look like the following:

`[centos-stream-9_baseos]`

or for EPEL for RHEL9:

`[epel_epel-9]`

or EPEL-Next for CentOS-Stream-9

`[epel_epel-next-9]`

All repo files in the `repos.d/` directory are "concatenated", so having the "project" identifier be part of the repoid
stops the repoid names from being overloaded when multiple projects have the same repoid name (for example, CentOS-Stream-9
and the future CentOS-Stream-10 having the same baseos repo).


## The Fine Print
This software is free to use under the BSD 2-clause sumplified license (see LICENSE.txt in this git repo). I do this stuff
for fun, and maybe someone else will find it useful to.

      
