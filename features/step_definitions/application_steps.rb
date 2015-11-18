And(/^I am logged in as an administrator$/) do
  log_in_admin
  expect(WorkshopApp.admin_logged_in).to eq true

end

And(/^I click "([^"]*)" link$/) do |element|
  click_link_or_button element
end

Then(/^break$/) do
  binding.pry
end

Then(/^a new "([^"]*)" should be created$/) do |model|
  expect(Object.const_get(model).count).to eq 1
end

Given(/^I an a registered user$/) do
  steps %Q{
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