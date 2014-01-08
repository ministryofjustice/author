require_relative '../client.rb'

Email = "#{Time.now.to_i}@example.com"

describe Authentication::Client do
  before :each do
    @user = {email: Email, password: 'Password1'}
    @client = Authentication::Client.new('http://localhost:3111')
  end

  it 'can register a new user' do
    success = @client.register(@user[:email], @user[:password])
    expect(success).to be true
  end

  it 'can login as that user' do
    success = @client.login(@user[:email], @user[:password])
    expect(success).to be true
    expect(@client.session.length).to be 'E6UNi3NmLdGGzsp2JaGQ'.length
  end

  it 'can verify session token' do
    @client.login(@user[:email], @user[:password])
    success = @client.verify(@client.session)
    expect(success).to be true
    expect(@client.user_id).to eql @user[:email]
  end

  it 'can logout' do
    @client.login(@user[:email], @user[:password])
    session = @client.session
    success = @client.logout session
    expect(success).to be true
    expect(@client.verify session).to be false
  end
end