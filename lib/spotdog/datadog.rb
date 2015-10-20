module Spotdog
  class Datadog
    DEFAULT_PREFIX = "spotinstance"
    STATUS_PREFIX = "status"

    def self.send_price_history(api_key, spot_price_history, prefix: DEFAULT_PREFIX)
      self.new(api_key, prefix).send_price_history(spot_price_history)
    end

    def self.send_spot_instance_requests(api_key, spot_instance_requests, prefix: DEFAULT_PREFIX)
      self.new(api_key, prefix).send_spot_instance_requests(spot_instance_requests)
    end

    def initialize(api_key, prefix)
      @client = Dogapi::Client.new(api_key)
      @prefix = prefix
    end

    def send_price_history(spot_price_history)
      price_groups_from(spot_price_history).each { |metric_name, price_history| @client.emit_points(metric_name, price_points_of(price_history)) }
    end

    def send_spot_instance_requests(spot_instance_requests)
      request_groups_from(spot_instance_requests).each { |metric_name, requests| @client.emit_points(metric_name, request_points_of(requests)) }
    end

    private

    def price_groups_from(spot_price_history)
      spot_price_history.inject({}) do |result, spot_price|
        metric_name = price_metric_name_of(spot_price)
        result[metric_name] ||= []
        result[metric_name] << spot_price
        result
      end
    end

    def request_groups_from(spot_instance_requests)
      spot_instance_requests.group_by { |request| request_metric_name_of(request) }
    end

    def price_metric_name_of(spot_price)
      # "spotinstance.c4_xlarge.linux_vpc.ap-northeast-1b"
      [
        @prefix,
        spot_price[:instance_type].sub(".", "_"),
        os_type_of(spot_price),
        spot_price[:availability_zone].gsub("-", "_")
      ].join(".")
    end

    def request_metric_name_of(spot_instance_request)
      [
        @prefix,
        STATUS_PREFIX,
        spot_instance_request[:state],
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

    def price_points_of(spot_price_history)
      spot_price_history.map { |spot_price| [spot_price[:timestamp], spot_price[:spot_price].to_f] }
    end

    def request_points_of(requests)
      current_time = Time.now
      requests.map { |request| [current_time, requests.length] }
    end
  end
end
