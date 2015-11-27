Feature: As a course administrator,
  In order to be able to issue the right certificates for a course,
  I want to be able display course title, course date and the
  participants name on the certificate


Scenario: Generate certificates
  Given the delivery for the course "Basic" is set to "2015-12-01"
  And the data file for "2015-12-01" is imported
  And I am on 2015-12-01 show page
  And I click "Generate certificates" link
  Then 3 instances of "Certificate" should be created
  And 3 certificates should be generated
  And 3 images of certificates should be created
  And I should see "Generated 3 certificates"
  And I should see "Thomas Ochman"
  And I should see "Anders Andersson"
  And I should see "Kalle Karlsson"
  And I should see 3 "view certificate" links

Scenario: Certificate generation is disabled if certificates exists
  Given valid certificates exists
  Then I should not see "Generate certificates"

