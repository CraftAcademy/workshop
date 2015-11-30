#### Adding views

The next thing we need to do is to make the `And I click "All courses" link` step pass. For now, that step is undefined. Let's define it first.

In our `application_steps.rb` let's add:

```ruby
# features/step_definitions/application_steps.rb

And(/^I click "([^"]*)" link$/) do |element|
  click_link_or_button element
end
```

`click_link_or_button` is a Capybara command that looks for either a HTML link or a button tag and clicks it. Pretty handy, right?

If you run `cucumber` again you'll get an error message that Capybara simply can't find that element. That is perfectly normal, we haven't created that yet.

```shell
Unable to find link or button "All courses" (Capybara::ElementNotFound)
```

Views are the actual web pages that will be rendered in your browser. This is what the user will see.
In order to get some views rendered by the application we, of course:

1. Need to create them and;
2. Tell the application to show them to us depending on what is going on.

Right now, the app is not showing any views. If you have a look in your `application.rb` you can see the following block of code:

```ruby
get '/' do
  'Hello WorkshopApp!'
end
```

This means that the only thing that will be shown when we open the application in the browser is the text "Hello WorkshopApp!" and nothing else.

We want to change that of course.

In our `lib` folder, we need to create a `views` folder. In that folder, we want to create a subfolder called `layouts` and then inside of that folder a `application.erb` file. 

To do all that head over to your terminal, navigate to your project folder and execute the following shell commands:

```shell
$ cd lib
$ mkdir -p views/layouts
$ touch views/layouts/application.erb
```

For now, the only code we want to place in that file is:

```HTML+ERB
# lib/views/layouts/application.erb

<%= yield %>
```

We will cover the `application.erb` in more detail further down the road.

Another file we need to create a `index.erb` in the `views` folder.

```shell
$ touch views/index.erb
```

Add the following code to that file:

```HTML+ERB
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

What happens if we run cucumber again?

[Step 5](step5.md)
