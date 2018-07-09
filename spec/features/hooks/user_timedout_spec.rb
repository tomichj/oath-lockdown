require 'spec_helper'

feature 'User signs in' do
  scenario 'user session times out' do
    with_oath_config(timeout_in: 15.minutes) do
      User.create!(email: 'example@example.com', password_digest: 'password')

      visit sign_in_path
      fill_in 'session[email]', with: 'example@example.com'
      fill_in 'session[password]', with: 'password'
      click_button 'go'

      Timecop.travel(Time.current + 20.minutes)

      visit posts_path
      expect(current_path).to eq sign_in_path
    end
  end

  scenario 'user logs in, subsequent click within timeout' do
    with_oath_config(timeout_in: 15.minutes) do
      User.create!(email: 'example@example.com', password_digest: 'password')

      visit sign_in_path
      fill_in 'session[email]', with: 'example@example.com'
      fill_in 'session[password]', with: 'password'
      click_button 'go'

      visit posts_path
      expect(current_path).to eq posts_path
    end
  end
end
