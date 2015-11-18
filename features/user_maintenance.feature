Feature: As a employee of a education institution
  In order to access all features of the application
  I would like to be given access by creating an administration account

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

Scenario: Log in to the application
  Given I an a registered user
  Given I am on the home page
  And I click "Log in" link
  Then I should be on Log in page
  And I fill in "Email" with "thomas@random.com"
  And I fill in "Password" with "my_password"
  And I click "Submit" link
  Then I should be on the home page
  And I should see "Successfully logged in Thomas"
  And I should not see "Register"

Scenario: Log out from the application


