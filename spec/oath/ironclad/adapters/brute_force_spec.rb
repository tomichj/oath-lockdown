require 'spec_helper'
require 'oath/ironclad/adapters/brute_force'

describe Oath::Ironclad::Adapters::BruteForce do
  describe '#valid?' do
    context 'with valid user attributes' do
      it 'is valid' do
        user = double(locked_at: nil, failed_logins_count: 0)
        bf_adapter = Oath::Ironclad::Adapters::BruteForce.new(user)
        expect(bf_adapter).to be_required_fields
      end
    end
    context 'with invalid user attributes' do
      it 'is valid' do
        user = double()
        bf_adapter = Oath::Ironclad::Adapters::BruteForce.new(user)
        expect(bf_adapter).to_not be_required_fields
      end
    end
  end

  describe '#register_failed_login!' do
    context 'with nil failed logins' do
      it 'initializes and sets a nil failed_login_count' do
        with_oath_config(max_consecutive_bad_logins_allowed: 2, bad_login_lockout_period: 1.minute) do
          user = User.new failed_logins_count: nil
          bf_adapter = Oath::Ironclad::Adapters::BruteForce.new(user)
          bf_adapter.register_failed_login!
          expect(user.failed_logins_count).to eq 1
        end
      end
    end
    context 'with failed_logins_count about to lock account' do
      it 'locks account on next failed login' do
        with_oath_config(max_consecutive_bad_logins_allowed: 1, bad_login_lockout_period: 5.minute) do
          user = User.new failed_logins_count: 1
          bf_adapter = Oath::Ironclad::Adapters::BruteForce.new(user)
          bf_adapter.register_failed_login!
          expect(bf_adapter.attempts_exceeded?).to be_truthy
        end
      end
    end
  end

  describe '#unlocked?' do
    context 'with nil locked_at' do
      it 'is not locked' do
        user = User.new locked_at: nil
        bf_adapter = Oath::Ironclad::Adapters::BruteForce.new(user)
        expect(bf_adapter.unlocked?).to be_truthy
      end
    end
    context 'with lock_expires_at in the past' do
      it 'is not locked' do
        with_oath_config(bad_login_lockout_period: 10.minutes) do
          user = User.new locked_at: Time.current.utc - 20.minutes
          bf_adapter = Oath::Ironclad::Adapters::BruteForce.new(user)
          expect(bf_adapter.unlocked?).to be_truthy
        end
      end
    end
    context 'with lock_expires_at in the future' do
      it 'is not locked' do
        user = User.new locked_at: Time.current.utc + 10.minutes
        bf_adapter = Oath::Ironclad::Adapters::BruteForce.new(user)
        expect(bf_adapter.unlocked?).to be_falsey
      end
    end
  end

  describe '#locked?' do
    context 'when user is locked' do
      it 'reports lock' do
        with_oath_config(max_consecutive_bad_logins_allowed: 1, bad_login_lockout_period: 50.minute) do
          user = User.new locked_at: Time.current.utc - 1.minutes, failed_logins_count: 4
          bf_adapter = Oath::Ironclad::Adapters::BruteForce.new(user)
          expect(bf_adapter.locked?).to be_truthy
        end
      end
    end
    context 'when user is not locked' do
      it 'reports lock' do
        with_oath_config(max_consecutive_bad_logins_allowed: 1, bad_login_lockout_period: 5.minute) do
          user = User.new locked_at: nil, failed_logins_count: nil
          bf_adapter = Oath::Ironclad::Adapters::BruteForce.new(user)
          expect(bf_adapter.locked?).to be_falsey
        end
      end
    end
  end

  describe '#unlock!' do
    context 'when user is locked' do
      it 'resets lock attributes' do
        with_oath_config(max_consecutive_bad_logins_allowed: 1, bad_login_lockout_period: 5.minute) do
          user = User.new locked_at: Time.current.utc, failed_logins_count: 4
          bf_adapter = Oath::Ironclad::Adapters::BruteForce.new(user)
          bf_adapter.unlock!
          expect(user.locked_at).to be_nil
          expect(user.failed_logins_count).to eq 0
        end
      end
    end
    context 'when user is not locked' do
      it 'resets lock attributes' do
        with_oath_config(max_consecutive_bad_logins_allowed: 2, bad_login_lockout_period: 5.minute) do
          user = User.new locked_at: nil, failed_logins_count: 0
          bf_adapter = Oath::Ironclad::Adapters::BruteForce.new(user)
          bf_adapter.unlock!
          expect(user.locked_at).to be_nil
          expect(user.failed_logins_count).to eq 0
        end
      end
    end
  end
end
