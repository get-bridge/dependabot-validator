#!/usr/bin/env ruby

require 'yaml'
require 'awesome_print'

DEBUG = false

puts "args: [#{ARGV.join(', ')}]" if DEBUG
puts "args: [#{ARGV.join(', ')}]"

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
    results.all? do |scanner|
      scanner.all? do |_, group|
        group.all? do |_, res|
          res
        end
      end
    end
  end

  def initialize(directory:, dependabot:)
    @directory = directory
    @dependabot = dependabot
  end

  def scan
    DependabotValidator.scanners.map do |scanner|
      reference_config = scanner.generate(directory: directory)
      ap reference_config if DEBUG
      existing_config = scanner.parse(dependabot: dependabot)
      ap existing_config if DEBUG

      results = reference_config.map do |reference|
        [reference.fetch('directory'), existing_config.any? do |existing|
          ap existing if DEBUG
          reference.fetch('directory') == existing.fetch('directory')
        end]
      end

      { scanner.to_s => results }
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

    def print_config(directory:)
      <<~TEMPLATE
        - package-ecosystem: bundler
          directory: #{directory}
          schedule:
            interval: daily
          open-pull-request-limit: 5
      TEMPLATE
    end
  end
end

validator = DependabotValidator.new(directory: PROJECT_PATH, dependabot: DEPENDABOT_CONFIG_PATH)
results = validator.scan

ap results
if DependabotValidator.valid?(results)
  puts "DependabotValidator.valid? => true"
else
  results.map do |scanner|
    scanner.map do |_, group|
      group.map do |path, _|
        ap path
      end
    end
  end
  raise "Dependabot configuration needs updating"
end
