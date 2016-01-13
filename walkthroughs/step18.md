### Generating images of certificates

We also want to generate images of certificates so that we can display them on the verification page.

Add the following step to your `Generate a certificate` scenario in `certificate_generation.feature`:

```gherkin
# features/certificate_generation.feature

Scenario: Generate a certificate
  ...
  And 3 images of certificates should be created

```

We are going to save the images of the certificates in a subfolder of our `assets/img` folder, named `usr`.
For testing purposes we are going to use a folder named `test`. We'll have separate folders for `development` and `production` environments.

Create the folders and the necessary `.keep` files in your terminal:
```shell
$ mkdir -p assets/img/usr/test
$ mkdir -p assets/img/usr/development
$ mkdir -p assets/img/usr/production

$ touch assets/img/usr/test/.keep
$ touch assets/img/usr/development/.keep
$ touch assets/img/usr/production/.keep
```

Add the following step to your `application_steps.rb`

```ruby
# features/step_definitions/application_steps.rb

And(/^([^"]*) images of certificates should be created$/) do |count|
  image_count = Dir['assets/img/usr/test/**/*.jpg'].length
  expect(image_count).to eq count.to_i
end

```

We also need to update our `database_cleaner.rb` with a command that will purge the `test` folder of images generated for test purposes:

```ruby
# features/support/database_cleaner.rb

Around do |scenario, block|
  ...
  FileUtils.rm_rf Dir['assets/img/usr/test/**/*.jpg']
end
```

Okay, that's our tests. Now we need to implement a solution to actually create an image of the certificate and save it. We are going to use a free software suite to create, edit, compose, or convert bitmap images, called `ImageMagick`. You can read more about `ImageMagick` on [www.imagemagick.org](http://www.imagemagick.org/).

The gem we are going to use is called `RMagick`.


Add `RMagick` to your `Gemfile` and install it with `bundle install`:

```ruby
# Gemfile

gem 'rmagick'
```

The actual implementation is not overly complicated. We are going to place the actual code that generates the image inside the `CertificateGenerator` module:

```ruby
# lib/certificate_generator.rb

require 'rmagick'

module CertificateGenerator
...
  def self.generate(certificate)
  ...
    im = Magick::Image.read(output)
    im[0].write("assets/img/usr/#{ENV_PATH}/" + [details[:name], details[:date]].join('_').downcase.gsub!(/\s/, '_') + '.jpg')
  end
```

Running `cucumber` now should show all tests passing.

The next step is to create a verification page.

