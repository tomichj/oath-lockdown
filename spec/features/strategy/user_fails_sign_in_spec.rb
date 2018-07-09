require 'spec_helper'

feature 'User signs in' do
  scenario 'with already locked account' do
    with_oath_config(max_consecutive_bad_logins_allowed: 2, bad_login_lockout_period: nil) do
      User.create!(email: 'example@example.com', password_digest: 'password', failed_logins_count: 3)

      visit sign_in_path
      fill_in 'session[email]', with: 'example@example.com'
      fill_in 'session[password]', with: 'password'
      click_button 'go'

      expect(current_path).to eq posts_path
    end
  end
end
