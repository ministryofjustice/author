require 'httparty'

module Authentication
  class Client
    attr_accessor :session, :user_id

    def initialize(base_url)
      @base_url = base_url.gsub(/\/$/, '')
    end

    def register(email, password)
      response = HTTParty.post("#{@base_url}/auth/users", body: { user: { email: email, password: password } })
      if response.code == 201
        extract_session_key response 
      else
        handle_errors response
      end
      response.code == 201
    end

    def login(email, password)
      response = HTTParty.post("#{@base_url}/auth/sessions", body: { user: { email: email, password: password } })
      if response.code == 201
        extract_session_key response 
      else
        handle_errors response
      end
      response.code == 201
    end

    def verify(session_id)
      response = HTTParty.get("#{@base_url}/auth/users/#{session_id}")
      if response.code == 200
        extract_user_details response
      else
        handle_errors response
      end
      response.code == 200
    end

    def logout(session_id)
      response = HTTParty.delete("#{@base_url}/auth/sessions/#{session_id}")
      if response.code == 204
        delete_instance_vars
      else
        handle_errors response
      end
      response.code == 204
    end

  private
    def delete_instance_vars
      remove_instance_variable :@user_id if defined? @user_id
      remove_instance_variable :@session if defined? @session
    end

    def extract_user_details(response)
      if response.headers.has_key? 'x-user-id'
        @user_id = response.headers['x-user-id']
      else
        raise ServerError, 'Missing x-user-id header in auth server response'
      end
    end

    def extract_session_key(response)
      if response.has_key? 'authentication_token'
        @session = response['authentication_token']
      else
        raise ServerError, "Missing Authentication Token in auth server response."
      end
    end

    def handle_errors(response)
      if response.code == 401
        raise AuthorisationRequired
      end
      
      errors = JSON.parse response.body
      if errors.has_key? 'email'
        raise InvalidEmailError, "Email address is invalid."
      elsif errors.has_key? 'password'
        if errors['password'] == "can't be blank"
          raise BlankPasswordError, "Password can't be blank."
        else
          raise StandardError, "Unknown problem with password."
        end
      elsif response.code == 500
        raise ServerError, "Server error."
      end
    end
  end
end