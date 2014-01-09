require_relative '../lib/authentication.rb'

require 'SecureRandom'

describe Authentication::Client do
  before :each do
    @client = Authentication::Client.new('http://localhost:3111')
  end

  def session_token_length
    20
  end

  def new_user
    {email: "#{SecureRandom.uuid}@example.com", password: 'Password1'}
  end

  def register_new_account
    @user = new_user
    @client.register(@user[:email], @user[:password])
  end

  context "register" do
    it 'new user' do
      expect(register_new_account).to be true
      expect(@client.session.length).to be session_token_length
    end

    it 'throws InvalidEmailError' do
      expect { @client.register('', new_user[:password]) }.to raise_error Authentication::InvalidEmailError
    end

    it 'throws InvalidPasswordError' do
      expect { @client.register(new_user[:email], '') }.to raise_error Authentication::InvalidPasswordError
    end
  end

  context "login" do
    before :each do
      register_new_account
    end

    it 'valid credentials' do
      expect(@client.login(@user[:email], @user[:password])).to be true
      expect(@client.session.length).to be session_token_length
    end

    it 'throws AuthorisationRequiredError with blank details' do
      expect { @client.login('', '') }.to raise_error Authentication::AuthorisationRequiredError
    end

    it 'throws AuthorisationRequiredError with incorrect email' do
      expect { @client.login('', @user[:password]) }.to raise_error Authentication::AuthorisationRequiredError
    end

    it 'throws AuthorisationRequiredError with incorrect password' do
      expect { @client.login(@user[:email], '') }.to raise_error Authentication::AuthorisationRequiredError
    end
  end

  context "verify" do
    before :each do
      register_new_account
    end

    it 'valid session token' do
      expect(@client.verify(@client.session)).to be true
      expect(@client.user_id).to eql @user[:email]
    end

    it 'throws AuthorisationRequiredError on invalid session token' do
      expect { @client.verify('invalid_token') }.to raise_error Authentication::AuthorisationRequiredError
    end
  end

  context "logout" do
    before :each do
      register_new_account
    end

    it 'valid session token' do
      session = @client.session
      expect(@client.logout session).to be true
      expect { @client.verify session }.to raise_error Authentication::AuthorisationRequiredError
    end

    it 'throws AuthorisationRequiredError on invalid session token' do
      expect{ @client.logout 'not_a_session' }.to raise_error Authentication::AuthorisationRequiredError
    end
  end
end