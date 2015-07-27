module = angular.module('maestrano.components.mno-scroll-to',['maestrano.assets'])

module.directive('mnoScrollTo', ['$location', '$anchorScroll', ($location, $anchorScroll) ->
  return {
      restrict: 'A'
      scope:
        mnoScrollTo: '@'
      link: (scope, element, attrs) ->
        element.on "click", (event)  ->
          event.preventDefault()
          $location.hash(scope.mnoScrollTo)
          $anchorScroll()
    }
])
