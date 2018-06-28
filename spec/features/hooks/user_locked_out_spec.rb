require 'spec_helper'

feature 'User account is locked' do
  scenario 'user cannot log in' do
    with_oath_config(max_consecutive_bad_logins_allowed: 2, bad_login_lockout_period: 10.minute) do
      User.create!(email: "example@example.com", password_digest: "password",
                   lock_expires_at: Time.current.utc + 1.day, failed_logins_count: 2)

      visit sign_in_path
      fill_in "session[email]", with: "example@example.com"
      fill_in "session[password]", with: "wrong password"
      click_button "go"

      expect(current_path).to eq root_path
    end
  end
end
