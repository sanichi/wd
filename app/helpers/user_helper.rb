module UserHelper
  def user_role_menu(selected)
    opts = User::ROLES.map { |r| [t("user.roles.#{r}"), r] }
    options_for_select(opts, selected)
  end
end
