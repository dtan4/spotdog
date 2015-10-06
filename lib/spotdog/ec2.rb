module Spotdog
  class EC2
    LINUX_VPC = "Linux/UNIX (Amazon VPC)"
    LINUX_CLASSIC = "Linux/UNIX"
    SUSE_VPC = "SUSE Linux (Amazon VPC)"
    SUSE_CLASSIC = "SUSE Linux"
    WINDOWS_VPC = "Windows (Amazon VPC)"
    WINDOWS_CLASSIC = "Windows"

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
