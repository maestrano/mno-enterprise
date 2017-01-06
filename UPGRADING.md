# Upgrading mno-enterprise

## Upgrading the frontend

Compare `mno-enteprise-angular/src/app/stylesheets/variables.less` with your `frontend/src/app/stylesheets/variables.less` to see if new variables were added.

## Migrating from v3.0/v3.1 to v3.2

See the [CHANGELOG](CHANGELOG.md)

### New frontend build process

The frontend build process has been refactored, `package.json` is now replacing the `bower.json` file.

- Run `bin/rake mnoe:frontend:install` to generate a new `package.json` file and build the frontend
- Edit `package.json`: change the `mno-enterprise-angular` and `impac-angular` versions to match your needs (see the `bower.json` file)
- Run `bin/rake mnoe:frontend:update` if you've edited `package.json`
- Delete the obsolete `bower.json` file


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
