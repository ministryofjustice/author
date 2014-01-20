begin
  require 'httparty'
rescue Exception => e
  puts e.to_s
end

module Author
  class Client
    def initialize(uri)
      uri = URI.parse(uri)
      @scheme = uri.scheme
      @host = uri.host
      @port = uri.port.to_i
    end

    def to_s
      url
    end

    def register(email, password)
      post url('/auth/users'), user: { email: email, password: password }
    end

    def confirm_registration(confirmation_token)
      post url("/auth/users/confirmation/#{confirmation_token}")
    end

    def login(email, password)
      post url('/auth/sessions'), user: { email: email, password: password }
    end

    def verify(authentication_token)
      get url("/auth/users/#{authentication_token}")
    end

    def logout(session)
      delete url("/auth/sessions/#{session}")
    end

  private
    def post(resource, body={})
      HTTParty.post(resource, body: body)
    end

    def get(resource)
      HTTParty.get(resource)
    end

    def delete(resource)
      HTTParty.delete(resource)
    end

    def url(path='')
      URI::HTTP.build(scheme: @scheme, host: @host, port: @port, path: path).to_s
    end
  end
end