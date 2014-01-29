## Reference Client Auth Implementation

This gem provides a Service Gateway component to integrate Ruby/Rails projects with the MoJ Authentication service.

### Usage

Add Author to your Gemfile

```
# Authentication Proxy
gem 'author', :github => 'ministryofjustice/author'
```

Initalise a client object in `/config/application.rb`

`config.auth_client = Author::Client.new(ENV['API_HOST'])`

When you need to interact with the Authentication service, use the Author proxy like so:

```
author = Author::Proxy.new(Rails.application.config.auth_client)
if(author.login email, password)
  token = author.session
end
```

### Controller mixin for use with ActiveResource

`include Author::Controller` in application_controller.rb to enable header based authentication for your ActiveResource models.
