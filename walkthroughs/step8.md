##### Adding users

We are not done with all the user stories related to creating and maintaining courses. Far from. But for the moment, we are going to focus on users.

We already touched upn the need to have an administrator and we kind of brushed it off while working on the first course scenario.

Lets have a look at that again and add a User class.

First some background.

This application will only one type of user that will have access to it functionality apart from viewing content - that will be tha Course Administrator.
All other users that we will need information about are, of course the Course Participants, but that data will only be needed for processing, we will not allow them to actually log in to the application and perform any tasks.
The ability to view and validate course certificates will not require a log in - this feature will be open to anonymous visitors.

Okay, having that i mind lets start writing some user stories:

```
As a employee of a education institution
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

Lets start with some acceptance tests (Cucumner).

In your `features` folder, create a file named `user_maintenance.feature`. Write some headlines for the scenarios we will be working on:

```ruby
# features/user_maintenance.feature

Feature: As a employee of a education institution
  In order to access all features of the application
  I would like to be given access by creating an administration account

Scenario: Create an account

Scenario: Log in to the application

Scenario: Log out from the application
```

Lets add some steps to the `Create an account` scenario:

```ruby
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
  Then a new "User" should be created
  And I should see "Your account has been created, Thomas"
```

Okay, looks pretty straight forward, right? Lets run it. Remember how?

We are failing on tha second step:

```
Unable to find link or button "Register" (Capybara::ElementNotFound)
```

Lets add that link to the `layout.erb` (it is located in the `lib/views` folder)

```HTML+ERB
<%= link_to 'Register', '/users/register' %>

<%= yield %>
```

After every addition, keep on running `cucumber` and see if you get a new error message.

Open up the `features/support/paths.rb` file and add the route to `/users/ registration`:

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

The next step is to create a folder named `users` as a subfolder to `lib/views` and create a `register.erb`file in that folder.

Place the following `form_for` code in that file:

```ruby
# views/users/register.erb
<% form_for :user, '/users/create', id: 'create' do |f|  %>
  <%#= f.error_messages %>
  <%= f.text_field_block :name, caption: 'Name' %>
  <%= f.text_field_block :email, caption: 'Email' %>
  <%= f.password_field_block :password, caption: 'Password'  %>
  <%= f.password_field_block :password_confirmation, caption: 'Password confirmation'  %>
  <%= f.submit 'Register' %>
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

As we did before, let's quit Cucumber for a moment and focus on writing specs for our `User` class.

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

Run Rspec and see the tests fail.

Now open the `lib/user.rb` file and define tha properties:

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

That is, of course, because we haw no method that actually creates the User in our controller yet. Let's create that:

```ruby
# lib/application.rb

  post 'users/create' do
    User.create(name: params[:user][:name], email: params[:user][:email], password_digest: params[:user][:password] )
    redirect '/'
  end
```

And that creates a User for us.

But we also want to give the user fome sort of feedback that the account has been created, right? (That is the last step in the scenario we are working on)

In order to do that we need to enable sessions that can, among other things, be used to pass information between the controller and the view.

Firs, in your `application.rb`, inside your class, add the following setting:

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

<% if sesion[:flash] %>
  <%= session[:flash] %>
  <% session[:flash].clear %>
<% end %>
```

And, finally, in your main controller, on the post route, add:

```ruby
# lib/application.rb

  post 'users/create' do
    User.create(name: params[:user][:name], email: params[:user][:email], password_digest: params[:user][:password] )
    session[:flash] = "Your account has been created, #{params[:user][:name]}"
    redirect '/'
  end
```

That should do it for the user, right. Well, not quite... ;-)

[Step 9](step9.md)















