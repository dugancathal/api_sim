require "http_sim/version"
require 'http_sim/app_builder'

module HttpSim
  def self.build_app(&block)
    configuration = AppBuilder.new
    configuration.instance_eval &block
    configuration.rackapp
  end
end