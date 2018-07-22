require 'spec_helper'

describe 'User tracking', type: :feature do
  it 'records ip address' do
    sign_user_in
    expect(@user.current_sign_in_ip).to_not be nil
  end

  it 'remembers last ip address' do
    sign_user_in
    expect(@user.last_sign_in_ip).to_not be nil
  end

  it 'sets initial sign in count' do
    sign_user_in
    expect(@user.sign_in_count).to eq 1
  end

  it 'increments sign in count for subsequent logins' do
    sign_user_in
    sign_user_out
    expect{ do_sign_in_screen }.to change {@user.sign_in_count}.by 1
  end

  it 'sets sign in time' do
    sign_user_in
    expect(@user.last_sign_in_at).to_not be nil
  end

  it 'records sign in time' do
    sign_user_in
    expect(@user.current_sign_in_at).to_not be nil
  end

  it 'records previous sign in time' do
    sign_user_in
    sign_user_out
    do_sign_in_screen
    expect(@user.last_sign_in_at).to_not be nil
    expect(@user.last_sign_in_at).to be < @user.current_sign_in_at
  end
end

def sign_user_in
  @user = User.create!(email: 'example@example.com', password_digest: 'password')
  do_sign_in_screen
end

def do_sign_in_screen
  with_oath_config(track_user: true) do
    visit sign_in_path
    fill_in 'session[email]', with: 'example@example.com'
    fill_in 'session[password]', with: 'password'
    click_button 'go'
  end
end

def sign_user_out
  click_link 'Sign out'
end
