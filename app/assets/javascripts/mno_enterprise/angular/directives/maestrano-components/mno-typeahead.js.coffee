module = angular.module('maestrano.components.mno-typeahead',[])

# Remote typeahead.
# E.g:
#
# <input type="text" mno-typeahead='tpaResult' remote = '/path/to/typeahead', 'min-length' => '6'>
# <div ng-show="tpaResult.isReady() && tpaResult.isEmpty()" }>
#   No results!
# </div>
#
# 
# In this case the scope variable 'tpaResult' can be used to:
# tpaResult.list: get the list of results
# tpaResult.isEmpty(): check if the list of results is empty
# tpaResult.hasAny(): check if the list has any result
# tpaResult.isReady(): check the input has a value that's greater than the 'min-length'
# tpaResult.isLoading(): check whether the widget is loading
#
module.directive('mnoTypeahead', ['$http', '$window', ($http, $window) ->
  return {
      restrict: 'A'
      scope: {
        mnoTypeahead: '='
        minLength: '@'
        remote: '@'
      }
      link: (scope, element, attrs) ->
        scope.minLength ||= 3
        scope.mnoTypeahead = { list:[] }
        return false unless angular.isString(scope.remote)
        scope.qList = []
        
        scope.mnoTypeahead.isLoading = ->
          scope.loading
        
        scope.mnoTypeahead.hasAny = ->
          scope.mnoTypeahead.list.length > 0
        
        scope.mnoTypeahead.isEmpty = ->
          scope.mnoTypeahead.list.length == 0
        
        scope.mnoTypeahead.isReady = ->
          !scope.loading && scope.currVal? && scope.currVal.length > 0 && scope.currVal.length > scope.minLength
        
        # Fetch data remotely. The typeahead widget is kept 'loading'
        # if there is a need to refetch or if there are still queries
        # being performed (qList)
        scope.fetchData = ->
          scope.needFetch = false
          q = $http.get(scope.remote + "?q=#{scope.currVal}")
          scope.qList.push(q)
          
          q.success (data) ->
            scope.qList.shift()
            unless scope.needFetch || scope.qList.length > 0
              scope.loading = false
              angular.copy(data,scope.mnoTypeahead.list)
            
        # Trigger a fetch if there is a need for it
        # Used by the scheduler at the bottom
        scope.pollData = ->
          if scope.needFetch
            scope.fetchData()
        
        # Flag the widget as 'loading' and set needFetch to
        # true to trigger a fetch at next interval
        scope.triggerFetch = ->
          scope.loading = true
          scope.needFetch = true
        
        # Binding method to be used on keyup/keydown event
        scope.refresh = ->
          scope.minLength ||= 3
          scope.currVal = element.val()
          
          if scope.currVal.length > 0 && scope.currVal.length >= scope.minLength
            scope.triggerFetch()
          else
            scope.mnoTypeahead.list.length = 0
        
        # Bind refresh on keystrokes
        element.keyup(scope.refresh)
        element.keydown(scope.refresh)
          
        # Schedule periodic data polling (rate limit of one query per second)
        $window.setInterval((-> scope.pollData()), 1000)
          
    }
])
