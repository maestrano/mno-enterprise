# MNO Enterprise Rails Application Template

This template bootstrap a MNO Enterprise project.

## How to Use

```bash
rails new [project_name] -TOJ -m https://raw.githubusercontent.com/maestrano/mno-enterprise/master/rails-template/mnoe-app-template.rb
```

Or

```bash
rails new [project_name] -TOJ -m <path-to>/mnoe-app-template.rb
```

Feel free to adapt the flags used if you need ActiveRecord or Test::Unit:

* `-O` or `--skip-active-record`
* `-T` or `--skip-test-unit`
* `-S` or `--skip_sprockets`
* `-J` or `--skip_javascript`

Once the app exists:

```bash
cd [project_name]
foreman start
```

## What it does

1. Adds the following gems:
  - CI:
    - [rubocop](https://github.com/bbatsov/rubocop): Ruby static code analyzer
    - [brakeman](https://github.com/presidentbeef/brakeman): A static analysis security vulnerability scanner
    - [bundler-audit](https://github.com/rubysec/bundler-audit): Patch level verification for bundler
  - Testing:
    - [rspec-rails](https://github.com/rspec/rspec-rails): Rspec is a testing tool for test-driven and behavior-driven development..
    - [factory_girl_rails](https://github.com/thoughtbot/factory_girl): FactoryGirl is a fixtures replacement with a straightforward definition syntax.
    - [shoulda-matchers](https://github.com/thoughtbot/shoulda-matchers): Collection of testing matchers extracted from Shoulda
    - [simplecov](https://github.com/colszowka/simplecov): Code coverage

2. Add and install `mno-enterprise`

3. Initializes a new git repository with an initial commit.
