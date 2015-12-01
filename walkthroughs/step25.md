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
Run that scenario by pointing cucumber to the line of code where it starts:

```shell
$ cucumber features/certificate_generation.feature:7
```

We want to install a gem that helps us to send emails from the application. As a first step we will do the simplest implementation we possibly can.

Let's add [Mail](https://github.com/mikel/mail) to our `Gemfile` and run `bundle`

```ruby
# Gemfile

gem 'mail'
```

In our controller, we add a configuration block:

```ruby
# lib/application.rb

...
Mail.defaults do
  delivery_method :smtp, {
    address: 'smtp.gmail.com',
    port: '587',
    user_name: ENV['GMAIL_ADDRESS'],
    password: ENV['GMAIL_PASSWORD'],
    authentication: :plain,
    enable_starttls_auto: true
  }
end
...
```

And, of course, you need to update your `.env` file with those variables:

```yml
# .env

...
GMAIL_ADDRESS=<your gmail email address>
GMAIL_PASSWORD=<your gmail password>
```
**I can not stress this enough - MAKE SURE THAT `.env` IS OUTSIDE YOUR VERSION CONTROL**

Okay, moving on.

In `certificate_generator.rb` add the key `:email` to the `details` hash:

```ruby
# lib/certificate_generator.rb

...
details = {name: certificate.student.full_name,
           email: certificate.student.email,
           date: certificate.delivery.start_date.to_s,
           course_name: certificate.delivery.course.title,
           course_desc: certificate.delivery.course.description,
           verify_url: [URL, certificate.identifier].join('')}
...
```

Also, add a method called `send_email` to that module. That method needs to have access to the `details` hash, so we are going to allow it to take two arguments:

```ruby
# lib/certificate_generator.rb

...
 def self.send_email(details, file)
    mail = Mail.new do
      from     "The course team <#{ENV['GMAIL_ADDRESS']}>"
      to       "#{details[:name]} <#{details[:email]}>"
      subject  "Course Certificate - #{details[:course_name]}"
      body     File.read('pdf/templates/body.txt')
      add_file filename: "#{PATH}#{file}.pdf", mime_type: 'application/x-pdf', content: File.read("#{PATH}#{file}.pdf")
    end
    mail.deliver
  end
...
```

Create a file named `body.txt` in `pdf/templates` folder:

```shell
$ touch pdf/templates/body.txt
```

Add some content to that file:

```text
# pdf/templates/body.txt

Hello,

This is your Course Certificate.

Live Long And Prosper!

/The Course Ppl
```

We could personalize this message, but for now some static content will do.

Another update we need to make is again in the `certificate_generator.rb` We need to call the `send_email` method from the `generate` method in order to actually send the message with the certificate attached to it:


```ruby
# lib/certificate_generator.rb

...
def self.generate(certificate)
  ...
  if ENV['RACK_ENV'] != 'test'
    send_email(details, file_name)
  end

  certificate.update(certificate_key: certificate_output, image_key: image_output )
end
...
```





