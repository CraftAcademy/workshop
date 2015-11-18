##### Restricting access

Time to do some refactoring of the initial scenarios we wrote and then add some more features to our application.

```
# features/course_create.feature

# delete:
And I am logged in as an administrator

# replace with:
Given I am a registered and logged in user
```

And also delete the step definition for that step:

```ruby
# features/step_definitions/application_steps.rb

# delete:
And(/^I am logged in as a administrator$/) do
  log_in_admin
  expect(WorkshopApp.admin_logged_in).to eq true
end
```


And we need to get rid of the, now obsolete, `admin_logged_in` method.

```ruby
# lib/application.rb

# delete:
set :admin_logged_in, false
```

Make sure that you have not broaken anything by running all your tests again, both `cucumber` and `rspec`.



