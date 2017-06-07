<p align="center">
<img src="https://raw.github.com/maestrano/maestrano-ruby/master/maestrano.png" alt="Maestrano Logo">
<br/>
<br/>
</p>

[![Gem Version](https://badge.fury.io/rb/mno-enterprise.svg)](https://rubygems.org/gems/mno-enterprise)
[![Build Status](https://travis-ci.org/maestrano/mno-enterprise.svg?branch=master)](https://travis-ci.org/maestrano/mno-enterprise)
[![Dependency Status](https://gemnasium.com/badges/github.com/maestrano/mno-enterprise.svg)](https://gemnasium.com/github.com/maestrano/mno-enterprise)
[![Code Climate](https://codeclimate.com/github/maestrano/mno-enterprise/badges/gpa.svg)](https://codeclimate.com/github/maestrano/mno-enterprise)
[![Test Coverage](https://codeclimate.com/github/maestrano/mno-enterprise/badges/coverage.svg)](https://codeclimate.com/github/maestrano/mno-enterprise/coverage)

The Maestrano Enterprise Engine can be included in a Rails project to bootstrap an instance of Maestrano Enterprise Express.

The goal of this engine is to provide a base that you can easily extend with custom style or logic.

- - -

1.  [Install](#install)
2.  [Upgrade](#upgrade)
3.  [Configuration](#configuration)
    1. [Emailing Platform](#emailing-platform)
    2. [Intercom](#intercom)
    3. [Active Job Backend](#active-job-backend)
4.  [Building the Frontend](#building-the-frontend)
5.  [Modifying the style - Theme Previewer](#modifying-the-style---theme-previewer)
6.  [Extending the Frontend](#extending-the-frontend)
    1. [Adding a custom font](#adding-a-custom-font)
    2. [Adding a favicon](#adding-favicon)
7.  [Replacing the Frontend](#replacing-the-frontend)
8.  [Extending the Backend](#extending-the-backend)
    1. [Overriding Models and Controllers with the Decorator Pattern](#overriding-models-and-controllers-with-the-decorator-pattern)
    2. [Generating a database extension](#generating-a-database-extension)
9.  [Deploying](#deploying)
    1.  [Deploy a Puma stack on EC2 via Webistrano/Capistrano](#deploy-a-puma-stack-on-ec2-via-webistranocapistrano)
    2.  [Sample nginx config for I18n](#sample-nginx-config-for-i18n)
    3.  [Health Checks](#health-checks)
10. [Contributing](#contributing)

- - -

## Install

### One step install (recommended)

You can generate a complete rails project using the application template:
```ruby
rails new [project_name] -TOJ -m https://raw.githubusercontent.com/maestrano/mno-enterprise/master/rails-template/mnoe-app-template.rb
```

For more details see the template [README](rails-template/README.md).

### Manual Install

Create a new rails project:
```ruby
rails new name-enterprise
```

Add mno-enterprise to your Gemfile.
```ruby
# Maestrano Enterprise Engine
gem 'mno-enterprise', '~> 3.0'
```

Run the install script
```bash
rails g mno_enterprise:install
```

The install script will perform three things:
- Generate an initializer for Maestrano Enterprise (config/initializers/mno_enterprise.rb)
- Install and build the mno-enterprise-angular frontend
- Install and build the admin dashboard frontend
- Create a /frontend directory in your application for all frontend customisations/overrides

**Manual Node setup (optional):**
Building the frontend requires you to have nodejs and yarn installed. While the rake task will attempt to install these dependencies, you may want to install these manually prior to running the install task.
See the [nodejs](https://nodejs.org/en/) and [yarn](https://yarnpkg.com/en/docs/install) websites for instructions on how install them on your machine.

Once node is installed, you can run the following commands to ensure that all dependencies are installed:
```bash
bin/rake mnoe:frontend:install_dependencies
```

## Upgrade

We follow [Semantic Versioning](https://semver.org/) so upgrading to a compatible version should be straightforward.

For major upgrade between versions see [UPGRADING](UPGRADING.md).

## Configuration

### Emailing platform

Maestrano Enterprise supports either [Mandrill](https://www.mandrill.com/) or [SparkPost](https://www.sparkpost.com/) as well as regular SMTP.

You can use either provider as long as your account has the [required templates](https://maestrano.atlassian.net/wiki/display/DEV/Emailing).

If you  want to copy the default templates to your own account you can use the tools in `tools/emails`.

#### Mandrill

```ruby
# Gemfile
gem 'mandrill-api', '~> 1.0.53'

# config/application.yml
MANDRILL_API_KEY: api_key

# config/initializers/mno_enterprise.rb
MnoEnterprise.configure do |config|
  config.mail_adapter = :mandrill
end
```

#### SparkPost

```ruby
# Gemfile
gem 'sparkpost', '~> 0.1.4'

# config/application.yml
SPARKPOST_API_KEY: api_key

# config/initializers/mno_enterprise.rb
MnoEnterprise.configure do |config|
  config.mail_adapter = :sparkpost
end
```

#### SMTP

It's also possible to use a regular SMTP server. In this case, Maestrano Enterprise will use the templates bundled within the gem, see the next section to customise them.

```ruby
# Gemfile
gem 'premailer-rails'

# config/application.rb
Rails.application.configure do
  # Email configuration
  config.action_mailer.delivery_method = :smtp

  config.action_mailer.smtp_settings = {
    address:              ENV['SMTP_HOST'],
    port:                 ENV['SMTP_PORT'],
    domain:               ENV['SMTP_DOMAIN'],
    user_name:            ENV['SMTP_USERNAME'],
    password:             ENV['SMTP_PASSWORD'],
    authentication:       'plain',
    enable_starttls_auto: true  
  }
end

# config/environments/<production|uat>.rb
Rails.application.configure do
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { host: host_domain, port: port_number }
  config.action_mailer.asset_host = your_apps_root_url
end

# config/initializers/mno_enterprise.rb
MnoEnterprise.configure do |config|
  config.mail_adapter = :smtp
end

# config/initializers/assets.rb
Rails.application.config.assets.precompile += %w( mno_enterprise/mail.css )
```


In this example, the SMTP server settings are passed via environment variables. See sample configurations below.

**Gmail**

If you don't have access to a SMTP server, a personal Gmail account can be used as an alternative.
The Gmail account should be set to allow "less secure apps".

```ruby
# config/application.yml
SMTP_HOST: smtp.gmail.com
SMTP_PORT: 587
SMTP_DOMAIN: gmail.com
SMTP_USERNAME: user@gmail.com
SMTP_PASSWORD: password
```

**Mailgun**

[Mailgun](https://www.mailgun.com/sending-email) provides an SMTP mode and allow you to manage multiple domain within the same account.

```ruby
# config/application.yml
SMTP_HOST: smtp.mailgun.org
SMTP_PORT: 587
SMTP_DOMAIN: mg.acme-enterprise-mnoe-uat.maestrano.io
SMTP_USERNAME:
SMTP_PASSWORD:
```

##### Customization of mail templates
- You can override the default mail templates by adding template files (`template-name.html.erb`, `template-name.text.erb`) to the mail view directory (`/app/views/system_notifications`).
- Logo can also be overridden by adding your own logo image (`main-logo.png`) to the image assets directory (`/app/assets/images/mno_enterprise`).
- Write your own stylesheet by adding a `mail.css` file to the stylesheets directory (`/app/assets/stylesheets/mno_enterprise`). The css rules you write will be applied to all the mail templates including the default ones.

### Intercom

Intercom is already integrated in mno-enterprise, you just need to enable it!

Add the gem to your `Gemfile`

```ruby
gem 'intercom', '~> 3.5.4'
```

Expose the following environments variables (via `application.yml` or your preferred method)

```
INTERCOM_APP_ID
INTERCOM_TOKEN
```

If you want to enable secure mode (recommended), expose `INTERCOM_API_SECRET`.

If you built your app with an older version of mno-enterprise, double-check that `config/initializer/mno-enteprise.rb` contains the following lines:

```ruby
# Intercom
config.intercom_app_id = ENV['INTERCOM_APP_ID']
config.intercom_api_secret = ENV['INTERCOM_API_SECRET']
config.intercom_token = ENV['INTERCOM_TOKEN']
```

#### (Deprecated) Using API Keys

Expose the following environments variables (via `application.yml` or your preferred method)

```
INTERCOM_APP_ID
INTERCOM_API_KEY
INTERCOM_API_SECRET
```

If you built your app with an older version of mno-enterprise, double-check that `config/initializer/mno-enteprise.rb` contains the following lines:

```ruby
# Intercom
config.intercom_app_id = ENV['INTERCOM_APP_ID']
config.intercom_api_secret = ENV['INTERCOM_API_SECRET']
config.intercom_api_key = ENV['INTERCOM_API_KEY']
```

### Active Job Backend

Maestrano Enterprise uses Active Job to process background jobs such as logging event or emails.

By default if no adapter is set, the jobs are immediately executed.

To see an up-to-date list of all queueing backend supported by Active Job see the documentation for [Active Job](http://edgeguides.rubyonrails.org/active_job_basics.html#backends)

#### Sucker Punch

This is the easiest as it runs within the application process, so you don't have to maintain a separate process to run background jobs.

Add this line to your application's `Gemfile`:

```ruby
gem 'sucker_punch', '~> 2.0'
```

To enable backward compatibility with ActiveJob 4.2, create the following initializer:

```ruby
# config/initializers/sucker_punch.rb

require 'sucker_punch/async_syntax'
```

Then in `config/application.rb`:

```ruby
# Use Sucker Punch for ActiveJob
config.active_job.queue_adapter = :sucker_punch
```

#### Sidekiq

This is more involved as you need to manage a separate process (the sidekiq worker) and add Redis to your stack.

Here's a quick start guide, see https://github.com/mperham/sidekiq/wiki/Active-Job for more details.


Add this line to your application's `Gemfile`:

```ruby
gem 'sidekiq'
```

Create a `config/sidekiq.yml`:

```yaml
---
:queues:
  - default
  - mailers
```

In `config/application.rb`:

```ruby
# Use Sidekiq for ActiveJob
config.active_job.queue_adapter = :sidekiq
```

Run the worker process, if you use a `Procfile` you can add the following line to it:

```
worker: bundle exec sidekiq
```

To enable the web interface only for admin, add to your `Gemfile`:

```ruby
gem 'sinatra', '~> 1.4.7', require: false
```

and to `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  ...

  #================================================
  # Sidekiq admin interface
  #================================================
  require 'sidekiq/web'
  authenticate :user, -> (u) { u.admin_role == 'admin' } do
    mount Sidekiq::Web, at: '/sidekiq'
  end

  ...
end
```


## Building the frontend
The Maestrano Enterprise frontend is a Single Page Application (SPA) that is separate from the Rails project. The source code for this frontend can be found on the [mno-enterprise-angular Github repository](https://github.com/maestrano/mno-enterprise-angular)

Build the frontend by running the following command:
```bash
bin/rake mnoe:frontend:build
```
This will create a "dashboard" directory under the /public folder with the compiled frontend.

Building the frontend is only required if you modify the CSS and/or JavaScripts files under /frontend.

### Upgrading the frontend

To upgrade the frontend version, edit the `package.json` file if needed, then run:

```
bin/rake mnoe:frontend:update
```

This will upgrade the frontend version, respecting the constraint in `package.json`, and rebuild it.

## Modifying the style - Theme Previewer
The Maestrano Enterprise Express frontend is bundled with a Theme Previewer allowing you to easily modify and save the style of an Express instance without reloading the page.

The Theme Previewer is available by accessing the following path: /dashboard/theme-previewer.html
```
e.g.: http://localhost:7000/dashboard/theme-previewer.html
```

Under the hood this Theme Previewer will modify the LESS files located under the /frontend directory.

Two types of "save" actions are available in the Theme Previewer.

**Save:**  
This action will temporarily save the current style in /frontend/src/app/stylesheets/theme-previewer-tmp.less so as to keep it across page reloads on the Theme Previewer only. This action will NOT publish the style, meaning that it will NOT apply the style to the /dashboard/index.html page.

**Publish:**  
This action will save the current style in /frontend/src/app/stylesheets/theme-previewer-published.less and rebuild the whole frontend. This action WILL publish the style, meaning that it WILL apply the style to the /dashboard/index.html page.

## Extending the Frontend
You can easily override or extend the Frontend by adding files to the /frontend directory. All files in this directory will be taken into account during the frontend build and will override the base files of the mno-enterprise-angular project.
You can also override the login page background adding an image and gif loaders, which is managed by rails,  including the files into the path ../app/assets/images/mno_enterprise. You can generate really cool gifs for this task in pages like http://loading.io/ .


Files in this folder MUST follow the [mno-enterprise-angular](https://github.com/maestrano/mno-enterprise-angular) directory structure. For example, you can override the application layout by creating /frontend/src/app/views/layout.html in your project - it will override the original src/app/views/layout.yml file of the mno-enterprise-angular project.

You can also add new files to this directory such as adding new views. This allows you to easily extend the current frontend to suit your needs.

While extending the frontend, you can run this command to start the frontend using gulp serve and automatically override the original files with the ones in the frontend folder(be aware it does not take into account images or folders):
```bash
foreman start -f Procfile.dev
```

This will accelerate your development as the gulp serve task use BrowserSync to reload the browser any time a file is changed.

### Adding a custom font

It is possible to add custom fonts, shared all over the rails application screens and the AngularJS SPA.

Simply copy the font files under the directory `/frontend/src/fonts/` of your host application and create a `font-faces.less` file containing your *font-face* definitions.

An example of a project using a custom font can be seen on the [mno-enterprise-demo](https://github.com/maestrano/mno-enterprise-demo) project.

NB: Your host project may have been generated or created before the implementation of this feature, in this case make sure the file `/app/assets/stylesheets/main.less` contains:
```less
// Import custom fonts
//--------------------------------------------
@import "../../../frontend/src/fonts/font-faces";
```

### Adding favicon

Use  http://www.favicon-generator.org/ to generate all the favicon and put them in frontend/src/images/favicons


## Replacing the Frontend

In some cases you may decide that the current [mno-enterprise-angular](https://github.com/maestrano/mno-enterprise-angular) frontend is not appropriate at all.

In this case we recommend cloning or copying the [mno-enterprise-angular](https://github.com/maestrano/mno-enterprise-angular) repository in a new repository so as to keep the directory structure and build (Gulp) process. From there you can completely change the frontend appearance to fit your needs.

Once done you can replace the frontend source by specifying your frontend github repository in the /package.json file. You can then build it by running the usual:
```bash
bin/rake mnoe:frontend:build
```

## Extending the Backend

### Overriding Models and Controllers with the Decorator Pattern

`mno-enteprise` follows the decorator pattern recommended in the [Engine Rails guide](http://guides.rubyonrails.org/engines.html#improving-engine-functionality)

#### Using `ActiveSupport::Concern`

Most of `mno-enteprise` classes use `ActiveSupport::Concern` making it really easy to extend them.

For example look at the following `MnoEnterprise::Organization` class:

```ruby
module MnoEnterprise
  class Organization < BaseResource
    include MnoEnterprise::Concerns::Models::Organization
  end
end
```

Let's say we want to add an extra method, a scope and not allow removal of users:

```ruby
# foobar-enterprise/app/models/mno_enterprise/organization.rb
module MnoEnterprise
  class Organization < BaseResource
    include MnoEnterprise::Concerns::Models::Organization
    
    scope :big, -> { where('size.gt': 10) }
    
    def monkey_patched?
     true
    end
    
    # PATCH: do nothing
    def remove_user(user)
    end
  end
end
```


#### Using `Class#class_eval`

Sometime the class you want to extend does not use a Concern. In this case, you can use `Class#class_eval`.

For example, to override the `after_sign_in_path`:

```ruby
# foobar-enterprise/app/decorators/controllers/mno_enterprise/application_controller_decorator.rb
MnoEnterprise::ApplicationController.class_eval do
  # Patch: return to custom url
  def after_sign_in_path_for(resource)
    "my_custom_url"
  end
end
```

All decorators matching the glob `Dir.glob(Rails.root + "app/decorators/**/*_decorator*.rb")` are automatically loaded.

### Generating a database extension

If you want to add fields to existing models, you can create a database extension for it.

```
rails g mno_enterprise:database_extension Model field:type
```

eg:

```
rails g mno_enterprise:database_extension Organization growth_type:string
```

## Deploying

### Docker file

TBC

### Sample nginx config for I18n

We need to accept URIs like `/en/dashboard` and serve `public/dashboard/index.html`.
A simple combination of location regex and try_files does the trick.

```
server {
  listen       80;
  server_name  mnoe.mno.local;

  root /apps/<%= app_name %>/current/public;
  index        index.html index.htm;

  location ~* "^/[A-Za-z]{2}/dashboard(.*)" {
    try_files  /dashboard$1/index.html /dashboard$1.html /dashboard$1 @backend;
  }

  try_files  $uri/index.html $uri.html $uri @backend;
```

### Health Checks

There are various endpoints to perform health checks:

`/mnoe/ping`: A simple check to see that the app is up. Returns `{status: 'Ok'}`

`/mnoe/version`: Version check. It will returns the version of the different components (app & mnoe gem):
```json
{
  "app-version": "9061048-6811c4a",
  "mno-enterprise-version": "0.0.1",
  "env": "test",
  "mno-api-host": "https://api-hub.maestrano.com"
}
```

`/mnoe/health_check` & `/mnoe/health_check/full`: Complete health check (cache, smtp, database, ...).
See [health_check](https://github.com/ianheggie/health_check) and the [initalizer](api/config/initializers/health_check.rb) for the default configuration.

You can override it by creating an initalizer in the host app, eg:

```ruby
# my-mnoe-app/config/initializers/health_check.rb
HealthCheck.setup do |config|
  # You can customize which checks happen on a standard health check
  config.standard_checks = %w(cache site)

  # You can set what tests are run with the 'full' or 'all' parameter
  config.full_checks = %w(cache site custom database migrations)
end
```

## Contributing

# Contributing to MnoEnterprise

We love pull requests from everyone. Here are some ways *you* can contribute:

* by using alpha, beta, and prerelease versions
* by reporting bugs
* by suggesting new features
* by writing or editing documentation
* by writing specifications
* by writing code ( **no patch is too small** : fix typos, add comments, clean up inconsistent whitespace )
* by refactoring code
* by closing [issues][]
* by reviewing patches

[issues]: https://github.com/maestrano/mno-enterprise/issues

## Submitting an Issue
We use the [GitHub issue tracker][issues] to track bugs and features. Before
submitting a bug report or feature request, check to make sure it hasn't
already been submitted. When submitting a bug report, please include a [Gist][]
that includes a stack trace and any details that may be necessary to reproduce
the bug, including your gem version, Ruby version, and operating system.
Ideally, a bug report should include a pull request with failing specs.

[gist]: https://gist.github.com/

## Submitting a Pull Request
1. [Fork][fork] the [official repository][repo].
2. [Create a topic branch.][branch]
3. Write tests for your feature/bug.
3. Implement your feature or bug fix.
4. Run the specs with:
```bash
bundle exec rake test
```
4. Add, commit, and push your changes.
5. [Submit a pull request.][pr]

## Notes
* Please add tests if you changed code. Contributions without tests won't be accepted.
* Please don't update the Gem version.

[repo]: https://github.com/maestrano/mno-enterprise/tree/master
[fork]: https://help.github.com/articles/fork-a-repo/
[branch]: https://help.github.com/articles/creating-and-deleting-branches-within-your-repository/
[pr]: https://help.github.com/articles/using-pull-requests/

Inspired by https://github.com/thoughtbot/factory_girl/blob/master/CONTRIBUTING.md
