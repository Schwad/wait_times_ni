class ApplicationController < ActionController::Base
  before_action do
    Rack::MiniProfiler.authorize_request
  end
end
