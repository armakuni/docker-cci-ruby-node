# Dockerfile - Ruby + Node + PhantomJS

This repository contains a Dockerfile of Ruby, nodejs and npm for Docker's automated build published to the public Docker Hub Registry.

## What's included
- Ruby 2.2.2
- Nodejs (latest)
- npm
- PhantomJS 1.9.7

### Installation

1. Install [Docker](https://www.docker.com/).
2. Download [automated build](https://hub-beta.docker.com/r/armakuni/docker-cci-ruby-node-automated/) from public [Docker Hub Registry](https://registry.hub.docker.com/): `docker pull armakuni/docker-cci-ruby-node-automated`

   (alternatively, you can build an image from Dockerfile: `docker build -t="armakuni/docker-cci-ruby-node" github.com/armakuni/docker-cci-ruby-node`)


## Upload images to docker

```bash
docker login
docker tag <container> comicrelief/docker-cci-ruby-node:latest
docker push comicrelief/docker-cci-ruby-node
```
