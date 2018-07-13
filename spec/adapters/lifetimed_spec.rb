require 'spec_helper'
require 'oath/lockdown/adapters/lifetimed'

describe Oath::Lockdown::Adapters::Lifetimed do
  describe '#feature_enabled?' do
    it 'enabled with max_session_lifetime set' do
      with_oath_config(max_session_lifetime: 10.minutes) do
        lifetimed = Oath::Lockdown::Adapters::Lifetimed.new double
        expect(lifetimed.feature_enabled?).to be_truthy
      end
    end

    it 'disabled with nil max_session_lifetime' do
      with_oath_config(max_session_lifetime: nil) do
        lifetimed = Oath::Lockdown::Adapters::Lifetimed.new double
        expect(lifetimed.feature_enabled?).to be_falsey
      end
    end
  end

  describe '#lifetime_exceeded?' do
    it 'not exceeded while under max lifetime' do
      with_oath_config(max_session_lifetime: 10.minutes) do
        lifetimed = Oath::Lockdown::Adapters::Lifetimed.new double
        expect(lifetimed.lifetime_exceeded?(9.minutes.ago)).to be_falsey
      end
    end

    it 'exceeded when over max lifetime' do
      with_oath_config(max_session_lifetime: 10.minutes) do
        lifetimed = Oath::Lockdown::Adapters::Lifetimed.new double
        expect(lifetimed.lifetime_exceeded?(11.minutes.ago)).to be_truthy
      end
    end
  end
end
