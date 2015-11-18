Add the following scenario:

```ruby
# features/user_maintenance.feature

Scenario: Log in to the application
  Given I am on the home page
  And I click "Log in" link
  Then I should be on Log in page
  And I fill in "Email" with "thomas@random.com"
  And I fill in "Password" with "my_password"
  And I click "Submit" link
  Then I should be on the home page
  And I should see "Successfully logged in Thomas"
  And I should not see "Ragister"
```

Run `cucumber` (`cucumber features/user_maintenance.feature`)


Update your `application.erb` by adding the Log in link:

```ruby
# lib/views/layouts/application.erb`

...
<%= link_to 'Log in', '/users/login' %>
...
```

And add that path to `paths.rb` so Cucumber knows where to go:

```ruby
# features/support/paths.rb

...
when /Log in page/
  '/users/login'
...
```

Create a `login.erb` file in `views/users`

```HTML+ERB
# lib/views/users/login.erb

<%= form_tag '/users/session' do %>
  <%= label_tag :email %>
  <%= text_field_tag :email %>

  <%= label_tag :password %>
  <%= password_field_tag :password %>

  <%= submit_tag 'Submit' %>
<% end %>
```



