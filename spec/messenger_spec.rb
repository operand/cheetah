require File.dirname(__FILE__) + '/spec_helper'

describe Messenger do

  before(:each) do
  end

  describe ".parse_username_and_provider" do
    it "returns the domain" do
      CheetahMailer.parse_username_and_provider("leo@email.com").should == ['leo', 'email']
    end
  end

  describe ".validate_email" do

    it "returns false if the email domain is aol.com and the email does not match ^[a-z][a-z0-9]{2,15}$" do
      CheetahMailer.validate_email('12leo@aol.com').should be_false
    end

  end

  describe ".map_city_interests" do

    it "should work just like the old version" do
      def old_map_city_interests(city_interests)
        bitfield_length = 31
        bitfield_arr = Array.new(Location.count/bitfield_length+1, 0)
        (city_interests or "").split(/\s*,+\s*/).each do |city_name|
          location = Location.find_by_name(city_name) or next
          bitfield_arr[(location.id/bitfield_length)] = ( bitfield_arr[(location.id/bitfield_length)] or 0 ) + 2**((location.id-1)%bitfield_length)
        end
        params = {}
        params['LOCATIONS_1']           = bitfield_arr[0] or 0 # bit field
        params['LOCATIONS_2']           = bitfield_arr[1] or 0 # bit field
        params['LOCATIONS_3']           = bitfield_arr[2] or 0 # bit field
        params
      end

      locations = [Factory(:location),Factory(:location),Factory(:location),Factory(:location)]

      city_interests = locations.map{|loc|loc.name}.join(", ")

      new_user = Factory.build(:user)
      locations.each{|loc|new_user.subscribe_to loc}
      new_user.save!

      new_hash = CheetahMailer.map_city_interests(new_user)
      old_hash = old_map_city_interests(city_interests)
      new_hash.should == old_hash
    end

  end

  describe ".get_specific_matcher" do
    matchers = {
      'aol'     => /^[a-z][a-z0-9]{2,15}$/,
      'hotmail' => /^[a-z][a-z0-9._-]+$/,
      'msn'     => /^[a-z0-9_.-]+$/,
      'yahoo'   => /^[a-z][a-z0-9._\-]{1,31}$/,
      'gmail'   => /^[a-z0-9_.\-\+]+$/,
      'live'    => /^[a-z0-9_.-]+$/
    }

    matchers.keys.each do |domain|
      it "should return the appropriate matcher for #{domain}" do
        CheetahMailer.domain_specific_matcher(domain).should == matchers[domain]
      end
    end

    it "returns nil if the domain isn't found" do
      CheetahMailer.domain_specific_matcher("blah.com").should be_nil
    end

  end

  context ".do_request" do
    [CheetahPermanentException, CheetahAuthorizationException, Exception].each do |exception|
      it "should suppress #{exception}" do
        Cheetah.stub(:login).and_raise(CheetahPermanentException)
        Cheetah.stub(:do_post).and_raise(exception)
        Cheetah.do_request "", {}
      end
    end
  end

  context ".log" do
    it "should suppress logger exceptions" do
      @mock_logger.stub!(:info).and_raise("mock exception")
      CheetahMailer.log "foo"
    end
  end

  context '.send' do
    before do
      @path = '/'
      @params = {'email' => 'foo@foo.com'}
    end
    context 'in production mode' do
      before do
        ENV['RAILS_ENV'] = 'production'
      end
      after do
        ENV['RAILS_ENV'] = 'test'
      end
      it 'should enqueue a delayed job' do
        Delayed::Job.stub(:enqueue)
        Delayed::Job.should_receive(:enqueue)
        CheetahMailer.send(@path, @params)
      end
    end
    context 'in staging mode' do
      before do
        ENV['RAILS_ENV'] = 'staging'
      end
      after do
        ENV['RAILS_ENV'] = 'test'
      end
      it 'should enqueue a delayed job' do
        Delayed::Job.stub(:enqueue)
        Delayed::Job.should_receive(:enqueue)
        CheetahMailer.send(@path, @params)
      end
    end
    context 'in development mode' do
      before do
        ENV['RAILS_ENV'] = 'development'
      end
      after do
        ENV['RAILS_ENV'] = 'test'
      end
      context 'with a whitelisted email' do
        before do
          @params['email'] = 'foo@buywithme.com'
        end
        it 'should send the email immediately' do
          CheetahMailer.stub(:do_request)
          CheetahMailer.should_receive(:do_request).with(@path, @params)
          CheetahMailer.send(@path, @params)
        end
      end
      context 'without a whitelisted email' do
        it 'should not send anything' do
          CheetahMailer.stub(:do_request)
          CheetahMailer.should_not_receive(:do_request)
          CheetahMailer.send(@path, @params)
        end
      end
    end
    context 'in test mode' do
      before do
        ENV['RAILS_ENV'] = 'test'
      end
      it 'should not send or enqueue anything' do
        Delayed::Job.stub(:enqueue)
        Delayed::Job.should_not_receive(:enqueue)
        CheetahMailer.stub(:do_request)
        CheetahMailer.should_not_receive(:do_request)
        CheetahMailer.send(@path, @params)
      end
    end
  end
end

