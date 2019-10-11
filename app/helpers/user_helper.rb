module UserHelper
  def user_role_menu(selected)
    opts = User::ALLOWED_ROLES.map { |r| [t("user.roles.#{r}"), r] }
    options_for_select(opts, selected)
  end
end
