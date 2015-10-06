module Spotdog
  class Datadog
    DEFAULT_PREFIX = "spotinstance"

    def initialize(api_key, prefix: DEFAULT_PREFIX)
      @client = Dogapi::Client.new(api_key)
      @prefix = prefix
    end

    def post_prices(spot_prices)
      groups_from(spot_prices).each { |metric_name, prices| @client.emit_points(metric_name, points_of(prices)) }
    end

    private

    def groups_from(spot_prices)
      spot_prices.inject({}) do |result, spot_price|
        metric_name = metric_name_of(spot_price)
        result[metric_name] ||= []
        result[metric_name] << spot_price
        result
      end
    end

    def metric_name_of(spot_price)
      # "spotinstance.c4_xlarge.linux_vpc.ap-northeast-1b"
      [
        @prefix,
        spot_price[:instance_type].sub(".", "_"),
        os_type_of(spot_price),
        spot_price[:availability_zone].gsub("-", "_")
      ].join(".")
    end

    def machine_os_of(spot_price)
      case spot_price[:product_description]
      when /\ASUSE/
        "suse"
      when /\AWindows/
        "windows"
      else
        "linux"
      end
    end

    def machine_type_of(spot_price)
      spot_price[:product_description].include?("VPC") ? "vpc" : "classic"
    end

    def os_type_of(spot_price)
      "#{machine_os_of(spot_price)}_#{machine_type_of(spot_price)}"
    end

    def points_of(spot_prices)
      spot_prices.map { |spot_price| [spot_price[:timestamp], spot_price[:spot_price].to_f] }
    end
  end
end
