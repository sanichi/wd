module UserHelper
  def user_role_menu(selected)
    opts = User::ALLOWED_ROLES.map { |role| [t("user.roles.#{role}"), role] }
    options_for_select(opts, selected)
  end

  def user_roles(user)   = user.roles.map { |role| t("user.roles.#{role}") }.join(", ")
  def otp_required(user) = t("symbol.#{user.otp_required?       ? 'tick' : 'cross'}")
  def otp_active(user)   = t("symbol.#{user.otp_secret.present? ? 'tick' : 'cross'}")

  def handle_menu(selected)
    handles = User.all.pluck(:handle)
    opts = Journal.where(handle: handles).group(:handle).count.to_a.sort_by(&:last).map(&:first).reverse
    opts.unshift [t("any"), "any"]
    opts.push [t("other"), "other"]
    options_for_select(opts, selected)
  end
end
