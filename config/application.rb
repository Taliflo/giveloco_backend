require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ApiBase
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Disable assets pipeline
    config.assets.enabled = false

    # Disable generation of helpers, javascripts, css, and view specs
    config.generators do |generate|
      generate.helper false
      generate.assets false
      generate.view_specs false
    end

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = 'utf-8'

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    giveloco_email = '"GiveLoco Community" <support@giveloco.com>'

    config.action_mailer.default_options = {
      :from => giveloco_email,
      :reply_to => giveloco_email
    }

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Load Grape API and its subdirectories
    config.paths.add 'app/api', glob: '**/*.rb'
    config.autoload_paths += Dir["#{Rails.root}/app/api/*"]

    config.mailchimp_api_key = secrets.mailchimp_api_key
    config.mailchimp_list_id = secrets.mailchimp_list_id

    # Auto-Load all library files
    config.autoload_paths += Dir["#{Rails.root}/lib"]

    # CORS configuration
    config.middleware.insert_before ActionDispatch::Static, Rack::Cors do
      allow do
        # origins(/http:\/\/localhost:(\d*)/,
        #         /http:\/\/127.0.0.1:(\d*)/,
        #         'http://www.giveloco.com',
        #         'https://www.giveloco.com'
        #         )
        origins '*'
        resource '*',
            :headers => '*, X-Requested-With, X-Prototype-Version, X-CSRF-Token, Content-Type',
            :methods => [:get, :post, :put, :delete, :options]
      end
    end

    config.stripe_client_id = ENV['STRIPE_APP_CLIENT_ID'] || ''
    config.stripe_secret_key = ENV['STRIPE_SECRET_KEY'] || ''

    config.community_email = 'support@giveloco.com'

  end
end
