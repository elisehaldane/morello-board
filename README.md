# DSbD board scripts

## Description

These files are intended to be installed onto the physical, CHERI-based Morello hosts to help bootstrap various jails running under CheriBSD, version 24.05 (FreeBSD v15) in particular. Additional bootstrapping may be added in the future, depending on the demand for additional ABI support or the need to test OS forks and components under development.


## Dependencies

- curl
- git
- pot
- sudo


## Configuration

One of the dependencies, Pot, a jail manager, requires the use of OpenZFS as the host filesystem, hence the CheriBSD host needs to be installed with it at the outset; using UFS with Pot-based ZFS jails on top is not recommended. Use `sysrc zfs_enable` on the host to confirm that ZFS is configured.

To run GitHub Actions in a jail, the process will also require the creation of a GitHub organisation and a fine-grained personal access token with read and write permissions to access that organisation's self-hosted runners. Instructions on creating PATs are available here: [docs.github.com][github]. Organisations should limit self-hosted runners to "private" or "internal" repositories. Risks around the use of self-hosted runners are documented here: [docs.github.com][self-hosted].


## Installation

Jail installation and configuration is done largely via scripting under `/etc/rc.d` on the Morello host. Other files include cronjobs, particularly for restarting jails and adding them to `/etc/rc.conf`, and "flavours" for the different versions of CheriBSD.

Change `GITHUB_ORG` and `GITHUB_PAT` to their respective values.

```sh
export GITHUB_ORG="$NAME"
export GITHUB_PAT="$SECRET"
pkg64 install git -y
git clone https://github.com/dc-dsbd/dsbd-board-scripts
cd ./dsbd-board-scripts
sudo cp -R etc/ /etc
sudo cp -R usr/ /usr
sudo service dsbd_lab_board start
```

Pot uses a declarative model, inspired by OCI containers, where each jail can pull in certain "flavours" that could potentially configure servers, install dependencies, or perform other routine operations. In this repository, there is a set of CheriBSD-related flavours for use on Morello boards, to be placed under `/usr/local64/etc/pot/flavours`, which is where Pot will expect to find them. At the time of writing, there are five CheriBSD releases and each flavour in that subdirectory facilitates the bootstrapping of corresponding libraries for the commands `pkg64`, `pkg64cb`, and `clang` to function as expected.
- `pkg64cb` corresponds to the benchmark ABI. It will be missing files from `/usr/lib64cb` without the bootstrapping, hence those need copying into the jail
- `pkg64`, for example, corresponds to CheriBSD's hybrid ABI and requires extra files in `/usr/lib64` respectively
- `pkg64c` is natively supported and requires no additional work to bootstrap it


## Environment variables

In addition to the GitHub variables mentioned earlier, others were introduced. What follows is a complete list:

- `GITHUB_ORG`: the organisation's name
- `GITHUB_PAT`: a read/write GitHub token for organisation runners
- `HOST_ID`: a label for the host, appears first in the runner name
- `HOST_INTERFACE`: the host's ethernet interface ID
- `RUNNER_PREFIX`: a prefix in the runner name, commonly a project ID
- `RC_VERSION`: the script version, appears third in the runner name

A runner name comprises four components: the `HOST_ID`, `RUNNER_PREFIX`, `RC_VERSION`, and then a suffix of random alphanumeric characters (the `RUNNER_SUFFIX`). To avoid collisions when the runner is created, the random suffix is the only part that the user cannot modify via the above variables.


## Additional context

- Further information on Arm's Morello prototype can be found here: [developer.arm.com][arm].

- Introductions to the CHERI architectural model are accessible via the initiative's host, the University of Cambridge's Department of Computer Science and Technology: [cl.cam.ac.uk][cambridge].

- Details about the UKRI's Digital Security by Design programme (2020-2025) are available from the archive: [dsbd.tech][dsbd] or [web.archive.org][archive] respectively.

<!-- Links -->
[archive]: https://web.archive.org/web/20250000000000*/https://dsbd.tech
[arm]: https://developer.arm.com/documentation/den0132/0200/Overview
[cambridge]: https://www.cl.cam.ac.uk/research/security/ctsrd/cheri/
[dsbd]: https://www.dsbd.tech/
[github]: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-fine-grained-personal-access-token
[self-hosted]: https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/about-self-hosted-runners#self-hosted-runner-security
