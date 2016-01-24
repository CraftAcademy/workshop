### Verification stats

One of the initial user stories that we defined was:

```
As a course administrator,
In order to know how often my verification system is being used
I want to track every call to a verification url
```

That is the feature we will be working on right now.

Before we start developing this feature I would like to take a moment and talk about one of the principles that guide me in my work - to write new code only if I have to. Every new line of code I write is code that needs to be tested, potentially debugged, understood and definitely supported.
It's painful for most software developers to acknowledge this, because we love code so much, but **the best code is no code at all**!

So if we don't need to write any code but still implement a feature and solve a problem - then that must be a good thing, right?

That is exactly what we're going to do with this particular feature.

My idea is that we can use the link shortening service [bit.ly](https://bitly.com) that, apart from shortening url's, also provides simple analytics.

We are going to use a ruby wrapper around the BitLy API - found at [github.com/philnash/bitly](https://github.com/philnash/bitly).

This way, we will not have write our own tracking module AND we get to display a shorter validation link on the certificate.

We start with adding the gem to our `Gemfile`:

```ruby
# Gemfile

gem 'bitly'
```

As always, run `bundle install` to install the new dependency.

In your `.env` file, add two environmental variables:

```yml
# .env

...
BITLY_USERNAME = < bit.ly username >
BITLY_API_KEY= < bit.ly api key >
```

You'll get those credentials if you sign up for Bit.ly, go to your profile settings (Advanced) and look under the Legacy API Key section.

If you have deployed your application to Heroku, you need to save your credentials as vars on your application as well:

```shell
$ heroku config:set BITLY_USERNAME=< bit.ly username >
$ heroku config:set BITLY_API_KEY=< bit.ly api key >

# On your deployed app add:
$ heroku config:set SERVER_URL=< your heroku url WITH an extra '/verify/' at the end <- Important! >
```
Add the following code to your `certificate_generator.rb`:

```ruby
# lib/certificate_generator.rb

require 'prawn'
require 'rmagick'
require 'aws-sdk'
if ENV['RACK_ENV'] != 'production'
  require 'dotenv'
end
require 'bitly'

module CertificateGenerator
  if ENV['RACK_ENV'] != 'production'
    Dotenv.load
  end
  Bitly.use_api_version_3
  CURRENT_ENV = ENV['RACK_ENV'] || 'development'
  PATH = "pdf/#{CURRENT_ENV}/"
  TEMPLATE = File.absolute_path('./pdf/templates/certificate_tpl.jpg')
  URL = ENV['SERVER_URL'] || 'http://localhost:9292/verify/'
  S3 = Aws::S3::Resource.new(region: ENV['AWS_REGION'])
  BITLY = Bitly.new(ENV['BITLY_USERNAME'], ENV['BITLY_API_KEY'])

  def self.generate(certificate)
    details = {name: certificate.student.full_name,
               date: certificate.delivery.start_date.to_s,
               course_name: certificate.delivery.course.title,
               course_desc: certificate.delivery.course.description,
               verify_url: [URL, certificate.identifier].join('')}

    file_name = [details[:name], details[:date], details[:course_name]].join('_').downcase.gsub!(/\s/, '_')

    certificate_output = "#{PATH}#{file_name}.pdf"
    image_output = "#{PATH}#{file_name}.jpg"

    make_prawn_document(details, certificate_output)
    make_rmagic_image(certificate_output, image_output)

    upload_to_s3(certificate_output, image_output)

    if ENV['RACK_ENV'] != 'test'
       send_email(details, file_name)
    end

    { certificate_key: certificate_output, image_key: image_output }
  end

  private

  def self.make_prawn_document(details, output)
    File.delete(output) if File.exist?(output)

    Prawn::Document.generate(output,
                             page_size: 'A4',
                             background: TEMPLATE,
                             background_scale: 0.8231,
                             page_layout: :landscape,
                             left_margin: 30,
                             right_margin: 40,
                             top_margin: 7,
                             bottom_margin: 0,
                             skip_encoding: true) do |pdf|
      pdf.move_down 245
      pdf.font 'assets/fonts/Gotham-Bold.ttf'
      pdf.text details[:name], size: 44, color: '009900', align: :center
      pdf.move_down 20
      pdf.font 'assets/fonts/Gotham-Medium.ttf'
      pdf.text details[:course_name], indent_paragraphs: 150, size: 20
      pdf.text details[:course_desc], indent_paragraphs: 150, size: 20
      pdf.move_down 95
      pdf.text "Göteborg #{details[:date]}", indent_paragraphs: 120, size: 12
      pdf.move_down 65
      pdf.text "To verify this certificate, visit: #{get_url(details[:verify_url])}", indent_paragraphs: 100, size: 8
    end
  end

  def self.make_rmagic_image(certificate_output, output)
    im = Magick::Image.read(certificate_output)
    im[0].write(output)
  end

  def self.upload_to_s3(certificate_output, image_output)
    s3_certificate_object = S3.bucket(ENV['S3_BUCKET']).object(certificate_output)
    s3_certificate_object.upload_file(certificate_output, acl: 'public-read')
    s3_image_object = S3.bucket(ENV['S3_BUCKET']).object(image_output)
    s3_image_object.upload_file(image_output, acl: 'public-read')
  end

  def self.get_url(url)
    begin
      BITLY.shorten(url).short_url
    rescue
      url
    end
  end

end
```

##### Displaying stats

We need to retrieve stats from bit.ly in two steps.

1. Identify the resource using the `lookup` method
2. Get the statistics by using the `global_clicks` method

First we need the `Certificate` to respond to a new method that will give us the verification url. In your `certificate_spcec.rb` add the following test:

```ruby
# specs/certificate_spec.rb

...
# in the main describe block:

it 'returns #bitly_lookup' do
  expect(@certificate.bitly_lookup).to eq "http://localhost:9292/verify/#{@certificate.identifier}"
end

it 'returns #stats' do
  expect(@certificate.stats).to eq 0
end

```

And implement the methods:

```ruby
# lib/certificate.rb

require 'bitly'

...
def stats
  Bitly.use_api_version_3
  bitly = Bitly.new(ENV['BITLY_USERNAME'], ENV['BITLY_API_KEY'])
  begin
    bitly.lookup(self.bitly_lookup).global_clicks
  rescue
    0
  end
end

def bitly_lookup
  server = ENV['SERVER_URL'] || 'http://localhost:9292/verify/'
  "#{server}#{self.identifier}"
end
...
```

At this point we have access to an `Certificate` instance method `#stats` that will return the total amount of clicks for us. We can use that on our view:

```erb
# lib/views/valid.erb

<h3 style="color: #368a55">Valid course certificate for</h3>

<h2><%= link_to @certificate.student.full_name, @certificate.certificate_url %></h2>
<p><%= link_to @certificate.delivery.course.title, "/courses/delivery/show/#{@certificate.delivery.id}" %></p>
<p>Course date: <%= @certificate.delivery.start_date %></p>
<% if @certificate.stats != 0 %>
  <div>
    Viewed <%= @certificate.stats %> <%= @certificate.stats == 1 ? 'time' : 'times' %>
  </div>

<% end %>
<div>
  <img src="<%= @certificate.image_url %>"/>
</div>
```

With this changes we are getting the click count on the valid certificate show page (`valid.erb`). 

We have successfully set up a link shortening service, displayed the link on the generated certificate and we are accessing the analytic functionality of Bit.ly. 

**Not bad for an hours work, right?**


