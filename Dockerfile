#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#

#
# Dockerfile for guacamole-server
#

# The Debian image that should be used as the basis for the guacd image
ARG DEBIAN_BASE_IMAGE=buster-slim

# Use Debian as base for the build
FROM debian:${DEBIAN_BASE_IMAGE} AS builder

#
# The Debian repository that should be preferred for dependencies (this will be
# added to /etc/apt/sources.list if not already present)
#
# NOTE: Due to limitations of the Docker image build process, this value is
# duplicated in an ARG in the second stage of the build.
#
ARG DEBIAN_RELEASE=buster-backports

# Add repository for specified Debian release if not already present in
# sources.list
RUN grep " ${DEBIAN_RELEASE} " /etc/apt/sources.list || echo >> /etc/apt/sources.list \
    "deb http://deb.debian.org/debian ${DEBIAN_RELEASE} main contrib non-free"

#
# Base directory for installed build artifacts.
#
# NOTE: Due to limitations of the Docker image build process, this value is
# duplicated in an ARG in the second stage of the build.
#
ARG PREFIX_DIR=/usr/local/guacamole

# Build arguments
ARG BUILD_DIR=/tmp/guacd-docker-BUILD
ARG BUILD_DEPENDENCIES="              \
        autoconf                      \
        automake                      \
        freerdp2-dev                  \
        gcc                           \
        libcairo2-dev                 \
        libgcrypt-dev                 \
        libjpeg62-turbo-dev           \
        libavcodec-dev 				  \
        libavformat-dev               \
        libavutil-dev	              \
        libswscale-dev				  \
        libossp-uuid-dev              \
        libpango1.0-dev               \
        libpulse-dev                  \
        libssh2-1-dev                 \
        libssl-dev                    \
        libtelnet-dev                 \
        libtool                       \
        libvncserver-dev              \
        libwebsockets-dev             \
        libwebp-dev                   \
        make"

# Do not require interaction during build
ARG DEBIAN_FRONTEND=noninteractive

# Bring build environment up to date and install build dependencies
RUN apt-get update                                              && \
    apt-get install -t ${DEBIAN_RELEASE} -y $BUILD_DEPENDENCIES git && \
    apt reinstall libcurl3-gnutls/stable && \
    rm -rf /var/lib/apt/lists/*

RUN git clone --branch 1.3.0 https://github.com/apache/guacamole-server.git "$BUILD_DIR"

RUN cd "$BUILD_DIR" && ./configure --with-init-dir="$PREFIX_DIR" && make && make install

