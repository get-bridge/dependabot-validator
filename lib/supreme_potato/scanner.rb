module Scanner
  def generate(directory: '.')
    sourcefiles = Dir.glob(File.join(directory, '**', filename))
    # TODO: figure out how to do yaml without anchors/aliases
    directories(sourcefiles: sourcefiles).map do |d|
      { 'directory' => d }.merge(default_entry)
    end
  end

  def parse(dependabot: '.github/dependabot.yml')
    File.open(dependabot) do |file|
      dependabot_config = YAML.safe_load(file.read)
      warn "Running package manager search: #{package_ecosystem}" if DEBUG
      dependabot_config.fetch('updates').select do |entry|
        entry.fetch('package-ecosystem') == package_ecosystem
      end
    end
  end

  private

  def directories(sourcefiles:)
    sourcefiles.map do |sourcefile|
      File.dirname(sourcefile)
    end
  end

  attr_reader :package_ecosystem, :filename, :default_entry
end
