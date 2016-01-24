### Adding Students

Students will be added as a separate class by uploading a datafile. Each student can be assigned to multiple Deliveries and thus be issued several Certificates.

A user story:

```
As a course administrator
In order to be able to issue course certificates
I want to be able to import a datafile with student information
```

We start by creating a new feature file in the `features` folder. Call it `student_data_import.feature`.

We will be doing this in small increments so we will not define all steps at once but rather work our way through the scenario in parts, doing new steps as we move along. Let's start with these initial steps:

```gherkin
# features/student_data_import.feature

Scenario: Data file upload
  Given the delivery for the course "Basic" is set to "2015-12-01"
  And I am on the Course index page
  And I click on "2015-12-01" for the "Basic programming" Course
  Then I should be on 2015-12-01 show page

```

Add the following step to your `application_steps.rb`

```ruby
# features/step_definitions/application_steps.rb

Given(/^the delivery for the course "([^"]*)" is set to "([^"]*)"$/) do |name, date|
  steps %(
    Given the course "#{name}" is created
    And I am on the Course index page
    And I click on "Add Delivery date" for the "#{name}" Course
    And I fill in "Start" with "#{date}"
    And I click "Submit" link
  )
end
```

And in the `support/paths.rb` we have to configure the path for Cucumber to know where to go.

```ruby

# features/support/paths.rb

...
when /^(.*) show page$/i
  d = Delivery.find(date: $1).first
  "/courses/deliveries/show/#{d.id}"
...
```
And lastly update your `course/index.erb` file as follows:

```erb
# lib/views/courses/index.erb

<!-- # replace  -->
<%= date.start_date %>

<!-- # with  -->
<%= link_to date.start_date, "/courses/deliveries/show/#{date.id}" %>
```

In our controller, we need to define that route as well:

```ruby
# lib/application.rb

...
get '/courses/deliveries/show/:id', auth: :user do
  @delivery = Delivery.get(params[:id].to_i)
  erb :'courses/deliveries/show'
end

post '/courses/deliveries/file_upload' do
  # TODO: Add method to parse csv
end
...
```

In that route we are pointing to an `erb` template that is still missing (you'll see that when you run `cucumber`, right?)

We need to create a new folder and a new `erb` file. Can you figure out how?

```erb
# lib/views/courses/deliveries/show.erb

<h2><%= @delivery.course.title %></h2>

<% form_tag '/courses/deliveries/file_upload', method: :post, multipart: true do %>
  <%= hidden_field_tag :id, value: @delivery.id %>
  <%= file_field_tag :file %>
  <%= submit_tag 'Submit' %>
<% end %>

```
If you run `cucumber` at this point, all the steps should be green.

Moving on. Let's add some more steps to our scenario.

```gherkin
# features/student_data_import.feature

Scenario: Data file upload
  Given the delivery for the course "Basic" is set to "2015-12-01"
  And I am on the Course index page
  And I click on "2015-12-01" for the "Basic programming" Course
  Then I should be on 2015-12-01 show page
  When I select the "students.csv" file
  And I click "Submit" link
  Then 3 instances of "Student" should be created

```

We need to add two new step definitions:

```ruby
# features/step_definitions/application_steps.rb

...

When(/^I select the "([^"]*)" file$/) do |file_name|
  attach_file('file', File.absolute_path("./features/fixtures/#{file_name}"))
end

Then(/^([^"]*) instances of "([^"]*)" should be created$/) do |count, model|
  expect(Object.const_get(model).count).to eq count.to_i
end
```

To save some time, use the following two commands to create a `fixture` folder (where we will store some dummy data) and an empty `students.csv`:

```shell
$ mkdir features/fixtures
$ touch features/fixtures/students.csv
```

Now run your tests again and you'll see that you have moved forward a bit but also that you can not move any further without defining a new `Student` class. Time for some `RSpec` and unit testing.

We start by creating a `student_spec.rb` file in the `spec` folder and add a few expectations:

```ruby
# spec/student_spec.rb

describe Student do

  it { is_expected.to have_property :id }
  it { is_expected.to have_property :full_name }
  it { is_expected.to have_property :email }

  it { is_expected.to have_many_and_belong_to :deliveries }
end
```

And we need to, of course, create a `Student` class:

```ruby
# lib/student.rb

class Student
  include DataMapper::Resource

  property :id, Serial
  property :full_name, String
  property :email, String

  has n, :deliveries, through: Resource
end
```

Don't forget to include the `Student` class in your controller:

```ruby
# lib/application.rb

...
require './lib/student'
...
```

Run the `student_spec.rb`:

```shell
$ rspec spec/student_spec.rb
```

The specs should pass.

Time to add a module to parse the uploaded file. In your `lib` folder, create a file named `csv_parse.rb`. There we will place some logic on how to parse a data file and create Student objects.

```ruby
# lib/csv_parse.rb

require 'csv'

module CSVParse
  def self.import(file, obj, parent)
    import = CSV.read(file, quote_char: '"',
                      col_sep: ';',
                      row_sep: :auto,
                      headers: true,
                      header_converters: :symbol,
                      converters: :all).collect do |row|
      Hash[row.collect { |c, r| [c, r] }]
    end
    CSVParse.create_instance(parent, obj, import)
  end

  def self.create_instance(parent, obj, dataset)
    dataset.each do |data|
      student = obj.first_or_create({full_name: data[:full_name]}, {full_name: data[:full_name], email: data[:email]})
      student.deliveries << parent unless student.deliveries.include? parent
      student.save
    end
  end
end

```

Now, let's go back to our controller.

You have to require and include the module (look closely at the code below) and update your `post` request route with this code:

```ruby
# lib/application.rb

...
require './lib/csv_parse'

class WorkshopApp < Sinatra::Base
  include CSVParse
...

...
post '/courses/deliveries/file_upload' do
  @delivery = Delivery.get(params[:id])
  CSVParse.import(params[:file][:tempfile], Student, @delivery)
  redirect "/courses/deliveries/show/#{@delivery.id}"
end
...
```

Add some content to your fixture file, the `students.csv`:

```
# features/fixtures/students.csv

full_name; email
Thomas Ochman;thomas@random.se
Anders Andersson;anders@anders.se
Kalle Karlsson;kalle@kalle.se
```

Now, if you run the scenario, all the steps should pass.

Add another few steps to your scenario:

```gherkin
# features/student_data_import.feature

Scenario: Data file upload
  Given the delivery for the course "Basic" is set to "2015-12-01"
  And I am on the Course index page
  And I click on "2015-12-01" for the "Basic programming" Course
  Then I should be on 2015-12-01 show page
  When I select the "students.csv" file
  And I click "Submit" link
  Then 3 instances of "Student" should be created
  Then I should be on 2015-12-01 show page
  And I should see "Students:"
  And I should see "Thomas Ochman"
  And I should see "Anders Andersson"
  And I should see "Kalle Karlsson"

```

We need to add an relationship between `Delivery` and `Student` for the `Delivery` to know what `Student`s it is associated with. It needs to do that so we can display that information on the page after we've uploaded and parsed the data file.

We start by adding a spec for that relation:

```ruby
# spec/delivery_spec.rb

it { is_expected.to have_many_and_belong_to :students }
```

And we add that relation to our `Delivery` class:

```ruby
# lib/delivery.rb

...
has n, :students, through: Resource
```

Finally, add the following code to the `show.erb` template:

```erb
# lib/views/courses/deliveries/show.erb

...
<div>
  <% if @delivery.students.any? %>
    Students:
    <% @delivery.students.each do |student| %>
      <%= [student.full_name, ''].join(' ') %>
    <% end %>
  <% end %>
</div>
```

Run all your specs and features. You should see a lot of green on your screen. That is always a good sign. ;-)

Next, we will be creating the actual certificates. Exciting?


