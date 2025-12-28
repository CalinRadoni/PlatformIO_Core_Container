# For PYTHON_VERSION use 3, 3-trixie, 3-slim, ... (https://hub.docker.com/_/python/)
# Use "3.13-slim" for compatibility with pioarduino !
ARG PYTHON_VERSION="3.13-slim"
FROM python:${PYTHON_VERSION}

# For PLATFORMIO_VERSION use "latest" or a specific version like "6.1.18"
ARG PLATFORMIO_VERSION="latest"

# Set image's label
ARG APP="PlatformIO Core"
LABEL org.opencontainers.image.title="${APP}" \
      org.opencontainers.image.version="${PLATFORMIO_VERSION}" \
      org.opencontainers.image.authors="Calin Radoni" \
      org.opencontainers.image.created=$(date --rfc-3339=seconds) \
      org.opencontainers.image.description="${APP} ${PLATFORMIO_VERSION} on Python ${PYTHON_VERSION}" \
      org.opencontainers.image.url='https://github.com/CalinRadoni/PlatformIO_Core_Container' \
      org.opencontainers.image.documentation='https://github.com/CalinRadoni/PlatformIO_Core_Container' \
      org.opencontainers.image.source='https://github.com/CalinRadoni/PlatformIO_Core_Container' \
      org.opencontainers.image.licenses='GNU GPLv3'

# Install system dependencies
RUN apt-get update && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get -y install --no-install-recommends git curl ca-certificates && \
    apt-get -y autoremove && apt-get -y clean && rm -rf /var/lib/apt/lists/*

# Install PlatformIO
RUN export PIP_ROOT_USER_ACTION=ignore && \
    python3 -m pip install --upgrade pip && \
    mkdir -p '/platformio' '/project' && \
    export PLATFORMIO_CORE_DIR='/platformio' && \
    if [ "${PLATFORMIO_VERSION}" = 'latest' ]; then python3 -m pip install platformio; \
    else python3 -m pip install "platformio==${PLATFORMIO_VERSION}"; fi

# Set the default directory
WORKDIR /project

# Set the entry point
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
