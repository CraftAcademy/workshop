Let's go ahead and create an application. We will be using Sinatra as a framework for our application. Thet means that we will be using Ruby as a
programming language. You can read more about Sinatra at....


There are several ways to create a new Sinatra application but we will make use of a
script that creates an app for us AND configures it (at least partially) for use with Cucumber and another testing framework called RSpec (more on that later.

In you terminal, install the following gem:

```
gem install cucumber-sinatra
```

after the installation is complete, run:

```
cucumber-sinatra init --app WorkshopApp application.rb
```

There wil be a lot of new files created and we will go over all of them in a while. For now, I want you to
open up your `Gemfile` and add:

```
gem 'rspec'
```

Bundle and run `cucumber` again.

The first step (in both scenarios) is passing! That is a really good sign!





