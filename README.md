# Fano Web Framework

Pascal web application framework

## Requirement

- [Free Pascal](https://www.freepascal.org/) >= 3.0
- Web Server (Apache, nginx)

## Installation

Fano is standalone library and basically is not very useful on its own
because it depends on an application to bootstrap.

### From Sample Application

You may clone [Fano App](https://github.com/zamronypj/fano-app) repository as
base application skeleton.

When you clone [Fano App](https://github.com/zamronypj/fano-app) repository, it automatically pulls this repository as its submodule which then ready to be compiled and run.

Follow the instruction [Fano App](https://github.com/zamronypj/fano-app) repository for installation.

### From Scratch

If you decide to start from scratch,

    $ mkdir my-cool-app
    $ cd my-cool-app
    $ git init
    $ git submodule add git@github.com:zamronypj/fano.git

If you do not use SSH, then you can use HTTPS

    $ git submodule add https://github.com/zamronypj/fano.git

This command will pull Fano Web Framework repository into `fano` directory inside
your `my-cool-app` directory.
