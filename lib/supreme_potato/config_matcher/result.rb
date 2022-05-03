class ConfigMatcher
  class Result
    def initialize(directory:, match:, package_ecosystem:)
      @directory = directory
      @match = match
      @package_ecosystem = package_ecosystem
    end

    def valid?
      @match
    end

    def to_s
      inspect
    end

    def print_config
      <<~TEMPLATE
        - package-ecosystem: #{@package_ecosystem}
          directory: #{@directory}
          schedule:
            interval: daily
          open-pull-request-limit: 5
      TEMPLATE
    end
  end
end
