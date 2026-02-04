Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.send_default_pii = true
  
  # Sample rates - adjust if too expensive
  config.traces_sample_rate = 0.5
  config.profiles_sample_rate = 0.5
  
  # Only in production
  config.enabled_environments = %w[production]
end if ENV['SENTRY_DSN'].present?
