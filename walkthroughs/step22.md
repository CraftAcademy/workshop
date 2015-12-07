### Refactor the verification view

Just a quick modification of the template that is called when we verify a course certificate.

Now that we have access to the image as a AWS resource, we can modify the view and display the certificate and the image:


```erb
# lib/views/verify/valid.erb

<h3 style="color: #368a55">Valid course certificate for</h3>
<h2><%= link_to @certificate.student.full_name, @certificate.certificate_url %></h2>
<p><%= link_to @certificate.delivery.course.title, "/courses/delivery/show/#{@certificate.delivery.id}" %></p>
<p>Course date: <%= @certificate.delivery.start_date %></p>

<img src="<%= @certificate.image_url %>" />
```

[Step 23](step23.md)