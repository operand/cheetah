require 'spec_helper'

describe Cheetah::ResqueTransactionalMessenger do

  before do
    @transactional_messenger = mock(:transactional_messenger)
    Cheetah::TransactionalMessenger.stub(:new).and_return(@transactional_messenger)

    @messenger = Cheetah::ResqueTransactionalMessenger.new
  end

  context 'resque-retry' do
    before(:each) do
      @clazz = Cheetah::ResqueTransactionalMessenger
    end
    it 'should retry 4 times' do
      @clazz.retry_limit.should == 4
    end
    it 'should wait 60 seconds in between attempts' do
      @clazz.retry_delay.should == 60
    end
    it 'should retry the Timeout::Error' do
      @clazz.retry_exceptions.should == [Timeout::Error]
    end
  end

  context "#send_message" do
    it 'should use the cheetah queue' do
      Cheetah::ResqueTransactionalMessenger.instance_variable_get(:@queue).should == :cheetah
    end
    it "should queue message for delivery" do
      params = {foo: 'bar'}
      message = mock :message, params: params

      Resque.should_receive(:enqueue).with(@messenger.class, params)

      @messenger.send_message message
    end

    it "should serialize attachments" do
      attachment = UploadIO.new StringIO.new('My content'),
                               'text/plain',
                               'foo.txt'
      message = mock :message, params: {SYSTEMMAIL_ATTACHMENT_FOO: attachment}

      Resque.should_receive(:enqueue) do |_, params|
        params[:SYSTEMMAIL_ATTACHMENT_FOO][:body].should == Base64.encode64('My content')
      end

      @messenger.send_message message
    end
  end

  context "#perform" do
    it "should recompose and deliver message" do
      params = {foo: 'bar'}
      message = mock(:message)

      Message.should_receive(:new).with(nil, params).and_return(message)
      @transactional_messenger.should_receive(:send_message).with(message)

      Cheetah::ResqueTransactionalMessenger.perform params
    end

    it "should deserialize attachments" do
      params = { 'SYSTEMMAIL_ATTACHMENT_FOO' =>
        {
          'content_type' => 'text/plain',
          'original_filename' => 'foo.txt',
          'body' => Base64.encode64('My content')
        }
      }

      @transactional_messenger.stub :send_message

      Message.should_receive(:new) do |_, params|
        params['SYSTEMMAIL_ATTACHMENT_FOO'].should be_kind_of UploadIO
      end

      Cheetah::ResqueTransactionalMessenger.perform params
    end
  end

  context "serialize_attachment" do
    it "should handle UploadIO object" do
      attachment = UploadIO.new StringIO.new('My content'),
                               'text/plain',
                               'foo.txt'

      serialized = Cheetah::ResqueTransactionalMessenger.serialize_attachment attachment
      serialized.should == {
        content_type: 'text/plain',
        original_filename: 'foo.txt',
        body: Base64.encode64('My content')
      }
    end

    it "should handle File object" do
      tempfile = Tempfile.new 'resqueue_transactional_messenger_spec'
      tempfile.write 'My content'
      tempfile.close

      attachment = File.new(tempfile.path)

      serialized = Cheetah::ResqueTransactionalMessenger.serialize_attachment attachment
      serialized.should == {
        content_type: nil,
        original_filename: File.basename(tempfile.path),
        body: Base64.encode64('My content')
      }
    end

    it "should raise if not a supported attachmentment type" do
      -> do
        Cheetah::ResqueTransactionalMessenger.serialize_attachment Object.new
      end.should raise_error Cheetah::ResqueTransactionalMessenger::UnsupportedAttachmentTypeError
    end
  end

  context "deserialize_attachment" do
    it "should deserialize to an UploadIO object" do
      serialized = {
        'content_type' => 'text/plain',
        'original_filename' => 'foo.txt',
        'body' => Base64.encode64('My content')
      }

      attachment = Cheetah::ResqueTransactionalMessenger.deserialize_attachment serialized
      attachment.content_type.should == 'text/plain'
      attachment.original_filename.should == 'foo.txt'
      attachment.read.should == 'My content'
    end
  end
end

