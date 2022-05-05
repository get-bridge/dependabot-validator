require_relative 'config_matcher/result'

class ConfigMatcher
  attr_reader :generated_config, :existing_config

  def initialize(generated_config:, existing_config:)
    @generated_config = generated_config
    @existing_config = existing_config
  end

  def generate!
    generated_config.map do |generated|
      directory = generated.fetch('directory')
      match = existing_config.any? do |existing|
        ap existing if DEBUG
        if directory == existing.fetch('directory')
          ap [directory, existing.fetch('directory'), generated.fetch('package-ecosystem')]
          true
        else
          false
        end
      end

      Result.new(directory: directory, match: match, package_ecosystem: generated.fetch('package-ecosystem'))
    end
  end
end
