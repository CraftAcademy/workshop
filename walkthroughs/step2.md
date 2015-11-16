Let's go ahead and create an application. We will be using Sinatra as a framework for our application. That means that we will be using Ruby as a
programming language. You can read more about [Sinatra here](http://www.sinatrarb.com/)

There are several ways to create a new Sinatra application but we will make use of a
script that creates an app for us AND configures it (at least partially) for use with Cucumber and another testing framework called RSpec (more on that later.

Open your `Gemfile` and add the following lines:
```
gem 'sinatra'
gem 'cucumber-sinatra'
```

Then run `bundle install` to install the new gem we just added.

after the installation is complete, run:

```
cucumber-sinatra init --app WorkshopApp application.rb
```

There will be a lot of new files created and we will go over all of them in a while. For now, I want you to open up your `Gemfile` again and add:

```
gem 'rspec'
```

Run `bundle install` to install new gem then run `cucumber` again.

The first step (in both scenarios) is passing! That is a really good sign!

```
2 scenarios (2 undefined)
14 steps (5 skipped, 7 undefined, 2 passed)
0m0.045s
```
