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

    def self.spot_instance_requests(client: Aws::EC2::Client.new)
      self.new(client).spot_instance_requests
    end

    def self.spot_price_history(client: Aws::EC2::Client.new, instance_types: nil, max_results: nil,
      product_descriptions: nil, start_time: nil, end_time: nil)
      self.new(client).spot_price_history(instance_types, max_results, product_descriptions, start_time, end_time)
    end

    def initialize(client)
      @client = client
    end

    def spot_instance_requests
      @client.describe_spot_instance_requests.spot_instance_requests.map(&:to_h)
    end

    def spot_price_history(instance_types, max_results, product_descriptions, start_time, end_time)
      @client.describe_spot_price_history(
        instance_types: instance_types,
        max_results: max_results,
        product_descriptions: product_descriptions,
        start_time: start_time,
        end_time: end_time,
      ).spot_price_history.map(&:to_h)
    end
  end
end
