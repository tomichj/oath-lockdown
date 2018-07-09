require 'spec_helper'

describe 'User account locking', type: :feature do
  context 'with locked account inside lockout period' do
    it 'does not allow login' do
      with_oath_config(max_consecutive_bad_logins_allowed: 2, bad_login_lockout_period: 10.minute) do
        User.create!(email: 'example@example.com', password_digest: 'password',
                     locked_at: Time.current.utc - 1.minute, failed_logins_count: 2)

        visit sign_in_path
        fill_in 'session[email]', with: 'example@example.com'
        fill_in 'session[password]', with: 'wrong password'
        click_button 'go'

        expect(current_path).to eq root_path
      end
    end
  end

  context 'with locked account outside lockout period' do
    it 'allows login' do
      with_oath_config(max_consecutive_bad_logins_allowed: 2, bad_login_lockout_period: 10.minutes) do
        User.create!(email: 'example@example.com', password_digest: 'password',
                     locked_at: Time.current.utc - 20.minutes, failed_logins_count: 3)

        visit sign_in_path
        fill_in 'session[email]', with: 'example@example.com'
        fill_in 'session[password]', with: 'password'
        click_button 'go'

        expect(current_path).to eq posts_path
      end
    end
  end
end
