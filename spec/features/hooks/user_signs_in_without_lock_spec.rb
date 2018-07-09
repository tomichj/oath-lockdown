require 'spec_helper'

describe 'User signs in', type: :feature do
  context 'with nil failed_logins_count' do
    before do
      User.create!(email: 'example@example.com', password_digest: 'password',
                   locked_at: nil, failed_logins_count: nil)
    end
    it 'signs in' do
      visit sign_in_path
      fill_in 'session[email]', with: 'example@example.com'
      fill_in 'session[password]', with: 'password'
      click_button 'go'

      expect(current_path).to eq posts_path
    end
  end

  context 'with 0 failed_logins_count' do
    before do
      User.create!(email: 'example@example.com', password_digest: 'password',
                   locked_at: nil, failed_logins_count: 0)
    end
    it 'signs in' do
      with_oath_config(max_consecutive_bad_logins_allowed: 1, bad_login_lockout_period: 5.minute) do
        visit sign_in_path
        fill_in 'session[email]', with: 'example@example.com'
        fill_in 'session[password]', with: 'password'
        click_button 'go'

        expect(current_path).to eq posts_path
      end
    end
  end
end
