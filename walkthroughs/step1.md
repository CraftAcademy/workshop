#### The development process

We will be using RSpec and Cucumber to test our application.
During the development process we'll take an approach that mixes high level acceptance tests and low level unit tests to both drive the development process and make sure that we build a robust and well structures application.

Let's start with writing some high level acceptance tests.

We don't have an application yet. And we don't need one at this stage. ;-)
What we want to do at this stage is to get the user stories we have defined and take a look at them from a users perspective
and what an actual implementation of features would look like. I short, we want to take each user story and break it down to
scenarios that each represents a use case in the application. Sounds confusing? It is, but look at it as a form of a blue print
that you will use when we start to actually build the app.

First we need to install a testing tool. We will be using a number of tools in this project but at this point we will introduce you to `Cucumber`.

Cucumber (https://cucumber.io/) is a framework for writing and executing high level descriptions of your software's functionality.
One of Cucumber's most compelling features is that it provides the ability to write these descriptions using plain text - even in your native language.

Cucumber is not installed on your system so we need to do that as a first step.

Open your terminal and let's setup the project folder:

```shell
$ mkdir workshop
$ cd workshop
$ echo "source 'https://rubygems.org'" > Gemfile
$ echo "gem 'cucumber'" >> Gemfile
```

Now run the following command..

```shell
$ bundle install
```

..and watch the system install it together with some other libraries it depends on in order to be able to run,

Once that is complete I'd like you to initiate Cucumber by simply typing in:

```shell
$ cucumber --init
```
That will create some files and folders for you:

```shell
create   features
create   features/step_definitions
create   features/support
create   features/support/env.rb
```

Okay, now, in your terminal, you type in:

```shell
$ cucumber
```
The output you will see should look something like this:

```shell
0 scenarios
0 steps
0m0.000s
```

Alright, we have installed and initiated the first testing framework. Big step.

Now let's take a moment to talk about how a Cucumber file is built and then we'll write our first of many tests.

A feature is defined by one or more scenarios. A scenario is a sequence of steps through the feature that exercises one path.

A scenario is made up of 3 sections related to the 3 types of steps:

- `Given:` This sets up preconditions, or context, for the scenario. It works much like the setup in xUnit and before blocks in RSpec.
- `When:` This is what the feature is talking about, the action, the behaviour that we're focused on.
- `Then:` This checks postconditions. it verifies that the right thing happen in the When stage.

There is yet another type of step you can use in a scenario path, and that is the `And` keyword. And can be used in any of the three sections.
It serves as a nice shorthand for repeating the `Given`, `When`, or `Then`. And stands in for whatever the most recent explicitly named step was.

In the newly created `features` folder, please create a `course_create.feature` by returning to your terminal window and  typing in:

```shell
$ touch features/course_create.feature
```

Open that file and add the following code:

```gherkin
Feature: As a course administrator,
  In order to be able to issue certificates,
  I want to be able to create a course offering with a description and multiple delivery dates
```

This is added mainly for your and your fellow project members reference and tells a reader what this test file is actually about - setting the scope of the tests.

Now we will add two basic scenarios to this Feature.

```gherkin
# features/course_create.feature

Scenario: List courses
  Given I am on the home page
  And I am logged in as an administrator
  When I click "All courses" link
  Then I should see "You have not created any courses"

Scenario: Create a course
  Given I am on the home page
  And I am logged in as an administrator
  And I click "All courses" link
  And I click "Create course" link
  And I fill in "Course Title" with "Basic programming"
  And I fill in "Course description" with "Your first step into the world of programming"
  And I click "Create" link
  Then a new "Course" should be created
  And I should be on the Course index page
  And I should see "Basic programming"
```

Let's have a look at the first one:

1. The 2 preconditions for our scenario is that we have logged in to the application and are currently visiting the root path of the app.
2. The action I'm taking is clicking on the `All courses` link.
3. The postcondition is the fact that I see the message "You have not created any courses"

Now in your terminal window, go ahead and type `cucumber` again and watch the test framework do its job. If you have followed my instructions, you will se an output similar to this:

```shell
$ cucumber
Feature: As a course administrator,
  In order to be able to issue certificates,
  I want to be able to create a course offering with a description and multiple delivery dates

  Scenario: List courses                                 # features/course_create.feature:5
    Given I am on the home page                          # features/course_create.feature:6
    And I am logged in as an administrator               # features/course_create.feature:7
    And I click "All courses" link                       # features/course_create.feature:8
    Then I should see "You have not created any courses" # features/course_create.feature:9

  Scenario: Create a course                                                          # features/course_create.feature:11
    Given I am on the home page                                                      # features/course_create.feature:12
    And I am logged in as an administrator                                           # features/course_create.feature:13
    And I click "All courses" link                                                   # features/course_create.feature:14
    And I click 'Create course" link                                                 # features/course_create.feature:15
    And I fill in "Title" with "Basic programming"                                   # features/course_create.feature:16
    And I fill in "Description" with "Your first step into the world of programming" # features/course_create.feature:17
    And I click "Create" link                                                        # features/course_create.feature:18
    Then a new "Course" should be created                                            # features/course_create.feature:19
    And I should be on the Course index page                                         # features/course_create.feature:20
    And I should see "Basic programming"                                             # features/course_create.feature:21

2 scenarios (2 undefined)
14 steps (14 undefined)
0m0.237s
```
And also:

```shell
You can implement step definitions for undefined steps with these snippets:

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

Given(/^I fill in "([^"]*)" with "([^"]*)"$/) do |arg1, arg2|
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/^a new "([^"]*)" should be created$/) do |arg1|
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/^I should be on the Course index page$/) do
  pending # Write code here that turns the phrase above into concrete actions
end
```

This is perfectly normal, and means that we need to start doing some serious programming in order to actually implement the tests and eventually make them pass.

[Step 2](step2.md)
