#### Rendering certificates

Moving on to actually generating some certificates.

We start with a feature test. Create a new file in your `features` folder, named `certificate_generation.feature` and add the following scenario:

```ruby
# features/certificate_generation.feature

Feature: As a course administrator,
  In order to be able to issue the right certificates for a course,
  I want to be able display course title, course date and the
  participants name on the certificate


Scenario: Generate a certificate
  Given the delivery for the course "Basic" is set to "2015-12-01"
  And the data file for "2015-12-01" is imported
  And I am on 2015-12-01 show page
  And I click "Generate certificates" link
  Then 3 certificates should be generated
```

That will do for now. Run `cucumber` and see the tests fail.

Add some new step definition in your `application_steps.rb`

```ruby
# features/step_definitions/application_steps.rb

And(/^the data file for "([^"]*)" is imported$/) do |date|
  steps %Q{
  And I am on the Course index page
  And I click on "#{date}" for the "Basic programming" Course
  When I select the "students.csv" file
  And I click "Submit" link
        }
end

Then(/^([^"]*) certificates should be generated$/) do |count|
  pdf_count = Dir['pdf/**/*.pdf'].length
  expect(pdf_count).to eq count.to_i
end
```

Okay, running the scenario now will tell us that no certificates have been created:

```shell
$ cucumber features/certificate_generation.feature
Feature: As a course administrator,
  In order to be able to issue the right certificates for a course,
  I want to be able display course title, course date and the
  participants name on the certificate

  Scenario: Generate a certificate                                   # features/certificate_generation.feature:7
    Given the delivery for the course "Basic" is set to "2015-12-01" # features/step_definitions/application_steps.rb:56
    And the data file for "2015-12-01" is imported                   # features/step_definitions/application_steps.rb:66
    And I am on 2015-12-01 show page                                 # features/step_definitions/web_steps.rb:19
    And I click "Generate certificates" link                         # features/step_definitions/application_steps.rb:3
    Then 3 certificates should be generated                          # features/step_definitions/application_steps.rb:85

      expected: 3
           got: 0

      (compared using ==)
       (RSpec::Expectations::ExpectationNotMetError)
      ./features/step_definitions/application_steps.rb:87:in `/^([^"]*) certificates should be generated$/'
      ./features/support/database_cleaner.rb:7:in `block in <top (required)>'
      features/certificate_generation.feature:12:in `Then 3 certificates should be generated'

Failing Scenarios:
cucumber features/certificate_generation.feature:7 # Scenario: Generate a certificate

1 scenario (1 failed)
5 steps (1 failed, 4 passed)
0m0.467s
```



