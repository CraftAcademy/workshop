### Restricting access

Now that we have the most important `User` features in place, we want to allow the logged in user to perform certain actions and disallow visitors (non logged in users) from accessing certain routes.

Before we move on and implement some basic authorization methods we want to take a step back and get rid of some code that we no longer need.

It's time to do some re-factoring of the initial scenarios we wrote and delete obsolete code.

```
# features/course_create.feature

# delete:
Given I am on the home page
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

Also, in the `features/support/env.rb`, it is safe to remove the method we used to change the `admin_logged_in` setting:

```ruby
# features/support/env.rb

# delete:
def log_in_admin
  WorkshopApp.admin_logged_in = true
end
```

Make sure that you have not broken anything by running all your tests again - both `cucumber` and `rspec`.

If all your test are passing (and they should be), we should be able to move on and make sure that the administrator and the administrator only should be able to create new Courses.

Add the following scenario to your `course_create.feature`

```gherkin
# features/course_create.feature

...
Scenario: Non logged in user can not create course
  Given I am on the home page
  And I click "All courses" link
  Then I should not see "Create course"

Scenario: Non logged in user can not access the create new course form
  Given I am on Create course page
  And I should see "You are not authorized to access this page"

```

If you run your tests now, you'll get errors on those two scenarios.

They should look something like this:

```shell
  Scenario: Non logged in user can not create course # features/course_create.feature:23
    Given I am on the home page                      # features/step_definitions/web_steps.rb:19
    And I click "All courses" link                   # features/step_definitions/application_steps.rb:1
    Then I should not see "Create course"            # features/step_definitions/web_steps.rb:128
      expected #has_no_content?("Create course") to return true, got false (RSpec::Expectations::ExpectationNotMetError)
      ./features/step_definitions/web_steps.rb:131:in `block (2 levels) in <top (required)>'
      ./features/step_definitions/web_steps.rb:14:in `with_scope'
      ./features/step_definitions/web_steps.rb:129:in `/^(?:|I )should not see "([^\"]*)"(?: within "([^\"]*)")?$/'
      ./features/support/database_cleaner.rb:7:in `block in <top (required)>'
      features/course_create.feature:26:in `Then I should not see "Create course"'

  Scenario: Non logged in user can not access the create new course page # features/course_create.feature:28
    Given I am on Create course page                                     # features/step_definitions/web_steps.rb:19
      Can't find mapping from "Create course page" to a path.
      Now, go and add a mapping in /Users/thomas/MakersSweden/workshop/features/support/paths.rb (RuntimeError)
      ./features/support/paths.rb:29:in `path_to'
      ./features/step_definitions/web_steps.rb:20:in `/^(?:|I )am on (.+)$/'
      ./features/support/database_cleaner.rb:7:in `block in <top (required)>'
      features/course_create.feature:29:in `Given I am on Create course page'
    And I should see "You are not authorized to access this page"        # features/step_definitions/web_steps.rb:107


```

The error on `I should not see "Create course"` step is easy. Let’s fix that first.

Open up your `courses/index.erb` file and simply condition the display of the "Create course" link:

```HTML+ERB
# lib/views/courses/index.erb
...
<% if current_user %>
  <%= link_to 'Create course', '/courses/create' %>
<% end %>
```

The error on the next scenario requires some more work. First, add that path to `paths.rb` so Cucumber knows where to go:

```ruby
# features/support/paths.rb

...
when /Create course page/
  '/courses/create'
...
```

Now, open your main controller and locate the `auth(type)` method and change it to:

```ruby
# lib/application.rb

...
def auth(type)
  condition do
    restrict_access = Proc.new { session[:flash] = 'You are not authorized to access this page'; redirect '/' }
    restrict_access.call unless send("is_#{type}?")
  end
end
...
```

And in the same file, find the route to `/courses/create` and add a call to the `auth(type)` method like this:

```ruby
# lib/application.rb

...
  get '/courses/create', auth: :user do
    erb :'courses/create'
  end
...
```

This means that every time that path is requested, the application will check if a user is logged in. If not, it will set a flash message and redirect to the main path of the application.
From now on, you can restrict every path like this if you want it to be accessible by a logged in user only.

Run your tests now and see them pass!

