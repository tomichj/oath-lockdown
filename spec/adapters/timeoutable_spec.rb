require 'spec_helper'
require 'oath/lockdown/adapters/lifetimed'

describe Oath::Lockdown::Adapters::Timeoutable do
  describe '#timedout?' do
    it 'false while less than timeout_in' do
      with_oath_config(timeout_in: 10.minutes) do
        timeoutable = Oath::Lockdown::Adapters::Timeoutable.new double
        expect(timeoutable.timedout?(9.minutes.ago)).to be_falsey
      end
    end

    it 'true while greater than timeout_in' do
      with_oath_config(timeout_in: 10.minutes) do
        timeoutable = Oath::Lockdown::Adapters::Timeoutable.new double
        expect(timeoutable.timedout?(11.minutes.ago)).to be_truthy
      end
    end
  end
end
