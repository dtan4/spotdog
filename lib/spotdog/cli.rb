module Spotdog
  class CLI < Thor
    desc "send", "Send spot instance price history"
    option :instance_types, type: :string, desc: "List of instance types", aliases: :i
    option :max_results, type: :numeric, desc: "Number of results", aliases: :m
    option :product_descriptions, type: :string, desc: "List of product descriptions", aliases: :p
    option :start_time, type: :string, desc: "The time which to start retriving the prices", aliases: :s
    option :end_time, type: :string, desc: "The time which to stop retriving the prices", aliases: :e
    option :last_minutes, type: :numeric, desc: "The duration in minutes which to retrive the prices", aliases: :l
    def send
      spot_price_history = Spotdog::EC2.spot_price_history(
        instance_types: options[:instance_types] ? options[:instance_types].split(",") : nil,
        max_results: options[:max_results],
        product_descriptions: options[:product_descriptions] ?
          convert_product_descriptions(options[:product_descriptions].split(",")) : nil,
        start_time: parse_start_time(options),
        end_time: parse_end_time(options),
      )
      Spotdog::Datadog.send_price_history(ENV["DATADOG_API_KEY"], spot_price_history)
    end

    private

    def convert_product_descriptions(product_descriptions)
      product_descriptions.map { |description| Spotdog::EC2::PRODUCT_DESCRIPTIONS[description.to_sym] }
    end

    def current_time
      @current_time ||= Time.now
    end

    def parse_start_time(options)
      if options[:last_minutes]
        current_time - options[:last_minutes] * 60
      else
        options[:start_time] ? Time.parse(options[:start_time]) : nil
      end
    end

    def parse_end_time(options)
      if options[:last_minutes]
        current_time
      else
        options[:end_time] ? Time.parse(options[:end_time]) : nil
      end
    end
  end
end
