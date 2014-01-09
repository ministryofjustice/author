require_relative '../lib/authentication.rb'

require 'SecureRandom'

describe Authentication::Client do
  before :each do
    @client = Authentication::Client.new('http://localhost:3111')
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
      success = register_new_account
      expect(success).to be true
      expect(@client.session.length).to be 20
    end

    it 'throws InvalidEmailError' do
      expect { @client.register('asd', new_user[:password]) }.to raise_error Authentication::InvalidEmailError
    end

    it 'throws InvalidPasswordError' do
      expect { @client.register(new_user[:email], '') }.to raise_error Authentication::InvalidPasswordError
    end
  end

  context "login" do
    before :each do
      register_new_account
    end

    it 'can login as that user' do
      success = @client.login(@user[:email], @user[:password])
      expect(success).to be true
      expect(@client.session.length).to be 'E6UNi3NmLdGGzsp2JaGQ'.length
    end
  end

  context "verify" do
    before :each do
      register_new_account
    end

    it 'can verify session token' do
      @client.login(@user[:email], @user[:password])
      success = @client.verify(@client.session)
      expect(success).to be true
      expect(@client.user_id).to eql @user[:email]
    end
  end

  context "logout" do
    before :each do
      register_new_account
    end


    it 'can logout' do
      @client.login(@user[:email], @user[:password])
      session = @client.session
      success = @client.logout session
      expect(success).to be true
      expect { @client.verify session }.to raise_error Authentication::AuthorisationRequired
    end
  end
end