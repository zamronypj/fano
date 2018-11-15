# Fano Web Framework

Pascal web application framework

## Requirement

- [Free Pascal](https://www.freepascal.org/) >= 3.0
- Web Server (Apache, nginx)

## Installation

Fano is standalone library, and basically, is not very useful on its own,
because it depends on an application to bootstrap.

### Install from sample application

You may clone [Fano App](https://github.com/fanoframework/fano-app) repository as
base application skeleton.

When you clone [Fano App](https://github.com/fanoframework/fano-app) repository,
it pulls this repository as its submodule automatically. After that, it is ready to be compiled and run.

Follow the instruction [Fano App](https://github.com/fanoframework/fano-app) repository for installation.

Other available sample application:

- [Fano Api](https://github.com/fanoframework/fano-api), base REST API web application skeleton.
- [Fano App Middleware](https://github.com/fanoframework/fano-app-middleware), base REST API web application skeleton with middleware support.

### Install from Fano Command Line tool

[Fano Cli](https://github.com/fanoframework/fano-cli) is command line tool intended
for [scaffolding web application](https://fanoframework.github.io/scaffolding-with-fano-cli/) using Fano, creating controllers, views, etc . It is similar how Laravel Artisan tool works.

    $ fanocli --create-project=my-cool-app
    $ cd my-cool-app
    $ fanocli --create-controller=Hello

While you can create project structure and initialize Fano repository, create controller, the tools is still in development.

### Install from scratch with Git submodule

If you decide to start from scratch,

    $ mkdir my-cool-app
    $ cd my-cool-app
    $ git init
    $ git submodule add git@github.com:fanoframework/fano.git

If you do not use SSH, then you can use HTTPS

    $ git submodule add https://github.com/fanoframework/fano.git

This command will pull Fano Web Framework repository into `fano` directory inside
your `my-cool-app` directory.

### Install from scratch without Git submodule

Using `git submodule` requires you to have copy of Fano respository locked to specific commit in your application project directory structure. If you have multiple applications that uses Fano, each of them will have their own copy of Fano respository that may be locked to different commit version. Updating Fano repository in one application does not affect other applications. It is roughly similar to how Composer (PHP) or NPM (Node.js) works.

If you do not want this code duplication, you may clone Fano repository as usual
in a directory, then, in your each application project configuration, you tell
Free Pascal, directory where to search Fano units.

This approach, however, has disadvantage. When you update your Fano repository,
all your applications that depends on Fano will be affected. If newer version of Fano repository introduces breaking changes, application that requires older version of Fano repository may fail.
