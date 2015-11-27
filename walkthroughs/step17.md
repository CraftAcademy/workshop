#### The certificate layout

1. `cd` in to the `pdf` folder and download the certificate layout file from the `workshop-assets` repository.
Again, we are going to use `subversion`:

```shell
svn export https://github.com/MakersSweden/workshop-assets/trunk/templates
```

Now we want to use the layout file as a background and make some changes to where we place the student and course information.

We need to make the following changes to the `CertificateGenerator`:

```ruby
# lib/certificate_generator.rb

module CertificateGenerator

  def self.generate(certificate)
    details = {name: certificate.student.full_name,
               date: certificate.delivery.start_date.to_s,
               course_name: certificate.delivery.course.title,
               course_desc: certificate.delivery.course.description}
    output = "pdf/#{details[:name]}-#{details[:date]}.pdf"
    image = File.absolute_path('./pdf/templates/certificate_tpl.jpg')
    url = "http://my_domain.com/verify/#{certificate.identifier}"
    File.delete(output) if File.exist?(output)
    Prawn::Document.generate(output,
                             page_size: 'A4',
                             background: image,
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
      pdf.text " #{details[:date]}", indent_paragraphs: 135, size: 12
      pdf.move_down 65
      pdf.text "To verify this certificate, visit: #{url}", indent_paragraphs: 100, size: 8
    end
  end

end
```

1. We set the page size to A4 in landscape.
2. We set the background and scale it to fit the page
3. We make use of the fonts that we downloaded with our assets
4. We place the relevant information on the page

Run all your specs now. If you want to actually have a look at one of the certificates, you need to use your debugger and set a break point on one of the specs in your `certificate_spec.rb`

```ruby
# spec/certificate_spec.rb

...
it 'adds an identifier after create' do
  binding.pry
  expect(@certificate.identifier.size).to eq 64
end
...
```

The way we have set up the application and our testing frameworks, we will loose out generated certificates every time we run our test suite. That is not a behavior we desire.
One way to fix that is to separate the folders in which we save the certificates depending on the environment we are in.

Go back to your `certificate_generator.rb` and add a `Constant` on top of the `CertificateGenerator` module and modify the `output` variable:

```ruby
# lib/certificate_generator.rb

module CertificateGenerator

  ENV_PATH = ENV['RACK_ENV'] || 'development'

...

output = "pdf/#{ENV_PATH}/#{details[:name]}-#{details[:date]}.pdf"
...
```

You will need to manually create the 3 folders in your `pdf` folder:

```shell
$ mkdir -p pdf/production
$ mkdir -p pdf/development
$ mkdir -p pdf/test
```

We need to modify the cleaning strategy we configured a while back so that only the `pdf/test` folder is cleaned:

```ruby
# features/support/database_cleaner.rb

...
Around do |scenario, block|
  DatabaseCleaner.cleaning(&block)
  FileUtils.rm_rf Dir['pdf/test/**/*.pdf']
end
...
```

And we also need to update our `after` block in the `certificate_spec.rb`:

```ruby
# spec/certificate_spec.rb

...
describe 'Creating a Certificate' do
...
  after { FileUtils.rm_rf Dir['pdf/test/**/*.pdf'] }
...
```

Finally, we need to do a small refactoring in `application_steps.rb`, adding the subfolder `/test` to the path:

```ruby
# features/step_definitions/application_steps.rb

...
Then(/^([^"]*) certificates should be generated$/) do |count|
  pdf_count = Dir['pdf/test/*.pdf'].length
  expect(pdf_count).to eq count.to_i
end
...
```

When you run your test now, the generated pdf's will be saved in the `pdf/test` folder. Your actual certificates will be saved in the `pdf/development` or the `pdf/production` folders, depending on what environment your server is running on.

[Step 18](step18.md)
