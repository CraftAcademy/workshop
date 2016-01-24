##### Adding a Course

The time has come for us to start adding a `Course` class. As mentioned before we will be using `DataMapper` as the ORM and the `Course` class that we created a while back needs to inherit some functionality
from that gem.

First thing we want to do is to make that class a `DataMapper` resource.

Modify your `lib/course.rb` to include the `DataMapper::Resource`:

```ruby
# lib/course.rb

class Course
  include DataMapper::Resource

  property :id, Serial
end
```

Okay. We have to write some tests (or specs as we usually call them). See the specs as a kind of blueprint for your class - basically describing the desired look and behaviour of your class/object.

To do that we will be using `RSpec` and a set of matchers for `DataMapper`. In your `spec` folder, create a file named `course_spec.rb`. Add the following code to that file:

```ruby
# spec/course_spec.rb

require './lib/course'

describe Course do
  it { is_expected.to have_property :id }
  it { is_expected.to have_property :title }
  it { is_expected.to have_property :description }
end
```

Move over to your terminal and type the following to run the specs:

```shell
$ rspec
```

You'll see a lot of errors.

You need to set up `DataMapper` in your `application.rb` for the application to know how to use it and where to store the information (access the database). Add the following code to your `application.rb` file:

```ruby
# lib/application.rb
require 'data_mapper'

...
class WorkshopApp < Sinatra::Base
  ...
  env = ENV['RACK_ENV'] || 'development'
  DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://localhost/workshop_#{env}")
  DataMapper::Model.raise_on_save_failure = true
  DataMapper.finalize
  DataMapper.auto_upgrade!
  ...
end
```

Before we continue we need to install `PostgreSQL` on our system.
[I will get instructions for both Mac OSX and Ubuntu]

Once the install is complete, move back to your terminal then run the following command to create your databases:

```shell
psql -c 'create database workshop_development;' -U postgres
psql -c 'create database workshop_test;' -U postgres
```

We are adding one database for you to use when you develop the application, and another for the testing framework to use when running tests.

If all is set up properly, and you run `rspec` again, you should see the following errors in your terminal output:

```shell
Course
  should have property id
  should have property title (FAILED - 1)
  should have property description (FAILED - 2)

Failures:

  1) Course should have property title
     Failure/Error: it { is_expected.to have_property :title }
       expected to have property title
     # ./spec/course_spec.rb:5:in `block (2 levels) in <top (required)>'

  2) Course should have property description
     Failure/Error: it { is_expected.to have_property :description }
       expected to have property description
     # ./spec/course_spec.rb:6:in `block (2 levels) in <top (required)>'

Finished in 0.02704 seconds (files took 1.09 seconds to load)
3 examples, 2 failures

Failed examples:

rspec ./spec/course_spec.rb:5 # Course should have property title
rspec ./spec/course_spec.rb:6 # Course should have property description
```

The terminal output that `RSpec` returns contains an intimidating amount of text (not so much as it usually is when `RSpec` encounters error, but still a lot). The important takeaway from this is that one test passed and two tests failed.

We were expecting the `Course` class to have 3 attributes: `id`, `title`, and `description`.
But in our class, so far, we only defined `id`. As you remember we set that datatype to a `Serial` meaning that it will be automatically incremented by the database each time we create a new course.

All tables needs an `id` - that is called a `primary key` and is used to identify the record when we are trying to retrieve it.

So we need to add `title` and `description` to the course class. Let's do it by adding those properties like this:

```ruby
# lib/course.rb

class Course
  include DataMapper::Resource

  property :id, Serial
  property :title, String
  property :description, Text
end
```

And run our specs again. We should go all green - our specs are passing. We now have a `Course` class that can be given a `Title` and a `Description`. That is a good start.

Let's shift our attention to `application.rb` for a moment.

Open it up and locate the part where we are handling the `post` request that will create a Course using the form we added earlier.

It should look something like this:

```ruby
# lib/application.rb

...
post '/courses/create' do
  # TODO: place Course creation code here:
  erb :'courses/index'
end
...
```

What we need to know is that each time a form is submitted in a browser, the field values are sent off to the server in a set of key and value pairs (a `Hash`) called `params`.

In this case the post request will send of something like this:
```ruby
{"authenticity_token"=>
 "9c5220b56ab8a74e03f5ac331206ba163bb82f7cda3e1782bd8e18526caab213",
 "course"=>
   {
   "title"=>"Basic programming", 
   "description"=>"Your first step into the world of programming"
   }
}
```

Never mind the `authenticity_token` for now but let's focus on the `"course"=>...` part of the hash. We filled in two fields in our feature test, the `title` and the `description`, right? The params `course` key holds information about what we submitted.

We are going to access those values and use them to create a record of that `Course` in our database.

Modify you post route like this:

```ruby
# lib/application.rb

  post '/courses/create' do
    Course.create(title: params[:course][:title], 
                  description: params[:course][:description])
    redirect 'courses/index'
  end
```

Now run `cucumber` again and see the next step go green.

But we have a new error.

At this point Cucumber does not know where to go and look for the `Course` index page. We need to make sure it does know that. Open your `features/support/paths.rb` file and add the following code to the `path_to(page_name)`  method:

```ruby
# features/support/paths.rb

...
when /the Course index page/
  '/courses/index'
...
```

And run `cucumber`again.

What?!? Another error? Will this ever end? 

The answer to that is basically **NO**. In test driven development you will keep on getting errors all the time. That is the nature of testing first - writing code later.

What you want to make sure is that you keep on progressing in your development by small steps that manifests themselves by your testing framework changing the error message.

Every time you run your test and the message changes means that you have taken a small step forward. After a while, those small steps amount to a fully working feature.

Anyway, the error we are seeing now should be something like this:

```shell
Then a new "Course" should be created      # features/step_definitions/application_steps.rb:15

    expected: 1
         got: 2

    (compared using ==)
     (RSpec::Expectations::ExpectationNotMetError)
    ./features/step_definitions/application_steps.rb:16:in `/^a new "([^"]*)" should be created$/'
    features/course_create.feature:19:in `Then a new "Course" should be created'
```

Okay, so this means that `cucumber` was expecting one `Course` in the database but found two. That is because this is the second time we run this test. The course that we created the first time around is still there. So the assertion in our step definition, will not work any more:

```ruby
Then(/^a new "([^"]*)" should be created$/) do |model|
  expect(Object.const_get(model).count).to eq 1
end
```

This means that there should only be one instance of `Course` saved. (One could argue that the assertion should be rewritten, but for the sake of making my point I would like to stick with this one for now).

What we need to do is to make sure that every time we run our test we are providing the testing framework with a clean database. For that we are going to use a gem called `DatabaseCleaner`.

As usual (you should know this procedure by now) we add that gem to our Gemfile's `development` and `test` group:

```ruby
# Gemfile

gem 'database_cleaner'

```

And run `bundle install`

After that finishes, create a file `features/support/database_cleaner.rb` that looks like this:

```ruby
# features/support/database_cleaner.rb

require 'database_cleaner'
require 'database_cleaner/cucumber'

DatabaseCleaner.strategy = :truncation

Around do |scenario, block|
  DatabaseCleaner.cleaning(&block)
end
```

Now, if you run `cucumber` again, you will be presented with a new error message (I told you!).

We are closing in to the end of our first two scenarios and the only thing that remains for us to do is to tell the view (`courses/index.erb`) to actually list our courses.

We do that in our `applications.rb` and the `get '/courses/index'` route. Open up that file and locate that route. We need to tell the application to store information about the courses in a variable that Sinatra automatically passes over to the view:

```ruby
# lib/application.rb

  get '/courses/index' do`
    @courses = Course.all
    erb :'courses/index'
  end
```

So `@courses` is an array containing information about all the courses in our database (hence `Course.all`). In our `courses/index.erb` we need to tell the application to show those courses unless the `@courses` array is empty.
If it is empty, we want to display a message telling the user: `You have not created any courses` (we had that in our first scenario, right?).

So, in order to do that we are going to use some ruby in the `course/index.erb` view to condition what is being shown to the user:

```html
# courses/index.erb

<% if @courses.any? %>
  <% @courses.each do |course| %>
    <h3><%= course.title %></h3>
    <p><%= course.description  %></p>
  <% end %>
<% else %>
  <h1>You have not created any courses</h1>
<% end %>
<%= link_to 'Create course', '/courses/create' %>

```

Let's have a look what this code does.

1. `<% if @courses.any? %>` does a check if the array stored in the `@courses` variable actually contains anything.
2. If it does, the application iterates over the array (with `@courses.each do..` , creates a block and stores the current object in a local variable called `course`
3. The html between the `do` and the `end` keywords are executed as many times as there are courses in the array (in our case, for now, only once)
4. The value of the attributes `course.title` and `course.description` are rendered on the view.
5. If the `@courses`array is empty, the message "You have not created any courses" is rendered on the view

Pretty neat, right?

So if you run `cucumber` again, all the steps in our first two scenarios should pass. Congratulations. You just finished your first feature!


