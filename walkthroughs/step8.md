#### Adding a User

We are not done with all the user stories related to creating and maintaining courses. Far from it. But for the moment, we are going to focus on users.

We already touched on the need to have an administrator and we kind of brushed it off while working on the first course scenario.

Let’s have a look at that again and add a User class.

First some background.

The features that allow users to create accounts (and edit or delete their profiles) are called user management features. Allowing users to sign in and identify themselves is called authentication. Typically, we request an email address and a password to authenticate the user, so we can be sure whoever is signing in is the same person who created the account.

It’s important to distinguish authentication, which identifies a user, from authorization, which controls what a user is allowed to do.

This application will only have one type of user that will have access to its functionality apart from viewing content - that will be the Course Administrator.
All other users that we will need information about are, of course the Course Participants, but that data will only be needed for processing, we will not allow them to actually log in to the application and perform any tasks.
The ability to view and validate course certificates will not require a log in - this feature will be open to anonymous visitors.

Okay, having that i mind let's start writing some user stories:

```
As an employee of an education institution
In order to access all features of the application
I would like to be given access by creating an administration account
```

```
As a potential administrator
In order to be given access
I would like to create an account
```

```
As a administrator
In order to be able to return to the application
I would like my credentials to be saved/persisted
```

Something like that. Basically, we want to create a mechanism for users to sign up and log in to the application. We also want to restrict access to some of the applications functionality for users that are logged in.

Let’s start with some acceptance tests (`Cucumber`).

In your `features` folder, create a file named `user_maintenance.feature`. Write some headlines for the scenarios we will be working on:

```gherkin
# features/user_maintenance.feature

Feature: As an employee of an education institution
  In order to access all features of the application
  I would like to be given access by creating an administration account

Scenario: Create an account

Scenario: Log in to the application

Scenario: Log out from the application
```

Let’s add some steps to the `Create an account` scenario:

```gherkin
# feature/user_maintenance.feature

...
Scenario: Create an account
  Given I am on the home page
  And I click "Register" link
  Then I should be on Registration page
  And I fill in "Name" with "Thomas"
  And I fill in "Email" with "thomas@random.com"
  And I fill in "Password" with "my_password"
  And I fill in "Password confirmation" with "my_password"
  And I click "Create" link
  Then a new "User" should be created
  And I should see "Your account has been created, Thomas"
```

Okay, looks pretty straight forward, right? Let’s run it. Remember how?

We are failing on the second step:

```
Unable to find link or button "Register" (Capybara::ElementNotFound)
```

Let’s add that link to the `application.erb` (it is located in the `lib/views/layouts` folder, remember?)

```html
# lib/views/layouts/application.erb

<%= link_to 'Register', '/users/register' %>

<%= yield %>
```

After every addition, keep on running `cucumber` and see if you get a new error message.

The 'Register link' step should now pass and the next test should fail with an error message similar to the following:

```shell
Then I should be on Registration page                    # features/step_definitions/web_steps.rb:195
  Can't find mapping from "Registration page" to a path.
  Now, go and add a mapping in /path/to/project/folder/features/support/paths.rb (RuntimeError)
  ./features/support/paths.rb:18:in `path_to'
  ./features/step_definitions/web_steps.rb:198:in `/^(?:|I )should be on (.+)$/'
  ./features/support/database_cleaner.rb:7:in `block in <top (required)>'
  features/user_maintenance.feature:8:in `Then I should be on Registration page'
```

In order to fixe this, open up the `features/support/paths.rb` file and add the route to users registration page:

```ruby
# features/support/paths.rb

when /Registration page/
  '/users/register'
```
And also add that route to you main controller, the `application.rb

```ruby
# lib/application.rb

get '/users/register' do
  erb :'users/register'
end
```

The next step is to create a folder named `users` as a subfolder to `lib/views` and create a `register.erb` file in that folder.

Place the following `form_for` code in that file:

```ruby
# views/users/register.erb

<% form_for :user, '/users/create', id: 'create' do |f|  %>
  <%#= f.error_messages %>
  <%= f.text_field_block :name, caption: 'Name' %>
  <%= f.text_field_block :email, caption: 'Email' %>
  <%= f.password_field_block :password, caption: 'Password'  %>
  <%= f.password_field_block :password_confirmation, caption: 'Password confirmation'  %>
  <%= f.submit 'Create' %>
<% end %>
```

Okay, now when you run `cucumber` again (as you do after every addition in order to keep track of the changing error messages), you should see a familiar error:

```
And I click "Register" link          # features/step_definitions/application_steps.rb:7
  uninitialized constant User (NameError)
```

Remember what we did last time we saw a similar error? We created a `Course` class. Now, we need to create a `User` class.

In your `lib` folder, add a file named `user.rb` and add this simple class definition:

```ruby
# lib/user.rb

class User

end
```

Also, don't forget to require that file in your `application.rb`

```ruby
# lib/application.rb

require './lib/user'
...
```

Great! If you run `cucumber` now you will get the following error:

```shell
Then a new "User" should be created                      # features/step_definitions/application_steps.rb:10
  undefined method `count' for User:Class (NoMethodError)
  ./features/step_definitions/application_steps.rb:11:in `/^a new "([^"]*)" should be created$/'
  ./features/support/database_cleaner.rb:7:in `block in <top (required)>'
  features/user_maintenance.feature:14:in `Then a new "User" should be created'
```

As we did before, now is a good time to switch from our acceptance tests (`cucumber`) to writing some unit tests for our `User` class using `rspec`.

In the `spec` folder, create a file named `user_spec.rb`and add the following specs:

```ruby
# spec/user_spec.rb

describe User do
  it { is_expected.to have_property :id }
  it { is_expected.to have_property :name }
  it { is_expected.to have_property :email }
  it { is_expected.to have_property :password_digest }
end
```

Run `rspec` and see the tests fail.

Now open the `lib/user.rb` file and define the properties:

```ruby
# lib/user.rb

class User
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :email, String
  property :password_digest, Text
end
```

Now when you run `rspec` your tests should go all green. But when you return to `cucumber` you should see:

```
 Then a new "User" should be created                      # features/step_definitions/application_steps.rb:15

      expected: 1
           got: 0
```

That is, of course, because we have no method that actually creates the `User` in our controller yet. Let's create that:

```ruby
# lib/application.rb
...
  post '/users/create' do
    User.create(name: params[:user][:name], email: params[:user][:email], password_digest: params[:user][:password] )
    redirect '/'
  end
...
```

And that creates a User for us.

But we also want to give the user some sort of feedback that the account has been created, right? (That is the last step in the scenario we are working on)

In order to do that we need to enable sessions that can, among other things, be used to pass information between the controller and the view.

First, in your `application.rb`, inside your class, add the following setting:

```ruby
# lib/application.rb

...
  enable :sessions
  set :session_secret, '11223344556677' #`or whatever you fancy as a secret.
...
```

Then, in your `application.erb` (the layout template), add this code that will display the message:

```HTML+ERB
# lib/views/layouts/application.erb

<% if session[:flash] %>
  <%= session[:flash] %>
  <% session[:flash].clear %>
<% end %>
```

And, finally, in your main controller, on the post route, add:

```ruby
# lib/application.rb
...
  post 'users/create' do
    User.create(name: params[:user][:name],
                email: params[:user][:email],
                password_digest: params[:user][:password] )
    session[:flash] = "Your account has been created, #{params[:user][:name]}"
    redirect '/'
  end
...
```

That should do it for the user, right? Well, not quite... :wink:


