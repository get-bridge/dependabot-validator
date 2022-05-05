require_relative 'dependabot_validator/build_gradle_scanner'
require_relative 'dependabot_validator/gemfile_scanner'
require_relative 'dependabot_validator/github_actions_scanner'
require_relative 'dependabot_validator/package_json_scanner'

require_relative 'dependabot_validator/config_matcher'
require_relative 'dependabot_validator/results_collection'

class DependabotValidator
  attr_reader :directory, :dependabot

  SCANNERS = [
    BuildGradleScanner,
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

      results = ConfigMatcher.new(generated_config: generated_config, existing_config: existing_config).generate!
      ResultCollection.new(scanner: scanner, results: results)
    end
  end
end
