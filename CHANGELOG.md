# Change Log

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
