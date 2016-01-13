#### Adding a database

The time has come for us to add a database and to start defining our objects. At this point our application will start to grow more complex.

We will:

1. Introduce a new testing framework to test our objects - `RSpec`
2. Introduce a database - `PostgreSQL`
3. Introduce a Object Relation Mapping (ORM) library - `DataMapper`

Add the following gems to your `Gemfile`

```ruby
# Gemfile

gem 'data_mapper'
gem 'dm-postgres-adapter'
gem 'pg'
```

Also, we need to start grouping our gems in that `Gemfile`. Please create the following group:

```ruby
# Gemfile

group :development, :test do

end
```

Add the following gem to that group:
```ruby
# Gemfile

gem 'dm-rspec'
```

The `dm-rspec` gem extends `RSpec` with a set of matchers for DataMapper objects. Having access to those matchers will make our testing much easier.

Also, I would like you to move all gems that we use for testing purposes to the `:development, :test` group.

Your `Gemfile` should look something like this:

```ruby
# Gemfile

source 'https://rubygems.org'

gem 'cucumber'
  gem 'sinatra'
  gem 'padrino', '~> 0.13.0'
  gem 'data_mapper'
  gem 'dm-postgres-adapter'
  gem 'pg'

group :development, :test do
  gem 'rspec'
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'dm-rspec'
end
```

Don't forget to do `bundle install` once you have made all the changes.

In terminal run the following command:

```shell
$ rspec --init
```

You should see the following output:

```shell
create   .rspec
create   spec/spec_helper.rb
```

Now, open `.rspec` file (it is located in your main project folder but it is a hidden file, so your text editor might not show it) and modify it so that the first line is set to:

```
--format documentation
...
```

Now, in your terminal, type in `rspec` and hit enter.

The output you see should be something like:

```shell
No examples found.

Finished in 0.00023 seconds (files took 0.5029 seconds to load)
0 examples, 0 failures
```

We are not quite done yet. Sorry. :-(

I want you to open the `spec/spec_helper.rb` file. You'll se a lot of lines. Most of them are not needed so I would like you to delete all lines that begin with the `#`sign.
These are comments and we don't need them - for now, they are just a distraction. .

When you are done you should see something like this:

```ruby
# spec/spec_helper.rb

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
```

Not so bad, ey?

Alright, we need to add some of the libraries/gems we want to use in our `spec_helper`. Modify your file to include:

```ruby
# spec/spec_helper.rb

ENV['RACK_ENV'] = 'test'

require File.join(File.dirname(__FILE__), '..', 'lib/application.rb')
require 'capybara'
require 'capybara/rspec'
require 'rspec'
require 'dm-rspec'

```

...and in the `RSpec.configure` block, add:

```ruby
# spec/spec_helper.rb

...
config.include Capybara::DSL
config.include DataMapper::Matchers
...
```

Now, run `rspec` again and you should receive no errors.

```shell
No examples found.

Finished in 0.00032 seconds (files took 0.72891 seconds to load)
0 examples, 0 failures
```

Okay, this means that you have successfully added and set up `RSpec` as a testing framework. The next step will be to start writing some tests for our `Course` class.

#### More on databases

A database is an organized collection of related data, typically stored on disk, and accessible by possibly many concurrent users. Databases are often separated into application areas. For example, one database may contain Product information data; another may contain sales data; another may contain accounting data; and so on.

More on [databases](https://en.wikipedia.org/wiki/Database) and [Relational Databases](https://en.wikipedia.org/wiki/Relational_database)
