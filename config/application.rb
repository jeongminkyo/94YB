require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module YB94
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.time_zone = 'Seoul'
    config.active_record.default_timezone = :local
    config.active_record.time_zone_aware_attributes = false

    config.eager_load_paths += Dir["#{config.root}/lib/**/"]

    config.middleware.insert_before 0, "Rack::Cors" do
      allow do
        origins '*'
        resource '/api/v1/*', :headers => :any, :methods => [:get, :post, :options]
      end
    end
  end
end
