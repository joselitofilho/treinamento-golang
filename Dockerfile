ARG GO_VERSION=1.16.5
FROM golang:${GO_VERSION}

ARG HP_GHE_TOKEN
RUN if [ -z ${HP_GHE_TOKEN} ]; then echo "ERROR: You need pass a 'HP_GHE_TOKEN' as argument of 'docker build' command"; exit 1; fi
ENV GOPRIVATE=github.azc.ext.hp.com

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils 2>&1

# Verify git, process tools, lsb-release (common in install instructions for CLIs) installed.
RUN apt-get -y install curl git iproute2 lsb-release procps vim wget

# Install Go tools.
RUN apt-get update \
    # Install other tools.
    && GO111MODULE=on go get golang.org/x/tools/gopls@latest \
    && go get -u -v \
        github.com/mdempsky/gocode \
        github.com/uudashr/gopkgs/v2/cmd/gopkgs \
        github.com/ramya-rao-a/go-outline \
        github.com/acroca/go-symbols \
        golang.org/x/tools/cmd/guru \
        golang.org/x/tools/cmd/gorename \
        github.com/go-delve/delve/cmd/dlv \
        github.com/stamblerre/gocode \
        github.com/rogpeppe/godef \
        golang.org/x/tools/cmd/goimports \
        golang.org/x/lint/golint 2>&1 \
        github.com/sqs/goreturns \
        github.com/jnewmano/grpc-json-proxy \
    # Clean up.
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src

# Get internal dependecies
RUN git config --global url."https://${HP_GHE_TOKEN}:x-oauth-basic@github.azc.ext.hp.com/".insteadOf "https://github.azc.ext.hp.com/"

# Revert workaround at top layer.
ENV DEBIAN_FRONTEND=dialog