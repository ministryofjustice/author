module Author
  module Controller

    before_filter :set_signed_in
    around_action :set_secure_token

    def set_signed_in
      @signed_in = read_secure_token.present?
    end

    def read_secure_token
      session[:secret_token]
    end

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

  end
end