# Sidekiq::Metriks

[ ![Codeship Status for sidekiq-metriks](https://www.codeship.io/projects/67077520-0995-0131-95d7-0ab7c49cb21d/status)](https://www.codeship.io/projects/217)


## Installation

Add this line to your application's Gemfile:

    gem 'metriks-sidekiq',    github: 'codeship/metriks-sidekiq

And then execute:

    $ bundle

## Usage

	Sidekiq.configure_server do |config|
	  config.server_middleware do |chain|
    	chain.add MetriksSidekiq::Middleware, Metriks, prefix: "testing.sidekiq"
  	  end
	end


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
