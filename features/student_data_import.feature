Feature: As a course administrator
  In order to be able to issue course certificates
  I want to be able to import a datafile with student information


Scenario: Data file upload
  Given the delivery for the course "Basic" is set to "2015-12-01"
  And I am on the Course index page
  And I click on "2015-12-01" for the "Basic programming" Course
  Then I should be on 2015-12-01 show page
  When I select the "students.csv" file
  And I click "Submit" link
  Then 3 instances of "Student" should be created
