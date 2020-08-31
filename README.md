# **az-toolset**: A Docker image with a set of tools for managing Azure services and AKS from a Linux-environment.

This docker image is suitable for DevOps-work with Azure and k8s.
It includes the following tools:
* kubectl
* az-cli
* sudo

The Dockerfile is configured to always download and install the latest releases of `az-cli` and `kubectl` when building the image. It takes two build arguments:
* `user`: A user `(id=1000)` the container session will run as. The user is created without a password.
* `pw`: If you want to use `sudo` you need to pass this argument with a pre-generated hash that will be inserted into `/etc/shadow`. 
        A password hash can be generated with the following command: `mkpasswd -m sha-512 [password] [salt >= 8 chars]`

A custom prompt is configured to show which k8s-context is currently active.

# Common use cases
A typical scenario would be if you are in a non-GNU Linux environment and wants to harness the advantages of a cli to improve productivity or if you are in a restricted one, for example: 
* You are using (corporate managed) Windows 10 or macOS
* Your workplace doesn't allow you to install custom applications on your workstation, or they are not available in the local repository.

# Installation
1. Clone the repo with `git clone git@github.com:utsamir/az-toolset.git`
2. build the image with custom arguments
   ```
   docker build --rm -t az-toolset:latest -f Dockerfile --build-args user=[user] --build-arg pw=[password hash] .
   ```
3. run in a Docker engine on your favorite platform.
4. Be productive

# Usage
```
$ docker run -ti --rm az-toolset:latest
```
