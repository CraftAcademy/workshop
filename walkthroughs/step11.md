### Logging out

At the moment we can create a user and we can allow her/him to log in. We also need to give her/him a chance to log out, right? Then of course we should have a profile page and a feature to allow the user to update his credentials and so on. That is outside of the scope of this exercise but you will be given plenty of opportunities to add these features yourself once you have mastered the Sinatra framework and ruby.

Add more steps to the log out scenario:

```gherkin
# features/user_maintenance.feature

Scenario: Log out from the application
  Given I am a registered and logged in user
  And I click "Log out" link
  Then I should be on the home page
  And I should see "Successfully logged out"
```


Add the following step definition, again reusing some previous steps:

```ruby
# features/step_definitions/application_steps.rb

...
Given(/^I am a registered and logged in user$/) do
  steps %(
    Given I am a registered user
    And I am on the home page
    And I click "Log in" link
    Then I should be on Log in page
    And I fill in "Email" with "thomas@random.com"
    And I fill in "Password" with "my_password"
    And I click "Submit" link
  )
end
```

Add the `/users/logout` route to `application.rb`

```ruby
# lib/application.rb

...
  get '/users/logout' do
    session[:user_id] = nil
    session[:flash] = 'Successfully logged out'
    redirect '/'
  end
...
```

Update your `application.erb` by adding the Log in link:

```html+erb
# lib/views/layouts/application.erb`

<% if current_user %>
  <%= current_user.email %>
  <%= link_to 'Log out', '/users/logout' %>
<% else %>
  <%= link_to 'Register', '/users/register' %>
  <%= link_to 'Log in', '/users/login' %>
<% end %>
...
```

The scenario should pass. We now have a registration, log in and log out features in place.

What else? For now we will leave the `User` class as it is. For the sake of the exercise we have all the basic functionality we need,
but to be honest, we would need to add a few more features to `User` before we can use it in production. For instance, we do not validate the uniqueness of the `email` during registration
 meaning that two users could register with the same email address. Is that okay? Think about that for a moment. Can you come up with some other functionality that could prove useful or even mission critical?



