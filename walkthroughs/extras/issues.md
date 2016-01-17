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

START THE POSTGRESQL SERVICE
```shell
sudo service postgresql start
```



Create a password for the `postgres` user
```shell
sudo sudo -u postgres psql
postgres-# \password postgres
Enter new password: postgres
```

DataMapper setup in `application.rb`:

```ruby
  DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://postgres:postgres@localhost/workshop_#{env}")

```

##### ImageMagick
If you have problems with installing `rmagick` you need to run this
```shell
$ sudo apt-get install imagemagick libmagickwand-dev
```


###### Run on Cloud9

In order to run your application run the following command in the terminal:

```shell
ruby lib/application.rb  -p $PORT -o $IP
```

RVM installation. 

Installing RVM on C9 is straight forward until we get to sourcing the RVM init file. 

Is switching to `su` a solution?

```
$ sudo su
```

```shell
$ source ~/.rvm/scripts/rvm
Error: /proc must be mounted
  To mount /proc at boot you need an /etc/fstab line like:
      proc   /proc   proc    defaults
  In the meantime, run "mount proc /proc -t proc"
```

But when we run this we get
```shell
$ mount proc /proc -t proc
mount: only root can do that
```



###### Squashing commits
There are several methods you can use to
Reset the current branch to the commit just before the last 5:

```shell
$ git reset --hard HEAD~5
```

HEAD@{1} is where the branch was just before the previous command.

This command sets the state of the index to be as it would just after a merge from that commit:

```shell
$ git merge --squash HEAD@{1}
```
Commit those squashed changes.  The commit message will be helpfully populated with the commit messages of all the squashed commits:


```shell
$ git commit
```

Or give the new commit a custom message

```shell
$ git commit -m "your message"
```


