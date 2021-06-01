class Layout
  BP = %w/xs sm md lg xl xx xxl/.map(&:to_sym)

  def initialize(args)
    raise I18n.t("layout.error.input") unless args.is_a?(Hash)
    @bps = BP.each_with_object({}){ |bp, h| h[bp] = args[bp] if args[bp].is_a?(Array) }
    @bps[:xxl] = @bps.delete(:xx) if @bps.has_key?(:xx)
    check!
    @col = @bps.map{ |bp, arrays_or_numbers| @rmg = 0; transform(arrays_or_numbers, bp) }
  end

  def to_a
    (0...@number).map{ |i| @col.map{ |col| col[i] }.join(" ") }
  end

  private

  def check!
    raise I18n.t("layout.error.keys") if @bps.empty?
    @number = nil
    @bps.each_pair do |bp, row_or_cols|
      if row_or_cols.map{|w| w.is_a?(Integer)}.all?
        row = row_or_cols
        raise I18n.t("layout.error.empty") if row.empty?
        raise I18n.t("layout.error.width") unless row.map{|w| w > 0 && w <= 12}.all?
        raise I18n.t("layout.error.total") if row.sum > 12
        if @number
          raise I18n.t("layout.error.number") unless @number == row.length
        else
          @number = row.length
        end
      else
        cols = row_or_cols
        cols.each do |row|
          raise I18n.t("layout.error.row") unless row.is_a?(Array) && !row.empty?
          raise I18n.t("layout.error.width") unless row.map{|w| w.is_a?(Integer) && w > 0 && w <= 12}.all?
          raise I18n.t("layout.error.total") if row.sum > 12
        end
        if @number
          raise I18n.t("layout.error.number") unless @number == cols.map(&:length).sum
        else
          @number = cols.map(&:length).sum
        end
      end
    end
  end

  def transform(arrays_or_numbers, bp)
    if arrays_or_numbers.first.is_a?(Integer)
      transform_numbers(arrays_or_numbers, bp)
    else
      transform_arrays(arrays_or_numbers, bp)
    end
  end

  def transform_numbers(numbers, bp)
    numbers.each_with_index.map do |n, i|
      col = bp == :xs ? "col-#{n}" : "col-#{bp}-#{n}"
      if i == 0
        lmg = ((12 - numbers.sum) / 2.0).ceil
        m = lmg
        m += @rmg unless lmg + n > @rmg
        col += bp == :xs ? " offset-#{m}" : " offset-#{bp}-#{m}"
        @rmg = 12 - n - lmg
      else
        col += bp == :xs ? " offset-0" : " offset-#{bp}-0"
        @rmg -= n
      end
      col
    end
  end

  def transform_arrays(arrays, bp)
    arrays.map{ |numbers| transform_numbers(numbers, bp) }.flatten
  end
end
