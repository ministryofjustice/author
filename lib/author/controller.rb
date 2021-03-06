begin
  require 'rack_moj_auth'
rescue Exception => e
  puts e.to_s
end

module Author

  ##
  # Mixin to include in ApplicationController of Rails applications which
  # require authentication checks and perform API communication via
  # ActiveResource models.
  #
  # To include in controller:
  #   include Author::Controller
  #
  module Controller

    def self.included controller
      controller.around_action :set_secure_token_for_authenticated_api_calls
    end

    def signed_in?
      read_secure_token.present?
    end

    def read_secure_token
      session[:secret_token]
    end

    def write_secure_token token
      session[:secret_token] = token
    end

    protected

    # Override as needed, return all ActiveResource models used for
    # API communication.
    def api_models
      Rails.application.eager_load! unless Rails.configuration.cache_classes
      ActiveResource::Base.descendants
    end

    def set_secure_token_for_authenticated_api_calls model_classes=api_models
      token_header = 'HTTP_SECURE_TOKEN'.sub('HTTP_','')

      begin
        if token = read_secure_token
          model_classes.each do |model_class|
            model_class.headers = model_class.headers.merge(token_header => token)
          end
        end
        yield
      ensure
        # ensure token always removed from headers
        model_classes.each do |model_class|
          if model_class.headers[token_header]
            model_class.headers = model_class.headers.except(token_header)
          end
        end
      end
    end

  end
end

module ActiveResource; end

class ActiveResource::Base
  class << self
    attr_writer :headers
  end
end
