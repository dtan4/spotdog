module Spotdog
  class EC2
    PRODUCT_DESCRIPTIONS = {
      linux_vpc: "Linux/UNIX (Amazon VPC)",
      linux_classic: "Linux/UNIX",
      suse_vpc: "SUSE Linux (Amazon VPC)",
      suse_classic: "SUSE Linux",
      windows_vpc: "Windows (Amazon VPC)",
      windows_classic: "Windows",
    }.freeze

    def self.spot_price_history(client: Aws::EC2::Client.new)
      self.new(client).spot_price_history
    end

    def initialize(client)
      @client = client
    end

    def spot_price_history(opts = {})
      @client.describe_spot_price_history(
        instance_types: opts[:instance_types],
        max_results: opts[:max_results],
        product_descriptions: opts[:product_descriptions],
        start_time: opts[:start_time],
        end_time: opts[:end_time],
      ).spot_price_history.map(&:to_h)
    end
  end
end
