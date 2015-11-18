And(/^I click "([^"]*)" link$/) do |element|
  click_link_or_button element
end

Then(/^break$/) do
  binding.pry
end

Then(/^a new "([^"]*)" should be created$/) do |model|
  expect(Object.const_get(model).count).to eq 1
end

Given(/^I am a registered user$/) do
  steps %q{
  Given I am on the home page
  And I click "Register" link
  Then I should be on Registration page
  And I fill in "Name" with "Thomas"
  And I fill in "Email" with "thomas@random.com"
  And I fill in "Password" with "my_password"
  And I fill in "Password confirmation" with "my_password"
  And I click "Create" link
        }
end

Given(/^I am a registered and logged in user$/) do
  steps %q{
  Given I am a registered user
  And I am on the home page
  And I click "Log in" link
  Then I should be on Log in page
  And I fill in "Email" with "thomas@random.com"
  And I fill in "Password" with "my_password"
  And I click "Submit" link
        }
end

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
  within "div#course-#{object.id}" do
    click_link_or_button element
  end
end

