require 'spec_helper'

describe OmniAuth::AuthHash do
  subject{ OmniAuth::AuthHash.new }
  it 'should convert a supplied info key into an InfoHash object' do
    subject.info = {:first_name => 'Awesome'}
    subject.info.should be_kind_of(OmniAuth::AuthHash::InfoHash)
    subject.info.first_name.should == 'Awesome'
  end

  describe '#valid?' do
    subject{ OmniAuth::AuthHash.new(:uid => '123', :provider => 'example', :name => 'Steven') }

    it 'should be valid with the right parameters' do
      subject.should be_valid
    end

    it 'should require a uid' do
      subject.uid = nil
      subject.should_not be_valid
    end

    it 'should require a provider' do
      subject.provider = nil
      subject.should_not be_valid
    end

    it 'should require a name in the user info hash' do
      subject.name = nil
      subject.should_not be_valid?
    end
  end

  describe '#name' do
    subject{ OmniAuth::AuthHash.new(
      :name => 'Phillip J. Fry',
      :info => {
        :first_name => 'Phillip',
        :last_name => 'Fry',
        :nickname => 'meatbag',
        :email => 'fry@planetexpress.com'
    })}

    it 'should default to the name key' do
      subject.name.should == 'Phillip J. Fry'
    end

    it 'should fall back to go to first_name last_name concatenation' do
      subject.name = nil
      subject.name.should == 'Phillip Fry'
    end

    it 'should display only a first or last name if only that is available' do
      subject.name = nil
      subject.info.first_name = nil
      subject.name.should == 'Fry'
    end

    it 'should display the nickname if no name, first, or last is available' do
      subject.name = nil
      %w(first_name last_name).each{|k| subject.info[k] = nil}
      subject.name.should == 'meatbag'
    end

    it 'should display the email if no name, first, last, or nick is available' do
      subject.name = nil
      %w(first_name last_name nickname).each{|k| subject.info[k] = nil}
      subject.name.should == 'fry@planetexpress.com'
    end
  end

  describe '#to_hash' do
    subject{ OmniAuth::AuthHash.new(:uid => '123', :provider => 'test', :name => 'Bob Example')}
    let(:hash){ subject.to_hash }

    it 'should be a plain old hash' do
      hash.class.should == ::Hash
    end

    it 'should have string keys' do
      hash.keys.should be_include('uid')
    end

    it 'should convert an info hash as well' do
      subject.info = {:first_name => 'Bob', :last_name => 'Example'}
      subject.info.class.should == OmniAuth::AuthHash::InfoHash
      subject.to_hash['info'].class.should == ::Hash
    end

    it 'should supply the calculated name in the converted hash' do
      subject.name = nil
      subject.info = {:first_name => 'Bob', :last_name => 'Examplar'}
      hash['name'].should == 'Bob Examplar'
    end
  end

  describe OmniAuth::AuthHash::InfoHash do
    describe '#valid?' do
      it 'should be valid if there is a name' do
        OmniAuth::AuthHash::InfoHash.new(:name => 'Awesome').should be_valid
      end
    end
  end
end
