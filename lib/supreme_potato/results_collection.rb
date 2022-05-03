class ResultCollection
  def initialize(scanner:, results:)
    @scanner = scanner
    @results = results
  end

  def valid?
    @results.all?(&:valid?)
  end

  def inspect
    "#<DependabotValidator::ResultCollection:#{object_id} @scanner=#{@scanner}, @results=[\n\t#{@results.join("\n\t")}\n]>"
  end

  def print_missing_configs
    @results.filter do |result|
      !result.valid?
    end.map(&:print_config)
  end
end
