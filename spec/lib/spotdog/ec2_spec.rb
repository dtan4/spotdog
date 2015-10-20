require "spec_helper"

module Spotdog
  describe EC2 do
    let(:client) do
      Aws::EC2::Client.new(stub_responses: true)
    end

    let(:ec2) do
      described_class.new(client)
    end

    describe ".spot_instance_requests" do
      before do
        allow_any_instance_of(described_class).to receive(:spot_instance_requests).and_return([])
      end

      it "should create new #{described_class} instance and call #spot_instance_requests" do
        expect_any_instance_of(described_class).to receive(:spot_instance_requests)
        described_class.spot_instance_requests(client: client)
      end
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

    describe "#spot_instance_requests" do
      let(:spot_instance_request) do
        {
          spot_instance_request_id: "sir-1234abcd",
          spot_price: "0.051120",
          type: "one-time",
          state: "active",
          status: {
            code: "fulfilled", update_time: Time.parse("2015-10-20 12:34:56 UTC"), message: "Your Spot request is fulfilled."
          },
          launch_specification: {
            image_id: "ami-1234abcd",
            key_name: "hoge",
            security_groups: [
              { group_name: "default", group_id: "sg-1234abcd" }
            ],
            instance_type: "c4.xlarge",
            placement: { availability_zone: "ap-northeast-1c" },
            block_device_mappings: [
              {
                device_name: "/dev/xvda", ebs: {
                  volume_size: 50, delete_on_termination: true, volume_type: "gp2"
                }
              },
              {
                device_name: "/dev/xvdb", no_device: ""
              }
            ],
            network_interfaces: [
              { device_index: 0, subnet_id: "subnet-1234abcd", associate_public_ip_address: true }
            ],
            ebs_optimized: true,
            monitoring: { enabled: false }
          },
          instance_id: "i-1234abcd",
          create_time: Time.parse("2015-10-20 12:34:56 UTC"),
          product_description: "Linux/UNIX",
          tags: [
            { key: "Name", value: "" }
          ],
          launched_availability_zone: "ap-northeast-1c"
        }
      end

      let(:spot_instance_requests) do
        [
          spot_instance_request
        ]
      end

      before do
        client.stub_responses(:describe_spot_instance_requests, spot_instance_requests: spot_instance_requests)
      end

      it "should return Array of Hash" do
        expect(
          ec2.spot_instance_requests
        ).to eq spot_instance_requests
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
