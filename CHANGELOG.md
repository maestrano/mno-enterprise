# Unreleased

## Added

* Add SparkPost support for transactional emails. You can now choose either Mandrill or SparkPost.

## Deprecated

* `MnoEnteprise.config.mandrill_key` is replaced with `ENV['MANDRILL_API_KEY']`
* `MandrillClient` is replaced with `MnoEnterprise::MailClient`

# 3.0.0 (2016-04-05)

* New angular based frontend
* Remove old Rails based frontend
* Theme builder/previewer
* I18n implementation

# 2.0.0 (2016-04-05)

* Split in multiple gems (api, core, frontend)
* Add admin frontend
