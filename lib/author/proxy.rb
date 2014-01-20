module Author
  class UnexpectedAuthServerResponse < StandardError; end

  class Proxy
    attr_accessor :session, :user_id, :errors, :confirmation_token

    def initialize(client)
      @client = client
      @errors = {}
    end

    def register(email, password)
      @response = @client.register(email, password)
      extract_confirmation_token
      @response.code == 201 && @errors.empty?
    end

    def confirm_registration confirmation_token
      @response = @client.confirm_registration(confirmation_token)
      @response.code == 200
    end

    def register_and_login_without_confirmation_step(email, password)
      register(email, password)
      confirm_registration(@confirmation_token)
      login(email, password)
    end

    def login(email, password)
      @response = @client.login(email, password)
      extract_session_key
      @response.code == 201 && @errors.empty?
    end

    def verify(session_id)
      @response = @client.verify(session_id)
      extract_user_details
      @response.code == 200 && @errors.empty?
    end

    def logout(session_id)
      @response = @client.logout(session_id)
      delete_instance_vars
      @response.code == 204 && @errors.empty?
    end

  private
    def delete_instance_vars
      remove_instance_variable :@user_id if defined? @user_id
      remove_instance_variable :@session if defined? @session
    end

    def extract_user_details
      @user_id = try(@response.headers, :[], 'x-user-id')
      handle_errors if @user_id.nil?
    end

    def extract_session_key
      @session = try(@response, :[], 'authentication_token')
      handle_errors if @session.nil?
    end

    def extract_confirmation_token
      @confirmation_token = try(@response, :[], 'confirmation_token')
      handle_errors if @confirmation_token.nil?
    end

    def handle_errors
      @errors = try(@response, :[], 'errors') || {}
      if @errors == {}
        @errors['messages'] = (try(@response, :[], 'error') || ['Unexpected response from server.'])
      end
    end

    # similer to http://api.rubyonrails.org/classes/Object.html#method-i-try
    def try(object, *method, &args)
      if !object.nil? && object.respond_to?(method.first)
        object.public_send(*method, &args) 
      end
    end
  end
end