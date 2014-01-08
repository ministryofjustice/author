module Authentication
  class InvalidEmailError < StandardError; end
  class BlankPasswordError < StandardError; end
  class LoginFailed < StandardError; end
  class AuthorisationRequired < StandardError; end
  class ServerError < StandardError; end
end