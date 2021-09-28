# Podman Security Tests

![Podman Security Tests running](img/benchmark_log.png)

Podman Security is a script that checks for dozens of common best-practices around deploying Podman containers in production. The tests are all automated, and are based on the [CIS Docker Benchmark v1.3.1](https://www.cisecurity.org/benchmark/docker/).

We are making this available as an open-source utility so the Podman community
can have an easy way to self-assess their hosts and podman containers against
this benchmark.

## Running Podman Security

### Run from your base host

You can simply run this script from your base host by running:

```sh
git clone https://github.com/containers/podman-security-bench.git
cd podman-security-bench
sudo sh podman-security-bench.sh
```

### Note

Podman bench requires Podman 3.3.0 or later in order to run.

Note that when distributions don't contain `auditctl`, the audit tests will check `/etc/audit/audit.rules` to see if a rule is present instead.

### Podman Security Bench options

```sh
  -b           optional  Do not print colors
  -h           optional  Print this help message
  -l FILE      optional  Log output in FILE, inside container if run using podman
  -c CHECK     optional  Comma delimited list of specific check(s) id
  -e CHECK     optional  Comma delimited list of specific check(s) id to exclude
  -i INCLUDE   optional  Comma delimited list of patterns within a container or image name to check
  -x EXCLUDE   optional  Comma delimited list of patterns within a container or image name to exclude from check
  -n LIMIT     optional  In JSON output, when reporting lists of items (containers, images, etc.), limit the number of reported items to LIMIT. Default 0 (no limit).
  -p PRINT     optional  Disable the printing of remediation measures. Default: print remediation measures.
```

By default, the Podman Security Bench script will run all available CIS tests and produce
logs in the log folder from current directory, named `podman-security-bench.log.json` and
`podman-security-bench.log`.

The CIS based checks are named `check_<section>_<number>`, e.g. `check_2_6` and community contributed checks are named `check_c_<number>`.

`sh podman-security-bench.sh -c check_2_2` will only run check `2.2 Ensure the logging level is set to 'info'`.

`sh podman-security-bench.sh -e check_2_2` will run all available checks except `2.2 Ensure the logging level is set to 'info'`.

`sh podman-security-bench.sh -e podman_enterprise_configuration` will run all available checks except the podman_enterprise_configuration group

`sh podman-security-bench.sh -e podman_enterprise_configuration,check_2_2` will run all available checks except the podman_enterprise_configuration group and `2.2 Ensure the logging level is set to 'info'`

`sh podman-security-bench.sh -c container_images -e check_4_5` will run just the container_images checks except `4.5 Ensure Content trust for Podman is Enabled`

Note that when submitting checks, provide information why it is a reasonable test to add and please include some kind of official documentation verifying that information.
