# Docker Exherbo CI Rust

A Docker image based on [Exherbo Linux](https://exherbo.org/) providing a ready-to-use CI environment with the Rust toolchain pre-installed.

## Overview

This image extends the official [`exherbo/exherbo_ci`](https://hub.docker.com/r/exherbo/exherbo_ci) base image by adding the Rust compiler and toolchain via Exherbo's native package manager ([Paludis](https://paludis.exherbo.org/)). It is designed to be used in CI pipelines to build and test Rust projects on Exherbo without needing to install the toolchain on every run.

## What's Included

- **Base**: `exherbo/exherbo_ci:latest`
- **Rust**: `dev-lang/rust` from the Exherbo repository
- **Build parallelism**: Automatically configured to match available CPU cores during image build

## Usage

### Pull the image

```bash
docker pull <registry>/docker-exherbo-ci-rust:latest
```

### Build locally

```bash
docker build -t exherbo-ci-rust .
```
