module Author
  class Proxy
    attr_accessor :session, :user_id

    def initialize(client)
      @client = client
    end

    def register(email, password)
      response = @client.register(email, password)
      if response.code == 201
        extract_session_key response 
      else
        handle_errors response
      end
      response.code == 201
    end

    def login(email, password)
      response = @client.login(email, password)
      if response.code == 201
        extract_session_key response 
      else
        handle_errors response
      end
      response.code == 201
    end

    def verify(session_id)
      response = @client.verify(session_id)
      if response.code == 200
        extract_user_details response
      else
        handle_errors response
      end
      response.code == 200
    end

    def logout(session_id)
      response = @client.logout(session_id)
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
      if (response.headers.to_s != '' && response.headers.has_key?('x-user-id'))
        @user_id = response.headers['x-user-id']
      else
        raise ServerError, 'Missing x-user-id header in auth server response'
      end
    end

    def extract_session_key(response)
      if (response.body.to_s != '' && response.has_key?('authentication_token'))
        @session = response['authentication_token']
      else
        raise ServerError, "Missing Authentication Token in auth server response."
      end
    end

    def handle_errors(response)
      errors = (response.body.to_s != '' && response.has_key?('errors')) ? response['errors'] : {}
          
      case response.code
      when 401
        raise AuthorisationRequiredError
      when 500
        raise ServerError
      when 422
        if errors.has_key? 'email'
          raise InvalidEmailError, errors[:email]
        elsif errors.has_key? 'password'
          raise InvalidPasswordError, errors[:password]
        end
        raise AuthenticationError, 'Unknown error!'
      else
        raise AuthenticationError, 'Unknown error!'
      end
    end
  end
end