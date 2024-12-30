# frozen_string_literal: true

require_relative "db_background_job/version"

module DbBackgroundJob
  class Error < StandardError; end

  def self.spawn(&block)
    with_db_connection do
      pid = Process.fork do
        setup_child(&block)
      end
      Process.detach(pid)
    end
  end

  def self.spawn_and_wait(&block)
    with_db_connection do
      pid = Process.fork do
        begin
          setup_child(&block)
          exit(0)
        rescue Exception => e
          puts "Error in background job: #{e.inspect}"
          exit(1)
        end
      end
      _, status = Process.wait2(pid)
      status.exitstatus
    end
  end

  private

  def self.with_db_connection(&block)
    dbconfig = ActiveRecord::Base.remove_connection
    begin
      yield
    ensure
      ActiveRecord::Base.establish_connection(dbconfig)
    end
  end

  def self.setup_child(&block)
    ActiveRecord::Base.establish_connection
    block.call
  ensure
    ActiveRecord::Base.remove_connection
  end
end
