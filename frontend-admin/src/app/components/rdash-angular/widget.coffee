#
# Widget Directive
#
@App.directive('rdWidget', ->
  transclude: true,
  template: '<div class="widget" ng-transclude></div>',
  restrict: 'EA'
)
