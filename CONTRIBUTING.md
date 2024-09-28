# Contributing to Podman Security Bench

Want to hack on Podman Security Bench? Awesome! Here are instructions to get you
started.

The Podman Security Bench is a part of the [Containers](https://github.com/containers)
project, and follows the same rules and principles. If you're already familiar
with the way Podman does things, you'll feel right at home.

Otherwise, go read
[Contribute to the Podman Project](https://github.com/containers/podman/blob/main/CONTRIBUTING.md).

## Development Environment Setup

### Start hacking

You can build the container that wraps the podman security bench:

```sh
git clone git@github.com:containers/podman-security.git
cd podman-security
podman build -t podman-security .
```

Or you can simply run the shell script locally:

```sh
git clone git@github.com:containers/podman-security.git
cd podman-security
sudo bash podman-security.sh
```

The Podman Security Bench has the main script called `podman-security.sh`.
This is the main script that checks for all the dependencies, deals with
command line arguments and loads all the tests.

The tests are split into the following files:

```sh
tests/
├── 1_host_configuration.sh
├── 2_podman_configuration.sh
├── 3_podman_configuration_files.sh
├── 4_container_images.sh
├── 5_container_runtime.sh
├── 6_podman_security_operations.sh
├── 8_podman_enterprise_configuration.sh
└── 99_community_checks.sh
```

To modify the Podman Security Bench you should first clone the repository,
make your changes, check your code with `shellcheck`, or similar tools, and
then sign off on your commits. After that feel free to send us a pull request
with the changes.

While this tool was inspired by the [CIS Docker 1.11.0 benchmark](https://www.cisecurity.org/benchmark/docker/)
and its successors, feel free to add new tests.
