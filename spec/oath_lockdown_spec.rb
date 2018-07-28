require 'spec_helper'

RSpec.describe Oath::Lockdown do
  it 'has a version number' do
    expect(Oath::Lockdown::VERSION).not_to be nil
  end

  describe '#serialize_into_cookie' do
    it 'emits cookie values' do
      user = User.create email: 'gug@gug.gug'
      Oath::Lockdown::Adapters::RememberMe.new(user).remember_me!
      id, token, date = Oath::Lockdown::Rememberable.serialize_into_cookie(user)
      expect(id).to eq user.id
      expect(token).to be_instance_of String
      expect(token.length).to eq 20
      expect(date).to be_instance_of String
    end
  end

  describe '#serialize_from_cookie' do
    it 'finds the user' do
      user = User.create! email: 'gug@gug.gug',
                          remember_token: '1234567890',
                          remember_token_created_at: Time.current.utc - 20.minutes
      cookie_bits = [user.id, user.remember_token, Time.current.utc.to_f.to_s]
      expect(Oath::Lockdown::Rememberable.serialize_from_cookie(*cookie_bits)).to eq user
    end
  end
end
