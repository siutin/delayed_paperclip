require "spec_helper"

RSpec.describe "DelayedJob::ProcessJob" do
  before :each do
    ActiveJob::Base.queue_adapter = :test
    ActiveJob::Base.logger = nil
  end

  let(:dummy) { Dummy.new(:image => File.open("#{ROOT}/fixtures/12k.png")) }

  describe "integration tests" do
    include_examples "base usage"
  end

  def process_jobs
    ActiveJob::Base.queue_adapter.enqueued_jobs.each do |job|
      job[:job].send(:perform_now, *job[:args])
    end
  end

  def jobs_count(queue = "paperclip")
    ActiveJob::Base.queue_adapter.enqueued_jobs.count do |job|
      job[:queue] == queue
    end
  end
end
