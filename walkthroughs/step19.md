#### The verification interface

Every `Certificate` we create has a unique identifier. Each generated certificate displays a url that can used to verify the authenticity of the document.

In order for it to work we need to:

1. Create a route in our controller (´application.rb`)
2. Create appropriate templates for valid & invalid certificates
3. Query the database for a certificate using the `identifier`
4. Display the right certificate on the `velid` page
5. Display the `invalid` template if there is no matching certificate

We start with writing a Cucumber feature. Create a new feature file:

```shell
$ touch features/verify_certificate.feature
```

Add the following scenario to that feature file:

```gherkin
# features/verify_certificate.feature

Feature: As a certificate reviewer,
  In order to asses the authenticity of a certificate
  I want to be able to access a web page showing me the certificate information
  by clicking the verification URL

  Scenario: Verify certificate with a valid URL
    Given valid certificates exists
    And I visit the url for a certificate
    Then I should be on the valid certificate page
```

Add the following step definitions to your `application_steps.rb`:

```ruby
# features/support/application_steps.rb

Given(/^valid certificates exists$/) do
  steps %(
    Given the delivery for the course "Basic" is set to "2015-12-01"
    And the data file for "2015-12-01" is imported
    And I am on 2015-12-01 show page
    And I click "Generate certificates" link
  )
end

And(/^I visit the url for a certificate$/) do
  cert = Certificate.last
  visit "/verify/#{cert.identifier}"
end
```

And the following path to your `paths.rb`:

```ruby
# features/support/paths.rb

when /the valid certificate page/
  c = Certificate.last
  "/verify/#{c.identifier}"
```

Keep on running `cucumber` after each addition to see if the error message is changing.
Create the following route to your `application.rb`

```ruby
#  lib/application.rb

...
  # Verification URI
  get '/verify/:hash' do
    @certificate = Certificate.first(identifier: params[:hash])
    if @certificate
      @image = "/img/usr/#{env}/" + [@certificate.student.full_name, @certificate.delivery.start_date].join('_').downcase.gsub!(/\s/, '_') + '.jpg'
      erb :'verify/valid'
    else
      erb :'verify/invalid'
    end
  end
...

```

Now we need to create a subfolder to `views` called `verify` and create the two templates we are going to use. One for a valid certificate and one if the certificate identifier is invalid.

```shell
$ mkdir lib/views/verify
$ touch lib/views/verify/valid.erb
$ touch lib/views/verify/invalid.erb
```

Add the following code to these templates:

```HTML+ERB
# lib/views/verify/valid.erb

<h3 style="color: #368a55">Valid certificate for</h3>
<h2><%= @certificate.student.full_name %></h2>
<p><%= @certificate.delivery.course.title %></p>
<p><%= @certificate.delivery.start_date %></p>

<img src="<%= @image%>" />
```

```HTML+ERB
# lib/views/verify/invalid.erb

<h3 style="color: red">Invalid certificate</h3>
<p>If you are an employer and was presented with a copy of the certificate
  as a part of an CV, know that this is a forged document </p>
<p>Please contact us with information on who gave it to you.</p>
```

Okay, run all your features and specs. Fire up the local server using `rackup` and have a look for yourself.
In order to get the verification url you'll need to access a generated pdf in your file system, open it and copy the link from the bottom of the page.
 Paste it in your browser and you should see the verification page.

Try modifying the long hash and reload the page. Now, you should see a page that uses the `invalid.erb` template.

Personally, I think we've come pretty far!

[Step 20](step20.md)
