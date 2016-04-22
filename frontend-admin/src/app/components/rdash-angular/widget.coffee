#
# Widget Directive
#
@App.directive('rdWidget', ->
  scope: {
    loading: '=?',
    classes: '@?'
  },
  transclude: true,
  template: '<div class="widget"><rd-loading ng-show="loading"></rd-loading><div ng-hide="loading" ng-transclude></div></div>',
  restrict: 'EA'
)
