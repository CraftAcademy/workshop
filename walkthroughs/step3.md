Let's have a look on the next step in our scenarion:

```
And I am logged in as an administrator
```

That is a little more tricky and we need to add some serious code in order to make it pass.
We need to crate an Administrator entry in a database (we dont'h have a database attached to the application yet) and
we need to create a mechanizm to store and retrieve passwords in order to authenticate the user that tries to use the application.
Or, we can take another approach. At this stage we are only interested to write the minimal amount of code to make this step pass and focus on
first listing and then creating a course (that is the main purpose of this test, right).

So how about just telling the application tto assume that an Administrator is logged in and return to actually creating those mechanizms at a later stage in our development?
I'm inclined to do exactly that.

In your `application.rb`, we can create a setting called `admin_logged_in` and set it to `false:`

```ruby
#application.rb

set :admin_logged_in, false
```

In the `support/env.rb` we can add a method to change that setting to `true`.

```ruby
def log_in_admin
  WorkshopApp.admin_logged_in = true
end
```

Finally, in the `step_definitions` folder, let's create a new file that we call `application_steps.rb` and add the following step definition:

```ruby
And(/^I am logged in as a administrator$/) do
  log_in_admin
  expect(WorkshopApp.admin_logged_in).to eq true
end
```

And run `cucumber` again. That step should go green for you. We have not actually created a feature that allows for logging in and out, but for the time being, we have fooled tha application to thing that an administrator is actually logged in. We will get back to this sooner then later and code an actual solution.




