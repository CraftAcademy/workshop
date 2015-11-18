Feature: As a course administrator,
  In order to be able to issue certificates,
  I want to be able to create a course offering with a description and multiple delivery dates

Scenario: List courses
  Given I am on the home page
  Given I am a registered and logged in user
  And I click "All courses" link
  Then I should see "You have not created any courses"

Scenario: Create a course
  Given I am on the home page
  Given I am a registered and logged in user
  And I click "All courses" link
  And I click "Create course" link
  And I fill in "Course Title" with "Basic programming"
  And I fill in "Course description" with "Your first step into the world of programming"
  And I click "Create" link
  Then a new "Course" should be created
  And I should be on the Course index page
  And I should see "Basic programming"

Scenario: Non logged in user can not create course
  Given I am on the home page
  And I click "All courses" link
  Then I should not see "Create course"

Scenario: Non logged in user can not access the create new course page
  Given I am on Create course page
  And I should see "You are not authorized to access this page"

Scenario: Add a delivery date to course
  Given the course "Basic programming" is created
  And I am on the Course index page
  And I click on "Add Delivery date" for the "Basic programming" Course
  Then show me the page
  And I fill in "Start" with "2015-12-01"
  And I click "Submit" link
  Then I should be on the Course index page
  And I should see "Basic programming"
  And I should see "Delivery dates:"
  And I should see "2015-12-01"