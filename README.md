# Backblaze b2 Utility

This repo contains scripts and Docker Images for uploading files to [Backblaze b2](https://www.backblaze.com/b2/cloud-storage.html).

A Docker Image is created from this repo. The most recent version lives on [Dockerhub](https://hub.docker.com/repository/docker/hipposareevil/b2).

# Upload Script

The *upload_to_b2.sh* script is used to upload files from a local directory to a b2 bucket. Documentation in file.

This requires the *jq* script to exist locally.


# Docker Image

Alpine based image containing the [Backblaze b2](https://www.backblaze.com/b2/docs/quick_command_line.html) command.


## Building

```
$ docker build -t b2-super-funk .
...
$
```

## Environment Variables

Tje Docker entrypoint expects the following variables:

* KEY_ID = Application Key ID
* APPLICATION_KEY = Application Key

## Usage

```
docker run --rm \
       -v $PWD:/scratch \
       -e KEY_ID=${YOUR_KEY} \
       -e APPLICATION_KEY=${YOUR_APPLICATION_KEY} \
       hipposareevil/b2 "$@"
```

or as a function in your .zshrc

```
b2() {
  docker run --rm \
       -v $PWD:/scratch \
       -e KEY_ID=${YOUR_KEY} \
       -e APPLICATION_KEY=${YOUR_APPLICATION_KEY} \
       hipposareevil/b2 "$@"
}

$ b2 --help 2>&1| head -2
Using https://api.backblazeb2.com
This program provides command-line access to the B2 service.
$

```


