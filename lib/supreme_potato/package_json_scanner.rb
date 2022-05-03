require_relative 'scanner'

class PackageJSONScanner
  include Scanner

  FILENAME = 'package.json'.freeze
  DEFAULT_ENTRY = {
    'package-ecosystem' => 'npm',
    'schedule' => {
      'interval' => 'weekly'
    },
    'open-pull-requests-limit' => 5
  }.freeze

  def initialize
    @package_ecosystem = 'npm'
    @filename = FILENAME
    @default_entry = DEFAULT_ENTRY
  end
end
