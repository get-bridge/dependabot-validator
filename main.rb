#!/usr/bin/env ruby

require 'yaml'
require 'awesome_print'

# class Scanner
#   def initialize(file:, package_ecosystem:)
#     @file = file
#     @package_ecosystem = package_ecosystem.to_s
#   end
#
#   def valid?
#     dependabot_config = YAML.safe_load(@file.read)
#     config = dependabot_config.fetch('updates').find do |entry|
#       entry.fetch('package-ecosystem') == @package_ecosystem
#     end
#     !config.nil?
#   end
# end
#
# File.open('spec/fixtures/dependabot.yml') do |file|
#   scanner = Scanner.new(file: file, package_ecosystem: :bundler)
#   puts scanner.valid?
# end

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

  # def self.run(directory: '.', dependabot:)
  #   files = Dir.glob(File.join(directory, '**', FILENAME))
  #   paths = files.map { |file| File.dirname(file) }
  #   dependabot_config = YAML.safe_load(dependabot.read)
  #   bundler_entries = dependabot_config.fetch('updates').select do |entry|
  #     entry.fetch('package-ecosystem') == 'bundler'
  #   end
  #   res = bundler_entries.map do |be|
  #     be.fetch('directory')
  #   end
  #   puts res
  # end

  def self.generate(directory: '.')
    files = Dir.glob(File.join(directory, '**', FILENAME))
    paths = files.map { |file| File.dirname(file) }
    # TODO: figure out how to do yaml without anchors/aliases
    paths.map do |path|
      { 'directory' => path }.merge(DEFAULT_ENTRY)
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
  reference_config = scanner.generate(directory: 'spec/fixtures/test_app')
  existing_config = scanner.parse(dependabot: 'spec/fixtures/dependabot.yml')

  Hash[scanner.to_s, reference_config.map do |reference|
    [reference.fetch('directory'), existing_config.any? do |existing|
      reference.fetch('directory') == existing.fetch('directory')
    end]
  end]
end

if DependabotValidator.valid?(results)
  ap results
  puts "DependabotValidator.valid? => true"
else
  ap results
  raise "Dependabot configuration needs updating"
end
