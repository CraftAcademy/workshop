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

If you have touble installing the `do-postgres` gem try to run this command and run `bundle install` again after the updates are done.
```shell
sudo apt-get install postgresql-9.3 postgresql-server-dev-9.3 libpq-dev
```

DataMapper setup in `application.rb`:

```ruby

  DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://postgres:postgres@localhost/workshop_#{env}")

```


###### Run on Cloud9

In order to run your application run the following command in the terminal:

```shell
ruby lib/application.rb  -p $PORT -o $IP
```


