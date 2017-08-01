# Change Log

## [Unreleased](https://github.com/maestrano/mno-enterprise/tree/master)
[Full Changelog](https://github.com/maestrano/mno-enterprise/compare/v3.3.1...HEAD)

## [v3.3.1](https://github.com/maestrano/mno-enterprise/tree/v3.3.1) (2017-07-24)
[Full Changelog](https://github.com/maestrano/mno-enterprise/compare/v3.3.0...v3.3.1)

**Implemented enhancements:**

- Add caching to marketplace endpoint [\#377](https://github.com/maestrano/mno-enterprise/pull/377) ([ouranos](https://github.com/ouranos))
- \[IMPAC-623\] create email alert on widget kpi create [\#375](https://github.com/maestrano/mno-enterprise/pull/375) ([xaun](https://github.com/xaun))
- \[MNOE-499\] Add locales [\#368](https://github.com/maestrano/mno-enterprise/pull/368) ([hedudelgado](https://github.com/hedudelgado))
- \[MNOE-501\] Locales added for on-boarding improvement [\#333](https://github.com/maestrano/mno-enterprise/pull/333) ([rheasunshine](https://github.com/rheasunshine))
- \[MNOE-474\] Add endpoints to admin api [\#327](https://github.com/maestrano/mno-enterprise/pull/327) ([adamaziz15](https://github.com/adamaziz15))

**Fixed bugs:**

- Fix missing locales [\#381](https://github.com/maestrano/mno-enterprise/pull/381) ([alexnoox](https://github.com/alexnoox))
- Fix impac locales task [\#379](https://github.com/maestrano/mno-enterprise/pull/379) ([ouranos](https://github.com/ouranos))
- \[MNOE-554\] Exclude Maestrano CDN from app description sanitisation [\#378](https://github.com/maestrano/mno-enterprise/pull/378) ([ouranos](https://github.com/ouranos))
- \[MNOE-474\] Fix locale typo [\#376](https://github.com/maestrano/mno-enterprise/pull/376) ([ouranos](https://github.com/ouranos))
- \[DEVPL-158\] Pricing Sync [\#372](https://github.com/maestrano/mno-enterprise/pull/372) ([adamaziz15](https://github.com/adamaziz15))
- \[MNOE-544\] Onboarding: fix locales [\#370](https://github.com/maestrano/mno-enterprise/pull/370) ([alexnoox](https://github.com/alexnoox))
- \[MNOE-533\] Reload her team object and fix fetch teams [\#360](https://github.com/maestrano/mno-enterprise/pull/360) ([hedudelgado](https://github.com/hedudelgado))

**Merged pull requests:**

- \[MNOE-474\] Update locales for review frontend [\#334](https://github.com/maestrano/mno-enterprise/pull/334) ([adamaziz15](https://github.com/adamaziz15))

## [v3.3.0](https://github.com/maestrano/mno-enterprise/tree/v3.3.0) (2017-06-20)
[Full Changelog](https://github.com/maestrano/mno-enterprise/compare/v3.2.0...v3.3.0)

See [UPGRADING](UPGRADING.md#migrating-from-v32-to-v33)

**Summary:**

* Onboarding wizard
* Audit Log in the dashboard and admin panel 
* Better app generation
* Extracted Admin Panel to a separate project (feature flags & style customisation)
* Improved design of static pages
* Improved Intercom integration
* [Lots of new feature flags](https://github.com/maestrano/mno-enterprise/compare/v3.2...3.3#TODO)

**Implemented enhancements:**

- Impac! i18n [\#322](https://github.com/maestrano/mno-enterprise/pull/322) ([cesar-tonnoir](https://github.com/cesar-tonnoir))
- Implement Fast Ruby idioms [\#318](https://github.com/maestrano/mno-enterprise/pull/318) ([ouranos](https://github.com/ouranos))
- \[MNOE-473\] Update settings template to include question feature flag [\#317](https://github.com/maestrano/mno-enterprise/pull/317) ([adamaziz15](https://github.com/adamaziz15))
- Ability - case insensitive check of admin\_role [\#316](https://github.com/maestrano/mno-enterprise/pull/316) ([ouranos](https://github.com/ouranos))
- \[MNOE-426\] - Logged additional events [\#309](https://github.com/maestrano/mno-enterprise/pull/309) ([fgourichon](https://github.com/fgourichon))
- \[MNOE-447\] Add admin dashboard templates: [\#308](https://github.com/maestrano/mno-enterprise/pull/308) ([hedudelgado](https://github.com/hedudelgado))
- \[IMPAC-578\] Create Widget KPIs [\#306](https://github.com/maestrano/mno-enterprise/pull/306) ([xaun](https://github.com/xaun))
- Update impac-angular and minimum node version [\#304](https://github.com/maestrano/mno-enterprise/pull/304) ([ouranos](https://github.com/ouranos))
- Add new fields and cache to the Marketplace [\#302](https://github.com/maestrano/mno-enterprise/pull/302) ([ouranos](https://github.com/ouranos))
- \[MNOE-407\] Onboarding wizard [\#301](https://github.com/maestrano/mno-enterprise/pull/301) ([alexnoox](https://github.com/alexnoox))
- \[MNO-643\] Fix logos no readable on white background in invoices [\#298](https://github.com/maestrano/mno-enterprise/pull/298) ([hedudelgado](https://github.com/hedudelgado))
- Displays frozen organisations [\#297](https://github.com/maestrano/mno-enterprise/pull/297) ([x4d3](https://github.com/x4d3))
- \[MNOE-246\] Follow NewRelic naming conventions [\#287](https://github.com/maestrano/mno-enterprise/pull/287) ([ouranos](https://github.com/ouranos))
- Add billing feature flag [\#282](https://github.com/maestrano/mno-enterprise/pull/282) ([ouranos](https://github.com/ouranos))
- \[MNOE-420\] Implement Organization freeze/unfreeze [\#279](https://github.com/maestrano/mno-enterprise/pull/279) ([x4d3](https://github.com/x4d3))
- \[MNOE-399\] Add ACL and settings [\#273](https://github.com/maestrano/mno-enterprise/pull/273) ([ouranos](https://github.com/ouranos))
- \[MNOE-399\] Add AuditLog to dashboard [\#272](https://github.com/maestrano/mno-enterprise/pull/272) ([ouranos](https://github.com/ouranos))
- \[MNOE-399\] Improve CSV export [\#271](https://github.com/maestrano/mno-enterprise/pull/271) ([ouranos](https://github.com/ouranos))
- Update travis rubies [\#269](https://github.com/maestrano/mno-enterprise/pull/269) ([ouranos](https://github.com/ouranos))
- \[MNOE-399\] Audit Log [\#261](https://github.com/maestrano/mno-enterprise/pull/261) ([ouranos](https://github.com/ouranos))
- \[MNOE-389\] Expose invoices in admin api [\#260](https://github.com/maestrano/mno-enterprise/pull/260) ([ouranos](https://github.com/ouranos))
- \[MNOE-246\] Update Rails template & Install generator [\#259](https://github.com/maestrano/mno-enterprise/pull/259) ([ouranos](https://github.com/ouranos))
- Add Admin Panel feature flags [\#258](https://github.com/maestrano/mno-enterprise/pull/258) ([ouranos](https://github.com/ouranos))
- \[MNOE-143\] Add marketplace settings [\#257](https://github.com/maestrano/mno-enterprise/pull/257) ([ouranos](https://github.com/ouranos))
- Bump default impac-angular version [\#256](https://github.com/maestrano/mno-enterprise/pull/256) ([ouranos](https://github.com/ouranos))
- \[MNOE-379\] User & Organization management feature flag [\#254](https://github.com/maestrano/mno-enterprise/pull/254) ([ouranos](https://github.com/ouranos))
- Update UPGRADING.md [\#245](https://github.com/maestrano/mno-enterprise/pull/245) ([ouranos](https://github.com/ouranos))
- \[MNOE-361\] Feature Flag - Disable Signup routes [\#243](https://github.com/maestrano/mno-enterprise/pull/243) ([ouranos](https://github.com/ouranos))
- \[MNOE-362\] Disable Payment [\#242](https://github.com/maestrano/mno-enterprise/pull/242) ([clemthenem](https://github.com/clemthenem))
- \[MNOE-360\] - add flag for impersonating [\#239](https://github.com/maestrano/mno-enterprise/pull/239) ([clemthenem](https://github.com/clemthenem))
- \[MNOE-301\] - Refactor billing details page to use the auth design [\#237](https://github.com/maestrano/mno-enterprise/pull/237) ([clemthenem](https://github.com/clemthenem))
- Add add\_on field for marketplace apps [\#235](https://github.com/maestrano/mno-enterprise/pull/235) ([hedudelgado](https://github.com/hedudelgado))
- Add endpoint for events webhook [\#231](https://github.com/maestrano/mno-enterprise/pull/231) ([hedudelgado](https://github.com/hedudelgado))
- Admin Panel build [\#230](https://github.com/maestrano/mno-enterprise/pull/230) ([alexnoox](https://github.com/alexnoox))
- Update default packages version [\#228](https://github.com/maestrano/mno-enterprise/pull/228) ([ouranos](https://github.com/ouranos))
- Feature - Rework impac interfaces [\#222](https://github.com/maestrano/mno-enterprise/pull/222) ([cesar-tonnoir](https://github.com/cesar-tonnoir))
- Add a new loader gif accordind to the new color palette [\#202](https://github.com/maestrano/mno-enterprise/pull/202) ([alexnoox](https://github.com/alexnoox))
- Redesigned the confirmation email page. [\#198](https://github.com/maestrano/mno-enterprise/pull/198) ([clemthenem](https://github.com/clemthenem))
- Fix static pages build [\#184](https://github.com/maestrano/mno-enterprise/pull/184) ([alexnoox](https://github.com/alexnoox))
- \[MNO-287\] Change developer registration event description [\#171](https://github.com/maestrano/mno-enterprise/pull/171) ([hedudelgado](https://github.com/hedudelgado))

**Fixed bugs:**

- Fix Impac! I18n specs [\#325](https://github.com/maestrano/mno-enterprise/pull/325) ([ouranos](https://github.com/ouranos))
- \[IMPAC-598\] Extend manage\_kpi ability for widget kpis [\#324](https://github.com/maestrano/mno-enterprise/pull/324) ([xaun](https://github.com/xaun))
- \[MNOE-463\] - Display error message when connecting wrong Xero  [\#323](https://github.com/maestrano/mno-enterprise/pull/323) ([fgourichon](https://github.com/fgourichon))
- \[MNOE-307\] - Impersonate with the right organization [\#314](https://github.com/maestrano/mno-enterprise/pull/314) ([fgourichon](https://github.com/fgourichon))
- Fix backward compatibility with MnoHub [\#305](https://github.com/maestrano/mno-enterprise/pull/305) ([ouranos](https://github.com/ouranos))
- Fix locales [\#303](https://github.com/maestrano/mno-enterprise/pull/303) ([hedudelgado](https://github.com/hedudelgado))
- Fix no organisation locale [\#299](https://github.com/maestrano/mno-enterprise/pull/299) ([alexnoox](https://github.com/alexnoox))
- Fix locale [\#295](https://github.com/maestrano/mno-enterprise/pull/295) ([hedudelgado](https://github.com/hedudelgado))
- \[MNOE-88\] Generate nginx config file [\#293](https://github.com/maestrano/mno-enterprise/pull/293) ([ouranos](https://github.com/ouranos))
- \[MNOE-291\] Fix association cache bug [\#291](https://github.com/maestrano/mno-enterprise/pull/291) ([ouranos](https://github.com/ouranos))
- \[MNOE-401\] Locales: Access of user without organizations [\#289](https://github.com/maestrano/mno-enterprise/pull/289) ([alexnoox](https://github.com/alexnoox))
- Fix connec\_ready? star\_ready? and responsive methods of App [\#286](https://github.com/maestrano/mno-enterprise/pull/286) ([x4d3](https://github.com/x4d3))
- \[MNOE-418\] Improve Intercom integration [\#285](https://github.com/maestrano/mno-enterprise/pull/285) ([ouranos](https://github.com/ouranos))
- \[MNOE-439\] Fix email address change notification wording [\#284](https://github.com/maestrano/mno-enterprise/pull/284) ([ouranos](https://github.com/ouranos))
- \[MNOE-433\] Fix flash helper for angular 1.6 [\#283](https://github.com/maestrano/mno-enterprise/pull/283) ([ouranos](https://github.com/ouranos))
- \[MNOE-399\] Fix locale [\#277](https://github.com/maestrano/mno-enterprise/pull/277) ([ouranos](https://github.com/ouranos))
- \[MNOE-399\] Fix ACL [\#274](https://github.com/maestrano/mno-enterprise/pull/274) ([ouranos](https://github.com/ouranos))
- \[MNOE-399\] Fix improve audit log config [\#270](https://github.com/maestrano/mno-enterprise/pull/270) ([ouranos](https://github.com/ouranos))
- \[MNOE-403\] Fix tooltip locale [\#266](https://github.com/maestrano/mno-enterprise/pull/266) ([alexnoox](https://github.com/alexnoox))
- Fix doc hyperlinks [\#250](https://github.com/maestrano/mno-enterprise/pull/250) ([ouranos](https://github.com/ouranos))
- Admin Panel: Fix logout [\#247](https://github.com/maestrano/mno-enterprise/pull/247) ([alexnoox](https://github.com/alexnoox))
- Fix the bang on Angular 1.6 [\#244](https://github.com/maestrano/mno-enterprise/pull/244) ([clemthenem](https://github.com/clemthenem))
- \[MNOE-155\] - Staff invite workflow [\#182](https://github.com/maestrano/mno-enterprise/pull/182) ([clemthenem](https://github.com/clemthenem))

**Merged pull requests:**

- \[MNOE-407\] Onboarding: Create account locales [\#321](https://github.com/maestrano/mno-enterprise/pull/321) ([alexnoox](https://github.com/alexnoox))
- \[MNOE-407\] Onboarding: fix missing locale [\#315](https://github.com/maestrano/mno-enterprise/pull/315) ([alexnoox](https://github.com/alexnoox))
- \[MNOE-407\] Onboarding locales update [\#313](https://github.com/maestrano/mno-enterprise/pull/313) ([alexnoox](https://github.com/alexnoox))
- \[DEVPL-407\] Onboarding locales update [\#311](https://github.com/maestrano/mno-enterprise/pull/311) ([alexnoox](https://github.com/alexnoox))
- \[MNOE-407\] Onboarding locales [\#310](https://github.com/maestrano/mno-enterprise/pull/310) ([alexnoox](https://github.com/alexnoox))
- Fix locale [\#296](https://github.com/maestrano/mno-enterprise/pull/296) ([hedudelgado](https://github.com/hedudelgado))
- Add URL\_CONFIG [\#290](https://github.com/maestrano/mno-enterprise/pull/290) ([fgourichon](https://github.com/fgourichon))


## [v3.2.0](https://github.com/maestrano/mno-enterprise/tree/v3.2.0) (2017-06-14)
[Full Changelog](https://github.com/maestrano/mno-enterprise/compare/v3.1.4...v3.2.0)

**Breaking changes:**

_Event Logger:_

If you're doing custom event login in your app, the `EventLogger.info` signature has changed:
```diff
-self.info(key, current_user_id, description, metadata, object)
+self.info(key, current_user_id, description, object, metadata = {})
```

_Frontend build:_

The frontend build process has been refactored. See [UPGRADING](UPGRADING.md#new-frontend-build-process).

**Major Features:**

- New frontend build process
- Implement App Rating/Review & App Comparison (disabled by default)
- Intercom in backend
- New purchase workflow
- Improve generated Rails application

**Implemented enhancements:**

- App Template: add protocol to mailer url config [\#319](https://github.com/maestrano/mno-enterprise/pull/319) ([ouranos](https://github.com/ouranos))
- Use settings.yml template as default settings [\#253](https://github.com/maestrano/mno-enterprise/pull/253) ([ouranos](https://github.com/ouranos))
- \[MNOE-375\]  Add Payment restrictions [\#252](https://github.com/maestrano/mno-enterprise/pull/252) ([ouranos](https://github.com/ouranos))
- \[MNOE-375\]  Add Payment restrictions [\#249](https://github.com/maestrano/mno-enterprise/pull/249) ([ouranos](https://github.com/ouranos))
- \[MNOE-328\] Add external\_id and source tagging to Intercom [\#248](https://github.com/maestrano/mno-enterprise/pull/248) ([ouranos](https://github.com/ouranos))
- Add User\#external\_id and meta\_data [\#240](https://github.com/maestrano/mno-enterprise/pull/240) ([ouranos](https://github.com/ouranos))
- \[MNOE-246\] Add Puma config file [\#227](https://github.com/maestrano/mno-enterprise/pull/227) ([ouranos](https://github.com/ouranos))
- \[IMPAC-328\] include params opts in kpis\_controller \#index [\#226](https://github.com/maestrano/mno-enterprise/pull/226) ([xaun](https://github.com/xaun))
- \[Mnoe Template\] Ask which mnoe version to use [\#224](https://github.com/maestrano/mno-enterprise/pull/224) ([ouranos](https://github.com/ouranos))
- \[MNO-512\] Discrepancy between Mno active admin and Intercom [\#223](https://github.com/maestrano/mno-enterprise/pull/223) ([x4d3](https://github.com/x4d3))
- \[MNOE-283\]\[MNOE-285\]\[MNOE-286\] App reviews [\#220](https://github.com/maestrano/mno-enterprise/pull/220) ([ouranos](https://github.com/ouranos))
- \[MNOE-265\] Logo size change [\#206](https://github.com/maestrano/mno-enterprise/pull/206) ([clemthenem](https://github.com/clemthenem))
- \[MNOE-282\] Disable app comparison by default [\#201](https://github.com/maestrano/mno-enterprise/pull/201) ([ouranos](https://github.com/ouranos))
- \[MNOE-282\] App comparison config [\#199](https://github.com/maestrano/mno-enterprise/pull/199) ([c3gdlk](https://github.com/c3gdlk))
- Relax constraint on config gem [\#189](https://github.com/maestrano/mno-enterprise/pull/189) ([ouranos](https://github.com/ouranos))
- Added automatic locales generation to the build [\#187](https://github.com/maestrano/mno-enterprise/pull/187) ([clemthenem](https://github.com/clemthenem))
- Application Rating & Review [\#186](https://github.com/maestrano/mno-enterprise/pull/186) ([ouranos](https://github.com/ouranos))
- \[MNO-436\] notify user of changes [\#183](https://github.com/maestrano/mno-enterprise/pull/183) ([clemthenem](https://github.com/clemthenem))
- \[MNOE-242\] Refactor build process [\#181](https://github.com/maestrano/mno-enterprise/pull/181) ([ouranos](https://github.com/ouranos))
- \[MNOE-246\] Improve generated app config [\#178](https://github.com/maestrano/mno-enterprise/pull/178) ([ouranos](https://github.com/ouranos))
- Comments pagination [\#177](https://github.com/maestrano/mno-enterprise/pull/177) ([hedudelgado](https://github.com/hedudelgado))
- \[MNO-399\] Upgrade Angular and jQuery on Rails pages [\#174](https://github.com/maestrano/mno-enterprise/pull/174) ([ouranos](https://github.com/ouranos))
- \[MNO-396\] Sanitize mandrill merge vars [\#173](https://github.com/maestrano/mno-enterprise/pull/173) ([ouranos](https://github.com/ouranos))
- \[MNOE-162\] Add Intercom support for personal token [\#172](https://github.com/maestrano/mno-enterprise/pull/172) ([ouranos](https://github.com/ouranos))
- \[MNOE-259\] Add New Relic config to generator [\#166](https://github.com/maestrano/mno-enterprise/pull/166) ([ouranos](https://github.com/ouranos))
- \[MNO-390\] Remove calls to kpi\_enabled? [\#155](https://github.com/maestrano/mno-enterprise/pull/155) ([x4d3](https://github.com/x4d3))
- \[MNOE-243\] Disable I18n by default in generator [\#154](https://github.com/maestrano/mno-enterprise/pull/154) ([ouranos](https://github.com/ouranos))
- \[MNO-287\] Developer Section in My Account [\#153](https://github.com/maestrano/mno-enterprise/pull/153) ([hedudelgado](https://github.com/hedudelgado))
- Update email doc in README [\#152](https://github.com/maestrano/mno-enterprise/pull/152) ([ouranos](https://github.com/ouranos))
- \[MNOE-157\] - Admin connect app [\#147](https://github.com/maestrano/mno-enterprise/pull/147) ([clemthenem](https://github.com/clemthenem))
- \[Perf\] Add AssociationProxy\#loaded? [\#146](https://github.com/maestrano/mno-enterprise/pull/146) ([ouranos](https://github.com/ouranos))
- Add Organization\#widgets and /organizations/:id/widgets [\#144](https://github.com/maestrano/mno-enterprise/pull/144) ([cesar-tonnoir](https://github.com/cesar-tonnoir))
- Add documentation on how to extend the backend [\#140](https://github.com/maestrano/mno-enterprise/pull/140) ([ouranos](https://github.com/ouranos))
- Extract Team to Concern [\#139](https://github.com/maestrano/mno-enterprise/pull/139) ([ouranos](https://github.com/ouranos))
- Locales related to app provisionning fixes [\#138](https://github.com/maestrano/mno-enterprise/pull/138) ([alexnoox](https://github.com/alexnoox))
- Add Intercom documentation [\#137](https://github.com/maestrano/mno-enterprise/pull/137) ([ouranos](https://github.com/ouranos))
- \[MNOE-188\] - Added SSO icons on the login page [\#136](https://github.com/maestrano/mno-enterprise/pull/136) ([clemthenem](https://github.com/clemthenem))
- Decorate controllers and removed unused ones [\#135](https://github.com/maestrano/mno-enterprise/pull/135) ([ouranos](https://github.com/ouranos))
- \[MNOE-170\] App modals SPA: Locales [\#132](https://github.com/maestrano/mno-enterprise/pull/132) ([alexnoox](https://github.com/alexnoox))
- \[MNOE-206\] Expose free\_trial\_end\_at to mnoe angular [\#131](https://github.com/maestrano/mno-enterprise/pull/131) ([hedudelgado](https://github.com/hedudelgado))
- Add sidekiq documentation [\#129](https://github.com/maestrano/mno-enterprise/pull/129) ([ouranos](https://github.com/ouranos))
- \[MNOE-170\] - Purchase Workflow [\#125](https://github.com/maestrano/mno-enterprise/pull/125) ([clemthenem](https://github.com/clemthenem))
- \[MNOE-207\] Intercom Event Logger - Add user\_id [\#117](https://github.com/maestrano/mno-enterprise/pull/117) ([x4d3](https://github.com/x4d3))
- Intercom - Add more information when app is launched [\#109](https://github.com/maestrano/mno-enterprise/pull/109) ([x4d3](https://github.com/x4d3))
- Improve perf in json views [\#108](https://github.com/maestrano/mno-enterprise/pull/108) ([alachaum](https://github.com/alachaum))
- \[MNOE-167\] Add OAuth SSO [\#107](https://github.com/maestrano/mno-enterprise/pull/107) ([ouranos](https://github.com/ouranos))
- Impac alert porting [\#106](https://github.com/maestrano/mno-enterprise/pull/106) ([cesar-tonnoir](https://github.com/cesar-tonnoir))
- \[MNOE-62\] Add Terms page [\#103](https://github.com/maestrano/mno-enterprise/pull/103) ([ouranos](https://github.com/ouranos))
- Asynchronous Event Logging & improve doc [\#102](https://github.com/maestrano/mno-enterprise/pull/102) ([ouranos](https://github.com/ouranos))
- Add corners variable to login box [\#101](https://github.com/maestrano/mno-enterprise/pull/101) ([hedudelgado](https://github.com/hedudelgado))
- \[MNOE-165\] Does not permit to install a second app if the app is not multi\_instantiable [\#88](https://github.com/maestrano/mno-enterprise/pull/88) ([x4d3](https://github.com/x4d3))
- \[MNOE-156\] - Improvements [\#87](https://github.com/maestrano/mno-enterprise/pull/87) ([clemthenem](https://github.com/clemthenem))
- Expose user API  credentials [\#86](https://github.com/maestrano/mno-enterprise/pull/86) ([cesar-tonnoir](https://github.com/cesar-tonnoir))
- \[MNO-271\] Add support for Intercom secure mode [\#85](https://github.com/maestrano/mno-enterprise/pull/85) ([ouranos](https://github.com/ouranos))
- Add Intercom Server Side [\#82](https://github.com/maestrano/mno-enterprise/pull/82) ([x4d3](https://github.com/x4d3))
- \[MNO-281\] Add intercom setting [\#71](https://github.com/maestrano/mno-enterprise/pull/71) ([hedudelgado](https://github.com/hedudelgado))
- \[MNOE-135\] Add .editorconfig [\#63](https://github.com/maestrano/mno-enterprise/pull/63) ([ouranos](https://github.com/ouranos))
- Add i18n for dock and its settings [\#62](https://github.com/maestrano/mno-enterprise/pull/62) ([hedudelgado](https://github.com/hedudelgado))
- Transmit parameters  given to launch in the redirection [\#60](https://github.com/maestrano/mno-enterprise/pull/60) ([x4d3](https://github.com/x4d3))
- \[MNOE-109\] Better App title management [\#52](https://github.com/maestrano/mno-enterprise/pull/52) ([winnietan](https://github.com/winnietan))

**Fixed bugs:**

- \[MNOE-443\] Fix password change notification [\#292](https://github.com/maestrano/mno-enterprise/pull/292) ([ouranos](https://github.com/ouranos))
- Patch devise lockable hook [\#275](https://github.com/maestrano/mno-enterprise/pull/275) ([ouranos](https://github.com/ouranos))
- Fix locale error [\#267](https://github.com/maestrano/mno-enterprise/pull/267) ([ouranos](https://github.com/ouranos))
- \[MNOE-394\] Respect yarn.lock dependencies on build [\#265](https://github.com/maestrano/mno-enterprise/pull/265) ([ouranos](https://github.com/ouranos))
- Fix T&C page when no apps are present [\#264](https://github.com/maestrano/mno-enterprise/pull/264) ([adamaziz15](https://github.com/adamaziz15))
- Update mnohub endpoint in the generator [\#262](https://github.com/maestrano/mno-enterprise/pull/262) ([ouranos](https://github.com/ouranos))
- Fix cache refresh when there's a marshalling error [\#251](https://github.com/maestrano/mno-enterprise/pull/251) ([ouranos](https://github.com/ouranos))
- Devise - Do not load an ORM [\#233](https://github.com/maestrano/mno-enterprise/pull/233) ([ouranos](https://github.com/ouranos))
- Fix Devise \#authenticate\_user! signature [\#229](https://github.com/maestrano/mno-enterprise/pull/229) ([ouranos](https://github.com/ouranos))
- Fix staff page inaccessible [\#204](https://github.com/maestrano/mno-enterprise/pull/204) ([clemthenem](https://github.com/clemthenem))
- 	\[MNOE-294\] Wrong redirection when connecting an app [\#196](https://github.com/maestrano/mno-enterprise/pull/196) ([ouranos](https://github.com/ouranos))
- Fix outdated wiki link in README [\#193](https://github.com/maestrano/mno-enterprise/pull/193) ([ouranos](https://github.com/ouranos))
- Fix locales generation [\#192](https://github.com/maestrano/mno-enterprise/pull/192) ([ouranos](https://github.com/ouranos))
- \[IMPAC-411\] kpi\_enable property on mnoe user model [\#176](https://github.com/maestrano/mno-enterprise/pull/176) ([xaun](https://github.com/xaun))
- \[MNOE-54\]\[MNO-324\] Manage admin role update backend [\#160](https://github.com/maestrano/mno-enterprise/pull/160) ([ouranos](https://github.com/ouranos))
- Fix SSO links when no providers configured [\#150](https://github.com/maestrano/mno-enterprise/pull/150) ([ouranos](https://github.com/ouranos))
- \[MNOE-153\] Fix admin panel app selection on non-retina screens [\#130](https://github.com/maestrano/mno-enterprise/pull/130) ([alexnoox](https://github.com/alexnoox))
- Fix deserialization error of deleted Object in EventLoggerJob [\#127](https://github.com/maestrano/mno-enterprise/pull/127) ([x4d3](https://github.com/x4d3))
- \[MNO-322\]\[MNO-333\] Improve App provisioning [\#114](https://github.com/maestrano/mno-enterprise/pull/114) ([ouranos](https://github.com/ouranos))
- Fix missing locales on marketplace [\#111](https://github.com/maestrano/mno-enterprise/pull/111) ([alexnoox](https://github.com/alexnoox))
- \[MNOE-138\]\[MNOE-168\] Fix double provisioning issue [\#110](https://github.com/maestrano/mno-enterprise/pull/110) ([ouranos](https://github.com/ouranos))
- Fix typo and add missing specs [\#69](https://github.com/maestrano/mno-enterprise/pull/69) ([ouranos](https://github.com/ouranos))

**Merged pull requests:**

- Missing locales [\#221](https://github.com/maestrano/mno-enterprise/pull/221) ([clemthenem](https://github.com/clemthenem))
- Addeds locales and fixed others [\#219](https://github.com/maestrano/mno-enterprise/pull/219) ([clemthenem](https://github.com/clemthenem))
- Added locales [\#218](https://github.com/maestrano/mno-enterprise/pull/218) ([clemthenem](https://github.com/clemthenem))
- Add :edited\_by\_name, :edited\_by\_admin\_role, :edited\_by\_id fields in a AppReview [\#217](https://github.com/maestrano/mno-enterprise/pull/217) ([x4d3](https://github.com/x4d3))
- Added locales to improve edit modal wording [\#215](https://github.com/maestrano/mno-enterprise/pull/215) ([clemthenem](https://github.com/clemthenem))
- Delete modals locales [\#214](https://github.com/maestrano/mno-enterprise/pull/214) ([alexnoox](https://github.com/alexnoox))
- Rephrase wording [\#213](https://github.com/maestrano/mno-enterprise/pull/213) ([clemthenem](https://github.com/clemthenem))
- Added app install component locales [\#212](https://github.com/maestrano/mno-enterprise/pull/212) ([clemthenem](https://github.com/clemthenem))
- \[MNOE-286\] - Locales from versioning [\#210](https://github.com/maestrano/mno-enterprise/pull/210) ([clemthenem](https://github.com/clemthenem))
- \[MNOE-282/286\] Application compare locales [\#209](https://github.com/maestrano/mno-enterprise/pull/209) ([clemthenem](https://github.com/clemthenem))
- Forgot to commit specs :s [\#180](https://github.com/maestrano/mno-enterprise/pull/180) ([ouranos](https://github.com/ouranos))
- Add locales in mnoe [\#179](https://github.com/maestrano/mno-enterprise/pull/179) ([alexnoox](https://github.com/alexnoox))
- Update settings.yml to include impac\_pusher\_key [\#169](https://github.com/maestrano/mno-enterprise/pull/169) ([xaun](https://github.com/xaun))
- Rename model Rating to Review [\#167](https://github.com/maestrano/mno-enterprise/pull/167) ([x4d3](https://github.com/x4d3))
- Ratings property is always displayed, even as an empry array [\#165](https://github.com/maestrano/mno-enterprise/pull/165) ([alexnoox](https://github.com/alexnoox))
- Add transparent logo [\#164](https://github.com/maestrano/mno-enterprise/pull/164) ([adamaziz15](https://github.com/adamaziz15))
- Implement comments management in Admin Panel [\#161](https://github.com/maestrano/mno-enterprise/pull/161) ([hedudelgado](https://github.com/hedudelgado))
- Add App User Rating [\#159](https://github.com/maestrano/mno-enterprise/pull/159) ([x4d3](https://github.com/x4d3))
- \[MNO-287\] Developer Section locales [\#157](https://github.com/maestrano/mno-enterprise/pull/157) ([alexnoox](https://github.com/alexnoox))
- \[MNOE-241\] Notification toastr after adding an app locales [\#156](https://github.com/maestrano/mno-enterprise/pull/156) ([alexnoox](https://github.com/alexnoox))
- Code Improvements [\#141](https://github.com/maestrano/mno-enterprise/pull/141) ([ouranos](https://github.com/ouranos))
- Travis: ruby 2.1.8 [\#128](https://github.com/maestrano/mno-enterprise/pull/128) ([ouranos](https://github.com/ouranos))
- \[IMPAC-371\] Fix targets & alerts being deleted on metadata currency update [\#116](https://github.com/maestrano/mno-enterprise/pull/116) ([xaun](https://github.com/xaun))
- \[MNOE-310\] Fix empty email error [\#113](https://github.com/maestrano/mno-enterprise/pull/113) ([alexnoox](https://github.com/alexnoox))
- Fix OAuth SSO [\#112](https://github.com/maestrano/mno-enterprise/pull/112) ([ouranos](https://github.com/ouranos))
- Fix typo [\#64](https://github.com/maestrano/mno-enterprise/pull/64) ([hedudelgado](https://github.com/hedudelgado))
- Add add\_on field to apps instances [\#59](https://github.com/maestrano/mno-enterprise/pull/59) ([hedudelgado](https://github.com/hedudelgado))
- Update Readme [\#58](https://github.com/maestrano/mno-enterprise/pull/58) ([hedudelgado](https://github.com/hedudelgado))
- Fix typo [\#57](https://github.com/maestrano/mno-enterprise/pull/57) ([hedudelgado](https://github.com/hedudelgado))
- Edited README.md [\#56](https://github.com/maestrano/mno-enterprise/pull/56) ([hedudelgado](https://github.com/hedudelgado))


## [v3.1.4](https://github.com/maestrano/mno-enterprise/tree/v3.1.4) (2017-06-05)
[Full Changelog](https://github.com/maestrano/mno-enterprise/compare/v3.1.3...v3.1.4)

**Fixed bugs:**

- \[MNOE-358\] Fix dev mailer [\#276](https://github.com/maestrano/mno-enterprise/pull/276) ([ouranos](https://github.com/ouranos))
- Merge [v3.0.7](#v3.0.7)

## [v3.1.3](https://github.com/maestrano/mno-enterprise/tree/v3.1.3) (2016-11-09)
[Full Changelog](https://github.com/maestrano/mno-enterprise/compare/v3.1.2...v3.1.3)

**Fixed bugs:**

- Fix built in email templates [\#149](https://github.com/maestrano/mno-enterprise/pull/149) ([ouranos](https://github.com/ouranos))
- Merge [v3.0.6](#v3.0.6)

## [v3.1.2](https://github.com/maestrano/mno-enterprise/tree/v3.1.2) (2016-09-30)
[Full Changelog](https://github.com/maestrano/mno-enterprise/compare/v3.1.1...v3.1.2)

**Implemented enhancements:**

- \[MNOE-149\] Use redirect\_uri when impersonating uri [\#81](https://github.com/maestrano/mno-enterprise/pull/81) ([ouranos](https://github.com/ouranos))

**Fixed bugs:**

- \[MNOE-148\] Only display connectors in admin onboarding [\#76](https://github.com/maestrano/mno-enterprise/pull/76) ([ouranos](https://github.com/ouranos))

- Merge [v3.0.5](#v3.0.5)

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

## [v3.0.7](https://github.com/maestrano/mno-enterprise/tree/v3.0.7) (2017-06-05)
[Full Changelog](https://github.com/maestrano/mno-enterprise/compare/v3.0.6...v3.0.7)

**Fixed bugs:**

- Merge [v2.0.9](#v2.0.9)

## [v3.0.6](https://github.com/maestrano/mno-enterprise/tree/v3.0.6) (2016-11-09)
[Full Changelog](https://github.com/maestrano/mno-enterprise/compare/v3.0.5...v3.0.6)

**Implemented enhancements:**

- \[MNOE-110\] Improve Health Check [\#121](https://github.com/maestrano/mno-enterprise/pull/121) ([ouranos](https://github.com/ouranos))

**Fixed bugs:**

- \[MNOE-205\] Add style to unlock page [\#126](https://github.com/maestrano/mno-enterprise/pull/126) ([ouranos](https://github.com/ouranos))

- Merge [v2.0.8](#v2.0.8)

## [v3.0.5](https://github.com/maestrano/mno-enterprise/tree/v3.0.5) (2016-09-30)
[Full Changelog](https://github.com/maestrano/mno-enterprise/compare/v3.0.4...v3.0.5)

**Fixed bugs:**

- Rephrased the link to terms of use [\#98](https://github.com/maestrano/mno-enterprise/pull/98) ([ouranos](https://github.com/ouranos))
- Fix time-dependent specs [\#94](https://github.com/maestrano/mno-enterprise/pull/94) ([ouranos](https://github.com/ouranos))
- \[MNOE-107\] Fix admin finance page [\#75](https://github.com/maestrano/mno-enterprise/pull/75) ([ouranos](https://github.com/ouranos))

- Merge [v2.0.7](#v2.0.7)
- Merge [v2.0.6](#v2.0.6)
- Merge [v2.0.5](#v2.0.5)

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

## [v2.0.9](https://github.com/maestrano/mno-enterprise/tree/v2.0.8) (2017-06-05)
[Full Changelog](https://github.com/maestrano/mno-enterprise/compare/v2.0.8...v2.0.9)

**Fixed bugs:**

- \[MNOE-27\] Fix double loading [\#307](https://github.com/maestrano/mno-enterprise/pull/307) ([ouranos](https://github.com/ouranos))

## [v2.0.8](https://github.com/maestrano/mno-enterprise/tree/v2.0.8) (2016-11-09)
[Full Changelog](https://github.com/maestrano/mno-enterprise/compare/v2.0.7...v2.0.8)

**Implemented enhancements:**

- \[PERF\] Avoid duplicated requests on admin endpoints [\#148](https://github.com/maestrano/mno-enterprise/pull/148) ([ouranos](https://github.com/ouranos))

**Fixed bugs:**

- \[MNOE-177\] UI: SignUp Page: Error message displayed when email is already registered [\#120](https://github.com/maestrano/mno-enterprise/pull/120) ([ouranos](https://github.com/ouranos))

## [v2.0.7](https://github.com/maestrano/mno-enterprise/tree/v2.0.7) (2016-09-30)
[Full Changelog](https://github.com/maestrano/mno-enterprise/compare/v2.0.6...v2.0.7)

**Fixed bugs:**

- Fix BaseResource\#save! [\#100](https://github.com/maestrano/mno-enterprise/pull/100) ([ouranos](https://github.com/ouranos))
- Fix belongs\_to when foreign key is nil [\#99](https://github.com/maestrano/mno-enterprise/pull/99) ([ouranos](https://github.com/ouranos))

## [v2.0.6](https://github.com/maestrano/mno-enterprise/tree/v2.0.6) (2016-09-27)
[Full Changelog](https://github.com/maestrano/mno-enterprise/compare/v2.0.5...v2.0.6)

**Implemented enhancements:**

- \[MNOE-149\] Use redirect\_uri when impersonating uri [\#80](https://github.com/maestrano/mno-enterprise/pull/80) ([ouranos](https://github.com/ouranos))

**Closed issues:**

- Improve performance for `dashboard.organizations` [\#73](https://github.com/maestrano/mno-enterprise/issues/73)

**Fixed bugs:**

- Fixed CVV field returned on empty credit card details [\#97](https://github.com/maestrano/mno-enterprise/pull/97) ([clemthenem](https://github.com/clemthenem))
- \[MNOE-154\] Fix phone number autofill in signup page [\#96](https://github.com/maestrano/mno-enterprise/pull/96) ([clemthenem](https://github.com/clemthenem))
- Fix Her monkey patch \#first\_or\_create/initialize [\#89](https://github.com/maestrano/mno-enterprise/pull/89) ([ouranos](https://github.com/ouranos))

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
