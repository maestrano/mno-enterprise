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
2.  [Configuration](#configuration)
3.  [Building the Frontend](#building-the-frontend)
4.  [Modifying the style - Theme Previewer](#modifying-the-style---theme-previewer)
5.  [Extending the Frontend](#extending-the-frontend)
6.  [Replacing the Frontend](#replacing-the-frontend)
7.  [Generating a database extension](#generating-a-database-extension)
8.  [Deploying](#deploying)
    1.  [Deploy a Puma stack on EC2 via Webistrano/Capistrano](#deploy-a-puma-stack-on-ec2-via-webistranocapistrano)
    2.  [Sample nginx config for I18n](#sample-nginx-config-for-i18n)
    3.  [Health Checks](#health-checks)
9.  [Migrating from v2 to v3](#migrating-from-v2-to-v3)
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
Building the frontend requires you to have nodejs and gulp install. While the rake task will attempt to install these dependencies, you may want to install these manually prior to running the install task. See the [nodejs website](https://nodejs.org/en/) for intructions on how to install node on your machine.

Once node is installed, you can run the following commands to ensure that all dependencies are installed:
```bash
bin/rake mnoe:frontend:install_dependencies
```

## Configuration

### Emailing platform

Maestrano Enterprise support either [Mandrill](https://www.mandrill.com/) or [SparkPost](https://www.sparkpost.com/).

You can use either provider as long as your account has the [required templates](https://maestrano.atlassian.net/wiki/display/MNOE/Emailing).

If you  want to copy the default templates to your own account you can use the tools in `tools/emails`

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
SMTP server settings are needed to send emails via SMTP. In case there's no SMTP server, a personal gmail account could be used as an alternative.
To use gmail to send SMTP emails, the gmail account should be set to allow "less secure apps".
Typically for security reasons, system environment variables 'SMTP_USERNAME' and 'SMTP_PASSWORD' should be used to set the SMTP credentials.

```ruby
# Gemfile
gem 'premailer-rails'

# config/environments/production.rb
Rails.application.configure do
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { :host => host_domain, :port => port_number }
  config.action_mailer.asset_host = your_apps_root_url
  config.action_mailer.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    address:              'smtp.gmail.com',
    port:                 587,
    domain:               'gmail.com',
    user_name:            ENV['SMTP_USERNAME'],
    password:             ENV['SMTP_PASSWORD'],
    authentication:       'plain',
    enable_starttls_auto: true  
  }
end

# config/initializers/mno_enterprise.rb
MnoEnterprise.configure do |config|
  config.mail_adapter = :smtp
end

# config/initializers/assets.rb
Rails.application.config.assets.precompile += %w( mno_enterprise/mail.css )
```

##### Customization of mail templates
- You can override the default mail templates by adding template files ( template-name.html.erb, template-name.text.erb ) to the mail view directory (/app/views/system_notifications).
- Logo can also be overriden by adding your own logo image (main-logo.png) to the image assets directory (/app/assets/images/mno_enterprise).
- Write your own stylesheet by adding mail.css file to the stylesheets directory (/app/assets/stylesheets/mno_enterprise). The css rules you write will be applied to all the mail templates including the default ones.

## Building the frontend
The Maestrano Enterprise frontend is a Single Page Application (SPA) that is separate from the Rails project. The source code for this frontend can be found on the [mno-enterprise-angular Github repository](https://github.com/maestrano/mno-enterprise-angular)

Build the frontend by running the following command:
```bash
bundle exec rake mnoe:frontend:dist
```
This will create a "dashboard" directory under the /public folder with the compiled frontend.

Building the frontend is only required if you modify the CSS and/or JavaScripts files under /frontend.

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

Once done you can replace the frontend source by specifying your frontend github repository in the /bower.json file. You can then build it by running the usual:
```bash
bundle exec rake mnoe:frontend:dist
```

## Generating a database extension

If you want to add fields to existing models, you can create a database extension for it.

```
rails g mno_enterprise:database_extension Model field:type
```

eg:

```
rails g mno_enterprise:database_extension Organization growth_type:string
```

## Deploying

### Deploy a Puma stack on EC2 via Webistrano/Capistrano

**IMPORTANT NOTE:** These are legacy instructions. They will soon be replaced by Docker instructions.

First, prepare your server. You will find a pre-made AMI on our AWS accounts called "AppServer" or "Rails Stack" that you can use.

Then, setup your new project via webistrano/capistrano.

When you're done, you can prepare the project by running the following generator for each environment your need to deploy (uat, production etc.)
```bash
# rails g mno_enterprise:puma_stack <environment>
$ rails g mno_enterprise:puma_stack production
```
This generator creates a script folder with all the configuration files required by nginx, puma, upstart and monit.

Perform a deploy:update via webistrano/capistrano (which will certainly fail). The whole codebase will be copied to the server.

Login to the server then run the following setup script
```bash
# sh /apps/<project-name>/current/scripts/<environment>/setup.sh
$ sh /apps/my-super-app/current/scripts/production/setup.sh
```
This script will setup a bunch of symlinks for nginx, upstart and monit pointing to the config files located under the scripts directory created previously.

That's it. You should be done!

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
  "env": "test"
}
```

`/mnoe/health_check` & `/mnoe/health_check/full`: Complete health check (cache, smtp, database, ...). See [health_check](https://github.com/ianheggie/health_check)

## Migrating from v2 to v3

### a) Upgrade the gem
First switch to a new branch such as v2-to-v3.
```bash
git co -b v2-to-v3
```

Open your Gemfile and ensure that your project points to the v3.0-dev branch of Maestrano Enterprise. You gemfile should look like this:
```ruby
gem 'mno-enterprise', git: 'https://some-token:x-oauth-basic@github.com/alachaum/mno-enterprise.git', branch: 'v3.0-dev'
```

Then update the gem by running
```bash
bundle update mno-enterprise
```

Ensure you've got node installed on your system. Some googling will surely provide you with the steps required to install Node on your machine.

Rerun the Maestrano Enterprise task in your project. This task will download and compile the enterprise angular frontend.
```bash
bundle exec rake mno_enterprise:install
```

After running this task a new "/frontend" directory will have appeared in the root of your project. This folder will contain any customization you want to make the frontend. It should already contain a few LESS files with a default theme.

### b) Reapply your style

The way styling and frontend customisations are handled by the platform has changed. Everything is now located under the "/frontend" directory.

In order to migrate your style, follow these instructions:

- Copy the content of your /app/assets/stylesheets/theme.less.erb into /frontend/src/app/stylesheets/theme.less. Replace any ERB variable by the actual LESS value
- Delete /app/assets/stylesheets/theme.less.erb
- Copy the content of your /app/assets/stylesheets/variables.less into /frontend/src/app/stylesheets/variables.less.
- Delete /app/assets/stylesheets/variables.less
- Create the file: /app/assets/stylesheets/main.less and copy the following content to it:
```less
/*-----------------------------------------------------------------------*/
/*                    Import Core LESS Framework                         */
/*-----------------------------------------------------------------------*/
// Import Core LESS Framework
@import "mno_enterprise/main";

/*-----------------------------------------------------------------------*/
/*                           Customization                               */
/*-----------------------------------------------------------------------*/

// Import theme colors
//--------------------------------------------
@import "../../../frontend/src/app/stylesheets/theme";

// Import custom variables
//--------------------------------------------
@import "../../../frontend/src/app/stylesheets/variables";

// Import theme published by Theme Previewer
//--------------------------------------------
// @import "../../../frontend/src/app/stylesheets/theme-previewer-published.less";

// Import any custom less file below
//--------------------------------------------
// @import 'homepage'
```
- Copy any CSS customization you have made in main.less.erb to main.less
- Rebuild the frontend with your style
```bash
rake mnoe:frontend:dist
```
- Copy your logo in /app/assets/images/mno_enterprise/main-logo.png to /public/dashboard/images/main-logo.png

Launch your application, your style should now be reapplied.

### c) Caveat: Impac! endpoint

The v3 is currently being finalised. There are some minor configuration options that still need to be implemented such as the "impact endpoint urls".

If deploying to UAT, the Impac! URLs need to be manually replaced. Search the "/public" directory for "http://localhost:4000" and replace by "https://api-impac-uat.maestrano.io". Save the files and deploy.

## Update mnoe-angular to the version in the bower.json.
```
rake mnoe:frontend:update
```

## Update the version of the gem according to the gemfile.
```
bundle update mno-enterprise

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
