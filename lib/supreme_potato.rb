require_relative 'supreme_potato/gemfile_scanner'

class DependabotValidator
  attr_reader :directory, :dependabot

  SCANNERS = [
    GemfileScanner,
    PackageJSONScanner
  ]

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

  class ResultCollection
    def initialize(scanner:, results:)
      @scanner = scanner
      @results = results
    end

    def valid?
      @results.all?(&:valid?)
    end

    def inspect
      "#<DependabotValidator::ResultCollection:#{object_id} @scanner=#{@scanner}, @results=[\n\t#{@results.join("\n\t")}\n]>"
    end

    def print_missing_configs
      @results.filter do |result|
        !result.valid?
      end.map(&:print_config)
    end
  end

  class Result
    def initialize(directory:, match:)
      @directory = directory
      @match = match
    end

    def valid?
      @match
    end

    def to_s
      inspect
    end

    def print_config
      <<~TEMPLATE
        - package-ecosystem: bundler
          directory: #{@directory}
          schedule:
            interval: daily
          open-pull-request-limit: 5
      TEMPLATE
    end
  end

  class ConfigMatcher
    attr_reader :generated_config, :existing_config

    def initialize(generated_config:, existing_config:)
      @generated_config = generated_config
      @existing_config = existing_config
      @results = []
    end

    def generate!
      generated_config.map do |generated|
        directory = generated.fetch('directory')
        match = existing_config.any? do |existing|
          ap existing if DEBUG
          generated.fetch('directory') == existing.fetch('directory')
        end

        Result.new(directory: directory, match: match)
      end
    end
  end
end
