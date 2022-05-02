module Scanner
  def generate(directory: '.')
    sourcefiles = Dir.glob(File.join(directory, '**', @filename))
    # TODO: figure out how to do yaml without anchors/aliases
    directories(sourcefiles: sourcefiles).map do |d|
      { 'directory' => d }.merge(@default_entry)
    end
  end

  def parse(dependabot: '.github/dependabot.yml')
    File.open(dependabot) do |file|
      dependabot_config = YAML.safe_load(file.read)
      puts "Running package manager search: #{@package_ecosystem}"
      dependabot_config.fetch('updates').select do |entry|
        entry.fetch('package-ecosystem') == @package_ecosystem
      end
    end
  end

  private

  def directories(sourcefiles:)
    sourcefiles.map do |sourcefile|
      File.dirname(sourcefile)
    end
  end
end

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

class GemfileScanner
  include Scanner

  FILENAME = 'Gemfile'.freeze
  DEFAULT_ENTRY = {
    'package-ecosystem' => 'bundler',
    'schedule' => {
      'interval' => 'weekly'
    },
    'open-pull-requests-limit' => 5
  }.freeze

  def initialize
    @package_ecosystem = 'bundler'
    @filename = FILENAME
    @default_entry = DEFAULT_ENTRY
  end
end
