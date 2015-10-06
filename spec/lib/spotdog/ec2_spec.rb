require "spec_helper"

module Spotdog
  describe EC2 do
    let(:client) do
      Aws::EC2::Client.new(stub_responses: true)
    end

    let(:ec2) do
      described_class.new(client)
    end

    describe ".spot_price_history" do
      before do
        allow_any_instance_of(described_class).to receive(:spot_price_history).and_return([])
      end

      it "should create new #{described_class} instance and call #spot_price_history" do
        expect_any_instance_of(described_class).to receive(:spot_price_history)
        described_class.spot_price_history(client: client)
      end
    end

    describe "#spot_price_history" do
      %i(instance_types max_results product_descriptions start_time end_time).each do |name|
        let(name) do
          nil
        end
      end

      let(:m3xlarge_suse_classic_1c) do
        {
          instance_type: "m3.xlarge",
          product_description: "SUSE Linux",
          spot_price: "0.143600",
          timestamp: Time.parse("2015-10-06 05:39:52 UTC"),
          availability_zone: "ap-northeast-1c",
        }
      end

      let(:c4xlarge_linux_vpc_1b) do
        {
          instance_type: "c4.xlarge",
          product_description: "Linux/UNIX (Amazon VPC)",
          spot_price: "0.233600",
          timestamp: Time.parse("2015-10-06 05:29:52 UTC"),
          availability_zone: "ap-northeast-1b",
        }
      end

      let(:m4large_windows_classic_1c) do
        {
          instance_type: "m4.large",
          product_description: "Windows",
          spot_price: "1.143600",
          timestamp: Time.parse("2015-10-06 05:20:52 UTC"),
          availability_zone: "ap-northeast-1c",
        }
      end

      let(:spot_price_history) do
        [
          m3xlarge_suse_classic_1c,
          c4xlarge_linux_vpc_1b,
          m4large_windows_classic_1c
        ]
      end

      before do
        client.stub_responses(:describe_spot_price_history, spot_price_history: spot_price_history)
      end

      it "should return Array of Hash" do
        expect(
          ec2.spot_price_history(instance_types, max_results, product_descriptions, start_time, end_time)
        ).to eq spot_price_history
      end
    end
  end
end
