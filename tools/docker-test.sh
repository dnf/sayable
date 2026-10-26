#!/usr/bin/env bash
# Run sayable's tests on Linux in the generated age/Dockerfile image, with this
# checkout mounted at /workspace and the host's hecatron at /opt/hecatron.
#
#   tools/docker-test.sh          # build the image and run every test suite
#   tools/docker-test.sh bash     # interactive shell inside the container
set -euo pipefail

cd "$(dirname "$0")/.."

if ! command -v hecatron >/dev/null 2>&1; then
    echo "error: hecatron is not on PATH (see https://github.com/dnf/hecatron)" >&2
    exit 1
fi
eval "$(hecatron env)"

docker build -t sayable-linux -f age/Dockerfile .

# Anonymous volumes shadow host directories that contain platform-specific
# artifacts (native binaries, build caches). This avoids macOS/Linux
# conflicts without modifying the host filesystem.
DOCKER_OPTS=(
    --rm
    -v "$(pwd)":/workspace
    -v "${HECATRON_HOME}":/opt/hecatron:ro
    -v /workspace/cli/build
)
if [ -t 0 ] && [ -t 1 ]; then
    DOCKER_OPTS+=(--interactive --tty)
fi
for _component in ${HECATRON_COMPONENTS}; do
    for _artifacts in typescript/node_modules python/.venv rust/target cpp/build \
                      groovy/.gradle java/.gradle kotlin/.gradle; do
        DOCKER_OPTS+=(-v "/workspace/${_component}/impl/${_artifacts}")
    done
done

# The image's PATH already holds every toolchain; hecatron goes in front.
# shellcheck disable=SC2016  # expanded inside the container
_with_hecatron=(bash -c 'export PATH="/opt/hecatron/bin:${PATH}" && exec "$@"' _)

# The Python hooks run pytest directly, as CI does after `pip install`.
if [ $# -eq 0 ]; then
    set -- bash -c 'uv tool install --quiet pytest && just test'
fi
docker run "${DOCKER_OPTS[@]}" sayable-linux "${_with_hecatron[@]}" "$@"
