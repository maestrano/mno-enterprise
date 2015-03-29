angular.module('maestrano.services.dashboard.app-instance', []).factory('DashboardAppInstance', ['$http','$q', ($http,$q) ->
  service = {}

  service.terminate = (id) ->
    return $http.put("/app_instances/#{id}/terminate")

  service.restart = (id) ->
    return $http.put("/app_instances/#{id}/restart")

  service.updateName = (id,newName) ->
    return $http.put("/app_instances/#{id}",{name:newName})

  return service

])
