require 'spec_helper'

feature 'User can lock account' do
  scenario 'with nil failed_logins_count' do
    with_oath_config(max_consecutive_bad_logins_allowed: 1, bad_login_lockout_period: 10.minute) do
      user = User.create!(email: 'example@example.com', password_digest: 'password',
                          locked_at: nil, failed_logins_count: nil)

      visit sign_in_path
      fill_in 'session[email]', with: 'example@example.com'
      fill_in 'session[password]', with: 'wrong password'
      click_button 'go'

      visit sign_in_path
      fill_in 'session[email]', with: 'example@example.com'
      fill_in 'session[password]', with: 'wrong password'
      click_button 'go'

      expect(current_path).to eq sign_in_path
      expect(user.failed_logins_count).to eq 2
      expect(user.locked_at).to_not be_nil
    end
  end

  scenario 'with 0 failed_logins_count' do
    with_oath_config(max_consecutive_bad_logins_allowed: 1, bad_login_lockout_period: 5.minute) do
      user = User.create!(email: 'example@example.com', password_digest: 'password',
                          locked_at: nil, failed_logins_count: 0)

      visit sign_in_path
      fill_in 'session[email]', with: 'example@example.com'
      fill_in 'session[password]', with: 'wrong password'
      click_button 'go'

      visit sign_in_path
      fill_in 'session[email]', with: 'example@example.com'
      fill_in 'session[password]', with: 'wrong password'
      click_button 'go'

      expect(current_path).to eq sign_in_path
      expect(user.failed_logins_count).to eq 2
      expect(user.locked_at).to_not be_nil
    end
  end
end
