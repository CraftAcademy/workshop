#### Adding views

The next thing we need to do is to make the `And I click "All courses" link` step to pass. For now, that step is undefined. So let's define it first.

In our `application_steps.rb` let's add:

```ruby
# features/step_definitions/application_steps.rb

And(/^I click "([^"]*)" link$/) do |element|
  click_link_or_button element
end
```

`click_link_or_button` is a Capybara command that looks for either a HTML link or a button tag and clicks it. Pretty handy, right?

 If you run cucumber again you'll get an error message that Capubara simply can't find that element. That is perfectly normal, we haven't created that yet.

 ```
 Unable to find link or button "All courses" (Capybara::ElementNotFound)
 ```

 Views are like webpages that will be shown in your browser.
 In order to get some views rendered by the application we, of course, a) need to create them and b) tell the application to show them to us depending on what is going on.

 Right now, tha app is not showing any views. If you have a look in your `application.rb` you can see the following code:

 ```ruby
 # lib/application.rb

 get '/' do
   'Hello WorkshopApp!'
 end
 ```

This means that the only thing that will be shown when we open the application in the browser is the text "Hello WorkshopApp!" and nothing else. We want to change that of course...


In our `lib` folder, we need to create a `views` folder. In that folder, we want to create a `layouts` folder and then inside of the folder a `application.erb` file. For now, the only code we want to place in that file is:

```ruby
# lib/views/layouts/application.erb

<%= yield %>
```

We will cover the `application.erb` in more detail further down the road.

Another file we need to create a `index.erb` in the `views` folder. Add the following code to that file:

```HTML+ERB
# lib/views/index.erb

<h1>Workshop App</h1>
<a href="/courses">All courses</a>
```

Now we have a template for the index view. We also need to tell the application to use that template when that page is requested by the browser. In order to do that we need to modify our `application.rb` once again:
```ruby
# lib/application.rb

get '/' do
  erb :index
end
```
What we did now was to remove the static text that was being showed on the web page and replace that with the template we just created. That template actually contain a link to list "All Courses".

So what happens if we run cucumber again?

[Step 5](step5.md)









