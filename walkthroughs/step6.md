##### Adding a database

The time has come for us to add a dtabase and to start defining our objects. At this point our application will start to grow more complex.

We will:
1. Introduce a new testing framework to test our objects - RSpec
2. Introduce a database - PostgreSQL
3. Intreoduce a Object Relation Mapping library - Datamapper

Add the following gems to your `Gemlile`

```ruby
gem 'data_mapper'
gem 'dm-postgres-adapter'
gem 'pg'
```

Also, we need to tart grouping our gems in that Gemfile. Please create the following group:

```ruby
group :development, :test do

end
```

and add:
```ruby
gem 'dm-rspec'
```
to that group. The 'dm-rspec' gem extends RSpec with a set of matchers for DataMapper objects that will make our testing much easier.

Also, I would like you to move all gems that we use for testing purposes to the `:development, :test` group.

Your `Gemfile` should look something like this:

```ruby
source 'https://rubygems.org'

gem 'cucumber'
  gem 'sinatra'
  gem 'padrino'
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

Don't forget to do `bundle install` once you have made all tha changes.

In terminal run the following command:

```
rspec --init
```

You should see the following output:

```
  create   .rspec
  create   spec/spec_helper.rb
```

Now, open `.rspec` file (it is located in  your main project folder but it is a hidden file, so your text editor might not show it) and modify it so that the first line is set to:

```
--format documentation
```

Now, in your terminal, type in `rspec` and hit enter.

The output you see should be something like:

```
No examples found.

Finished in 0.00023 seconds (files took 0.5029 seconds to load)
0 examples, 0 failures
```

We are not quite done yet. Sorry.

I want you to open the `pec/spec_helper.rb` file. Youll se a lot of lines. Most of them are not needed so I would like you to delete all lines that begin with the `#`sign. These are comments and we don't need them.

When you are done you should see something like this:

```ruby

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

Alright, we need to add some of the libraries/gems we want to use to `spec_helper`. Modify your file to include:

```ruby
require File.join(File.dirname(__FILE__), '..', 'lib/application.rb')
require 'capybara'
require 'capybara/rspec'
require 'rspec'
require 'dm-rspec'

```

...and in the `RSpec.configure` block, add:
```ruby
  config.include Capybara::DSL
  config.include DataMapper::Matchers
```

Now, run `rspec` again and you should recieve no errors.

```
No examples found.

Finished in 0.00032 seconds (files took 0.72891 seconds to load)
0 examples, 0 failures
```

Okay, this means that you have successfully added set up RSpec as a testing framework and





