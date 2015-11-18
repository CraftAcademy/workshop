Let's go ahead and create an application. We will be using Sinatra as a framework for our application. That means that we will be using Ruby as a
programming language. You can read more about [Sinatra here](http://www.sinatrarb.com/)

There are several ways to create a new Sinatra application but we will make use of a
script that creates an app for us AND configures it (at least partially) for use with Cucumber and another testing framework called RSpec (more on that later.

Open your `Gemfile` and add the following lines:
```ruby
gem 'sinatra'
gem 'cucumber-sinatra'
```

Then run `bundle install` to install the new gem we just added.

after the installation is complete, run:

```shell
$ cucumber-sinatra init --app WorkshopApp application.rb
```

There will be a lot of new files created and we will go over all of them in a while. For now, I want you to open up your `Gemfile` again and add:

```ruby
gem 'rspec'
```

Run `bundle install` to install new gem then run `cucumber` again.

The first step (in both scenarios) is passing! That is a really good sign!

```shell
2 scenarios (2 undefined)
14 steps (5 skipped, 7 undefined, 2 passed)
0m0.045s
```

Before we move to the next step we need to re-arrange a few things:
1. Create a `lib` folder
  ```shell
  $ mkdir lib
  ```

2. Move `application.rb` to the newly created `lib` folder
  ```shell
  $ mv application.rb lib
  ```

3. Update path to `application.rb` in `features/support/env.rb`

  Open the file with your text editor. At the top of that file you'll should see the following line

  ```ruby
  require File.join(File.dirname(__FILE__), '..', '..', 'application.rb')
  ```

  Change it to look like the following:
  ```ruby
  require File.join(File.dirname(__FILE__), '..', '..', 'lib/application.rb')
  ```

4. Run `cucumber` again to make sure the 2 steps from earlier on are still passing :-)


Great! That's all for now. Let's move to the next step where we'll get another scenario to pass.

[Step 3](step3.md)
