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

### From Scratch With git submodule

If you decide to start from scratch,

    $ mkdir my-cool-app
    $ cd my-cool-app
    $ git init
    $ git submodule add git@github.com:zamronypj/fano.git

If you do not use SSH, then you can use HTTPS

    $ git submodule add https://github.com/zamronypj/fano.git

This command will pull Fano Web Framework repository into `fano` directory inside
your `my-cool-app` directory.

### From Scratch Without git submodule

Using `git submodule` requires you to have copy of Fano respository locked to specific commit in your
application project directory structure. If you have multiple applications that uses Fano, each of them will have their own copy of Fano respository that may locked to different commit version. Updating Fano repository in one application
does not affect other applications. It is roughly similar to how Composer (PHP)
or NPM (Node.js) works.

If you do not want this code duplication, you may clone Fano repository as usual
in a directory, then, in your each application project configuration, you tell
Free Pascal, directory where to search Fano units.

This approach, however, has disadvantage. When you update your Fano repository,
all your applications that depends on Fano will be affected. If newer version of Fano repository introduces breaking changes, application that requires older version of Fano repository may fail.

