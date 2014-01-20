require_relative '../lib/author.rb'

require 'SecureRandom'
require 'HTTParty'

client = Author::Client.new('http://localhost:3111')

# TODO: mock service calls
unless  client.verify('xxx')
  puts "FAIL: expected to find authentication service on #{client}"
  exit(1)
end

describe Author::Proxy do
  let(:valid_user) { { email: "#{SecureRandom.uuid}@example.com", password: 'Password1' } }

  context ".register" do
    before :each do
      @auth = Author::Proxy.new(client)
      @result = @auth.register(email, password)
    end

    describe 'with valid credentials' do
      let(:email) { valid_user[:email] }
      let(:password) { valid_user[:password] }

      it 'should return true' do
        expect(@result).to be_true
      end
      context '.session' do
        it { @auth.session.should be_nil }
      end
      context '.confirmation_token' do
        it { @auth.confirmation_token.should_not be_nil }
      end
      context '.errors' do
        it { @auth.errors.should be_empty }
      end
    end

    describe 'with invalid email' do
      let(:email) { 'xxx' }
      let(:password) { valid_user[:password] }

      it 'should return false' do
        expect(@result).to be_false
      end
      context '.session' do
        it { @auth.session.should be_nil }
      end
      context '.confirmation_token' do
        it { @auth.confirmation_token.should be_nil }
      end
      context '.errors["email"]' do
        it { @auth.errors['email'].should_not be_empty }
      end
    end

    describe 'with invalid password' do
      let(:email) { valid_user[:email] }
      let(:password) { 'xxx' }

      it 'should return false' do
        expect(@result).to be_false
      end
      context '.session' do
        it { @auth.session.should be_nil }
      end
      context '.errors["password"]' do
        it { @auth.errors['password'].should_not be_empty }
      end
    end
  end

  context ".login" do
    before :each do
      @auth = Author::Proxy.new(client)
      @auth.register(email, password)
      @auth.confirm_registration(@auth.confirmation_token)
      @result = @auth.login(email, password)
    end

    describe 'with valid credentials' do
      let(:email) { valid_user[:email] }
      let(:password) { valid_user[:password] }

      it 'should return true' do
        expect(@result).to be_true
      end
      context '.session' do
        it { @auth.session.should_not be_nil }
      end
      context '.errors' do
        it { @auth.errors.should be_empty }
      end
    end

    describe 'with blank credentials' do
      let(:email) { '' }
      let(:password) { '' }

      it 'should return false' do
        expect(@result).to be_false
      end
      context '.session' do
        it { @auth.session.should be_nil }
      end
      context '.errors' do
        it { @auth.errors.should_not include %w(email password) }
        context '["messages"]' do
          it { @auth.errors['messages'].should_not be_empty }
        end
      end
    end

    describe 'with blank email' do
      let(:email) { '' }
      let(:password) { 'xxx' }

      it 'should return false' do
        expect(@result).to be_false
      end
      context '.session' do
        it { @auth.session.should be_nil }
      end
      context '.errors' do
        it { @auth.errors.should_not include %w(email password) }
        context '["messages"]' do
          it { @auth.errors['messages'].should_not be_empty }
        end
      end
    end

    describe 'with incorrect email' do
      let(:email) { 'xxx' }
      let(:password) { 'xxx' }

      it 'should return false' do
        expect(@result).to be_false
      end
      context '.session' do
        it { @auth.session.should be_nil }
      end
      context '.errors' do
        it { @auth.errors.should_not include %w(email password) }
        context '["messages"]' do
          it { @auth.errors['messages'].should_not be_empty }
        end
      end
    end

    describe 'with incorrect password' do
      let(:email) { valid_user[:email] }
      let(:password) { 'xxx' }

      it 'should return false' do
        expect(@result).to be_false
      end
      context '.session' do
        it { @auth.session.should be_nil }
      end
      context '.errors' do
        it { @auth.errors.should_not include %w(email password) }
        context '["messages"]' do
          it { @auth.errors['messages'].should_not be_empty }
        end
      end
    end

  end

  context ".verify" do
    before :each do
      @auth = Author::Proxy.new(client)
      @auth.register(email, password)
      @auth.confirm_registration(@auth.confirmation_token)
      @auth.login(email, password)
      @result = @auth.verify(session_token)
    end

    let(:email) { valid_user[:email] }
    let(:password) { valid_user[:password] }

    context 'with valid session token' do
      let(:session_token) { @auth.session }

      it 'should return true' do
        expect(@result).to be_true
      end
      context '.user_id' do
        it 'returns currently logged in user\'s id' do
          expect(@auth.user_id).to eql email
        end
      end
    end

    context 'with incorrect session token' do
      let(:session_token) { 'xxx' }

      it 'should return false' do
        expect(@result).to be_false
      end
      context '.user_id' do
        it { @auth.user_id.should be_nil }
      end
    end
  end

  context ".logout" do
    before :each do
      @auth = Author::Proxy.new(client)
      email = valid_user[:email]
      password = valid_user[:password]
      @auth.register(email, password)
      @auth.confirm_registration(@auth.confirmation_token)
      @auth.login(email, password)
    end

    context 'with valid session token' do
      let(:session_token) { @auth.session }

      it 'should return true' do
        expect(@auth.logout session_token).to be true
        expect(@auth.verify session_token).to be_false
      end
    end

    context 'with invalid session token' do
      let(:session_token) { 'xxx' }

      it 'should return false' do
        expect(@auth.logout session_token).to be false
      end
    end
  end
end