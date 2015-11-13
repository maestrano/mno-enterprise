#
# Widget Header Directive
#
@App.directive('rdWidgetHeader', ->
  requires: '^rdWidget'
  scope:
    title: '@'
    icon: '@'
  transclude: true
  template: '<div class="widget-header"><div class="row"><div class="pull-left"><i class="fa" ng-class="icon"></i> {{title}} </div><div class="pull-right" ng-transclude></div></div></div>'
  restrict: 'E'
)
