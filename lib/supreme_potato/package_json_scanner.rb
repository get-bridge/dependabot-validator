require_relative 'scanner'

class PackageJSONScanner
  include Scanner

  FILENAME = 'package.json'.freeze
  DEFAULT_ENTRY = {
    'package-ecosystem' => 'npm',
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
