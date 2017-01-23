# For backward compatibility with the mnoe backend
# Define null/default values for all the constants so that if the backend hasn't been upgraded
# to define this constants you don't get errors like:
#   Uncaught Error: [$injector:unpr] Unknown provider: INTERCOM_IDProvider <- INTERCOM_ID <- AnalyticsSvc
angular.module('mnoEnterprise.defaultConfiguration', [])
  .constant('REVIEWS_CONFIG', {enabled: false})
