class ResultCollection
  def initialize(scanner:, results:)
    @scanner = scanner
    @results = results
  end

  def valid?
    results.all?(&:valid?)
  end

  def inspect
    "#<ResultCollection:#{object_id} scanner=#{scanner.inspect}, results=[\n\t#{results.join("\n\t")}\n]>"
  end

  def print_missing_configs
    results.filter do |result|
      !result.valid?
    end.map(&:print_config).uniq
  end

  private

  attr_reader :scanner, :results
end
