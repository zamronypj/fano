# Fano Web Framework

Pascal web application framework

## Requirement

- [FreePascal](https://www.freepascal.org/) >= 3.0
- Web Server (Apache, nginx)

## Installation

### Build

Clone this repository and copy `*.cfg.sample` to `*.cfg`.
Make adjustment as you need in `build.cfg`, `build.prod.cfg`, `build.dev.cfg`
and run `build.sh` shell script.

Also copy `app/config/config.json.sample` to `app/config/config.json`.

    $ cp app/config/config.json.sample app/config/config.json
    $ cp build.prod.cfg.sample build.prod.cfg
    $ cp build.dev.cfg.sample build.dev.cfg
    $ cp build.cfg.sample build.cfg
    $ ./build.sh

`config.setup.sh` shell script is provided to simplify copying those
configuration files. Following shell command is similar to command above.

    $ ./config.setup.sh
    $ ./build.sh

By default, it will output binary executable in `app/public` directory.

### Build for different environment

To build for different environment, set `BUILD_TYPE` environment variable.

#### Build for production environment

    $ BUILD_TYPE=prod ./build.sh

Build process will use compiler configuration defined in `fpc.cfg`, `build.cfg` and `build.prod.cfg`.

#### Build for development environment

    $ BUILD_TYPE=dev ./build.sh

Build process will use compiler configuration defined in `fpc.cfg`, `build.cfg` and `build.dev.cfg`.

If `BUILD_TYPE` environment variable is not set, production environment will be assumed.

## Change Fano Web Framework Directory

By default, Fano web framework units reside in `fano` directory. If you choose
to move it to different location, you can set `FANO_DIR` environment variable

    $ FANO_DIR=/path/to/fano ./build.sh

## Change executable output directory

Compilation will output executable to directory defined in `EXEC_OUTPUT_DIR`
environment variable. By default is `app/public` directory.

    $ EXEC_OUTPUT_DIR=/path/to/public/dir ./build.sh

## Change executable name

Compilation will use executable filename as defined in `EXEC_OUTPUT_NAME`
environment variable. By default is `app.cgi` filename.

    $ EXEC_OUTPUT_NAME=server.cgi ./build.sh

## Run

### Run with a webserver

Setup a virtual host. Please consult documentation of web server you use.

For example on Apache,

```
<VirtualHost *:80>
     ServerName www.example.com
     DocumentRoot /home/example/app/public

     <Directory "/home/example/app/public">
         Options +ExecCGI
         AllowOverride FileInfo
         Require all granted
         DirectoryIndex app.cgi
         AddHandler cgi-script .cgi
     </Directory>
</VirtualHost>
```
On Apache, you will need to enable CGI module, such as `mod_cgi` or `mod_cgid`. If CGI module not loaded, above virtual host will cause `app.cgi` is downloaded instead of executed.

For example, on Debian, this will enable `mod_cgi` module.

```
$ sudo a2enmod cgi
$ sudo systemctl restart apache2
```

Depending on your server setup, for example, if  you use `.htaccess`, add following code:

```
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteRule ^(.*)$ app.cgi [L]
</IfModule>
```

Which basically tells Apache to serve existing files/directories directly. For any non-existing files/directories, pass them to our application.

### Simulate run on command line

```
$ cd app/public
$ REQUEST_METHOD=GET \
  REQUEST_URI=/test/test \
  SERVER_NAME=juhara.com \
  ./app.cgi
```

`simulate.run.sh` is bash script that can be used to simplify simulating run
application in shell.

    $ ./simulate.run.sh

or to change route to access, set `REQUEST_URI` variable.

    $ REQUEST_URI=/test/test ./simulate.run.sh

This is similar to simulating browser requesting this page,for example,

    $ wget -O- http://[your fano app hostname]/test/test

However, running using `simulate.run.sh` allows you to view output of heaptrc
unit for detecting memory leak (if you enable `-gh` switch in `build.dev.cfg`).

## Known Issues

### Issue with GNU Linker

When running `build.sh` script, you may encounter following warning:

```
/usr/bin/ld: warning: app/public/link.res contains output sections; did you forget -T?
```

This is known issue between FreePascal and GNU Linker.
There is few workaround such as adding `-k` compiler options that will be passed to GNU Linker.

However this warning is minor and can be ignored as it does not affect output executable.

### Issue with unsynchronized compiled unit with unit source

Sometime FreePascal can not compile your code because, for example, you deleted a
unit source code (.pas) but old generated unit (.ppu, .o, .a files) still there. Solution is to remove those files.

By default, generated compiled unit is in `bin/unit` directory.
But do not delete `README.md` file inside this directory as it is not being ignored by git.

```
$ rm bin/unit/*.ppu
$ rm bin/unit/*.o
$ rm bin/unit/*.rsj
$ rm bin/unit/*.a
```

Following shell command will remove all files inside `bin/unit` directory except
`README.md` file.

    $ find bin/unit ! -name 'README.md' -type f -exec rm -f {} +

`clear.compiled.units.sh` script is provided to simplify this task.
