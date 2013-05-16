require 'spec_helper'

class CheetahLogger
  include Cheetah::Logger
end

describe Cheetah::Logger do
  context '#logger' do
    before(:each) do
      @cheetah_logger = CheetahLogger.new
    end
    it 'should create a logger and cache it' do
      CheetahLogger.any_instance.should_receive(:log_file).and_return '/tmp/log.txt'
      ::Logger.should_receive(:new).with('/tmp/log.txt').and_return stub(:'formatter=' => true)
      @cheetah_logger.logger
      @cheetah_logger.logger
    end
  end

  context '#log_file' do
    context 'with a StringIO' do
      it 'should return a StringIO' do
        logger = CheetahLogger.new
        logger.logger_out = string_io = StringIO.new
        logger.log_file.should == string_io
      end
    end
    context 'with no Rails env' do
      it 'should define a tmp logfile' do
        CheetahLogger.new.log_file.should == '/tmp/cheetah_errors.log'
      end
    end
    context 'with a Rails env' do
      it 'should define a logfile in the Rails log directory' do
        Rails = stub( root: Pathname.new('/tmp/') )
        CheetahLogger.new.log_file.should == '/tmp/log/cheetah_errors.log'
      end
    end
  end

  context '#info' do
    before(:each) do
      @cheetah_logger = CheetahLogger.new
      @cheetah_logger.logger_out = StringIO.new
    end
    it 'should format the log entry' do
      Timecop.freeze(now = Time.now) do
        @cheetah_logger.logger.info('some message')
      end
      @cheetah_logger.logger_out.string.should == "#{now},some message\n"
    end
  end
end
