
#### Adding Students

Students will be added as a separate class and added by uploading a datafile in csv format (comma separated). Each student can be assigned to multiple Deliveries and thus be issued several Cartificates.

A user story:

```
As a course administrator
In order to be able to issue course certificates
I want to be able to import a datafile with student information
```

We start by creating a new feature file in the `features` folder. Call it `student_data_import.feature`.

We will be doing this in small increments sp we will not define all steps at once but rather work our way through the scenario in parts, dding new steps as we move along. Let's start with these initial steps:

```ruby
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
  steps %Q{
  Given the course "#{name}" is created
  And I am on the Course index page
  And I click on "Add Delivery date" for the "#{name}" Course
  And I fill in "Start" with "#{date}"
  And I click "Submit" link
        }
end
```

And in the `support/paths.rb` we have to configure the path for Cucumber to know where to go.

```ruby

# features/support/paths.rb

...
when /^(.*) show page$/i
  d = Delivery.find(date: $1).first
  "/courses/delivery/show/#{d.id}"
...
```

If you run these steps at this point they should all go green.




[Step 15](step15.md)