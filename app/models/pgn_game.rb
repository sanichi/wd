class PgnGame
  attr_reader :game

  def initialize(pgn)
    begin
      @game = PGN.parse(pgn).first
    rescue Whittle::ParseError => e
      Rails.logger.error "PGN parse error (#{e.message})"
    rescue StandardError => e
      Rails.logger.error "PGN error (#{e.message})"
    end
  end

  def self.clean(pgn)
    pgn = pgn.dup
    return pgn if pgn.blank?
    pgn.gsub!(/\r\n/, "\n")                      # convert line  endings
    pgn.gsub!(/\r/, "\n")                        # convert line  endings
    pgn.sub!(/\A[\n\s]+/, "")                    # remove leading space
    pgn.gsub!(/\s*\{\[[^\]\}]*\]\}\s*/, " ")     # remove time stamps
    pgn.gsub!(/\][\n\s]*\[/, "]\n[")             # headers always start a new line
    pgn.sub!(/\][\n\s]*([^\[\n\s])/, "]\n\n\\1") # two new lines between last header and moves
    pgn.sub!(/[\n\s]{2,}\[.*\z/m, "\n")          # remove any games after the first
    pgn.sub!(/[\n\s]+\z/, "\n")                  # remove trailing space
    pgn
  end

  def okay?
    !@game.nil?
  end

  def html(id)
    return unless okay?
    moves = @game.moves
    positions= @game.positions
    show_label = true
    html = moves.each_with_index.map do |move, i|
      position = positions[i]
      white = position.player == :white
      number = position.fullmove
      label = "#{number}.#{white ? '' : '..'}" if show_label
      notation = move.notation
      annotation = decode(move.annotation)
      comment = comment(move.comment, span: true)
      variations = variations(move, number, white)
      show_label = !white || comment || variations
      sep = white ? " " : "\n"
      %Q{%s<span class="move" data-i="%d">%s%s</span>%s%s%s} %
        [label, i + 1, notation, annotation, comment, variations, sep]
    end.join("")
    ("\n" + html.rstrip + "\n" + result + "\n").html_safe
  end

  private

  def variations(move, number, white)
    return unless check?(move.variations)
    %Q[ <span class="comment">#{reduce(move.variations, number, white, start: true)}</span>]
  end

  def reduce(variations, number, white, start: false)
    move = variations[0].pop
    variations.shift if move.nil?
    finish = variations.empty?
    parts = []
    parts.push start ? "( " : ""
    parts.push move ? text(move, number, white, start || white) : (finish ? "" : "; ")
    parts.push finish ? ") " : reduce(variations, number + (white ? 0 : 1), !white)
    parts.join("")
  end

  def text(move, number, white, show_label)
    label = show_label ? "#{number}#{white ? '.' : '...'}" : ''
    notation = move.notation
    annotation = decode(move.annotation)
    comment = comment(move.comment)
    "#{label}#{notation}#{annotation}#{comment} "
  end

  def decode(nag)
    case nag
    when nil then nil
    when "" then nil
    when "$1"  then "!"
    when "$2"  then "?"
    when "$3"  then "‼"
    when "$4"  then "⁇"
    when "$5"  then "⁉"
    when "$6"  then "⁈"
    when "$7"  then "□"
    when "$10" then "="
    when "$13" then "∞"
    when "$14" then "⩲"
    when "$15" then "⩱"
    when "$16" then "±"
    when "$17" then "∓"
    when "$18" then "+−"
    when "$19" then "−+"
    else nag
    end
  end

  def comment(text, span: false)
    return nil if text.blank?
    raw_comment = text.squish.sub(/\A\{\s*/, "").sub(/\s*\}\z/, "")
    safe_comment = Loofah.fragment(raw_comment).scrub!(:prune).to_s
    if span
      %Q[ <span class="comment">{ #{safe_comment} }</span>]
    else
      " " + safe_comment
    end
  end

  def result
    val = @game.result
    val = "½-½" if val == "1/2-1/2"
    val
  end

  def check?(variations)
    return false unless variations.is_a?(Array)
    return false if variations.empty?
    variations.each do |variation|
      return false unless variation.is_a?(Array)
      variation.each { |m| return false unless m.is_a?(PGN::MoveText) }
    end
    return true
  end
end
