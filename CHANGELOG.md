# Change Log

## [Unreleased](https://github.com/maestrano/mno-enterprise/tree/master)

[Full Changelog](https://github.com/maestrano/mno-enterprise/compare/v3.1.1...HEAD)

## [v3.1.1](https://github.com/maestrano/mno-enterprise/tree/v3.1.1) (2016-08-29)
[Full Changelog](https://github.com/maestrano/mno-enterprise/compare/v3.1.0...v3.1.1)

**Implemented enhancements:**

- \[MNOE-106\] Admin Panel Improvements [\#54](https://github.com/maestrano/mno-enterprise/pull/54) ([claire00](https://github.com/claire00))
- Improve doc regarding favicon [\#53](https://github.com/maestrano/mno-enterprise/pull/53) ([x4d3](https://github.com/x4d3))

**Fixed bugs:**

- Admin Panel bug fixes [\#68](https://github.com/maestrano/mno-enterprise/pull/68) ([alexnoox](https://github.com/alexnoox))
- \[MNOE-117\] Generate stub font-faces.less [\#65](https://github.com/maestrano/mno-enterprise/pull/65) ([ouranos](https://github.com/ouranos))

## [v3.1.0](https://github.com/maestrano/mno-enterprise/tree/v3.1.0) (2016-07-13)

[Full Changelog](https://github.com/maestrano/mno-enterprise/compare/v3.0.2..v3.0.3)

**Implemented enhancements:**

- Add SparkPost support for transactional emails. You can now choose either Mandrill or SparkPost.
- CI setup [\#37](https://github.com/maestrano/mno-enterprise/pull/37) ([ouranos](https://github.com/ouranos))
- \[MNOE-65\] / \[MNOE-87\] - Implemented staff manager page [\#35](https://github.com/maestrano/mno-enterprise/pull/35) ([clemthenem](https://github.com/clemthenem))
- Use price instead of price\_tag [\#34](https://github.com/maestrano/mno-enterprise/pull/34) ([x4d3](https://github.com/x4d3))
- \[MNOE-91\] Native possibility to set a background picture on the login page  [\#40](https://github.com/maestrano/mno-enterprise/pull/40) ([claire00](https://github.com/claire00))
- \[MNOE-56\] Google Tag Manager Container [\#48](https://github.com/maestrano/mno-enterprise/pull/48) ([claire00](https://github.com/claire00))
- \[MNOE-97\] Add missing value in rails template [\#47](https://github.com/maestrano/mno-enterprise/pull/47) ([winnietan](https://github.com/winnietan))
- \[MNOE-98\] Display App Pricing [\#43](https://github.com/maestrano/mno-enterprise/pull/43) ([winnietan](https://github.com/winnietan))
- UAT should be pointing to production as well. [\#42](https://github.com/maestrano/mno-enterprise/pull/42) ([x4d3](https://github.com/x4d3))

**Fixed bugs:**

- Fixed bugs in the staff page and added improvments [\#46](https://github.com/maestrano/mno-enterprise/pull/46) ([clemthenem](https://github.com/clemthenem))
- [MNOE-84] Fixed app ranking on express instances [\#45](https://github.com/maestrano/mno-enterprise/pull/45) ([hedudelgado](https://github.com/hedudelgado))

**Deprecated:**

- `MnoEnteprise.config.mandrill_key` is replaced with `ENV['MANDRILL_API_KEY']`
- `MandrillClient` is replaced with `MnoEnterprise::MailClient`

## [v3.0.4](https://github.com/maestrano/mno-enterprise/tree/v3.0.4) (2016-08-30)
[Full Changelog](https://github.com/maestrano/mno-enterprise/compare/v3.0.3...v3.0.4)

- Merge [v2.0.4](#v2.0.4)

## [v3.0.3](https://github.com/maestrano/mno-enterprise/tree/v3.0.3) (2016-07-13)

[Full Changelog](https://github.com/maestrano/mno-enterprise/compare/v3.0.2...v3.0.3)

**Implemented enhancements:**

- Add uat environment to the template [\#32](https://github.com/maestrano/mno-enterprise/pull/32) ([ouranos](https://github.com/ouranos))

**Fixed bugs:**

- Correct root redirection in template routes
- \[MNOE-70\] Anybody can access /admin/ [\#36](https://github.com/maestrano/mno-enterprise/pull/36) ([alexnoox](https://github.com/alexnoox))
- Fix time-dependent specs [\#44](https://github.com/maestrano/mno-enterprise/pull/44) ([ouranos](https://github.com/ouranos))
- Merge [v2.0.3](#v2.0.3)

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

## [v2.0.5](https://github.com/maestrano/mno-enterprise/tree/v2.0.5) (2016-09-09)
[Full Changelog](https://github.com/maestrano/mno-enterprise/compare/v2.0.4...v2.0.5)

**Implemented enhancements:**

- \[MNOE-149\] Allow impersonate\_redirect\_uri [\#78](https://github.com/maestrano/mno-enterprise/pull/78) ([ouranos](https://github.com/ouranos))
- Expose mno-api-host in /version [\#74](https://github.com/maestrano/mno-enterprise/pull/74) ([ouranos](https://github.com/ouranos))

**Fixed bugs:**

- \[MNOE-150\] Remove Kpi\#name [\#77](https://github.com/maestrano/mno-enterprise/pull/77) ([ouranos](https://github.com/ouranos))
- Add support for pending connector sync [\#72](https://github.com/maestrano/mno-enterprise/pull/72) ([BrunoChauvet](https://github.com/BrunoChauvet))

## [v2.0.4](https://github.com/maestrano/mno-enterprise/tree/v2.0.4) (2016-08-30)
[Full Changelog](https://github.com/maestrano/mno-enterprise/compare/v2.0.3...v2.0.4)

**Implemented enhancements:**

- \[MNOE-137\] Add Her middleware to handle errors [\#70](https://github.com/maestrano/mno-enterprise/pull/70) ([ouranos](https://github.com/ouranos))

**Fixed bugs:**

- \[MNOE-125\] Fix filtering on empty array [\#61](https://github.com/maestrano/mno-enterprise/pull/61) ([ouranos](https://github.com/ouranos))

## [v2.0.3](https://github.com/maestrano/mno-enterprise/tree/v2.0.3) (2016-07-12)
[Full Changelog](https://github.com/maestrano/mno-enterprise/compare/v2.0.2...v2.0.3)

**Implemented enhancements:**

- impac widgets\_controller to be overridable [\#39](https://github.com/maestrano/mno-enterprise/pull/39) ([cesar-tonnoir](https://github.com/cesar-tonnoir))

**Fixed bugs:**

- Fix invite when home\_path already has a fragment [\#49](https://github.com/maestrano/mno-enterprise/pull/49) ([ouranos](https://github.com/ouranos))
- Fix error when sending invite to unconfirmed email [\#31](https://github.com/maestrano/mno-enterprise/pull/31) ([ouranos](https://github.com/ouranos))

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

\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
