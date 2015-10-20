require "spec_helper"

module Spotdog
  describe CLI do
    let(:api_key) do
      "apikey"
    end

    let(:cli) do
      described_class.new
    end

    before do
      ENV["DATADOG_API_KEY"] = api_key
    end

    describe "#history" do
      let(:instance_types) do
        "c4.large,c4.xlarge"
      end

      let(:max_results) do
        10
      end

      let(:os_types) do
        "linux_vpc,suse_classic"
      end

      let(:start_time) do
        "2015-10-16 00:00 JST"
      end

      let(:end_time) do
        "2015-10-16 00:00 JST"
      end

      let(:spot_price_history) do
        [
          {
            instance_type: "c4.xlarge",
            product_description: "Linux/UNIX (Amazon VPC)",
            spot_price: "0.143600",
            timestamp: Time.parse("2015-10-06 05:39:52 UTC"),
            availability_zone: "ap-northeast-1b",
          }
        ]
      end

      before do
        allow(Spotdog::EC2).to receive(:spot_price_history).and_return(spot_price_history)
        allow(Spotdog::Datadog).to receive(:send_price_history)
      end

      context "when last_minutes is not specified" do
        it "should call modules respectively" do
          expect(Spotdog::EC2).to receive(:spot_price_history).with(
            instance_types: ["c4.large", "c4.xlarge"],
            max_results: max_results,
            product_descriptions: ["Linux/UNIX (Amazon VPC)", "SUSE Linux"],
            start_time: Time.parse(start_time),
            end_time: Time.parse(end_time),
          )
          expect(Spotdog::Datadog).to receive(:send_price_history).with(api_key, spot_price_history)

          cli.invoke("history", [], {
            instance_types: instance_types,
            max_results: max_results,
            product_descriptions: os_types,
            start_time: start_time,
            end_time: end_time,
          })
        end
      end

      context "when last_minutes is specified" do
        let(:current_time) do
          Time.parse("2015-10-06 18:00 JST")
        end

        let(:last_minutes) do
          10
        end

        it "should call modules respectively with related time range" do
          Timecop.freeze(current_time) do
            expect(Spotdog::EC2).to receive(:spot_price_history).with(
              instance_types: ["c4.large", "c4.xlarge"],
              max_results: max_results,
              product_descriptions: ["Linux/UNIX (Amazon VPC)", "SUSE Linux"],
              start_time: current_time - last_minutes * 60,
              end_time: current_time,
            )
            expect(Spotdog::Datadog).to receive(:send_price_history).with(api_key, spot_price_history)

            cli.invoke("history", [], {
              instance_types: instance_types,
              max_results: max_results,
              product_descriptions: os_types,
              start_time: start_time,
              end_time: end_time,
              last_minutes: last_minutes,
            })
          end
        end
      end
    end

    describe "#requests" do
      let(:spot_instance_requests) do
        []
      end

      before do
        allow(Spotdog::EC2).to receive(:spot_instance_requests).and_return(spot_instance_requests)
        allow(Spotdog::Datadog).to receive(:send_spot_instance_requests)
      end

      it "should call modules respectively" do
        expect(Spotdog::EC2).to receive(:spot_instance_requests).with(no_args)
        expect(Spotdog::Datadog).to receive(:send_spot_instance_requests).with(api_key, spot_instance_requests)

        cli.invoke("requests", [], {})
      end
    end
  end
end
