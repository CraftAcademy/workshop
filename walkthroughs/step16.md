### Rendering certificates

Moving on to actually generating some certificates.

We start with a feature test. Create a new file in your `features` folder, named `certificate_generation.feature` and add the following scenario:

```gherkin
# features/certificate_generation.feature

Feature: As a course administrator,
  In order to be able to issue the right certificates for a course,
  I want to display course title, course date and the
  participants name on the certificate


Scenario: Generate a certificate
  Given the delivery for the course "Basic" is set to "2015-12-01"
  And the data file for "2015-12-01" is imported
  And I am on 2015-12-01 show page
  And I click "Generate certificates" link
  Then 3 certificates should be generated
```

That will do for now. Run `cucumber` and see the tests fail.

Add some new step definition in your `application_steps.rb`

```ruby
# features/step_definitions/application_steps.rb

And(/^the data file for "([^"]*)" is imported$/) do |date|
  steps %q(
    And I am on the Course index page
    And I click on "#{date}" for the "Basic programming" Course
    When I select the "students.csv" file
    And I click "Submit" link
  )
end

Then(/^([^"]*) certificates should be generated$/) do |count|
  pdf_count = Dir['pdf/**/*.pdf'].length
  expect(pdf_count).to eq count.to_i
end
```

Also, add the `Generate certificates` link to the `deliveries/show.erb` template:

```erb
# lib/views/courses/deliveries/show.erb

...
<div>
  <% if @delivery.students.any? %>
    Students:
    <% @delivery.students.each do |student| %>
      <%= [student.full_name, ''].join(' ') %>
    <% end %>
    <div>
      <%= link_to 'Generate certificates', "/courses/generate/#{@delivery.id}" %>
    </div>
  <% end %>
</div>
```

Okay, running the scenario now will tell us that no certificates have been created:

```shell
$ cucumber features/certificate_generation.feature
Feature: As a course administrator,
  In order to be able to issue the right certificates for a course,
  I want to be able display course title, course date and the
  participants name on the certificate

  Scenario: Generate a certificate                                   # features/certificate_generation.feature:7
    Given the delivery for the course "Basic" is set to "2015-12-01" # features/step_definitions/application_steps.rb:56
    And the data file for "2015-12-01" is imported                   # features/step_definitions/application_steps.rb:66
    And I am on 2015-12-01 show page                                 # features/step_definitions/web_steps.rb:19
    And I click "Generate certificates" link                         # features/step_definitions/application_steps.rb:3
    Then 3 certificates should be generated                          # features/step_definitions/application_steps.rb:85

      expected: 3
           got: 0

      (compared using ==)
       (RSpec::Expectations::ExpectationNotMetError)
      ./features/step_definitions/application_steps.rb:87:in `/^([^"]*) certificates should be generated$/'
      ./features/support/database_cleaner.rb:7:in `block in <top (required)>'
      features/certificate_generation.feature:12:in `Then 3 certificates should be generated'

Failing Scenarios:
cucumber features/certificate_generation.feature:7 # Scenario: Generate a certificate

1 scenario (1 failed)
5 steps (1 failed, 4 passed)
0m0.467s
```

This is as far as we can go with our feature test at the moment. Let's create a `Certificate` class and the module for generating pdf's.

From your terminal, run these commands to create your spec and tour class file:

```shell
$ touch spec/certificate_spec.rb
$ touch lib/certificate.rb
```

Make sure you require the class file in your controller:

```ruby
# lib/application.rb

require './lib/certificate'
```


Let's start with adding some specs:

```ruby
# spec/certificate_spec.rb

describe Certificate do
  it { is_expected.to have_property :id }
  it { is_expected.to have_property :identifier }

  it { is_expected.to belong_to :delivery }
  it { is_expected.to belong_to :student }
end
```

And add the class definition:

```ruby
# lib/certificate.rb

class Certificate
  include DataMapper::Resource

  property :id, Serial
  property :identifier, Object
  property :created_at, ParanoidDateTime

  belongs_to :delivery
  belongs_to :student
end
```

Make sure you run your specs after every update.

We also need to update relationship in the `Student` models. We start by writing specs for that:

```ruby
# spec/student_spec.rb

...
it { is_expected.to have_many :certificates }
...
```

Then the implementation

```ruby
# lib/student.rb

...
has n, :certificates
...
```


We are going to add a mechanism to generate a unique identifier for each certificate using a callback that will be invoked when the Certificate is created. We also want to make sure that the certificate has access to all the relevant information that we are going to use while creating the pdf.

In the `certificate_spec.rb` add the following test:

```ruby
# spec/certificate_spec.rb

...
describe 'Creating a Certificate' do
  before do
    course = Course.create(title: 'Learn To Code 101', description: 'Introduction to programming')
    delivery = course.deliveries.create(start_date: '2015-01-01')
    student = delivery.students.create(full_name: 'Thomas Ochman', email: 'thomas@random.com')
    @certificate = student.certificates.create(created_at: DateTime.now, delivery: delivery)
  end

  it 'adds an identifier after create' do
    expect(@certificate.identifier.size).to eq 64
  end

  it 'has a Student name' do
    expect(@certificate.student.full_name).to eq 'Thomas Ochman'
  end

  it 'has a Course name' do
    expect(@certificate.delivery.course.title).to eq 'Learn To Code 101'
  end

  it 'has a Course delivery date' do
    expect(@certificate.delivery.start_date.to_s).to eq '2015-01-01'
  end
end
```
And make the following additions to your `Certificate` class:

```ruby
# lib/certificate.rb

class Certificate
...
  before :save do
    student_name = self.student.full_name
    course_name = self.delivery.course.title
    generated_at = self.created_at.to_s
    self.identifier = Digest::SHA256.hexdigest("#{student_name} - #{course_name} - #{generated_at}")
    self.save
  end

end
```

If you run into some errors with the database you need to add the following code to your `spec_helper.rb`:

```ruby
# spec/spec_helper.rb

...
DataMapper.auto_migrate!
...
```

Now we need to add a module that will handle the pdf creation for us. We will be using a gem called `Prawn`.
[Prawn](https://github.com/prawnpdf/prawn) is a PDF document generator for Ruby.

Let's start by adding it to our `Gemfile` and install it using `bundle install`

```ruby
# Gemfile

gem 'prawn'
```

(Since we'll only be using Prawn in our pdf generation module, we don't need to load it in our controller.)

Create a new file called `certificate_generator.rb` in your `lib` folder and add the following code to it:

```ruby
# lib/certificate_generator.rb

require 'prawn'

module CertificateGenerator

  def self.generate(certificate)
    details = {name: certificate.student.full_name,
               date: certificate.delivery.start_date.to_s,
               course_name: certificate.delivery.course.title,
               course_desc: certificate.delivery.course.description}
    output = "pdf/#{details[:name]}-#{details[:date]}.pdf"
    File.delete(output) if File.exist?(output)
    Prawn::Document.generate(output) do |pdf|
      pdf.text 'CERTIFICATE'
      pdf.text 'This is to certify, that'
      pdf.text details[:name]
      pdf.text 'has successfully participated in '
      pdf.text details[:course_name]
      pdf.text details[:course_desc]
      pdf.text "Issued on #{details[:date]}"
      pdf.text certificate.identifier
    end
  end
end
```

Modify your `Certificate` class by adding an `after :create` callback to it so that we invoke the `CertificateGenerator` every time an instance of `Certificate` is created:

```ruby
# lib/certificate.rb

require './lib/certificate_generator'

class Certificate
  include CertificateGenerator
...
  after :create do
    CertificateGenerator.generate(self)
  end
...
```

Alright, let's shift our attention back to the controller and the feature tests. We left off with the failing step that tested if 3 certificate was being created, remember?

```shell

Then 3 certificates should be generated         # features/step_definitions/application_steps.rb:85

  expected: 3
       got: 0
```

We need to create a route and tell it that we want to generate a certificate for each `Student` that has a relationship with that `Delivery`

```ruby
# lib/application.rb

get '/courses/generate/:id' do
  @delivery = Delivery.get(params[:id])
  @delivery.students.each do |student|
    c = student.certificates.new(created_at: DateTime.now, delivery: @delivery)
    c.save
  end
  redirect "/courses/deliveries/show/#{@delivery.id}"
end
```

Before we run our tests again head over to your terminal and create a folder named `pdf`

```shell
$ mkdir pdf
```

Now run your tests with `cucumber features/certificate_generation.feature`

We will be getting some conflicts in our tests if we keep the generated pdf's in the `pdf` folder while running our tests. We need to clear that folder after each run. In our database cleaner strategy, let's add a command to purge all files from that directory after each test:

```ruby
# features/support/database_cleaner.rb

...
Around do |scenario, block|
  DatabaseCleaner.cleaning(&block)
  FileUtils.rm_rf Dir['pdf/**/*.pdf']
end
...
```

And in our `certificate_spec.rb` we can add an `after` action to the `describe` block that tests the generator:

```ruby
# spec/certificate_spec.rb

...
describe 'Creating a Certificate' do
  before do
    course = Course.create(title: 'Learn To Code 101', description: 'Introduction to programming')
    delivery = course.deliveries.create(start_date: '2015-01-01')
    student = delivery.students.create(full_name: 'Thomas Ochman', email: 'thomas@random.com')
    @certificate = student.certificates.create(created_at: DateTime.now, delivery: delivery)
  end

  after { FileUtils.rm_rf Dir['pdf/**/*.pdf'] }
...
```

That pretty much concludes this part. In the next step we will make the certificate look a little better with a custom background, fonts and colors.


[Step 17](step17.md)
