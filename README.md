# Backblaze b2 docker image

Based on alpine running the b2 command from [Backblaze b2](https://www.backblaze.com/b2/docs/quick_command_line.html).

# Building

```
$ docker build -t super-b2 .
```

# Environment Variables

Docker entrypoint expects the following variables:

* KEY_ID = Application Key ID
* APPLICATION_KEY = Application Key

# Usage

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

