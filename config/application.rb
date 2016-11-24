require_relative 'boot'

require 'rails'
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'action_cable/engine'
require 'sprockets/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module HeapDumpAnalyzer
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    Dir[File.join(Rails.root, 'lib', 'ext', '**', '*.rb')].each {|l| require l }

    config.generators do |g|
      # g.test_framework :rspec, views: false, fixture: true
      # g.fixture_replacement :factory_girl
      g.view_specs false
      g.routing_specs false
      g.request_specs false
      g.helper_specs false
      g.stylesheets false
      g.javascripts false
      g.helper = false
    end
  end
end
