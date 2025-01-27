module ApplicationHelper
  def pagination_links(pager)
    links = Array.new
    links.push(link_to t("pagination.frst"), pager.frst_page, id: "pagn_frst") if pager.after_start?
    links.push(link_to t("pagination.next"), pager.next_page, id: "pagn_next") if pager.before_end?
    links.push(link_to t("pagination.prev"), pager.prev_page, id: "pagn_prev") if pager.after_start?
    links.push(link_to t("pagination.last"), pager.last_page, id: "pagn_last") if pager.before_end?
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

  def center(xs: 0, sm: 0, md: 0, lg: 0, xl: 0, xx: 0)
    klass = []
    klass.push "offset-#{(12 - xs) / 2} col-#{xs}"         if xs > 0
    klass.push "offset-sm-#{(12 - sm) / 2} col-sm-#{sm}"   if sm > 0
    klass.push "offset-md-#{(12 - md) / 2} col-md-#{md}"   if md > 0
    klass.push "offset-lg-#{(12 - lg) / 2} col-lg-#{lg}"   if lg > 0
    klass.push "offset-xl-#{(12 - xl) / 2} col-xl-#{xl}"   if xl > 0
    klass.push "offset-xxl-#{(12 - xx) / 2} col-xxl-#{xx}" if xx > 0
    klass.any? ? klass.join(" ") : "col-12"
  end

  def centre(*args)
    nums = args.map(&:to_i).select{ |n| n > 0 && n < 12 }.sort.reverse
    return "col" if nums.empty?
    nums = nums.first(6) if nums.length > 6
    nums.unshift(12) while nums.length < 6
    cols = %w/xs sm md lg xl xxl/
    0.upto(5).map do |i|
      if nums[i] < 12
        if i == 0
          "col-#{nums[i]}"
        else
          "col-#{cols[i]}-#{nums[i]}"
        end
      else
        nil
      end
    end.compact.join(" ")
  end

  def col(s)
    case s
    when true
      "col-12"
    when false, nil
      ""
    else
      s.to_s.gsub(/(\A| )(sx|ms|dm|gl|lx|lxx)-(\d|1[012])/) do
        "#{$1}offset-#{$2 == 'sx' ? '' : $2.reverse + '-'}#{$3}"
      end.gsub(/(\A| )((?:xs|sm|md|lg|xl|xxl)-)?(\d|1[012])/) do
        "#{$1}col-#{$2 == 'xs-' ? '' : $2}#{$3}"
      end
    end
  end

  def last_path(name)
    session["last_#{name}_path"] || "/#{name}"
  end
end
