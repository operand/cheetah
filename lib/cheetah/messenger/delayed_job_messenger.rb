require 'active_record'
require 'delayed_job'
Delayed::Worker.backend = :active_record # this is apparently needed to avoid a bug in delayed job

module Cheetah
  class DelayedJobMessenger < Messenger
    def send(message)
      priority = (Time.now.usec % 8 + 1)
      Delayed::Job.enqueue Delayed::PerformableMethod.new(self, :do_request, message), priority
    end
  end
end
