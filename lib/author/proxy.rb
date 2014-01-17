module Author
  class UnexpectedAuthServerResponse < StandardError; end

  class Proxy
    attr_accessor :session, :user_id, :errors, :confirmation_token

    def initialize(client)
      @client = client
      @errors = {}
    end

    def register(email, password)
      response = @client.register(email, password)
      if response.code == 201
        extract_confirmation_token response
      else
        handle_errors response
      end
      response.code == 201
    end

    def confirm_registration confirmation_token
      @client.confirm_registration confirmation_token
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
        raise UnexpectedAuthServerResponse, 'Missing User ID.'
      end
    end

    def extract_confirmation_token(response)
      if (response.body.to_s != '' && response.has_key?('confirmation_token'))
        @confirmation_token = response['confirmation_token']
      else
        raise UnexpectedAuthServerResponse, "Missing Confirmation Token."
      end
    end

    def extract_session_key(response)
      if (response.body.to_s != '' && response.has_key?('authentication_token'))
        @session = response['authentication_token']
      else
        raise UnexpectedAuthServerResponse, "Missing Session Token."
      end
    end

    def handle_errors(response)
      if response.body.to_s != ''
        if response.has_key?('errors')
          @errors = response['errors']
        elsif response.has_key?('error')
          @errors['messages'] ||= []
          @errors['messages'] << response['error']
        end
      end
    end
  end
end