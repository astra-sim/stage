FROM python:3.12-slim AS base

ARG HOST_UID=1000
ARG HOST_GID=1000

RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        build-essential \
        sudo \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ARG REPO_URL=https://github.com/astra-sim/stage
ARG REPO_COMMIT=main

RUN set -eux; \
    if ! getent group "${HOST_GID}" >/dev/null; then \
       groupadd -g "${HOST_GID}" appuser; \
    fi; \
    useradd -m -u ${HOST_UID} -g ${HOST_GID} -s /bin/bash appuser && \
    echo "appuser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-appuser && \
    chmod 0440 /etc/sudoers.d/90-appuser

USER appuser
WORKDIR /home/appuser

RUN git clone "$REPO_URL" stage_repo && \
    cd stage_repo && \
    git checkout "$REPO_COMMIT"

WORKDIR /home/appuser/stage_repo
RUN python -m pip install --user -r ./requirements.txt

WORKDIR /home/appuser
ENTRYPOINT ["/usr/bin/bash"]

