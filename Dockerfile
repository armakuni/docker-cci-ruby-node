FROM ruby:2.2.2

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r postgres && useradd -r -g postgres postgres

# grab gosu for easy step-down from root
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
  && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
  && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
  && gpg --verify /usr/local/bin/gosu.asc \
  && rm /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu \
  && apt-get purge -y --auto-remove ca-certificates wget

# make the "en_US.UTF-8" locale so postgres will be utf-8 enabled by default
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
  && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

RUN mkdir /docker-entrypoint-initdb.d

RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8

ENV PG_MAJOR 9.3
ENV PG_VERSION 9.3

RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main' $PG_MAJOR > /etc/apt/sources.list.d/pgdg.list

RUN apt-get update \
  && apt-get install -y postgresql-common \
  && sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf \
  && apt-get install -y \
    postgresql-$PG_MAJOR \
    postgresql-contrib-$PG_MAJOR \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/postgresql && chown -R postgres /var/run/postgresql

ENV PATH /usr/lib/postgresql/$PG_MAJOR/bin:$PATH
ENV PGDATA /var/lib/postgresql/data
VOLUME /var/lib/postgresql/data

COPY docker-entrypoint.sh /

RUN \
  apt-get update && apt-get install -y \
  python \
  python-dev \
  python-pip \
  python-virtualenv \
  libpq-dev \
  && \
  rm -rf /var/lib/apt/lists/*

# verify gpg and sha256: http://nodejs.org/dist/v0.10.31/SHASUMS256.txt.asc
# gpg: aka "Timothy J Fontaine (Work) <tj.fontaine@joyent.com>"
# gpg: aka "Julien Gilli <jgilli@fastmail.fm>"
# RUN gpg --keyserver pool.sks-keyservers.net --recv-keys 7937DFD2AB06298B2293C3187D33FF9D0246406D 114F43EE0176B71C7BC219DD50A3051F888C628D

# ENV NODE_VERSION 0.10.40
# ENV NPM_VERSION 2.11.3

# RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
#   && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
#   && gpg --verify SHASUMS256.txt.asc \
#   && grep " node-v$NODE_VERSION-linux-x64.tar.gz\$" SHASUMS256.txt.asc | sha256sum -c - \
#   && tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
#   && rm "node-v$NODE_VERSION-linux-x64.tar.gz" SHASUMS256.txt.asc \
#   && npm install -g npm@"$NPM_VERSION" \
#   && npm install -g node-gyp \
#   && npm cache clear



RUN mkdir -p /data/db
RUN mkdir -p /var/log/supervisor

RUN apt-get update -qq && apt-get upgrade -y && apt-get install -y \
    apt-utils \
    bison \
    build-essential \
    curl \
    flex \
    g++ \
    gcc \
    git \
    gperf \
    jython \
    libfontconfig1-dev \
    libfreetype6 \
    libicu-dev \
    libjpeg-dev \
    libpng-dev \
    libqt5webkit5-dev \
    libreadline6 \
    libreadline6-dev \
    libsqlite3-dev \
    libssl-dev \
    libxml2-dev \
    libxslt-dev \
    libyaml-dev \
    openssl \
    parallel \
    perl \
    rsync \
    ruby \
    ruby-dev \
    sqlite3 \
    unzip \
    vim \
    wget \
    zip \
    zlib1g-dev \
    zlibc \
    supervisor \
    redis-server \
    nodejs \
    npm

ENV PHANTOM_JS_TAG 2.0.0

RUN git clone https://github.com/ariya/phantomjs.git /tmp/phantomjs && \
  cd /tmp/phantomjs && git checkout $PHANTOM_JS_TAG && \
  ./build.sh --confirm && mv bin/phantomjs /usr/local/bin && \
  rm -rf /tmp/phantomjs

COPY redis.conf /redis.conf

COPY Gemfile /Gemfile
RUN bundle

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
RUN echo 'deb http://downloads-distro.mongodb.org/repo/debian-sysvinit dist 10gen' | tee /etc/apt/sources.list.d/mongodb.list

RUN apt-get install -y adduser mongodb-server mongodb-shell

RUN wget -O cf.tgz "https://cli.run.pivotal.io/stable?release=linux64-binary&source=github" && \
    tar xvf cf.tgz && \
    mv cf /usr/local/bin/ && \
    rm cf.tgz

RUN wget https://s3.amazonaws.com/bosh-init-artifacts/bosh-init-0.0.81-linux-amd64 \
  && chmod +x ./bosh-init-* \
  && mv ./bosh-init-* /usr/local/bin/bosh-init \
  && wget https://releases.hashicorp.com/terraform/0.6.8/terraform_0.6.8_linux_amd64.zip \
  && unzip terraform_0.6.8_linux_amd64.zip \
  && rm terraform_0.6.8_linux_amd64.zip \
  && chmod +x terraform* \
  && mv terraform* /usr/local/bin/

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

WORKDIR /app
ONBUILD ADD . /app

CMD /usr/bin/supervisord && bash
