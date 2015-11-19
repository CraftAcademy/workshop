### Dev and setup notes

##### Cloud9

###### Capybara Webkit gem

If you encounter errors while running `bundle install` on C9.
The capybara-webkit gem needs the Qt toolchain (including qmake and the webkit library and header files). You want version 4.8 or later. To install them in Ubuntu release 12.04 LTS "precise pangolin", or later, run:

```shell
 sudo apt-get install libqtwebkit-dev
```



###### PostgreSQL

Start your service [https://docs.c9.io/docs/setting-up-postgresql](https://docs.c9.io/docs/setting-up-postgresql)

```shell
sudo apt-get install postgresql-9.3 postgresql-server-dev-9.3 libpq-dev
```