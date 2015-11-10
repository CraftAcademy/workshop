Lets shift our attention to step definitions. Up until now we have been using a semi-english language to tell Cucumber what to do wit our (nonexisting)application.
But we haven't told Cucumber how to do it. Step definitions are those instructions, and we will be writing them now.

During the development process we will be creating a large amout of instructions for Cucumber to follow.

For that reason we want to store out step definitions in separate files and grouped after some kind of system. Why not choosing a system that groups them ....

Anyway, for now, let's cretate a basic_steps.rb" file in the `step_definitions` folder.`

```
touch step_definitions/basic_steps.rb
```

Open it up an paste the second half of the Cucumber output you got in your terminal window when you ran Cucumber last time:

```ruby
Given(/^I am on the home page$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Given(/^I am logged in as an administrator$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Given(/^I click "([^"]*)" link$/) do |arg1|
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/^I should see "([^"]*)"$/) do |arg1|
  pending # Write code here that turns the phrase above into concrete actions
end

Given(/^I click 'Create course" link$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Given(/^I fill in "([^"]*)" with "([^"]*)"$/) do |arg1, arg2|
  pending # Write code here that turns the phrase above into concrete actions
end

Given(/^I click "([^"]*)"$/) do |arg1|
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/^a new course should be created$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/^I should be on the Course index page$/) do
  pending # Write code here that turns the phrase above into concrete actions
end
```

Our first goal is to make the first step in the first scenario to pass. That is a challenge in itself, trust me!

First, remove the `pending... in
```ruby
Given(/^I am on the home page$/) do

end
```

What we want to do is to tell Cucumber to visit a certain URL in our browser, right.
I know, it's pretty strange that we want a program to do something that we could easily do ourselves,
 but if you have a lot of pages or a lot of forms to fill out and links to click, you really don't want
 to do that manually. You want to automate that. That is one of the many reasons we write automated tests.

Anyway, we want to tell this specific step definition to go to the homepage of the application. In out case it is `'/'` or `root_path`

So we simply tell Cucumber to `visit '/'` or `visit root_path`

```ruby
Given(/^I am on the home page$/) do
  visit '/'
end
```

Make the change, save your file and run `cucumber` again.

Now, the errors you see are different then before and that is a good sign. It means that we have moved ahead in our endeavour to make the tests pass. But we still have a loooong way to go.

Your terminal output should look something like this:

```ruby
cucumber
Feature: As a course administrator,
  In order to be able to issue certificates,
  I want to be able to create a course offering with a description and multiple delivery dates

  Scenario: List courses                                 # features/course_create.feature:5
    Given I am on the home page                          # features/step_definitions/basic_steps.rb:1
      undefined method `visit' for #<Object:0x007fdc53d70e60> (NoMethodError)
      ./features/step_definitions/basic_steps.rb:2:in `/^I am on the home page$/'
      features/course_create.feature:6:in `Given I am on the home page'
    And I am logged in as an administrator               # features/step_definitions/basic_steps.rb:5
    And I click "All courses" link                       # features/step_definitions/basic_steps.rb:9
    Then I should see "You have not created any courses" # features/step_definitions/basic_steps.rb:13

  Scenario: Create a course                                                          # features/course_create.feature:11
    Given I am on the home page                                                      # features/step_definitions/basic_steps.rb:1
      undefined method `visit' for #<Object:0x007fdc53eda080> (NoMethodError)
      ./features/step_definitions/basic_steps.rb:2:in `/^I am on the home page$/'
      features/course_create.feature:12:in `Given I am on the home page'
    And I am logged in as an administrator                                           # features/step_definitions/basic_steps.rb:5
    And I click "All courses" link                                                   # features/step_definitions/basic_steps.rb:9
    And I click 'Create course" link                                                 # features/step_definitions/basic_steps.rb:17
    And I fill in "Title" with "Basic programming"                                   # features/step_definitions/basic_steps.rb:21
    And I fill in "Description" with "Your first step into the world of programming" # features/step_definitions/basic_steps.rb:21
    And I click "Create"                                                             # features/step_definitions/basic_steps.rb:25
    Then a new course should be created                                              # features/step_definitions/basic_steps.rb:29
    And I should be on the Course index page                                         # features/step_definitions/basic_steps.rb:33
    And I should see "Basic programming"                                             # features/step_definitions/basic_steps.rb:13

Failing Scenarios:
cucumber features/course_create.feature:5 # Scenario: List courses
cucumber features/course_create.feature:11 # Scenario: Create a course

2 scenarios (2 failed)
14 steps (2 failed, 12 skipped)
0m0.245s
```
Lots of text but the only part that is relevant is the one you can find in the first scenario under the `Given I am on the homepage` step:
```
undefined method `visit' for #<Object:0x007fdc53d70e60> (NoMethodError)
```

Yeah, that means that Cucumber does not understand what we want him to do.

In order to make that clear for the testing framework we need to install another gem (library) and configure it for use with Cucumber.

Enter Capybara. Capybara is a giant rat but it is also the name of a testing tool that allows us to simulate user interacting with our application.

Also, now is a good time to add a file that will hold information about what libraries we are using. In Rubyworld, these are called *gems* and the file I'm referring to is named `Gemfile`

Create a `Gemfile` in your projecst folder by typing:

```
touch Gemfile
```

and open it in your editor.

The first thing we want to add to this file is where we want to look for sources of the gems we want to use.

```ruby
source "https://rubygems.org"
```

The next thing we need to do is to add information about which gems we want to use.
We are already using `cucumber` and now we want to start using `capybara`, right? So we add the following to our `Gemfile`:

```ruby
source "https://rubygems.org"

gem 'cucumber'
gem 'capybara'
gem 'capybara-webkit'
```

And modify the `features/support/env.rb` with the lollowing code:

```ruby
require 'capybara/cucumber'
require 'capybara/webkit'

Capybara.configure do |config|
  config.default_driver = :webkit
end
```

Let's run `cucumber` again. New errors (again, that in itself is a step forward!)







