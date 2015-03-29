module = angular.module('maestrano.components.file-model',[])

# Allows angular binding on <input type="file">
# Usage: <input type="file" file-model="someScopeObject.file">
module.directive("fileModel", [
  '$parse', '$compile',
  ($parse, $compile) ->
    return {
      restrict: 'A',
      link: (scope, element, attrs) ->
        model = $parse(attrs.fileModel)
        modelSetter = model.assign

        element.bind('change', ->
            scope.$apply( ->
                modelSetter(scope, element[0].files[0])
            )
        )
        
        # The filelist on an <input type="file"> is read only
        # which means we cannot clear the list of files attached to it
        # --
        # The watcher below detects when the file-model is set to null,
        # undefined or '' and automatically replaces the input element
        # by a new one (no filelist attached)
        scope.$watch(model
        , (value, oldValue)-> 
          if !angular.equals(value,oldValue) && (!value? || value = '')
            clone = $compile(element.clone())(scope)
            element.replaceWith(clone)
        )
    }
])
