from ubuntu:focal as base

ENV CNB_USER_ID=1000
ENV CNB_GROUP_ID=1000
ENV CNB_STACK_ID="io.flowerwork.stacks.focal"
LABEL io.buildpacks.stack.id="io.flowerwork.stacks.focal"

RUN groupadd cnb --gid ${CNB_GROUP_ID} && \
  useradd --uid ${CNB_USER_ID} --gid ${CNB_GROUP_ID} -m -s /bin/bash cnb

RUN apt-get update && \
  apt-get -y install xz-utils ca-certificates git && \
  rm -rf /var/lib/apt/lists/*

FROM base as run

USER ${CNB_USER_ID}:${CNB_GROUP_ID}

FROM base as build

RUN apt-get update && \
  apt-get -y install wget jq gawk sed curl grep

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
  apt-get -y install build-essential autoconf m4 libncurses5-dev libwxgtk3.0-gtk3-dev libwxgtk-webview3.0-gtk3-dev libgl1-mesa-dev libglu1-mesa-dev libpng-dev libssh-dev unixodbc-dev xsltproc fop libxml2-utils libncurses-dev openjdk-11-jdk

USER ${CNB_USER_ID}:${CNB_GROUP_ID}
