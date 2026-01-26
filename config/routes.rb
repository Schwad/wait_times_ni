Rails.application.routes.draw do
  # New dashboard
  root to: "dashboard#index"
  
  get "dashboard", to: "dashboard#index", as: :dashboard
  get "trends", to: "dashboard#trends", as: :trends
  get "compare", to: "dashboard#compare", as: :compare
  get "heatmap", to: "dashboard#heatmap", as: :heatmap
  get "live", to: "dashboard#live", as: :live
  get "api/data", to: "dashboard#api_data", as: :api_data
  
  # Legacy route (keep old static pages working)
  get "legacy", to: "static_pages#index", as: :legacy

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
