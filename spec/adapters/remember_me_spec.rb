require 'spec_helper'
require 'oath/lockdown/adapters/remember_me'

describe Oath::Lockdown::Adapters::RememberMe do
  before do
    Oath::Lockdown::Adapters::RememberMe.send(:public, *Oath::Lockdown::Adapters::RememberMe.protected_instance_methods)
  end

  describe '#remember_me!' do
    it 'creates token and creation date' do
      user = double(remember_token: nil, remember_token_created_at: nil)
      expect(user).to receive(:remember_token=).with(instance_of(String))
      # expect(user).to receive(:remember_token_created_at=).with(instance_of(ActiveSupport::TimeWithZone))
      expect(user).to receive(:remember_token_created_at=).with(instance_of(Time))
      expect(user).to receive(:save)
      rememberable = Oath::Lockdown::Adapters::RememberMe.new user
      rememberable.remember_me!
    end
  end

  describe '#forget_me!' do
    it 'nils out token and creation date' do
      user = double(remember_token: 'xxxx', remember_token_created_at: 2.minutes.ago)
      expect(user).to receive(:persisted?) { true }
      expect(user).to receive(:remember_token=).with(nil)
      expect(user).to receive(:remember_token_created_at=).with(nil)
      expect(user).to receive(:save)
      rememberable = Oath::Lockdown::Adapters::RememberMe.new user
      rememberable.forget_me!
    end
  end

  describe '#remembered?' do
    it 'is remembered with valid token and timestamp' do
      token = 'xxxxxxxx'
      user = double(remember_token: token, remember_token_created_at: 20.minutes.ago)
      rememberable = Oath::Lockdown::Adapters::RememberMe.new user
      expect(rememberable.remembered?(token, 5.minutes.ago)).to be_truthy
    end

    it 'is not remembered with invalid token' do
      user = double(remember_token: 'xxxxxxxx', remember_token_created_at: 20.minutes.ago)
      rememberable = Oath::Lockdown::Adapters::RememberMe.new user
      expect(rememberable.remembered?('yyyyyyyyyy', 5.minutes.ago)).to be_falsey
    end

    it 'is not remembered with invalid generated time' do
      token = 'xxxxxxxx'
      user = double(remember_token: token, remember_token_created_at: 20.minutes.ago)
      rememberable = Oath::Lockdown::Adapters::RememberMe.new user
      expect(rememberable.remembered?(token, 100.minutes.ago)).to be_falsey
    end
  end

  describe '#remember_token' do
    it 'generates a token 20 characters long' do
      rememberable = Oath::Lockdown::Adapters::RememberMe.new double
      expect(rememberable.remember_token.length).to eq 20
    end

    it 'generates a new token each time' do
      rememberable = Oath::Lockdown::Adapters::RememberMe.new double
      expect(rememberable.remember_token).to_not eq rememberable.remember_token
    end
  end

  describe '#compare_token' do
    it 'should complain when comparing empty or different sized passes' do
      rememberable = Oath::Lockdown::Adapters::RememberMe.new double
      [nil, ""].each do |empty|
        expect(rememberable.compare_token(empty, "something")).to be_falsey
        expect(rememberable.compare_token("something", empty)).to be_falsey
        expect(rememberable.compare_token(empty, empty)).to be_falsey
      end
      expect(rememberable.compare_token("size_1", "size_four")).to be_falsey
    end
  end
end
