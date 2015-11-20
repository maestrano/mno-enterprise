module = angular.module('maestrano.components.mno-password',['maestrano.assets'])

module.directive('mnoPassword', ['TemplatePath', (TemplatePath) ->
  return {
      restrict: 'AE',
      scope: {
        baseObject: '=mnoPassword',
        form: '='
      },
      templateUrl: TemplatePath['mno_enterprise/maestrano-components/password.html'],
      link: (scope, element, attrs) ->
        scope.isShown = false
        scope.hasEightChars = false
        scope.hasOneNumber = false
        scope.hasOneUpper = false
        scope.hasOneLower = false

        scope.fieldName = "#{attrs.mnoPassword}[password]"

        scope.check = ->
          scope.hasEightChars = scope.baseObject.password? && (scope.baseObject.password.length >= 8)
          scope.hasOneNumber = false
          scope.hasOneUpper = false
          scope.hasOneLower = false

          if angular.isString(scope.baseObject.password)
            angular.forEach(scope.baseObject.password.split(""), (letter) ->
              scope.hasOneNumber = true if parseInt(letter)
              scope.hasOneUpper = true if (letter == letter.toUpperCase() && letter != letter.toLowerCase() && !parseInt(letter))
              scope.hasOneLower = true if (letter == letter.toLowerCase() && letter != letter.toUpperCase() && !parseInt(letter))
            )

            # Will raise an error is form is not defined when the directive is used (in this case, we can't modify the validity of the form)
            if scope.hasEightChars && scope.hasOneNumber && scope.hasOneUpper && scope.hasOneLower
              scope.form[scope.fieldName].$setValidity("password", true)
            else
              scope.form[scope.fieldName].$setValidity("password", false)

    }
])
