require "api_sim/version"
require 'api_sim/app_builder'

module ApiSim
  def self.build_app(&block)
    configuration = AppBuilder.new
    configuration.instance_eval &block
    configuration.rackapp
  end
end