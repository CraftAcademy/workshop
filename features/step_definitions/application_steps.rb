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