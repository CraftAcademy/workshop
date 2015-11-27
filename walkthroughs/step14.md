#### The look and feel

Up until now we have been developing our application using tests - features and specs. Now is the time to start a browser and have a look at the application.
Brace yourself - you might be surprised. ;-)

In your terminal run the following command:

```shell
$ rackup
```

You should get an output that looks something like this:

```shell
[2015-11-18 21:56:22] INFO  WEBrick 1.3.1
[2015-11-18 21:56:22] INFO  ruby 2.2.0 (2014-12-25) [x86_64-darwin14]
[2015-11-18 21:56:22] INFO  WEBrick::HTTPServer#start: pid=46170 port=9292
```

Now, open up your browser and type in `http://localhost:9292` in the address field.

Ta da! What you see is some raw html pages. There is no colors and no styling on the pages.

So, browse around... Don't mind the raw look and feel of the pages you see. Focus on the functionality. It is all there.

Functionality is important - it's the backbone of an application. That goes without saying. But we consume with our eyes and the look and feel of an application is also important.

We will be using a freely available CSS library called `Foundation` to add a nice look and feel to our application. You can find out more about `Foundation` on <http://foundation.zurb.com/>



Let's start by telling the application where it should look for the `css`, `javascript` and `fonts` that will be used. Open up your `config.ru` file and add the following line to it:

```ruby
# config.ru

...
use Rack::Static, urls: ['/css', '/js', '/img', '/fonts'], root: 'assets'
...
```

Okay, our next step will be to download all the necessary assets directly to our main project folder using a command from a version control library called `Subversion`.

First check if you have Subversion installed by typing in the following command in your terminal:

```shell
$ svn --version
```

If you get an error, you don't have it and we need to install it. On OSX (Mac OS), the simplest way to install software packages is using a system called `Homebrew`.
If you don't have `Homebrew` installed just follow the description at <http://brew.sh/> to install it.

Use this command to install Subversion:
```shell
$ brew install svn
```

That should do it.

The next thing is to actually download the assets. You do it with this svn command:

```shell
$ svn export https://github.com/MakersSweden/workshop-assets/trunk/assets
```

You will be presented with a long list of files that are being copied to your computer. That is perfectly normal. Now you have all the necessary Foundation 5 assets available for use.

The next step is to include all necessary css and javascript files into your application layout file and add some custom java scripts, etc...

Modify your `application.erb` with the code below. We will go over all of this in a while, but for now, just trust me. ;-)

```HTML+ERB
# lib/views/layouts/application.erb

<!DOCTYPE html>
<!--[if IE 9]>
<html class="lt-ie10" lang="en"> <![endif]-->
<html class="no-js" lang="en">

<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Certificate Manager</title>

  <link rel="stylesheet" href="/css/normalize.css">
  <link rel="stylesheet" href="/css/foundation.css">
  <link rel="stylesheet" href="/css/foundation-icons.css"/>
  <link rel="stylesheet" href="/css/custom.css">

  <script src="/js/vendor/modernizr.js"></script>

</head>
<body>

<nav class="top-bar" data-topbar role="navigation">
  <ul class="title-area">
    <li class="name">
      <h1><a href="/">Certificate Manager</a></h1>
    </li>
    <!-- Remove the class "menu-icon" to get rid of menu icon. Take out "Menu" to just have icon alone -->
    <li class="toggle-topbar menu-icon"><a href="#"><span>Menu</span></a></li>
  </ul>

  <section class="top-bar-section">
    <!-- Right Nav Section -->
    <ul class="right">
      <% if current_user %>
        <li><p>Logged in as <%= current_user.email %><p></li>
        <li><%= link_to 'Log out', '/users/logout' %></li>
      <% else %>
        <li><%= link_to 'Register', '/users/register' %></li>
        <li><%= link_to 'Log in', '/users/login' %></li>
      <% end %>
    </ul>

    <!-- Left Nav Section -->
    <ul class="left">

    </ul>
  </section>
</nav>


<div class="row">
  <div class="medium-12 large-12 columns">
    <% unless session[:flash].blank? %>

      <div id="flash-container" data-alert class="alert-box info">
        <%= session[:flash] %>
        <a href="#" class="close">&times;</a>
      </div>
      <% session[:flash].clear %>
    <% end %>

    <%= yield %>
  </div>
</div>

<footer class="footer">
  <div class="row">
    <div class="small-12 columns">
      <div class="slogan"></div>
      <p class="description">
        Developed with Ruby using the Sinatra framework. Styled using Foundation 5.0. Tested with Cucumber, RSpec and
        Capybara. All OpenSourced and/or Free - just the way we like it!
      </p>

      <p class="copywrite">Made with <i class="fi-heart" style="color: red; font-size: 18px;"></i>
        at <%= link_to 'Makers Sweden', 'http://www.makersacademy.se' %></p>
    </div>
  </div>
</footer>


<script src="/js/vendor/jquery.js"></script>
<script src="/js/foundation.min.js"></script>
<script>
  function fixFooter() {
    footer=$(".footer");
    height=footer.height();
    paddingTop=parseInt(footer.css('padding-top'),10);
    paddingBottom=parseInt(footer.css('padding-bottom'),10);
    totalHeight=(height+paddingTop+paddingBottom);
    footerPosition=footer.position();
    windowHeight=$(window).height();
    height=(windowHeight - footerPosition.top)-totalHeight;
    if ( height > 0 ) {
      footer.css({
        'margin-top': (height) + 'px'
      });
    }
  }

  $(document).ready(function () {
    fixFooter();
    var flash = $('#flash-container');
    if (flash.length > 0) {
      window.setTimeout(function () {
        flash.fadeTo(500, 0).slideUp(500, function () {
          $(this).remove();
        });
      }, 5000);
    }
  });

  $(window).resize(function() {
    fixFooter();
  });
</script>
<script>
  $(document).foundation();
</script>
</body>
</html>
```

It seems like a lot, and rightly so. Before we start going over what each and every line of code do (it looks more complicated than it actually is), let's fire up the web server (`rackup`) and have another go at the application.

Go to your browser and reload `http://localhost:9292` Looks a little better now, right?

[Step 15](step15.md)
