module = angular.module('maestrano.components.mno-match',[])

module.directive("mnoMatch", ['$parse', ($parse) ->
  return {
    require: "ngModel",
    link: (scope, elem, attrs, ctrl) ->
      scope.$watch(
        () ->
          return $parse(attrs.mnoMatch)(scope) == ctrl.$modelValue
        , (currentValue) ->
          ctrl.$setValidity('mismatch', currentValue)
      )
  }
])