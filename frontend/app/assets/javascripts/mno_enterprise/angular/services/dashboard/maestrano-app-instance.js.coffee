angular.module('maestrano.services.dashboard.app-instance', []).factory('DashboardAppInstance', ['$http','$q', ($http,$q) ->
  service = {}

  service.terminate = (id) ->
    return $http.delete("/mnoe/jpi/v1/app_instances/#{id}")

  service.restart = (id) ->
    return $http.put("/app_instances/#{id}/restart")

  service.updateName = (id,newName) ->
    return $http.put("/app_instances/#{id}",{name:newName})

  return service

])
