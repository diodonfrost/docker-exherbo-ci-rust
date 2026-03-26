# Docker Exherbo CI Rust

image := "exherbo-ci-rust"
registry := "ghcr.io/diodonfrost"

build:
    docker build -t {{image}}:latest .

push: build
    docker tag {{image}}:latest {{registry}}/{{image}}:latest
    docker push {{registry}}/{{image}}:latest

shell:
    docker run --rm -it {{image}}:latest /bin/bash

rust-version:
    docker run --rm {{image}}:latest rustc --version

clean:
    docker rmi {{image}}:latest
