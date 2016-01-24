### Refactoring the workflow

We are going to add some scenarios to `certificate_generation.feature`

First a small re-factoring:

```gherkin
# features/certificate_generation.feature

...
# change Scenario title to:
Scenario: Generate certificates

# add step:
  And I should see 3 "view certificate" links

...
```
Add a new step definition to your `application_steps.rb`:

```ruby
# features/step_definitions/application_steps.rb

...
And(/^I should see ([^"]*) "([^"]*)" links$/) do |count, element|
  expect(page).to have_link(element, count: count)
end
...
```

We only want the user to be able to generate certificates if no certificates have been generated, right?  If we put that in a User Story, it could look something like this:
```
As a course administrator
In order to avoid duplicate certificates and validation links
I want to restrict the use of certificate generator to delivery
dates with no previously generated certificates.
```

In the `certificate_generation.feature` file, add the following scenario:

```gherkin
# features/certificate_generation.feature

...
Scenario: Certificate generation is disabled if certificates exists
  Given valid certificates exists
  Then I should not see "Generate certificates"
```

In order to get the `Certificate` model to validate, we want to slightly change the way we generate the `pdf's`. We are going to remove the `after :create` callback from that class:

```ruby
# lib/certificate.rb

# delete:
  after :create do
    CertificateGenerator.generate(self)
  end
```
And add that command to our controller. Along with some other changes.

Let's update our controller method:

```ruby
# lib/application.rb

...
get '/courses/generate/:id', auth: :user do
  @delivery = Delivery.get(params[:id])
  if !@delivery.certificates.find(delivery_id: @delivery.id).size.nil?
    session[:flash] = 'Certificates has already been generated'
  else
    @delivery.students.each do |student|
      cert = student.certificates.create(created_at: DateTime.now, delivery: @delivery)
      keys = CertificateGenerator.generate(cert)
      cert.update(certificate_key: keys[:certificate_key], image_key: keys[:image_key])
    end
    session[:flash] = "Generated #{@delivery.students.count} certificates"
  end
  redirect "/courses/delivery/show/#{@delivery.id}"
end
...
```

With this implementation we are:

1. Preventing unauthorized access to the route
2. Preventing certificates to be created if there already exists certificates for that course delivery
3. Creating a certificate for each student
4. Giving the user feedback on performed actions with a flash

We need to make an addition to the `Delivery` model - letting each `Delivery` know what `Certificates` are associated to it
using whatever `Certificates` are associated to the `Deliveries` `Students`.

We start by writing a spec for that:

```ruby
# spec/delivery_spec.rb

...
it { is_expected.to have_many_and_belong_to :certificates }
...
```

Then the implementation:

```ruby
# lib/delivery.rb

...
has n, :certificates, through: :students
...
```

We also want to open this view for non logged in users but only allowing actions to be performed if a user is logged in.
In that way, we do not need to create separate views for those contexts. Make sure you are not using the `auth: :user` method on the route to `get` that view:

```ruby
# lib/application.rb

...
  get '/courses/delivery/show/:id' do
    @delivery = Delivery.get(params[:id].to_i)
    erb :'courses/deliveries/show'
  end
...

```

The next step will be to refactor the view:

```erb

# lib/views/courses/deliveries/show.erb

<h2><%= @delivery.course.title %></h2>
<p>Course date: <%= @delivery.start_date %></p>

<% if @delivery.students.any? %>
  <div> Students:
    <ul>
      <% @delivery.students.each do |student| %>
        <li id="student-<%= student.id %>>"><%= [student.full_name, ''].join(' ') %>
          <% unless student.certificates.all(delivery_id: @delivery.id).empty? %>
            <%= link_to 'view certificate', student.certificates.first(delivery_id: @delivery.id).certificate_url, target: '_blank' %>
          <% end %>
        </li>
      <% end %>
    </ul>
    <% if current_user && @delivery.certificates.all(delivery_id: @delivery.id).empty? %>
      <div>
        <%= link_to 'Generate certificates', "/courses/generate/#{@delivery.id}", class: 'button' %>
      </div>
    <% end %>
  </div>
<% elsif current_user %>
  <% form_tag '/courses/deliveries/file_upload', method: :post, multipart: true do %>
    <%= hidden_field_tag :id, value: @delivery.id %>
    <%= file_field_tag :file %>
    <%= submit_tag 'Submit', class: 'button' %>
  <% end %>
<% end %>
```

This change is introducing several changes:

1. `Generate certificates` will only be visible if a) there is a `current_user` AND no certificates has been generated (`!@delivery.certificates.any?`).
2. The upload data file interface (the form) is visible only if there is a `current_user` present and there are no students associated to the delivery.
3. On the students list, a link to the certificate is visible IF there is a certificate associated with that student.
4. We are displaying the delivery date.
5. We add class `'button'` to links to give it look and feel of a button.

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

We know that the links to AWS are build in a specific way and we can use that to dynamically create our own urls. Add the following methods to your `certificate.rb`

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

If you run all your tests, they should pass. However, our tests are not very extensive and there are many scenarios that we have failed to write coverage for. I would like you to take a few minutes and think about what else we should be testing for in Cucumber.



