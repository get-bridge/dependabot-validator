#!/usr/bin/env ruby

require 'yaml'
require 'awesome_print'

require_relative 'lib/supreme_potato'

DEBUG = false
DEBUG_ARGS = true

warn "\nargs: [#{ARGV.join(', ')}]\n\n" if DEBUG_ARGS

PROJECT_PATH = ARGV.shift
DEPENDABOT_CONFIG_PATH = ARGV.shift

if ARGV.any? # any args left is an error
  ARGV.each do |arg|
    warn "Extra arg: #{arg}"
  end
  raise "Extra args detected! Exiting..."
end

validator = DependabotValidator.new(directory: PROJECT_PATH, dependabot: DEPENDABOT_CONFIG_PATH)
results = validator.scan

ap results if DEBUG
unless results.all?(&:valid?)
  warn "Add the following yaml to your .github/dependabot.yml configuration file:"
  results.each do |scanner|
    warn scanner.print_missing_configs
  end
  raise "Dependabot configuration needs updating"
end
