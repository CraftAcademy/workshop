### Focus on the feature

Let's have a look on the next step in our scenario:

```
And I am logged in as an administrator
```

That is a little more tricky and we need to add some serious code in order to make it pass.
We need to create a User entry with administrator right in a database (witch we don't have yet) and
we also need to define a mechanism to store and retrieve passwords in order to authenticate the user that tries to use the application.

Or, we can take another approach - and stay focused on the task at hand.

At this stage we are only interested in writing a minimal amount of code to make this scenario pass and focus on
first listing and then creating a course (that is the main purpose of this test, right?).

So how about just telling the application to assume that an administrator is logged in and return to actually creating those mechanism at a later stage in our development?

I'm inclined to do exactly that.

Within the `application.rb` file we created earlier on, let's add the following line which creates a setting called `admin_logged_in` and sets it to `false`

```ruby
# lib/application.rb

set :admin_logged_in, false
```

Your `application.rb` file should now look something like this:

```ruby
# lib/application.rb

require 'sinatra/base'

class WorkshopApp < Sinatra::Base
  set :admin_logged_in, false

  get '/' do
    'Hello WorkshopApp!'
  end

  # start the server if ruby file executed directly
   run! if app_file == $0
end
```

In the `features/support/env.rb` file we can add a method to change that setting to `true`.

```ruby
def log_in_admin
  WorkshopApp.admin_logged_in = true
end
```

Finally, in the `step_definitions` folder, let's create a new file that we call `application_steps.rb` and add the following step definition:

```ruby
# features/step_definitions/application_steps.rb

And(/^I am logged in as an administrator$/) do
  log_in_admin
  expect(WorkshopApp.admin_logged_in).to eq true
end
```

First we are calling on the `log_in_admin` method and on the next line we are setting an assertion or expectation that needs to be fulfilled in order for the step to pass.

Run `cucumber` again. That step should go green for you. We have not actually created a feature that allows for logging in and out, but for the time being, we have fooled the application to think that an administrator is actually logged in.

We will get back to this sooner rather than later and code an actual solution.
