require 'spec_helper'

feature 'User account lock expires' do
  scenario 'user is able to log in' do
    with_oath_config(max_consecutive_bad_logins_allowed: 1, bad_login_lockout_period: 10.minute) do
      User.create!(email: "example@example.com", password_digest: "password",
                   lock_expires_at: 30.minutes.ago, failed_logins_count: 3)

      visit sign_in_path
      fill_in "session[email]", with: "example@example.com"
      fill_in "session[password]", with: "password"
      click_button "go"

      expect(current_path).to eq posts_path
    end
  end
end
