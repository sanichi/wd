module ApplicationHelper
  def pagination_links(pager)
    links = Array.new
    links.push(link_to t("pagination.frst"), pager.frst_page, remote: pager.remote, id: "pagn_frst") if pager.after_start?
    links.push(link_to t("pagination.next"), pager.next_page, remote: pager.remote, id: "pagn_next") if pager.before_end?
    links.push(link_to t("pagination.prev"), pager.prev_page, remote: pager.remote, id: "pagn_prev") if pager.after_start?
    links.push(link_to t("pagination.last"), pager.last_page, remote: pager.remote, id: "pagn_last") if pager.before_end?
    raw "#{pager.min_and_max} #{t('pagination.of')} #{pager.count} #{links.size > 0 ? '∙' : ''} #{links.join(' ∙ ')}"
  end

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
