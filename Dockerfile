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

RUN \
  cd /tmp && \
  wget http://nodejs.org/dist/node-latest.tar.gz && \
  tar xvzf node-latest.tar.gz && \
  rm -f node-latest.tar.gz && \
  cd node-v* && \
  ./configure && \
  CXX="g++ -Wno-unused-local-typedefs" make && \
  CXX="g++ -Wno-unused-local-typedefs" make install && \
  cd /tmp && \
  rm -rf /tmp/node-v* && \
  npm install -g npm && \
  echo '\n# Node.js\nexport PATH="node_modules/.bin:$PATH"' >> /root/.bashrc

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
