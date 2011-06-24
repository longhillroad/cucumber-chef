require File.join(File.dirname(__FILE__), "../../spec_helper.rb")

describe Cucumber::Chef::TestLab do
  before(:all) do
    @config = Cucumber::Chef::Config.test_config
  end

  subject { Cucumber::Chef::TestLab.new(@config) }
    
  describe "with no running labs" do
    it "should not return any info" do
      subject.info.should == ""
    end
  end

  describe "build" do
    after(:each) { subject.destroy }

    it "should spin up an ec2 instance", :slow => true do
      output = StringIO.new
      subject.build(output)
      output.rewind
      output.read.should match(/Platform provisioned/)
    end

    it "should only spin up one ec2 instance", :slow => true do
      subject.build(StringIO.new)
      expect {
        subject.build(StringIO.new)
      }.to raise_error(Cucumber::Chef::TestLabError)
    end

    it "should report its public ip address", :slow => true do
      server = subject.build(StringIO.new)
      subject.info.should == server.public_ip_address
    end
  end

  describe "destroy" do
    it "should destroy the running ec2 instance", :slow => true do
      subject.build(StringIO.new)
      subject.destroy
      subject.exists?.should_not be
    end
  end
end

