FROM comicrelief/docker-cci-ruby-node:latest

RUN apt-get update -qq && apt-get upgrade -y && apt-get install -y \
  build-essential \
  zlibc \
  zlib1g-dev \
  ruby \
  ruby-dev \
  openssl \
  libxslt-dev \
  libxml2-dev \
  libssl-dev \
  libreadline6 \
  libreadline6-dev \
  libyaml-dev \
  libsqlite3-dev \
  sqlite3 \
  && wget https://s3.amazonaws.com/bosh-init-artifacts/bosh-init-0.0.81-linux-amd64 \
  && chmod +x ./bosh-init-* \
  && mv ./bosh-init-* /usr/local/bin/bosh-init \
