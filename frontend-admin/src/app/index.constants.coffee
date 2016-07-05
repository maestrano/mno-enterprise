@App
  .constant('USER_ROLES', ['Member', 'Power User', 'Admin', 'Super Admin'])
  .constant('ADMIN_ROLES', ['admin', 'staff'])  # Must be lower case
  .constant('STAFF_PAGE_AUTH', ['admin'])
  .constant('OBS_KEYS', {
    userChanged: 'userListChanged',
    staffChanged: 'staffListChanged',
    staffAdded: 'staffAdded'
    })
