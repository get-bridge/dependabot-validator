#!/usr/bin/env ruby

require 'yaml'

class Scanner
  def initialize(file:, package_ecosystem:)
    @file = file
    @package_ecosystem = package_ecosystem.to_s
  end

  def valid?
    dependabot_config = YAML.safe_load(@file.read)
    config = dependabot_config.fetch("updates").find do |entry|
      entry.fetch("package-ecosystem") == @package_ecosystem
    end
    !config.nil?
  end
end

File.open("spec/fixtures/dependabot.yml") do |file|
  scanner = Scanner.new(file: file, package_ecosystem: :bundler)
  puts scanner.valid?
end
