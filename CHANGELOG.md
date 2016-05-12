# Change Log

## [Unreleased](https://github.com/maestrano/mno-enterprise/tree/master)

**Implemented enhancements:**
- Add SparkPost support for transactional emails. You can now choose either Mandrill or SparkPost.

**Deprecated:**
- `MnoEnteprise.config.mandrill_key` is replaced with `ENV['MANDRILL_API_KEY']`
- `MandrillClient` is replaced with `MnoEnterprise::MailClient`

## [v3.0.2](https://github.com/maestrano/mno-enterprise/tree/v3.0.2) (2016-05-12)

[Full Changelog](https://github.com/maestrano/mno-enterprise/compare/v3.0.1...v3.0.2)

**Fixed bugs:**

- fix caching issue [\#20](https://github.com/maestrano/mno-enterprise/pull/20) ([ouranos](https://github.com/ouranos))
- Fix assets precompile: add sprockets [\#16](https://github.com/maestrano/mno-enterprise/pull/16) ([ouranos](https://github.com/ouranos))
- Merge [v2.0.2](#v2.0.2)

## [v3.0.1](https://github.com/maestrano/mno-enterprise/tree/v3.0.1) (2016-04-22)
[Full Changelog](https://github.com/maestrano/mno-enterprise/compare/v3.0.0...v3.0.1)

**Implemented enhancements:**
- Enable widget list filtering [\#7](https://github.com/maestrano/mno-enterprise/pull/7) ([ouranos](https://github.com/ouranos))
- \[MNOE-60\] Admin platform: Users pagination, search and KPIs refactoring [\#6](https://github.com/maestrano/mno-enterprise/pull/6) ([alexnoox](https://github.com/alexnoox))
- \[MNOE-24\] Rails App Template [\#5](https://github.com/maestrano/mno-enterprise/pull/5) ([ouranos](https://github.com/ouranos))
- Improve frontend generation task

**Fixed bugs:**
- Fix issue with company renaming [\#9](https://github.com/maestrano/mno-enterprise/pull/9) ([x4d3](https://github.com/x4d3))
- \[MNOE-64\] Fix bug introduced in 552c0b7b [\#10](https://github.com/maestrano/mno-enterprise/pull/10) ([ouranos](https://github.com/ouranos))
- Merge [v2.0.1](#v2.0.1)

## [v3.0.0](https://github.com/maestrano/mno-enterprise/tree/v3.0.0) (2016-04-05)
[Full Changelog](https://github.com/maestrano/mno-enterprise/compare/v2.0.0...v3.0.0)
- New angular based frontend
- Remove old Rails based frontend
- Theme builder/previewer
- I18n implementation

## [v2.0.2](https://github.com/maestrano/mno-enterprise/tree/v2.0.2) (2016-05-12)
[Full Changelog](https://github.com/maestrano/mno-enterprise/compare/v2.0.1...v2.0.2)

**Implemented enhancements:**
- MYOB products naming [\#24](https://github.com/maestrano/mno-enterprise/pull/24) ([cesar-tonnoir](https://github.com/cesar-tonnoir))

**Fixed bugs:**
- Fix OrgInvite workflow with new frontends [\#28](https://github.com/maestrano/mno-enterprise/pull/28) ([ouranos](https://github.com/ouranos))
- Backport caching issue fix [\#26](https://github.com/maestrano/mno-enterprise/pull/26) ([ouranos](https://github.com/ouranos))

## [v2.0.1](https://github.com/maestrano/mno-enterprise/tree/v2.0.1) (2016-04-21)
[Full Changelog](https://github.com/maestrano/mno-enterprise/compare/v2.0.0...v2.0.1)

**Fixed bugs:**
- Added missing User#admin_role field
- expose financial\_year\_end\_month [\#13](https://github.com/maestrano/mno-enterprise/pull/13) ([cesar-tonnoir](https://github.com/cesar-tonnoir))

## [v2.0.0](https://github.com/maestrano/mno-enterprise/tree/v2.0.0) (2016-04-05)
- Split in multiple gems (api, core, frontend)
- Add admin frontend
