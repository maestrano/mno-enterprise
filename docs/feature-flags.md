# Feature Flags

Most of the main features of the `mno-enterprise` framework are gated behind feature flags.
This allow to easily control the feature set of a given frontend without the need for development

You can see the description of all feature flags on our [Developers Space](https://maestrano.atlassian.net/wiki/display/DEV/Frontend+Feature+Flags)

This section will explain in details how the feature flags are implemented, if you just need to add a new feature flag you can skip to [Add a new feature flag](#adding-a-new-feature-flag).

- - -

1.  [Definition](#definition)
1.  [Usage](#usage)
1.  [Add a new feature flag](#adding-a-new-feature-flag)

- - -

## Definition

The feature flags are defined through a [JSON Schema](http://json-schema.org/) in [`core/config/initializers/00_tenant_config_schema.rb`](../core/config/initializers/00_tenant_config_schema.rb)

For each poperty we can define:
* a `type` (`string`, `boolean`, `array`, ...)
* a `default` value
* a `description`
* a `title`

There are 3 main sections:
* `system`: settings that are only exposed to the backend. Good for secret and backend configuration
* `dashboard`: controls the dashboard behavior (`mno-enterprise-angular`)
* `admin_panel`: controls the admin panel behavior (`mnoe-admin-panel`)

_Note_: The `dashboard` and `admin_panel` sections are exposed to the frontend. Be careful not to expose credentials in them.

## Usage

### Backend (`mno-enterprise`)

Feature flags are accessed through `Settings.section.config_entry` (eg: `Settings.system.app_name`)

They're ultimately controlled via MnoHub but here's the order of precedence in which they are set:

1. `TenantConfig::JSON_SCHEMA`: Used for default values. See `core/config/initializers/config.rb` (the schema is converted to a Ruby Hash with `MnoEnterprise::TenantConfig.to_hash`)
1. `Tenant#frontend_config`: Fetched from MnoHub. See [`core/lib/mno_enterprise/engine.rb`](../core/lib/mno_enterprise/engine.rb)
1. `ENV['SETTINGS__xxxx']`: Not recommended. See [`core/config/initializers/config.rb`](../core/config/initializers/config.rb)

The `config/settings.yml` and `config/settings/#{environment}.yml` files are still working, although no longer supported.
They're evaluated between 1 and 2.

### Frontend (`mno-enterprise-angular` & `mnoe-admin-panel`)

The `dashboard` and `admin_panel` sections of the configuration are exposed to the frontend as constants via `/mnoe/config.js`.
See [`config/show.js.coffee`](../api/app/views/mno_enterprise/config/show.js.coffee) for more details.

In the frontend, we use a wrapper around those constants.

See :
* [`MnoeConfig` service](https://github.com/maestrano/mno-enterprise-angular/blob/2.0/src/app/components/mnoe-config/mnoe-config.svc.coffee)
* [`MnoeAdminConfig` service](https://github.com/maestrano/mnoe-admin-panel/blob/2.0/src/app/components/mnoe-config/mnoe-admin-config.svc.coffee)

## Adding a new feature flag

### mno-enterprise:
* Edit `core/config/initializers/00_tenant_config_schema.rb`
* Update the `CONFIG_JSON_SCHEMA` with your new feature flag, including default value and description

### mno-enterprise-angular:
* Add a wrapper around your new feature flag in the [`MnoeConfig` service](https://github.com/maestrano/mno-enterprise-angular/blob/2.0/src/app/components/mnoe-config/mnoe-config.svc.coffee)
* Use the `MnoeConfig` wrapper in your code

### mnoe-admin-panel:
* Add a wrapper around your new feature flag in the [`MnoeAdminConfig` service](https://github.com/maestrano/mnoe-admin-panel/blob/2.0/src/app/components/mnoe-config/mnoe-admin-config.svc.coffee)
* Use the `MnoeAdminConfig` wrapper in your code
