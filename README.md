# Dockerfile - Ruby + Node

This repository contains a Dockerfile of Ruby, nodejs and npm for Docker's automated build published to the public Docker Hub Registry.

## What's included
- Ruby 2.2.2
- Nodejs (latest)
- npm
- PhantomJS 2

### Installation

1. Install [Docker](https://www.docker.com/).
2. Download [automated build](https://registry.hub.docker.com/u/armakuni/docker-cci-ruby-node/) from public [Docker Hub Registry](https://registry.hub.docker.com/): `docker pull armakuni/docker-cci-ruby-node`

   (alternatively, you can build an image from Dockerfile: `docker build -t="armakuni/docker-cci-ruby-node" github.com/armakuni/docker-cci-ruby-node`)

### Usage

    docker run -it --rm armakuni/docker-cci-ruby-node

#### Run `ruby`

    docker run -it --rm armakuni/docker-cci-ruby-node ruby

#### Run `node`

    docker run -it --rm armakuni/docker-cci-ruby-node node
