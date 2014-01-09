module Authentication
  class AuthenticationError < StandardError; end

  class InvalidEmailError     < AuthenticationError; end
  class InvalidPasswordError  < AuthenticationError; end
  class LoginFailed           < AuthenticationError; end
  class AuthorisationRequired < AuthenticationError; end
  class ServerError           < AuthenticationError; end
end