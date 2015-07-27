module = angular.module('maestrano.components.mno-helptext',[])

module.directive("mnoHelptext", ['$window', ($window) ->
  return {
    restrict: 'A'
    link: (scope, elem, attrs, ctrl) ->
      delay = attrs.helptextDelay
      scope.$watch(
        () ->
          attrs.mnoHelptext
        ,() ->
          $(elem).tooltip({
            title: attrs.mnoHelptext,
            html: true,
            delay: {
              show: (delay || 1000)
              hide: 100
            },
            animation: false,
            placement: () ->
              if attrs.helptextPlacement
                return attrs.helptextPlacement
              else
                # Calculate remaining space on bottom, right, left
                remainingBottom = $($window).height() + $($window).scrollTop() - $(elem).offset().top - $(elem).height()
                remainingLeft = $(elem).offset().left - $($window).scrollLeft()
                remainingRight = $($window).width() - remainingLeft - $(elem).width()

                # Adjust positioning based on remaining space
                # Note that according to the rules below bottom is clearly preferred
                position = (if remainingBottom < 200 then 'top' else 'bottom')
                position = 'right' if remainingLeft < 50
                position = 'left' if remainingRight < 50
                return position
          })
      )
  }
])