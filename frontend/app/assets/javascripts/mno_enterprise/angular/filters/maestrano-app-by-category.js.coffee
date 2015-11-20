
angular.module('maestrano.filters.app-by-category', []).filter('appByCategory',  ->
  return (apps, category) ->
    _.filter(apps, (app) -> _.contains(app.categories, category))
)
