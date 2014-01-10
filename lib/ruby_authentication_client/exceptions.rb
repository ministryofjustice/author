module Authentication
  class AuthenticationError < StandardError; end

  class InvalidEmailError           < AuthenticationError; end
  class InvalidPasswordError        < AuthenticationError; end
  class LoginFailedError            < AuthenticationError; end
  class AuthorisationRequiredError  < AuthenticationError; end
  class ServerError                 < AuthenticationError; end
end