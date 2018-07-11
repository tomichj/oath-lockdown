Warden::Manager.after_authentication do |user, warden, options|
  next unless warden.winning_strategy.respond_to?(:clean_up_csrf?)
  next unless warden.authenticated?

  if Oath.config.rotate_csrf_on_sign_in & warden.winning_strategy.clean_up_csrf?
    warden.request.session.try(:delete, :_csrf_token)
  end
end
