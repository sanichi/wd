module Pageable
  extend ActiveSupport::Concern

  module ClassMethods
    def paginate(matches, params, path, opt={})
      count = matches.count
      page = params[:page].to_i > 0 ? params[:page].to_i : 1
      per_page = opt[:per_page].to_i
      per_page = 10 if per_page == 0
      page = 1 + count / per_page if page > 1 && (page - 1) * per_page >= count
      if matches.respond_to?(:limit)
        matches = matches.offset(per_page * (page - 1)) if page > 1
        matches = matches.limit(per_page)
      else
        matches = matches[per_page * (page - 1), per_page]
      end
      Pager.new(matches, params, path, per_page, page, count, opt[:extra])
    end
  end

  class Pager
    attr_reader :matches, :count, :extra

    def initialize(matches, params, path, per_page, page, count, extra)
      @matches  = matches
      @params   = params.reject{ |key,val| %w[action controller button utf8].include?(key) }
      @path     = path
      @per_page = per_page
      @page     = page
      @count    = count
      @extra    = extra
    end

    def multi_page?
      @count > @per_page
    end

    def before_end?
      @page * @per_page < @count
    end

    def after_start?
      @page > 1
    end

    def frst_page
      page_path(page: 1)
    end

    def next_page
      page_path(page: @page + 1)
    end

    def prev_page
      page_path(page: @page - 1)
    end

    def last_page
      page_path(page: 1 + (@count > 0 ? (@count - 1) / @per_page : 0))
    end

    def min_and_max
      min = 1 + @per_page * (@page - 1)
      max = @per_page * @page
      max = @count if @count < max
      min == max ? min.to_s : "#{min}-#{max}"
    end

    def id_list
      return "" if @matches.empty?
      ids = @matches.map(&:id)
      ids.push    "page" if before_end?
      ids.unshift "page" if after_start?
      "_" + ids.join("_") + "_"
    end

    def page_path(opts={})
      @path + "?" + merge_params(opts)
    end

    private

    def merge_params(opts)
      params = @params.merge(opts)
      params[:page] ||= @page
      params.to_unsafe_h.to_query
    end
  end
end
