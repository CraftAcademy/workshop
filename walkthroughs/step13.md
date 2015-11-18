##### Adding relationships

Have a look at one of our initioal User stories:

```
As a course administrator,
In order to be able to issue certificates,
I want to be able to create a course offering with a description and multiple delivery dates
```

We are talking about `multiple delivery dates` for each Course, right? That is a crucial feature to implement. Each course must be held at some point, so that students can come, learn and get a certificate.

That is the next feature we will be working on.

Add the following scenario to your feature file:

```ruby
# features/course_create.feature

Scenario: Add a delivery date to course
  Given the course "Basic programming" is created
  And I am on the Course index page
  And I click on "Add Delivery date" for the "Basic programming" Course
  And I select "2015-12-01" from "Start date"
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
  steps %Q{
  Given I am on the home page
  Given I am a registered and logged in user
  And I click "All courses" link
  And I click "Create course" link
  And I fill in "Course Title" with "#{name}"
  And I fill in "Course description" with "Your first step into the world of programming"
  And I click "Create" link
        }
end

And(/^I click on "([^"]*)" for the "([^"]*)" ([^"]*)$/) do |element, name, model|
  object = Object.const_get(model).find(name: name).first
  find("#course-#{object.id}").click_link(element)
end

```

[Explain those two steps]



Modify your `courses/index.erb` like this:

```HTML+ERB
# lib/views/courses/index

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
1. Wraps each `course` instance in a div with a unique `id`
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

```HTML+ERB
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




[Step 13](step13.md)