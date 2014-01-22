module Author

  ##
  # Mixin to include in ApplicationController of Rails applications which
  # require authentication checks and perform API communication via
  # ActiveResource models.
  #
  # To include:
  #   include Author::Controller
  #
  module Controller

    def self.included controller
      controller.around_action :set_secure_token
    end

    def signed_in?
      read_secure_token.present?
    end

    def read_secure_token
      session[:secret_token]
    end

    protected

    def with_secure_token model_class
      token_header = RackMojAuth::Resources::SECURE_TOKEN.sub('HTTP_','')

      begin
        if token = read_secure_token
          model_class.headers = model_class.headers.merge(token_header => token)
        end
        yield
      ensure
        # ensure token always removed from headers
        if model_class.headers[token_header]
          model_class.headers = model_class.headers.except(token_header)
        end
      end
    end

    # Override as needed, return all ActiveResource models used for
    # API communication.
    def api_models
      []
    end

    def set_secure_token
      eval(
        (
          api_models.map {|m| "with_secure_token(#{m}) do" } +
          ["yield"] +
          api_models.map {|m| "end" }
        ).join("\n")
      )
    end

  end
end