Feature: As an certificate reviewer,
  In order to asses the authenticity of a certificate
  I want to be able to access a webpage showing me the certificate information
  by clicking the verification URL

Scenario: Verify certificate with a valid URL
  Given valid certificates exists
  And I visit the url for a certificate
  Then I should be on the valid certificate page