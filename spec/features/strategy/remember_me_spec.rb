require 'spec_helper'

describe 'User signs in', type: :feature do
  context 'with with remember_me' do
    before do
      User.create!(email: 'example@example.com', password_digest: 'password')
    end

    it 'signs in' do
      visit sign_in_path
      fill_in 'session[email]', with: 'example@example.com'
      fill_in 'session[password]', with: 'password'
      check 'session[remember_me]'
      click_button 'go'

      visit sign_in_path

      # already signed in, so you get forwarded to your root path
      expect(current_path).to eq posts_path
    end

  end
end
