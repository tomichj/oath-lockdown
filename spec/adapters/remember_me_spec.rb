require 'spec_helper'
require 'oath/lockdown/adapters/remember_me'

describe Oath::Lockdown::Adapters::RememberMe do
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
end
