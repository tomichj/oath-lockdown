require 'spec_helper'

describe 'CSRF rotation', type: :feature do
  around do |example|
    ActionController::Base.allow_forgery_protection = true
    example.run
    ActionController::Base.allow_forgery_protection = false
  end

  context 'user authenticates successfully' do
    before do
      @user = User.create!(email: "example@example.com", password_digest: "password")
    end

    it 'deletes CSRF token' do
      with_oath_config(rotate_csrf_on_sign_in: true) do
        visit sign_in_path
        csrf_token_at_login = csrf_token
        fill_in "session[email]", with: "example@example.com"
        fill_in "session[password]", with: "password"
        click_button "go"

        expect(current_path).to eq posts_path
        expect(csrf_token).to_not eq csrf_token_at_login
      end
    end
  end

  def csrf_token
    page.find('meta[name="csrf-token"]', visible: false)['content']
  end
end
