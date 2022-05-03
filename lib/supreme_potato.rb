require_relative 'supreme_potato/gemfile_scanner'
require_relative 'supreme_potato/github_actions_scanner'
require_relative 'supreme_potato/package_json_scanner'

require_relative 'supreme_potato/config_matcher'
require_relative 'supreme_potato/results_collection'

class DependabotValidator
  attr_reader :directory, :dependabot

  SCANNERS = [
    GemfileScanner,
    GithubActionsScanner,
    PackageJSONScanner
  ].freeze

  def self.valid?(results)
    results.all?(&:valid?)
  end

  def initialize(directory:, dependabot:)
    @directory = directory
    @dependabot = dependabot
  end

  def scan
    SCANNERS.map do |scanner_class|
      scanner = scanner_class.new
      generated_config = scanner.generate(directory: directory)
      ap generated_config if DEBUG
      existing_config = scanner.parse(dependabot: dependabot)
      ap existing_config if DEBUG

      config_matcher = ConfigMatcher.new(generated_config: generated_config, existing_config: existing_config)
      ResultCollection.new(scanner: scanner, results: config_matcher.generate!)
    end
  end
end
