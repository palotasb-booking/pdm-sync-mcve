# MCVE for PDM #2780

This is intended to be a minimal complete verifiable example for [PDM issue #2780](https://github.com/pdm-project/pdm/issues/2780)

> pdm sync intermittently fails when pdm manages itself and install.parallel is True

The issue is intermittent, thus a script, [`reproducer.sh`](reproducer.sh) is provided to run a large number of `pdm sync` operations in various Docker images to reproduce the issue.

To run the issue, execute the script:

```shell
$ ./reproducer.sh
```

The available options (and their default values) are:

```shell
$ N=30 PY='3.9 3.10 3.11' DISTRO='alpine slim' DOCKER_FLAGS='' ./reproducer.sh
```

* `N` is the number of docker containers.
* The Docker image used is `python:${PY}-${DISTRO}` for each value listed in those variables.
* `DOCKER_FLAGS` is passed to `docker run`. Pass `DOCKER_FLAGS="--pull never"` to avoid overloading the Docker registry.
