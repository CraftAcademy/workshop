##### Adding authentication to User

The problem with the way we have created the user information in the database is that we are saving the password in plain text. That is a big no no.

What we need to do is to encrypt the password before we save it. Then, when the user tries to log in, we need to compare the password he provides with the encrypted password in the database, and if it matches, allow the user in to the system.

There is a gem we can use to encrypt the password before we store it in the database - it is called `BCrypt`and you han find [more info about that gem here](https://github.com/codahale/bcrypt-ruby).

Add that gem to your Gemfile:
```ruby
# Gemfile

gem 'bcrypt'
```
As usual, you run `bundle install` once you add a new dependency.

The next step is to add some specs for the password encryption. In our `user_spec.rb` we add the following tests whithin our main describe block:

```ruby
# spec/user_spec.rb

describe 'password encryption' do
    it 'encrypts password' do
      user = User.create(email: 'test@test.com', password: 'test', password_confirmation: 'test')
      expect(user.password_digest).to_not eq 'test'
      expect(user.password_digest.class).to eq BCrypt::Password
    end

    it 'raises error it password_confirmation does not match' do
      create_user = lambda { User.create(email: 'test@test.com', password: 'test', password_confirmation: 'wrong-test') }
      expect(create_user).to raise_error DataMapper::SaveFailureError
    end
  end
```

In the first of the two specs we are a) creating a user with some credentials, b) asserting that the saved password (`password_digest`) is NOT the onew we passed in while creating the user and
c) that the saved password is of a `BCrypt::Password` class. We can not test for a specific encryption since BCrypt returns a different hash every time it is called on a word.
When this spec passes we can be sure that the right password have been saved in our database.

The second test is testing what happens if we try to create a user but pass in the wrong password confirmation. Password confirmation is mainly used to ensure that the user remembers what password he provides during registration and that he has not made a spelling mistake while typing it in.
First we save a command in a variable and then, on tha next line, we assert that when that command is executed it throws an error. If that passes, we can be sure that
password confirmation works and the user will not be created if password and password_confirmation does not match.

Save your spec file and run RSpec to see these tests fail.

n the first spec we get an failure about attribute `password` not being accessible on User. Let's fix that. Open your `user.rb` and add:

```ruby
# lib/user.rb

class User
  attr_writer :password, :password_confirmation
  ...
end
```

Also, on top of that file add:

```ruby
# lib/user.rb

require 'bcrypt'

class User
  ...
  include BCrypt
  ...
end
```

Once you've added those lines and run RSpec again, you should get the following error on that particular spec:

```
 Failure/Error: expect(user.password_digest.class).to eq BCrypt::Password

   expected: BCrypt::Password
        got: NilClass

   (compared using ==)

   Diff:
   @@ -1,2 +1,2 @@
   -BCrypt::Password
   +NilClass
```

An the second spec we've added, the error message should be:

```
Failure/Error: expect(create_user).to raise_error DataMapper::SaveFailureError
       expected DataMapper::SaveFailureError but nothing was raised
```

Let's move over to the `user.rb` file and fix that.

```ruby
# lib/user.rb
...
  validates_confirmation_of :password, message: 'Sorry, your passwords don\'t match'

  before :save do
    if self.password == self.password_confirmation
      self.password_digest = BCrypt::Password.create(self.password)
    else
      break
    end
  end
...
```

This code validates the confirmation of password and encrypts the password using BCrypt if the confirmation passes the validation.

Now, we need to update the method we use to create the user in the applications controller:

```ruby
# lib/application.rb

...
  post '/users/create' do
    begin
      User.create(name: params[:user][:name],
                  email: params[:user][:email],
                  password: params[:user][:password],
                  password_confirmation: params[:user][:password_confirmation])
      session[:flash] = "Your account has been created, #{params[:user][:name]}"
      redirect '/'
    rescue
      session[:flash] = 'Could not register you... Check your input.'
      redirect '/users/register'
    end
  end
...
```

Now, real quickly head over to the `user_maintenance.feature` and add the following scenario:

```ruby
# features/user_maintenance.feature

Scenario: Fail to create an account
  Given I am on the home page
  And I click "Register" link
  Then I should be on Registration page
  And I fill in "Name" with "Thomas"
  And I fill in "Email" with "thomas@random.com"
  And I fill in "Password" with "my_password"
  And I fill in "Password confirmation" with "wrong_password"
  And I click "Create" link
  Then I should be on Registration page
  And I should see "Could not register you... Check your input."
```
Run `cucumber` and watch it pass. The scenario we just added is called the sad path and is used to test not only what happens when everything is okay but also what happens when stuff go wrong.

Alright, now we have the users password saftly encrypted and saved in our database. The next step is to add a method to authenticate the user when he tries to log in to the application.


[Step 10](step10.md)