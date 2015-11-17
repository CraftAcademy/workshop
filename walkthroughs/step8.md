##### Adding users

We are not done with all the user stories related to creating and maintaining courses. Far from. But for the moment, we are going to focus on users.

We already touched upn the need to have an administrator and we kind of brushed it off while working on the first course scenario.

Lets have a look at that again and add a User class.

First some background.

This application will only one type of user that will have access to it functionality apart from viewing content - that will be tha Course Administrator.
All other users that we will need information about are, of course the Course Participants, but that data will only be needed for processing, we will not allow them to actually log in to the application and perform any tasks.
The ability to view and validate course certificates will not require a log in - this feature will be open to anonymous visitors.

Okay, having that i mind lets start writing some user stories:

``
As a employee of a education institution
In order to access all features of the application
I would like to be given access by creating an administration account
```

```
As a potential administrator
In order to be given access
I would like to create an account
```

``
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

Scenario: Log out from tha application
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



