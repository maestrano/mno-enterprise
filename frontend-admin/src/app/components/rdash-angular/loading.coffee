#
# Loading Directive
# @see http://tobiasahlin.com/spinkit/
#
@App.directive('rdLoading', ->
  restrict: 'AE'
  template: '<div class="loading"><div class="double-bounce1"></div><div class="double-bounce2"></div></div>'
)
