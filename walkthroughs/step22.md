#### Refactor the verification view

We want to be able to retrieve the files from S3 using a http request. For that we need to have access to a URL.

Add the following specs to your `certificate_spec.rb`

```ruby
# spec/certificate_spec.rb


describe 'Creating a Certificate' do
...
    describe 'S3' do
      before { CertificateGenerator.generate(@certificate) }

      it 'can be fetched by #image_url' do
        expect(@certificate.image_url).to eq 'https://certz.s3.amazonaws.com/pdf/test/thomas_ochman_2015-01-01.jpg'
      end

      it 'can be fetched by #certificate_url' do
        expect(@certificate.certificate_url).to eq 'https://certz.s3.amazonaws.com/pdf/test/thomas_ochman_2015-01-01.pdf'
      end
    end
end

```

Add the following methods to your `certificate.rb`

```ruby
# lib/certificate.rb

...
 def image_url
    "https://#{ENV['S3_BUCKET']}.s3.amazonaws.com/#{self.image_key}"
  end

  def certificate_url
    "https://#{ENV['S3_BUCKET']}.s3.amazonaws.com/#{self.certificate_key}"
  end

...
```

And now, we can modify the view and display the certificate and the image:


```html+erb
# lib/views/verify/valid.erb

<h3 style="color: #368a55">Valid course certificate for</h3>
<h2><%= link_to @certificate.student.full_name, @certificate.certificate_url %></h2>
<p><%= link_to @certificate.delivery.course.title, "/courses/delivery/show/#{@certificate.delivery.id}" %></p>
<p>Course date: <%= @certificate.delivery.start_date %></p>

<img src="<%= @certificate.image_url %>" />
```

[Step 23](step23.md)