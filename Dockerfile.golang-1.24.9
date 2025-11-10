# Committs to master will trigger a push to Dockerhub

# Stage 1: Build Go 1.24.9
FROM buildpack-deps:bullseye-scm AS build-go

ARG GO_VERSION=1.24.9
ENV PATH=/usr/local/go/bin:$PATH

RUN set -eux; \
    arch="$(dpkg --print-architecture)"; \
    case "$arch" in \
        amd64)  url="https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz"; sha256="5b7899591c2dd6e9da1809fde4a2fad842c45d3f6b9deb235ba82216e31e34a6"; ;; \
        arm64)  url="https://dl.google.com/go/go${GO_VERSION}.linux-arm64.tar.gz"; sha256="9aa1243d51d41e2f93e895c89c0a2daf7166768c4a4c3ac79db81029d295a540"; ;; \
        *) echo "unsupported arch: $arch" && exit 1 ;; \
    esac; \
    wget -O go.tgz "$url"; \
    echo "$sha256 *go.tgz" | sha256sum -c -; \
    tar -C /usr/local -xzf go.tgz; \
    rm go.tgz

# Stage 2: Main image
FROM buildpack-deps:bullseye-scm AS base

COPY --from=build-go /usr/local/go /usr/local/go
ENV PATH=/usr/local/go/bin:$PATH
ENV GOPATH=/go
ENV GOTOOLCHAIN=local
ENV DEBIAN_FRONTEND=noninteractive


# Install deps
RUN dpkg --add-architecture arm64                      \
 && dpkg --add-architecture s390x                      \
 && apt-get update                                     \
 && apt-get dist-upgrade -y -q                         \
        autoconf                                       \
        automake                                       \
        autotools-dev                                  \
        bc                                             \
        binfmt-support                                 \
        binutils-multiarch                             \
        binutils-multiarch-dev                         \
        build-essential                                \
        clang                                          \
        git-core                                       \
        crossbuild-essential-arm64                     \
        crossbuild-essential-s390x                     \
        crossbuild-essential-ppc64el                   \
        curl                                           \
        libtool                                        \
        multistrap                                     \
        patch                                          \
        wget                                           \
        xz-utils                                       \
        lsb-release                                    \
        cmake                                          \
        apt-transport-https                            \
        qemu-user-static                               \
        libxml2-dev                                    \
        lzma-dev                                       \
        openssl                                        \
        libssl-dev                                     \
        unzip                                          \
        sudo                                           \
        jq                                             \
        rpm

# install docker cli
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    echo "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && apt-get install -y docker-ce-cli

COPY upgrade-git-on-stretch.sh /
RUN /upgrade-git-on-stretch.sh ${DEB_VERSION}
RUN apt-get -y autoremove && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Used only when building locally, else the latest goreleaser is installed by GHA
RUN curl -fsSL https://github.com/goreleaser/goreleaser/releases/latest/download/goreleaser_Linux_x86_64.tar.gz  | tar -C /usr/bin/ -xzf - goreleaser

# Seems like there's an issue with buildx while running docker cli from within the container - the
# experimental features are not enabled for the  CLI - to mitigate that.
ENV DOCKER_CLI_EXPERIMENTAL=enabled

# pc.sh needs packagecloud
RUN go install github.com/tyklabs/packagecloud@latest

COPY unlock-agent.sh pc.sh /
COPY daemon.json /etc/docker/daemon.json
