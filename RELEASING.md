# Releasing mno-enterprise

This document outline the steps necessary to release mno-enterprise.

## Before the release

### Is the CI green? If not, make it green

Do NOT release with a red CI.

### Notify implementors

TODO

<!-- This is only required for major and minor releases, patch releases aren't a big enough deal, and are supposed to be backwards compatible. -->

## Prepare the release

### Update the CHANGELOG

Review the commits since the last release and update the CHANGELOG appropriately.

If the last release was 2.0.5, you can review the commits for the 3.0.6 release like this:

```
mno-enterprise (git:2.0) $ git log v2.0.5..
```

If you're doing a stable branch release, you should also ensure that the CHANGELOG entries in the stable branch is synced to the master branch.

### Update the MNOE_VERSION to reflect the new version

### Release the gems

Run `rake gem:release`. This will update the gem version from MNOE_VERSION, commit the changes, tag it and push the gems to rubygems.org.

### Send release annoucements

TODO
