FROM ruby:2.2.2

RUN \
  apt-get update && apt-get install -y \
  python \
  python-dev \
  python-pip \
  python-virtualenv \
  postgresql-9.4 \
  postgresql-server-dev-9.4 \
  libpq-dev \
  && \
  rm -rf /var/lib/apt/lists/*

# verify gpg and sha256: http://nodejs.org/dist/v0.10.31/SHASUMS256.txt.asc
# gpg: aka "Timothy J Fontaine (Work) <tj.fontaine@joyent.com>"
# gpg: aka "Julien Gilli <jgilli@fastmail.fm>"
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys 7937DFD2AB06298B2293C3187D33FF9D0246406D 114F43EE0176B71C7BC219DD50A3051F888C628D

ENV NODE_VERSION 0.10.40
ENV NPM_VERSION 2.11.3

RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --verify SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-x64.tar.gz\$" SHASUMS256.txt.asc | sha256sum -c - \
  && tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-x64.tar.gz" SHASUMS256.txt.asc \
  && npm install -g npm@"$NPM_VERSION" \
  && npm install -g node-gyp \
  && npm cache clear

RUN apt-get update -qq && apt-get upgrade -y && apt-get install -y \
    vim \
    curl \
    wget \
    git \
    build-essential \
    gcc \
    g++ \
    flex \
    bison \
    gperf \
    perl \
    libsqlite3-dev \
    libfontconfig1-dev \
    libicu-dev \
    libfreetype6 \
    libssl-dev \
    libpng-dev \
    libjpeg-dev \
    libqt5webkit5-dev

ENV PHANTOM_JS_TAG 2.0.0

RUN git clone https://github.com/ariya/phantomjs.git /tmp/phantomjs && \
  cd /tmp/phantomjs && git checkout $PHANTOM_JS_TAG && \
  ./build.sh --confirm && mv bin/phantomjs /usr/local/bin && \
  rm -rf /tmp/phantomjs

WORKDIR /app
ONBUILD ADD . /app

CMD ["bash"]
