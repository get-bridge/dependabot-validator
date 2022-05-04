require_relative 'scanner'

class GemfileScanner
  include Scanner

  FILENAME = 'Gemfile'.freeze
  DEFAULT_ENTRY = {
    'package-ecosystem' => 'bundler',
    'schedule' => {
      'interval' => 'daily'
    },
    'open-pull-requests-limit' => 5
  }.freeze

  def initialize
    @package_ecosystem = DEFAULT_ENTRY.fetch('package-ecosystem')
    @filename = FILENAME
    @default_entry = DEFAULT_ENTRY
  end
end
