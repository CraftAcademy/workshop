#### Adding more complex views

We are going to make use of another open source library that has been developed to add some functionality to the Sinatra framework and make programming easier. It is called `Padrino` and you can find more information about it on http://www.padrinorb.com/.
Together with `Padrino`, we need to install a gem called `Tilt`. We point to specific gem versions in order to avoid conflicts.

Add `Padrino` and `tilt` to your Gemfile:

```ruby
gem 'tilt', '~> 1.4', '>= 1.4.1'
gem 'padrino', '~> 0.13.0'
```

And don't forget to `bundle`.

Next step, as usually when we add a library, is to both require and register the modules we want to use. `Padrino` comes bundled with a lot of modules but for now, we only want to make use of so called Helper methods.

Add `padrino/helpers` to your `application.rb`

```ruby
# lib/application.rb

require 'sinatra/base'
require 'padrino-helpers'

class WorkshopApp < Sinatra::Base
  register Padrino::Helpers
  set :protect_from_csrf, true

  ... # rest of your code
end
```
(The `:protect_from_csrf` method is a security measure to avoid hacking attacks, more on that later. For now, let's just enable that.)

You also need to create additional routes in your `application.rb` in order to show the index and create interface and also to actually create a course. That will be a `post` route.

```ruby
# lib/application.rb

class WorkshopApp < Sinatra::Base
  ...

  get '/courses/index' do
    erb :'courses/index'
  end

  get '/courses/create' do
    erb :'courses/create'
  end

  post '/courses/create' do
    # TODO: place Course creation code here:
    erb :'courses/index'
  end
  ...
end
```

Modify your `views/index.erb` to look like this:

```HTML+ERB
# lib/views/index.erb

<h1>Workshop App</h1>
<%= link_to 'All courses', '/courses/index' %>
```

Create a new folder in `views` named `courses` and add two files in that folder: `index.erb` and `create.erb`

```shell
$ cd lib
$ mkdir -p views/courses
$ touch views/courses/index.erb
$ touch views/courses/create.erb
```

In the `index.erb` let's add a link to create a new course:

```HTML+ERB
# lib/views/courses/index.erb

<h1>You have not created any courses</h1>

<%= link_to 'Create course', '/courses/create' %>
```

And in the `create.erb` let's add a form to create a course:

```HTML+ERB
# lib/views/courses/create.erb

<% form_for :course, '/courses/create', id: 'create' do |f|  %>
  <%= f.text_field_block :title, caption: 'Course Title' %>
  <%= f.text_field_block :description, caption: 'Course description' %>
  <%= f.submit 'Create' %>
<% end %>
```

Now when we run cucumber again we will get a new error:
```shell
uninitialized constant Course (NameError)
```

That is a kind of a blocker for us. We need to create a `Course` class. So lets do that really quick - we will add more functionality to that class later.
 In the `lib` folder, create a `course.rb` file and add the following code:

 ```ruby
 # lib/course.rb

 class Course

 end
 ```

 And require that class in your `application.rb`:

 ```ruby
 # lib/application.rb

 require './lib/course'
 ...
 ```

Now, try to run your tests again. What does it looks like?

**As a last step this part I would like you to add two step definitions {really??? what defs is that???}**

