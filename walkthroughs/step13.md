### Adding relationships

Have a look at one of our initial User stories:

```
As a course administrator,
In order to be able to issue certificates,
I want to be able to create a course offering with a description and multiple delivery dates
```

We are talking about `multiple delivery dates` for each Course, right? That is a crucial feature to implement. Each course must be held at some point, so that students can come, learn and get a certificate.

That is the next feature we will be working on.

Add the following scenario to your feature file:

```gherkin
# features/course_create.feature

Scenario: Add a delivery date to course
  Given the course "Basic programming" is created
  And I am on the Course index page
  And I click on "Add Delivery date" for the "Basic programming" Course
  And I fill in "Start" with "2015-12-01"
  And I click "Submit" link
  Then I should be on the Course index page
  And I should see "Basic programming"
  And I should see "Delivery dates:"
  And I should see "2015-12-01"
```

We need to add two more step definitions:

```ruby
# features/step_definitions/application_steps.rb

Given(/^the course "([^"]*)" is created$/) do |name|
  steps %(
    Given I am on the home page
    And I am a registered and logged in user
    And I click "All courses" link
    And I click "Create course" link
    And I fill in "Course Title" with "#{name}"
    And I fill in "Course description" with "Your first step into the world of programming"
    And I click "Create" link
  )
end

And(/^I click on "([^"]*)" for the "([^"]*)" ([^"]*)$/) do |element, name, model|
  object = Object.const_get(model).find(name: name).first
  find("#course-#{object.id}").click_link(element)
end

```

In the first step we re-use some of the previously defined steps to define course creation step.

As for the second step, since we can have multiple courses displayed on the Course index page, this test will make sure that we click on the correct link to add start date to a specific course. We identify each course on the page markup using an `id` selector, the `id` is built by concatenating `course-` with the database id of every courses.

First thing to do is to retrieve the object from the database using the name provided to the test, in this case "Basic programming". Assuming the id of that course is `1`, the second line of the step will look on the page for portion of markup with id `course-1` and click on `Add Delivery date` link within that section.



Modify your `courses/index.erb` like this:

```erb
# lib/views/courses/index.erb

<% if @courses.any? %>
  <% @courses.each do |course| %>
    <div id="course-<%= course.id %>">
      <h3><%= course.title %></h3>
      <p><%= course.description %></p>
      <%= link_to 'Add Delivery date', "/courses/#{course.id}/add_date" %>
    </div>
  <% end %>
<% else %>
  <h1>You have not created any courses</h1>
<% end %>
<% if current_user %>
  <%= link_to 'Create course', '/courses/create' %>
<% end %>
```

1. Wraps each `course` instance in a `<div>` with a unique `id`
2. Adds a `Add Delivery date` link to each course with an unique url (that will make it possible for the controller to know what course we want to add the date to)

We need to create that route in our controller:

```ruby
# lib/application.rb

get '/courses/:id/add_date', auth: :user do
  @course = Course.get(params[:id])
  erb :'courses/add_date'
end
```

And create a view for that route:

```erb
# lib/views/courses/add_date.erb

<% form_tag('/courses/new_date', method: 'post') do %>
  <%= label_tag :start_date, caption: 'Start' %>
  <%= date_field_tag :start_date, id: 'start_date' %>
  <%= submit_tag 'Submit' %>
<% end %>
```

We also need to define how the post request should be handled:

```ruby
# lib/application.rb

post '/courses/new_date', auth: :user do
  Delivery.create(start_date: params[:start_date])
  redirect 'courses/index'
end

```

When we run `cucumber` now, we get an uninitialized constant error. We need to create the `Delivery`

```shell
And I click "Submit" link                        # features/step_definitions/application_steps.rb:3
      uninitialized constant WorkshopApp::Delivery (NameError)
```

As usual we start with writing some specs. Create a `delivery_spec.rb` file in the `spec` folder. Add these specs:

```ruby
# spec/delivery_spec.rb

describe Delivery do
  it { is_expected.to have_property :id }
  it { is_expected.to have_property :start_date }
end
```

Now, create a file named `delivery.rb` in the `lib` folder:

```ruby
# lib/delivery.rb

class Delivery
  include DataMapper::Resource

  property :id, Serial
  property :start_date, Date
end
```

Make sure to require it in the controller:

```ruby
# lib/application.rb
...
require './lib/delivery'
...
```

What we want to do now is to add a relationship between `Course` and `Delivery`. The type of relationship we want to add is a one to many relationship.

Let’s write some specs for it first. Add the following specs to the `course_spec.rb` and `delivery_spec.rb`:

```ruby
# spec/course_spec.rb

it { is_expected.to have_many :deliveries }
```

```ruby
# spec/delivery_spec.rb

it { is_expected.to belong_to :course }
```

First, run your specs to see them fail and then add the assosiations to your models:

```ruby
# lib/course.rb

...
has n, :deliveries
```

```ruby
# lib/delivery.rb

...
belongs_to :course
```

If we run our features now we get an error while saving the instance of `Delivery` we try to create. In order to make that work we need to update our form on `add_date.erb` and update the method we use to create the Delivery.

First we need to add a hidden field with the id ocf the course we are working with:

```erb
# lib/views/courses/add_date.erb

<% form_tag('/courses/new_date', method: 'post') do %>
  <%= hidden_field_tag :course_id, value: @course.id %>

  ...
<% end %>
```

Now, let's shift our attention to the controller and the post request. Update it to:

```ruby
# lib/application.rb

post '/courses/new_date', auth: :user do
  course = Course.get(params[:course_id])
  course.deliveries.create(start_date: params[:start_date])
  redirect 'courses/index'
end
```

That should do it. Now we need to display those dates on the `views/courses/index.erb`. Update it with the following code:

```erb
# lib/views/courses/index.erb

<% if @courses.any? %>
  <% @courses.each do |course| %>
    <div id="course-<%= course.id %>">
      <h3><%= course.title %></h3>
      <p><%= course.description %></p>
      <% if course.deliveries %>
        <p>Delivery dates:
          <% course.deliveries.each do |date| %>
           <%= date.start_date %>
          <% end %>
        </p>
      <% end %>
      <%= link_to 'Add Delivery date', "/courses/#{course.id}/add_date" if current_user %>
    </div>
  <% end %>
<% else %>
...
```

If you run your features now, all scenarios should go green. As a sanity check, do run all your specs as well. Just to make sure.



