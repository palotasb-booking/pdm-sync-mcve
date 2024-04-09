#!/bin/sh -eu

# Use these env vars to control what gets tested
# e.g.:
#    env N=10 PY="3.11 3.10" DISTRO="alpine slim" ./reproducer.sh
#    env N=10 PY="3.12" DISTRO="alpine" ./reproducer.sh
# Set DOCKER_FLAGS="--pull never" to avoid pulling too much from the Docker registry.
N="${N:-30}"
PY="${PY:-3.9 3.10 3.11}"
DISTRO="${DISTRO:-alpine slim}"
DOCKER_FLAGS="${DOCKER_FLAGS:-}"

printf "N=%q PY=%q DISTRO=%q DOCKER_FLAGS=%q %q\n" "$N" "$PY" "$DISTRO" "$DOCKER_FLAGS" "$0"

NN="$(seq "$N" | tr '\n' ' ')"
mkdir -p logs

for distro in $DISTRO
do
    for py in $PY
    do
        for n in $NN
        do
            echo "Running with distro=$distro, python=$py, n=$n"
            docker run \
                $DOCKER_FLAGS \
                --rm --mount type=bind,source="$(pwd)",target=/src \
                --workdir /root \
                -t \
                python:${py}-${distro} \
                sh -euxc '
                    mkdir -p $(pwd)
                    cp -a /src/pdm.lock /src/pdm.toml /src/pyproject.toml .
                    command -v python3
                    python3 -m venv .venv
                    . .venv/bin/activate
                    pip install --progress-bar=off pdm
                    pip freeze --all | tee pip-freeze-before
                    pdm info
                    pdm info --env
                    SUCCESS=true
                    pdm sync || SUCCESS=false 
                    pip freeze --all | tee pip-freeze-after
                    diff pip-freeze-before pip-freeze-after || true
                    test $SUCCESS = true
                    echo SUCCESS=$SUCCESS
                ' >logs/${distro}-${py}-${n}.o.log 2>logs/${distro}-${py}-${n}.E.log &
        done
        wait
    done
done

echo "done, log files showing the issue are:"
grep -r SUCCESS=false logs || { echo "(none - all succeeded)"; }
