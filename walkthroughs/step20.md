#### Storage: AWS

We are going to use Amazon Web Services for storing the generated certificates and images.

##### Set up AWS account

[Instructions on how to set up AWS account with some screen shots?]


##### Create S3 bucket

[Instructions on how to create an S3 bucket with some screen shots?]


##### Configure and implement AWS upload

```ruby
# Gemfile

gem 'aws-sdk'
gem 'dotenv'
```

Let's start with configuring `dotenv`

As early as possible in your application bootstrap process, load `.env`:

```ruby
# lib/application.rb

require 'dotenv'
...

class WorkshopApp < Sinatra::Base
Dotenv.load

...
```
Create a `.env` and `.env.example` file in the project root:

```shell
touch .env
touch .env.example
```

Make sure to exclude the configuration file from version control by adding `.env` to your `.gitignore`:


```ruby
# .gitignore

...
.env
```

Now, set up your credentials in your `.env` file:

```
# .env

S3_BUCKET=< your bucket name >
AWS_REGION=< your bucket region >
AWS_ACCESS_KEY_ID=< your access key id >
AWS_SECRET_ACCESS_KEY=< your secret access key >
```

Let's do some manual testing and upload a file to the S3 bucket

```ruby
# in irb:

s3 = Aws::S3::Resource.new(region:ENV['AWS_REGION'])
obj = s3.bucket(ENV['S3_BUCKET']).object(file)
file = 'pdf/development/Thomas_Ochman-2015-11-23.pdf'
obj.upload_file(file, acl:'public-read')
obj.public_url
```

Let's add two properties to the `Certificate` class:

```ruby
# spec/certificate_spec.rb

it { is_expected.to have_property :certificate_key }
it { is_expected.to have_property :image_key }
```

```ruby
# lib/certificate.rb

...
property :certificate_key, String
property :image_key, String
...
```
We are going to do some major refactoring of the  `CertificateGenerator`, extracting some functionality to private methods and adding a method that will handle our upload to S3:
Update your `certificate_generator.rb` with the following code:
```ruby
# lib/certificate_generator.rb

require 'prawn'
require 'rmagick'
require 'aws-sdk'
require 'dotenv'

module CertificateGenerator
  Dotenv.load!
  CURRENT_ENV = ENV['RACK_ENV'] || 'development'
  PATH = "pdf/#{CURRENT_ENV}/"
  TEMPLATE = File.absolute_path('./pdf/templates/certificate_tpl.jpg')
  URL = ENV['SERVER_URL'] || 'http://localhost:9292/verify/'
  S3 = Aws::S3::Resource.new(region: ENV['AWS_REGION'])

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

    certificate.update(certificate_key: certificate_output, image_key: image_output )
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
      pdf.text "To verify this certificate, visit: #{details[:verify_url]}", indent_paragraphs: 100, size: 8
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

end
```
We also want our `Certificate` class to delete the associated images and pdf's from S3 when the record is deleted. For that,
we need to create an `before :destroy` callback:

```ruby
# lib/certificate.rb

...

before :save do
  student_name = self.student.full_name
  course_name = self.delivery.course.title
  generated_at = self.created_at.to_s
  identifier = Digest::SHA256.hexdigest("#{student_name} - #{course_name} - #{generated_at}")
  self.identifier = identifier
  self.save!
end

before :destroy do
  s3 = Aws::S3::Resource.new(region: ENV['AWS_REGION'])
  bucket = s3.bucket(ENV['S3_BUCKET'])

  certificate_key = bucket.object(self.certificate_key)
  image_key = bucket.object(self.image_key)

  certificate_key.delete
  image_key.delete
end
...
```

Make sure to run all your features and specs. The testing suite will take longer to execute then it used to.
We are actually hitting the AWS cloud storage in our tests (that is in principle a no, no!). There is much room for improvement of the way we
set up our tests, but we will not focus on refactoring our test at this point. The important take away for you is that testing play a vital
supportive role in your development process and needs to be done in a smart way so it not becomes an obstacle.

Anyway, we have now implemented a cloud storage solution in our application. That is huge!


[Step 21](step21.md)


