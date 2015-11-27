#### Distributing the certificates

```
As a course administrator,
So that the right certificate is delivered to a student,
I would like certificates to be emailed to a students registered email address.
```

Let's start with modifying the `certificate_generation.feature` by adding the following step:

```gherkin
# features/certificate_generation.feature

...
  Then 3 instances of "Certificate" should be created
  And 3 certificates should be generated
  And 3 images of certificates should be created
  And 3 emails with certificates attached should be sent
  And I should see "Generated 3 certificates"
...
```
