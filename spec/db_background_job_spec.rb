require 'spec_helper'
require 'active_record'

RSpec.describe DbBackgroundJob do
  describe ".spawn" do
    it "forks a process and detaches it" do
      expect(Process).to receive(:fork).and_return(123)
      expect(Process).to receive(:detach).with(123)

      expect(ActiveRecord::Base).to receive(:remove_connection)
      expect(ActiveRecord::Base).to receive(:establish_connection)
    end
  end

  describe ".spawn_and_wait" do
    it "forks a process, waits for it to complete and returns exit status" do
      expect(Process).to receive(:fork).and_return(123)
      expect(Process).to receive(:wait2).with(123).and_return([123, double(exitstatus: 0)])

      expect(ActiveRecord::Base).to receive(:remove_connection)
      expect(ActiveRecord::Base).to receive(:establish_connection)

      expect(DbBackgroundJob.spawn_and_wait { puts "hello" }).to eq(0)
    end

    it "captures exceptions and returns non-zero exit status" do
      expect(Process).to receive(:fork).and_return(123)
      expect(Process).to receive(:wait2).with(123).and_return([123, double(exitstatus: 1)])

      expect(DbBackgroundJob.spawn_and_wait { raise "oops" }).to eq(1)
    end
  end

  describe ".with_db_connection" do
    it "removes connection, yields block, re-establishes connection" do
      config = double
      expect(ActiveRecord::Base).to receive(:remove_connection).and_return(config)
      expect(ActiveRecord::Base).to receive(:establish_connection).with(config)

      expect { |b| DbBackgroundJob.send(:with_db_connection, &b) }.to yield_control
    end
  end

  describe ".setup_child" do
    it "establishes connection, yields block, removes connection" do
      expect(ActiveRecord::Base).to receive(:establish_connection)
      expect(ActiveRecord::Base).to receive(:remove_connection)

      expect { |b| DbBackgroundJob.send(:setup_child, &b) }.to yield_control
    end
  end
end
