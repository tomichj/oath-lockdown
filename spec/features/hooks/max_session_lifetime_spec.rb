require 'spec_helper'

describe 'User signs in', type: :feature do
  context 'with max session lifetime' do
    before do
      User.create!(email: 'example@example.com', password_digest: 'password')
    end

    it 'logs out user when lifetime exceeded' do
      with_oath_config(max_session_lifetime: 60.minutes) do
        visit sign_in_path
        fill_in 'session[email]', with: 'example@example.com'
        fill_in 'session[password]', with: 'password'
        click_button 'go'

        Timecop.travel(Time.current + 61.minutes)

        visit posts_path
        expect(current_path).to eq sign_in_path
      end
    end

    it 'permits user with lifetime not exceeded' do
      with_oath_config(max_session_lifetime: 60.minutes) do
        visit sign_in_path
        fill_in 'session[email]', with: 'example@example.com'
        fill_in 'session[password]', with: 'password'
        click_button 'go'

        Timecop.travel(Time.current + 50.minutes)

        visit posts_path
        expect(current_path).to eq posts_path
      end
    end
  end
end
