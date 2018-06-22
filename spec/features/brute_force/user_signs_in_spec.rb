require 'spec_helper'

# user = User.new lock_expires_at: Time.current.utc + 20.minutes, failed_logins_count: 4

feature 'User signs in' do
  scenario 'with nil failed_logins_count' do
    user = User.create!(email: "example@example.com", password_digest: "password",
                        lock_expires_at: nil, failed_logins_count: nil)

    visit sign_in_path
    fill_in "session[email]", with: "Example@example.com"
    fill_in "session[password]", with: "password"
    click_button "go"

    expect(current_path).to eq posts_path
  end

  scenario 'with 0 failed_logins_count' do
    with_oath_config(max_consecutive_bad_logins_allowed: 1, bad_login_lockout_period: 5.minute) do
      user = User.create!(email: "example@example.com", password_digest: "password",
                          lock_expires_at: nil, failed_logins_count: 0)

      visit sign_in_path
      fill_in "session[email]", with: "Example@example.com"
      fill_in "session[password]", with: "password"
      click_button "go"

      expect(current_path).to eq posts_path
    end
  end
end
