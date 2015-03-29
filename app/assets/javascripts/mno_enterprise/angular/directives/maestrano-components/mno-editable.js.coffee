module = angular.module('maestrano.components.mno-editable',['maestrano.assets'])

#============================================
# Component
#============================================
module.controller('MnoEditableCtrl',[
  '$scope','$http','$element',
  ($scope, $http, $element) ->

    $scope.model = { orig:$scope.initialValue, value:$scope.initialValue }

    # Perform an ajax request to update the content element
    $scope.updateField = () ->
      route = "/mnoe/jpi/v1/admin/content/#{$scope.contentableId}"
      data = {
        contentable_type: $scope.contentableType
        field_name: $scope.fieldName
        value: $scope.model.value
      }
      $http.put(route,data).then(
        (success) ->
          $scope.model.orig = $scope.model.value
        ,(error) ->
          $scope.model.value = $scope.model.orig
      )
      return true

    $scope.uploadImage = () ->
      opts = { transformRequest: angular.identity, headers: {'Content-Type': undefined} }
      route = "/mnoe/jpi/v1/admin/content/#{$scope.contentableId}/upload_image"
      data = new FormData()
      data.append('image',$scope.model.image)
      data.append('contentable_type',$scope.contentableType)
      data.append('field_name',$scope.fieldName)
      $http.put(route,data,opts).then(
        (success) ->
          $scope.model.orig = success.data
      )

])

module.directive('mnoEditable', ['TemplatePath', (TemplatePath) ->
  return {
      restrict: 'A',
      scope: {
        contentableType:'@'
        contentableId:'@'
        fieldName:'@'
        contentType:'@'
        initialValue:'@'
        customStyle:'@'
      },
      controller: 'MnoEditableCtrl'
      templateUrl: TemplatePath['maestrano-components/editable.html'],
      link: (scope, element, attrs) ->
        scope.showForm = false
        element.on("mouseenter", ->
          scope.showForm = true
          scope.$apply()
        )

        element.on("mouseleave", ->
          scope.showForm = false
          scope.$apply()
        )

    }
])
