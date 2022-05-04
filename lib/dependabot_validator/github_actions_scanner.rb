require_relative 'scanner'

class GithubActionsScanner
  include Scanner

  FILENAME = '.github/workflows/*.y?ml'.freeze
  DEFAULT_ENTRY = {
    'package-ecosystem' => 'github-actions',
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
