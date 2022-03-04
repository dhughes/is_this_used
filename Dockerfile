FROM ruby:2.7.5-slim-bullseye

WORKDIR /app

RUN apt-get update -qq \
  && apt-get install --no-install-recommends -y \
    less \
    nano \
    mariadb-client-10.5 \
    libmariadb-dev-compat \
    libmariadb-dev \
    build-essential \
    git \
    shared-mime-info

ARG BUNDLER_VERSION=2.1.4

ENV BUNDLE_PATH /bundle
ENV GEM_HOME /bundle

RUN gem update --system \
    && gem install bundler -v ${BUNDLER_VERSION}

CMD /bin/bash
