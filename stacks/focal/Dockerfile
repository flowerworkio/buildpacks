FROM --platform=$BUILDPLATFORM ubuntu:focal AS base
ARG TARGETOS TARGETARCH

ENV CNB_USER_ID=1000
ENV CNB_GROUP_ID=1000
ENV CNB_STACK_ID="io.flowerwork.stacks.focal"
LABEL io.buildpacks.stack.id=$CNB_STACK_ID
LABEL io.buildpacks.stack.maintainer="Flowerwork Inc"
LABEL io.buildpacks.stack.homepage="https://github.com/flowerworkio/buildpacks"
LABEL io.buildpacks.stack.distro.name="Ubuntu"
LABEL io.buildpacks.stack.distro.version="20.04"
LABEL io.buildpacks.stack.description="Flowerwork stack based on Ubuntu 20.04 (focal)"
LABEL io.buildpacks.stack.metadata=""

RUN groupadd cnb --gid ${CNB_GROUP_ID} && \
  useradd --uid ${CNB_USER_ID} --gid ${CNB_GROUP_ID} -m -s /bin/bash cnb

RUN apt-get update && \
  apt-get -y install xz-utils ca-certificates git locales sed && \
  rm -rf /var/lib/apt/lists/* && \
  localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG en_US.utf8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

FROM --platform=$BUILDPLATFORM base AS run
LABEL io.buildpacks.stack.mixins='["xz-utils", "ca-certificates", "git", "locales", "sed"]'

USER ${CNB_USER_ID}:${CNB_GROUP_ID}

FROM --platform=$BUILDPLATFORM base AS build

LABEL io.buildpacks.stack.mixins='["xz-utils", "ca-certificates", "git", "locales", "sed", "build:wget", "build:jq", "build:gawk", "build:curl", "build:grep", "build:yj", "build:build-essential", "build:autoconf", "build:m4", "build:libncurses5-dev", "build:libwxgtk3.0-gtk3-dev", "build:libwxgtk-webview3.0-gtk3-dev", "build:libgl1-mesa-dev", "build:libglu1-mesa-dev", "build:libpng-dev", "build:libssh-dev", "build:unixodbc-dev", "build:xsltproc", "build:fop", "build:libxml2-utils", "build:libncurses-dev", "build:openjdk-11-jdk", "build:python3", "build:g++", "build:make", "build:python3-pip"]'
RUN apt-get update && \
  apt-get -y install wget jq gawk curl grep && \
  rm -rf /var/lib/apt/lists/* && \
  wget https://github.com/sclevine/yj/releases/download/v5.0.0/yj-linux -O /usr/local/bin/yj && \
  chmod +x /usr/local/bin/yj

# Erlang
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
  apt-get -y install build-essential autoconf m4 libncurses5-dev libwxgtk3.0-gtk3-dev libwxgtk-webview3.0-gtk3-dev libgl1-mesa-dev libglu1-mesa-dev libpng-dev libssh-dev unixodbc-dev xsltproc fop libxml2-utils libncurses-dev openjdk-11-jdk

# Nodejs
RUN apt-get update && \
  apt-get -y install python3 g++ make python3-pip

USER ${CNB_USER_ID}:${CNB_GROUP_ID}
