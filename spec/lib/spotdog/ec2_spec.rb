require "spec_helper"

module Spotdog
  describe EC2 do
    let(:client) do
      Aws::EC2::Client.new(stub_responses: true)
    end

    let(:ec2) do
      described_class.new(client)
    end

    describe "#spot_price_history" do
      let(:empty_args) do
        {
          instance_types: nil,
          max_results: nil,
          product_descriptions: nil,
          start_time: nil,
          end_time: nil,
        }
      end

      let(:spot_price_history) do
        double("spot_price_history", spot_price_history: [])
      end

      before do
        allow_any_instance_of(Aws::EC2::Client).to receive(:describe_spot_price_history).and_return(spot_price_history)
      end

      context "when no argument is given" do
        it "should call DescribeSpotPriceHistory with no argument" do
          expect_any_instance_of(Aws::EC2::Client).to receive(:describe_spot_price_history).with(empty_args)
          ec2.spot_price_history
        end
      end

      context "when instance_types is given" do
        let(:instance_types) do
          ["c4.xlarge"]
        end

        it "should call DescribeSpotPriceHistory with instance_types" do
          expect_any_instance_of(Aws::EC2::Client).to receive(:describe_spot_price_history).with(
            empty_args.merge(instance_types: instance_types)
          )
          ec2.spot_price_history(instance_types: instance_types)
        end
      end

      context "when max_results is given" do
        let(:max_results) do
          10
        end

        it "should call DescribeSpotPriceHistory with max_results" do
          expect_any_instance_of(Aws::EC2::Client).to receive(:describe_spot_price_history).with(
            empty_args.merge(max_results: max_results)
          )
          ec2.spot_price_history(max_results: max_results)
        end
      end

      context "when product_descriptions is given" do
        let(:product_descriptions) do
          [described_class::LINUX_VPC]
        end

        it "should call DescribeSpotPriceHistory with product_descriptions" do
          expect_any_instance_of(Aws::EC2::Client).to receive(:describe_spot_price_history).with(
            empty_args.merge(product_descriptions: product_descriptions)
          )
          ec2.spot_price_history(product_descriptions: product_descriptions)
        end
      end

      context "when start_time is given" do
        let(:start_time) do
          Time.parse("2015-10-06 01:32:57 UTC")
        end

        it "should call DescribeSpotPriceHistory with start_time" do
          expect_any_instance_of(Aws::EC2::Client).to receive(:describe_spot_price_history).with(
            empty_args.merge(start_time: start_time)
          )
          ec2.spot_price_history(start_time: start_time)
        end
      end

      context "when end_time is given" do
        let(:end_time) do
          Time.parse("2015-10-06 01:32:57 UTC")
        end

        it "should call DescribeSpotPriceHistory with end_time" do
          expect_any_instance_of(Aws::EC2::Client).to receive(:describe_spot_price_history).with(
            empty_args.merge(end_time: end_time)
          )
          ec2.spot_price_history(end_time: end_time)
        end
      end
    end
  end
end
