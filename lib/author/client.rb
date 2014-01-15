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

    def login(email, password)
      post url('/auth/sessions'), user: { email: email, password: password }
    end

    def verify(session)
      get url("/auth/users/#{session}")
    end

    def logout(session)
      delete url("/auth/sessions/#{session}")
    end

  private
    def post(resource, body)
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