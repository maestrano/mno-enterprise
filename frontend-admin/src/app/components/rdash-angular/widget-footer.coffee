#
# Widget Foooter Directive
#
@App.directive('rdWidgetFooter', ->
  requires: '^rdWidget'
  transclude: true
  template: '<div class="widget-footer" ng-transclude></div>'
  restrict: 'E'
)
