require 'spec_helper'

describe 'User signs in', type: :feature do
  context 'with remember_me requested' do
    it 'will assign remember_me cookie' do
      user_signs_in_with_remember_me
      expect(remember_cookie).to_not be_nil
    end
  end

  context 'with remember_me cookie set' do
    it 'is authenticated with remember_me cookie' do
      user_signs_in_with_remember_me
      visit sign_in_path
      expect(current_path).to eq root_path # remember_me forwards to root path
    end
  end
end

def user_signs_in_with_remember_me
  User.create!(email: 'example@example.com', password_digest: 'password')
  visit sign_in_path
  fill_in 'session[email]', with: 'example@example.com'
  fill_in 'session[password]', with: 'password'
  check 'session[remember_me]'
  click_button 'go'
end

def remember_cookie
  Capybara.current_session.driver.request.cookies['remember_user_key']
end
