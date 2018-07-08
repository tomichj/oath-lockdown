class ApplicationController < ActionController::Base
  include Oath::ControllerHelpers
  protect_from_forgery with: :exception
end
