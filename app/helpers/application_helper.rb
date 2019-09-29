module ApplicationHelper
  def flash_style(flash_name)
    bootstrap_name =
      case flash_name.to_s
      when "warning" then "warning"
      when "info"    then "info"
      when "alert"   then "danger"
      else "success"
      end
    "alert alert-#{bootstrap_name}"
  end
end
