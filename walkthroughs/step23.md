#### Deploy your application

In this step we will:

1. Set up an account on [Heroku](http://heroku.com)
2. Download heroku command line tools
3. Create a new application
4. Deploy the application
5. See the app go live on the internet

It is time to deploy the app to a server.

We will be using [Heroku](http://heroku.com) a [Platform as a Service](https://en.wikipedia.org/wiki/Platform_as_a_service) provider that
offers free accounts for developers. The main advantage with using Heroku is that it's extremely easy to start and get your application code deployed.
You don't need to deal with the infrastructure or setting up the server environment. It really just works.

The first thing you need to do is to head over to [http://heroku.com](http://heroku.com) and set up a new account. Make sure that you remember your username and password, as you will need them in a short while.

Next, head over to [toolbelt.heroku.com/](https://toolbelt.heroku.com/) and download the Heroku Toolbelt, a command line interface tool (CLI) for creating and managing Heroku apps.

Once installed, you can use the heroku command from your command shell.
Log in using the email address and password you used when creating your Heroku account (this authentication is required to allow both the heroku and git commands to operate):

```shell
$ heroku login
Enter your Heroku credentials.
Email: <the email you used to set up the Heroku account>
Password: <your Heroku password>
...
```
The next step is to create a Heroku application:

```shell
$ heroku create my-certz # choose your own name
Creating my-certz... done, stack is cedar-14
https://my-certz.herokuapp.com/ | https://git.heroku.com/my-certz.git
Git remote heroku added
```

The `dotenv` gem can couse some problems for us when we deploy to Heroku. We need to make some small changes to the way we require that gem and only load it if we are in `development` and `test`environment.


```ruby
# lib/application.rb

...
if ENV['RACK_ENV'] != 'production'
require 'dotenv'
end

class WorkshopApp < Sinatra::Base
  if ENV['RACK_ENV'] != 'production'
    Dotenv.load
  end
...

```

And also to the `CertificateGenerator` module:

```ruby
# lib/certificate_generator.rb

...
if ENV['RACK_ENV'] != 'production'
  require 'dotenv'
end

module CertificateGenerator
  if ENV['RACK_ENV'] != 'production'
    Dotenv.load
  end
...
```

A rew remote has been added to your git repository. Check it using this command:

```ruby
$ git remote -v
```

Make sure that your latest changes are committed (and preferably pushed up to GitHub):

```shell
# check your status:
$ git status

# add all files to the git staging area:
$ git add .

# make a commit:
git commit -am "latest changes.."

# push up to GitHub
$ git push origin master
```

Okay, now is the time to do an actual deploy:

```shell
$ git push heroku master
```

That's it, the application is now deployed.

If your tests has been passing up until now, the deployment should not be a problem.
You should get a message that the deployment was successful.

Before we visit the URL, we still need to do one more step. Since we are using environmental/config
variables to fetch our AWS credentials, we need to set them.

You can do it on the Heroku dashboards web interface, or you can set them using the CLI
(and we are programmers after all, right? We go with the second option):

```shell
$ heroku config:set S3_BUCKET=< your bucket name >
$ heroku config:set AWS_REGION=< your bucket region >
$ heroku config:set AWS_ACCESS_KEY_ID=< your access key id >
$ heroku config:set AWS_SECRET_ACCESS_KEY=< your secret access key >
$ heroku config:set SERVER_URL=https://my_certz.herokuapp.com/verify/
```

And check these settings with the `heroku config` command:

```shell
heroku config
=== my-certz Config Vars
AWS_ACCESS_KEY_ID:     ---
AWS_REGION:            us-east-1
AWS_SECRET_ACCESS_KEY: ---
DATABASE_URL:          postgres://--.amazonaws.com:5432/--
LANG:                  en_US.UTF-8
RACK_ENV:              production
S3_BUCKET:             certz
SERVER_URL:            https://my-certz.herokuapp.com/verify/
```

Of you want to remove a variable (if you misspell or for some other reason), you can do it using this command:

```shell
$ heroku config:unset <VARIABLE>
```

So, now you are all set. Head over to your browser window and type in `https://my-certs.herokuapp.com` or, if you want to be extra cool, just type:

```shell
$ heroku open
```

[Step 24](step24.md)
