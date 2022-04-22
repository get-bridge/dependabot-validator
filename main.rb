#!/usr/bin/env ruby

require 'yaml'
require 'awesome_print'

DEBUG = false
DEBUG_ARGS = DEBUG || true

puts "\nargs: [#{ARGV.join(', ')}]\n\n" if DEBUG_ARGS

PROJECT_PATH = ARGV.shift
DEPENDABOT_CONFIG_PATH = ARGV.shift

if ARGV.any? # any args left is an error
  ARGV.each do |arg|
    warn "Extra arg: #{arg}"
  end
  raise "Extra args detected! Exiting..."
end

class DependabotValidator
  attr_reader :directory, :dependabot

  def self.scanners
    [
      GemfileScanner
    ]
  end

  def self.valid?(results)
    results.all?(&:valid?)
  end

  def initialize(directory:, dependabot:)
    @directory = directory
    @dependabot = dependabot
  end

  def scan
    self.class.scanners.map do |scanner|
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

class GemfileScanner
  FILENAME = 'Gemfile'.freeze
  DEFAULT_ENTRY = {
    'package-ecosystem' => 'bundler',
    'schedule' => {
      'interval' => 'weekly'
    },
    'open-pull-requests-limit' => 5
  }.freeze

  def self.generate(directory: '.')
    sourcefiles = Dir.glob(File.join(directory, '**', FILENAME)).map do |path|
      GemfileSource.new(path: path)
    end
    # TODO: figure out how to do yaml without anchors/aliases
    directories(sourcefiles: sourcefiles).map do |d|
      { 'directory' => d }.merge(DEFAULT_ENTRY)
    end
  end

  def self.directories(sourcefiles:)
    sourcefiles.map do |sourcefile|
      File.dirname(sourcefile.path)
    end
  end

  def self.parse(dependabot: '.github/dependabot.yml')
    File.open(dependabot) do |file|
      dependabot_config = YAML.safe_load(file.read)
      dependabot_config.fetch('updates').select do |entry|
        entry.fetch('package-ecosystem') == 'bundler'
      end
    end
  end

  class GemfileSource
    attr_reader :path

    def initialize(path:)
      @path = path
    end
  end
end

validator = DependabotValidator.new(directory: PROJECT_PATH, dependabot: DEPENDABOT_CONFIG_PATH)
results = validator.scan

ap results if DEBUG
if results.all?(&:valid?)
  puts "DependabotValidator.valid? => true"
else
  warn "Add the following yaml to your .github/dependabot.yml configuration file:"
  results.each do |scanner|
    warn scanner.print_missing_configs
  end
  raise "Dependabot configuration needs updating"
end
