### Logging in

Now that we have signed up to the application, we want to be able to actually log in.

The log in process is about:

1. Accessing an interface that allows the user to provide his credentials (the log in page)
2. Checking and validating the credentials (in our case querying the database and comparing the provided email and password to whatever we have stored)
3. If successful, telling the application that a user is logged in
4. Making the user data available to the application (in our case storing the user id in the `session` and/or in a global variable)


We start with high level acceptance tests simulating the actions of a user that wants to log in. Add the following scenario to the `user_maintenance.feature`:

```gherkin
# features/user_maintenance.feature

Scenario: Log in to the application
  Given I am a registered user
  Given I am on the home page
  And I click "Log in" link
  Then I should be on Log in page
  And I fill in "Email" with "thomas@random.com"
  And I fill in "Password" with "my_password"
  And I click "Submit" link
  Then I should be on the home page
  And I should see "Successfully logged in Thomas"
  And I should not see "Register"
```

Add the following step definition, reusing some previous steps:

```ruby
# features/step_definitions/application_steps.rb

...
Given(/^I am a registered user$/) do
  steps %(
    Given I am on the home page
    And I click "Register" link
    Then I should be on Registration page
    And I fill in "Name" with "Thomas"
    And I fill in "Email" with "thomas@random.com"
    And I fill in "Password" with "my_password"
    And I fill in "Password confirmation" with "my_password"
    And I click "Create" link
  )
end
```

Run `cucumber` (`cucumber features/user_maintenance.feature`)


Update your `application.erb` by adding the `Log in` link:

```HTML+ERB
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

Add the following routes to `application.rb`

```ruby
# lib/application.rb

get '/users/login' do
  erb :'users/login'
end

post '/users/session' do
  session[:flash] = "Successfully logged in ..."
  redirect '/'
end
```

Create a `login.erb` file in the `views/users` folder:

```HTML+ERB
# lib/views/users/login.erb

<% form_tag('/users/session', method: 'post') do %>
  <%= label_tag :email, caption: 'Email' %>
  <%= text_field_tag :email, id: 'email' %>

  <%= label_tag :password, caption: 'Password' %>
  <%= password_field_tag :password, id: 'password' %>

  <%= submit_tag 'Submit' %>
<% end %>
```

Shifting our attention to the `User` model. We need to add a `authenticate` method to `User`.

Let’s start by writing some specs.

```ruby
# spec/user_spec.rb

...
  describe 'user authentication' do
    before { @user = User.create(name: 'Thomas', email: 'thomas@makersacademy.se', password: 'password', password_confirmation: 'password') }

    it 'succeeds with valid credentials' do
      expect(User.authenticate('thomas@makersacademy.se', 'password')).to eq @user
    end

    it 'fails with invalid credentials' do
      expect(User.authenticate('thomas@makersacademy.se', 'wrong-password')).to eq nil
    end
  end
...
```

Again, run `rspec` and see the tests fail.

Add the `authenticate` method to the User class:

```ruby
# lib/user.rb

...
def self.authenticate(email, password)
    user = first(email: email)
    if user && BCrypt::Password.new(user.password_digest) == password
      user
    else
      nil
    end
  end
...
```

These test will still fail...

We need to add DatabaseCleaner to the `spec_helper.rb`

```ruby
# spec/spec_helper.rb

require 'database_cleaner'
...
RSpec.configure do |config|
  ...
  config.before(:suite) do
  	DatabaseCleaner.strategy = :transaction
  	DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
  	DatabaseCleaner.clean
  end
  ...
end
```

And now all the tests go green.

Back to the main controller. Change the `post` route to:

```ruby
# lib/application.rb

...
  post '/users/session' do
    @user = User.authenticate(params[:email], params[:password])
    session[:user_id] = @user.id
    session[:flash] = "Successfully logged in  #{@user.name}"
    redirect '/'
  end
...
```

Also, in the same file, we need to add some methods to be able to access the currently logged in user:

```ruby
# lib/application.rb

...
  before do
    @user = User.get(session[:user_id]) unless is_user?
  end

  register do
    def auth (type)
      condition do
        redirect '/login' unless send("is_#{type}?")
      end
    end
  end

  helpers do
    def is_user?
      @user != nil
    end

    def current_user
      @user
    end
  end
...
```

We only want to show the `Log in` link if there is no user logged in, right? Update your `application.erb` by adding a condition for the display of the Log in link:

```HTML+ERB
# lib/views/layouts/application.erb`

<% if current_user %>
  <%= current_user.email %>
<% else %>
  <%= link_to 'Register', '/users/register' %>
  <%= link_to 'Log in', '/users/login' %>
<% end %>
...
```

If you run `cucumber` now, all your steps should go green. Time to set up the log out feature.

[Step 11](step11.md)
