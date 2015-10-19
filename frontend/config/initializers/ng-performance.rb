if Rails.env.development?
  Rails.application.config.assets.precompile  += %w( ng-performance/ngPerformance.js )
end
