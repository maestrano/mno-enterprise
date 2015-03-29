angular.module('maestrano.filters.replace-underscore-with-space', []).filter('replaceUnderscoreWithSpace', [ ->
  return (text) ->
    return text.replace(/_/g, ' ')
])
