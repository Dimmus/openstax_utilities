ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym 'OpenStax'
end

require "openstax/utilities/action_list"

module OpenStax
  module Utilities
    class Engine < ::Rails::Engine
      isolate_namespace OpenStax::Utilities

      config.generators do |g|
        g.test_framework :rspec, :fixture => false
        g.assets false
        g.helper false
      end
    end
  end
end