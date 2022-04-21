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

module DependabotValidator
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
    files = Dir.glob(File.join(directory, '**', FILENAME))
    directories = files.map { |file| File.dirname(file) }
    # TODO: figure out how to do yaml without anchors/aliases
    directories.map do |d|
      { 'directory' => d }.merge(DEFAULT_ENTRY)
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
end

results = DependabotValidator.scanners.map do |scanner|
  reference_config = scanner.generate(directory: PROJECT_PATH)
  ap reference_config if DEBUG
  existing_config = scanner.parse(dependabot: DEPENDABOT_CONFIG_PATH)
  ap existing_config if DEBUG

  results = reference_config.map do |reference|
    [reference.fetch('directory'), existing_config.any? do |existing|
      ap existing if DEBUG
      reference.fetch('directory') == existing.fetch('directory')
    end]
  end

  { scanner.to_s => results }
end

ap results if DEBUG
raise "Dependabot configuration needs updating" unless DependabotValidator.valid?(results)

puts "DependabotValidator.valid? => true"
