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
  end
end

