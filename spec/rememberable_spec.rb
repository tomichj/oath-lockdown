require 'spec_helper'
require 'oath/lockdown/adapters/lifetimed'

describe Oath::Lockdown::Rememberable do
  describe '#rememeber_me' do
    it 'writes a cookie' do
      warden = double
      cookie_jar = {}
      expect(warden).to receive_message_chain(:request, :cookie_jar, :signed) { cookie_jar }
      user = User.create! email: 'dude@dude.dude', remember_token: 'xxxxx', remember_token_created_at: 1.minute.ago
      # expect(user).to receive(:changed?) { true }

      rememberable = Oath::Lockdown::Rememberable.new(warden)
      rememberable.remember_me(user)

      remember_cookie = cookie_jar['remember_user_key']
      remember_values = remember_cookie[:value]
      expect(remember_cookie[:httponly]).to be_truthy
      expect(remember_cookie[:expires]).to be_instance_of(ActiveSupport::TimeWithZone)

      expect(remember_values[0]).to be_instance_of(Integer)
      expect(remember_values[0]).to eq user.id
      expect(remember_values[1]).to be_instance_of(String)
      expect(remember_values[1]).to eq user.remember_token
      expect(remember_values[2]).to be_instance_of(String)
    end
  end
end
