require_relative '../lib/ruby_authentication_client.rb'

require 'SecureRandom'

client = Authentication::Client.new('localhost', '3111')

# TODO: mock service calls
begin
  client.verify('xxx')
rescue
  puts "FAIL: expected to find authentication service on #{client}"
  exit(1)
end

describe Authentication::Proxy do
  before :each do
    @auth = Authentication::Proxy.new(client)
  end

  def session_token_length
    20
  end

  def new_user
    {email: "#{SecureRandom.uuid}@example.com", password: 'Password1'}
  end

  def register_new_account
    @user = new_user
    @auth.register(@user[:email], @user[:password])
  end

  context "register" do
    it 'new user' do
      expect(register_new_account).to be true
      expect(@auth.session.length).to be session_token_length
    end

    it 'throws InvalidEmailError' do
      expect { @auth.register('', new_user[:password]) }.to raise_error Authentication::InvalidEmailError
    end

    it 'throws InvalidPasswordError' do
      expect { @auth.register(new_user[:email], '') }.to raise_error Authentication::InvalidPasswordError
    end
  end

  context "login" do
    before :each do
      register_new_account
    end

    it 'valid credentials' do
      expect(@auth.login(@user[:email], @user[:password])).to be true
      expect(@auth.session.length).to be session_token_length
    end

    it 'throws AuthorisationRequiredError with blank details' do
      expect { @auth.login('', '') }.to raise_error Authentication::AuthorisationRequiredError
    end

    it 'throws AuthorisationRequiredError with incorrect email' do
      expect { @auth.login('', @user[:password]) }.to raise_error Authentication::AuthorisationRequiredError
    end

    it 'throws AuthorisationRequiredError with incorrect password' do
      expect { @auth.login(@user[:email], '') }.to raise_error Authentication::AuthorisationRequiredError
    end
  end

  context "verify" do
    before :each do
      register_new_account
    end

    it 'valid session token' do
      expect(@auth.verify(@auth.session)).to be true
      expect(@auth.user_id).to eql @user[:email]
    end

    it 'throws AuthorisationRequiredError on invalid session token' do
      expect { @auth.verify('invalid_token') }.to raise_error Authentication::AuthorisationRequiredError
    end
  end

  context "logout" do
    before :each do
      register_new_account
    end

    it 'valid session token' do
      session = @auth.session
      expect(@auth.logout session).to be true
      expect { @auth.verify session }.to raise_error Authentication::AuthorisationRequiredError
    end

    it 'throws AuthorisationRequiredError on invalid session token' do
      expect{ @auth.logout 'not_a_session' }.to raise_error Authentication::AuthorisationRequiredError
    end
  end
end