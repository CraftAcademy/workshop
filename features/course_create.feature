Feature: As a course administrator,
  In order to be able to issue certificates,
  I want to be able to create a course offering with a description and multiple delivery dates

Scenario: List courses
  Given I am on the home page
  And I am logged in as an administrator
  And I click "All courses" link
  Then I should see "You have not created any courses"

Scenario: Create a course
  Given I am on the home page
  And I am logged in as an administrator
  And I click "All courses" link
  And I click "Create course" link
  And I fill in "Course Name" with "Basic programming"
  And I fill in "Course description" with "Your first step into the world of programming"
  And I click "Create course" link
  Then a new "Course" should be created
  And I should be on the Course index page
  And I should see "Basic programming"