require 'httparty'

module Authentication
  class Client
    attr_accessor :errors, :session, :user_id

    def initialize(base_url)
      @base_url = base_url.gsub(/\/$/, '')
    end

    def register(email, password)
      response = HTTParty.post("#{@base_url}/auth/users", body: { user: { email: email, password: password } })
      if response.code == 201
        @errors = {}
      else
        @errors = parse_errors response
      end
      @errors == {}
    end

    def login(email, password)
      response = HTTParty.post("#{@base_url}/auth/sessions", body: { user: { email: email, password: password } })
      if response.code == 201
        @errors = {}
        @session = response['authentication_token']
      else
        @errors = parse_errors response
      end
      @errors == {}
    end

    def verify(session_id)
      response = HTTParty.get("#{@base_url}/auth/users/#{session_id}")
      if response.code == 200
        @user_id = response.headers['x-user-id']
      end
      response.code == 200
    end

    def logout(session_id)
      response = HTTParty.delete("#{@base_url}/auth/sessions/#{session_id}")
      if response.code == 204
        remove_instance_variable :@user_id if defined? @user_id
        remove_instance_variable :@session if defined? @session
      end
      response.code == 204
    end

  private
    def parse_errors(response)
      errors = JSON.parse response.body
    end
  end
end