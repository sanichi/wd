class PgnGame
  attr_reader :game

  def initialize(pgn)
    begin
      @game = PGN.parse(pgn).first
    rescue Whittle::ParseError => e
      logger.error "PGN parse error (#{e.message})"
    rescue StandardError => e
      logger.error "PGN error (#{e.message})"
    end
  end

  def self.clean(pgn)
    pgn = pgn.dup
    return pgn if pgn.blank?
    pgn.gsub!(/\r\n/, "\n")                      # convert line  endings
    pgn.gsub!(/\r/, "\n")                        # convert line  endings
    pgn.sub!(/\A[\n\s]+/, "")                    # remove leading space
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
      number = position.fullmove
      player = position.player == :white ? "w" : "b"
      label = "#{number}.#{player == 'w' ? '' : '..'}" if show_label
      show_label = player == 'b'
      notation = move.notation
      annotation = decode(move.annotation)
      comment = comment(move.comment)
      sep = player == 'b' ? "\n" : " "
      %Q{%s<span class="move game_%d" data-move="%d_%d_%s">%s%s</span>%s%s} %
        [label, id, id, number, player, notation, annotation, comment, sep]
    end.join("")
    ("\n" + html.rstrip + "\n").html_safe
  end

  private

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

  def comment(text)
    return nil if text.blank?
    raw_comment = text.squish.sub(/\A\{\s*/, "").sub(/\s*\}\z/, "")
    safe_comment = Loofah.fragment(raw_comment).scrub!(:prune).to_s
    %Q[ <span class="comment">{ #{safe_comment} }</span>]
  end
end