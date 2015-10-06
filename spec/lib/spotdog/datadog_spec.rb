require "spec_helper"

module Spotdog
  describe Datadog do
    let(:api_key) do
      "apikey"
    end

    let(:datadog) do
      described_class.new(api_key)
    end

    describe "#post_prices" do
      let(:c4xlarge_linux_vpc_1b_1) do
        {
          instance_type: "c4.xlarge",
          product_description: "Linux/UNIX (Amazon VPC)",
          spot_price: "0.143600",
          timestamp: Time.parse("2015-10-06 05:39:52 UTC"),
          availability_zone: "ap-northeast-1b",
        }
      end

      let(:c4xlarge_linux_vpc_1b_2) do
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

      let(:r3xlarge_suse_vpc_1c) do
        {
          instance_type: "r3.xlarge",
          product_description: "SUSE Linux (Amazon VPC)",
          spot_price: "1.343600",
          timestamp: Time.parse("2015-10-06 05:10:52 UTC"),
          availability_zone: "ap-northeast-1c",
        }
      end

      let(:spot_prices) do
        [
          c4xlarge_linux_vpc_1b_1,
          c4xlarge_linux_vpc_1b_2,
          m4large_windows_classic_1c,
          r3xlarge_suse_vpc_1c,
        ]
      end

      let(:c4xlarge_points) do
        [
          [Time.parse("2015-10-06 05:39:52 UTC"), 0.1436],
          [Time.parse("2015-10-06 05:29:52 UTC"), 0.2336],
        ]
      end

      let(:m4large_points) do
        [
          [Time.parse("2015-10-06 05:20:52 UTC"), 1.1436],
        ]
      end

      let(:r3xlarge_points) do
        [
          [Time.parse("2015-10-06 05:10:52 UTC"), 1.3436],
        ]
      end

      before do
        allow_any_instance_of(Dogapi::Client).to receive(:emit_point).and_return(nil)
      end

      it "should call emit_point" do
        expect_any_instance_of(Dogapi::Client).to receive(:emit_points).with(
          "spotinstance.c4_xlarge.linux_vpc.ap-northeast-1b",
          c4xlarge_points
        )
        expect_any_instance_of(Dogapi::Client).to receive(:emit_points).with(
          "spotinstance.m4_large.windows_classic.ap-northeast-1c",
          m4large_points
        )
        expect_any_instance_of(Dogapi::Client).to receive(:emit_points).with(
          "spotinstance.r3_xlarge.suse_vpc.ap-northeast-1c",
          r3xlarge_points
        )
        datadog.post_prices(spot_prices)
      end
    end
  end
end