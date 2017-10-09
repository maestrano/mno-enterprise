# Testing

Each gem contains its own series of tests, and for each directory, you need to
do a quick one-time creation of a test application and then you can use it to run
the tests.  For example, to run the tests for the core project.
```shell
cd core
bundle exec rake test_app
bundle exec rspec spec
```

If you want to run specs for only a single spec file
```shell
bundle exec rspec spec/models/mno_enterprise/user_spec.rb
```

If you want to run a particular line of spec
```shell
bundle exec rspec spec/models/mno_enterprise/user_spec.rb:13
```

If you want to run the simplecov code coverage report
```shell
COVERAGE=true bundle exec rspec spec
```
