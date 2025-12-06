require 'rails_helper'
require './lib/misc/chess_match_scraper'

RSpec.describe LmsMatchScraper do
  let(:fixture_id) { 1539 }
  let(:agent) { double('Mechanize Agent') }
  let(:scraper) { described_class.new(fixture_id, agent: agent) }

  describe '#scrape' do
    context 'with a valid match page' do
      let(:mock_page) do
        html = <<~HTML
          <html>
            <head><title>Match Details</title></head>
            <body>
              <h1>Civil Service 1 V Wandering Dragons 1</h1>
              <table class="team-match-table">
                <thead>
                  <tr>
                    <th>Board</th>
                    <th>Rating</th>
                    <th>Civil Service 1</th>
                    <th>V</th>
                    <th>Wandering Dragons 1</th>
                    <th>Rating</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td>1</td>
                    <td>1856</td>
                    <td><a href="/player/123">Smith, John</a></td>
                    <td>0-1</td>
                    <td><a href="/player/456">Jones, Alice</a></td>
                    <td>1923</td>
                  </tr>
                  <tr>
                    <td>2</td>
                    <td>1745</td>
                    <td><a href="/player/789">Brown, Bob</a></td>
                    <td>1-0</td>
                    <td><a href="/player/321">Wilson, Eve</a></td>
                    <td>1678</td>
                  </tr>
                  <tr>
                    <td>3</td>
                    <td>1634</td>
                    <td><a href="/player/654">Davis, Charlie</a></td>
                    <td>½-½</td>
                    <td><a href="/player/987">Taylor, Grace</a></td>
                    <td>1612</td>
                  </tr>
                  <tr>
                    <td>4</td>
                    <td>1589</td>
                    <td><a href="/player/111">Miller, David</a></td>
                    <td>0-1</td>
                    <td><a href="/player/222">Anderson, Helen</a></td>
                    <td>1601</td>
                  </tr>
                  <tr>
                    <td>5</td>
                    <td>1523</td>
                    <td><a href="/player/333">Moore, Frank</a></td>
                    <td>½ - ½</td>
                    <td><a href="/player/444">Thomas, Ian</a></td>
                    <td>1534</td>
                  </tr>
                  <tr>
                    <td>6</td>
                    <td>1478</td>
                    <td><a href="/player/555">Jackson, George</a></td>
                    <td>0-1</td>
                    <td><a href="/player/666">White, Jane</a></td>
                    <td>1489</td>
                  </tr>
                  <tr>
                    <td>Total</td>
                    <td></td>
                    <td></td>
                    <td>2 - 4</td>
                    <td></td>
                    <td></td>
                  </tr>
                </tbody>
              </table>
            </body>
          </html>
        HTML
        Nokogiri::HTML(html)
      end

      before do
        allow(agent).to receive(:get).with("#{LmsMatchScraper::BASE_URL}/#{fixture_id}").and_return(mock_page)
      end

      it 'extracts the home team name' do
        result = scraper.scrape
        expect(result[:home_team]).to eq('Civil Service 1')
      end

      it 'extracts the away team name' do
        result = scraper.scrape
        expect(result[:home_team]).to eq('Civil Service 1')
        expect(result[:away_team]).to eq('Wandering Dragons 1')
      end

      it 'extracts all games' do
        result = scraper.scrape
        expect(result[:games].length).to eq(6)
      end

      it 'extracts game details correctly' do
        result = scraper.scrape
        first_game = result[:games].first

        expect(first_game[:board]).to eq(1)
        expect(first_game[:home_player]).to eq('Smith, John')
        expect(first_game[:home_rating]).to eq(1856)
        expect(first_game[:result]).to eq('0-1')
        expect(first_game[:away_player]).to eq('Jones, Alice')
        expect(first_game[:away_rating]).to eq(1923)
      end

      it 'handles player names with links' do
        result = scraper.scrape
        expect(result[:games][1][:home_player]).to eq('Brown, Bob')
        expect(result[:games][1][:away_player]).to eq('Wilson, Eve')
      end

      it 'handles draw results with different spacing' do
        result = scraper.scrape
        expect(result[:games][2][:result]).to eq('½-½')
        expect(result[:games][4][:result]).to eq('½ - ½')
      end

      it 'calculates home score correctly' do
        result = scraper.scrape
        # 1 win (1 point) + 2 draws (1 point) = 2 points
        expect(result[:home_score]).to eq(2.0)
      end

      it 'calculates away score correctly' do
        result = scraper.scrape
        # 3 wins (3 points) + 2 draws (1 point) = 4 points
        expect(result[:away_score]).to eq(4.0)
      end

      it 'stops parsing at the totals row' do
        result = scraper.scrape
        expect(result[:games].length).to eq(6)
        expect(result[:games].none? { |g| g[:board] == 0 }).to be true
      end
    end

    context 'with a match missing ratings' do
      let(:mock_page) do
        html = <<~HTML
          <html>
            <body>
              <h1>Team A v Team B</h1>
              <table class="team-match-table">
                <thead>
                  <tr>
                    <th>Board</th>
                    <th>Rating</th>
                    <th>Team A</th>
                    <th>v</th>
                    <th>Team B</th>
                    <th>Rating</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td>1</td>
                    <td></td>
                    <td>Player A</td>
                    <td>1-0</td>
                    <td>Player B</td>
                    <td>1500</td>
                  </tr>
                </tbody>
              </table>
            </body>
          </html>
        HTML
        Nokogiri::HTML(html)
      end

      before do
        allow(agent).to receive(:get).and_return(mock_page)
      end

      it 'handles missing ratings as nil' do
        result = scraper.scrape
        expect(result[:games].first[:home_rating]).to be_nil
        expect(result[:games].first[:away_rating]).to eq(1500)
      end
    end

    context 'with player names without links' do
      let(:mock_page) do
        html = <<~HTML
          <html>
            <body>
              <h1>Team A V Team B</h1>
              <table class="team-match-table">
                <thead>
                  <tr>
                    <th>Board</th>
                    <th>Rating</th>
                    <th>Team A</th>
                    <th>V</th>
                    <th>Team B</th>
                    <th>Rating</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td>1</td>
                    <td>1600</td>
                    <td>Plain Name</td>
                    <td>½-½</td>
                    <td>Another Name</td>
                    <td>1650</td>
                  </tr>
                </tbody>
              </table>
            </body>
          </html>
        HTML
        Nokogiri::HTML(html)
      end

      before do
        allow(agent).to receive(:get).and_return(mock_page)
      end

      it 'extracts player names correctly' do
        result = scraper.scrape
        expect(result[:games].first[:home_player]).to eq('Plain Name')
        expect(result[:games].first[:away_player]).to eq('Another Name')
      end
    end

    context 'with default/forfeit games' do
      let(:mock_page) do
        html = <<~HTML
          <html>
            <body>
              <h1>Team A V Team B</h1>
              <table class="team-match-table">
                <thead>
                  <tr>
                    <th>Board</th>
                    <th>Rating</th>
                    <th>Team A</th>
                    <th>V</th>
                    <th>Team B</th>
                    <th>Rating</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td>1</td>
                    <td>1600</td>
                    <td>Player A</td>
                    <td>1-0</td>
                    <td>Player B</td>
                    <td>1650</td>
                  </tr>
                  <tr>
                    <td>2</td>
                    <td>1500</td>
                    <td>Player C</td>
                    <td>1-0</td>
                    <td></td>
                    <td></td>
                  </tr>
                  <tr>
                    <td>3</td>
                    <td></td>
                    <td></td>
                    <td>0-1</td>
                    <td>Player D</td>
                    <td>1700</td>
                  </tr>
                </tbody>
              </table>
            </body>
          </html>
        HTML
        Nokogiri::HTML(html)
      end

      before do
        allow(agent).to receive(:get).and_return(mock_page)
      end

      it 'handles missing players (defaults/forfeits) correctly' do
        result = scraper.scrape
        expect(result[:games].length).to eq(3)
        expect(result[:games][1][:away_player]).to eq('')
        expect(result[:games][2][:home_player]).to eq('')
        expect(result[:home_score]).to eq(2.0)
        expect(result[:away_score]).to eq(1.0)
      end
    end

    context 'with default wins marked with (def)' do
      let(:mock_page) do
        html = <<~HTML
          <html>
            <body>
              <h1>Bank of Scotland 3 V Edinburgh 7</h1>
              <table class="team-match-table">
                <thead>
                  <tr>
                    <th>Board</th>
                    <th>Rating</th>
                    <th>Bank of Scotland 3</th>
                    <th>V</th>
                    <th>Edinburgh 7</th>
                    <th>Rating</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td>1</td>
                    <td>1300</td>
                    <td>Ferrie, Louis C</td>
                    <td>1 - 0</td>
                    <td>Loumgair, Sue</td>
                    <td>807</td>
                  </tr>
                  <tr>
                    <td>2</td>
                    <td>1212</td>
                    <td>Williamson, Kevin</td>
                    <td>1 - 0</td>
                    <td>Kerr, Gerard</td>
                    <td>000</td>
                  </tr>
                  <tr>
                    <td>3</td>
                    <td>000</td>
                    <td>Ippoliti, Federico</td>
                    <td>1 - 0(def)</td>
                    <td>Default</td>
                    <td>000</td>
                  </tr>
                  <tr>
                    <td>4</td>
                    <td>1008</td>
                    <td>Craigmile, Neil</td>
                    <td>1 - 0(def)</td>
                    <td>Default</td>
                    <td>000</td>
                  </tr>
                  <tr>
                    <td>5</td>
                    <td>000</td>
                    <td>Default</td>
                    <td>0 - 1(def)</td>
                    <td>Smith, John</td>
                    <td>1500</td>
                  </tr>
                </tbody>
              </table>
            </body>
          </html>
        HTML
        Nokogiri::HTML(html)
      end

      before do
        allow(agent).to receive(:get).and_return(mock_page)
      end

      it 'handles default wins with (def) notation' do
        result = scraper.scrape
        expect(result[:games].length).to eq(5)
        expect(result[:games][2][:away_player]).to eq('Default')
        expect(result[:games][2][:result]).to eq('1 * 0')
        expect(result[:games][4][:home_player]).to eq('Default')
        expect(result[:games][4][:result]).to eq('0 * 1')
      end

      it 'calculates scores correctly with default wins' do
        result = scraper.scrape
        # Home: 3 wins (1-0) + 1 default win (1 * 0) - 1 default loss (0 * 1) = 4-1
        expect(result[:home_score]).to eq(4.0)
        expect(result[:away_score]).to eq(1.0)
      end

      it 'handles ratings of 000 as nil' do
        result = scraper.scrape
        expect(result[:games][2][:home_rating]).to be_nil
        expect(result[:games][2][:away_rating]).to be_nil
      end
    end

    context 'with default draws marked with (def)' do
      let(:mock_page) do
        html = <<~HTML
          <html>
            <body>
              <h1>Team X V Team Y</h1>
              <table class="team-match-table">
                <thead>
                  <tr>
                    <th>Board</th>
                    <th>Rating</th>
                    <th>Team X</th>
                    <th>V</th>
                    <th>Team Y</th>
                    <th>Rating</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td>1</td>
                    <td>1500</td>
                    <td>Player A</td>
                    <td>½ - ½(def)</td>
                    <td>Player B</td>
                    <td>1550</td>
                  </tr>
                  <tr>
                    <td>2</td>
                    <td>1400</td>
                    <td>Player C</td>
                    <td>1 - 0</td>
                    <td>Player D</td>
                    <td>1450</td>
                  </tr>
                </tbody>
              </table>
            </body>
          </html>
        HTML
        Nokogiri::HTML(html)
      end

      before do
        allow(agent).to receive(:get).and_return(mock_page)
      end

      it 'converts default draws from ½ - ½(def) to ½ * ½' do
        result = scraper.scrape
        expect(result[:games][0][:result]).to eq('½ * ½')
      end

      it 'calculates scores correctly with default draws' do
        result = scraper.scrape
        expect(result[:home_score]).to eq(1.5)
        expect(result[:away_score]).to eq(0.5)
      end
    end

    context 'error handling' do
      context 'when match has not been played' do
        let(:mock_page) do
          html = <<~HTML
            <html>
              <body>
                <h1>Team A V Team B</h1>
                <table class="team-match-table">
                  <thead>
                    <tr>
                      <th>Board</th>
                      <th>Rating</th>
                      <th>Team A</th>
                      <th>V</th>
                      <th>Team B</th>
                      <th>Rating</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr>
                      <td>1</td>
                      <td>1500</td>
                      <td>Player A</td>
                      <td>N</td>
                      <td>Player B</td>
                      <td>1600</td>
                    </tr>
                    <tr>
                      <td>2</td>
                      <td>1400</td>
                      <td>Player C</td>
                      <td>N</td>
                      <td>Player D</td>
                      <td>1550</td>
                    </tr>
                  </tbody>
                </table>
              </body>
            </html>
          HTML
          Nokogiri::HTML(html)
        end

        before do
          allow(agent).to receive(:get).and_return(mock_page)
        end

        it 'raises MatchNotPlayedError when all results are N' do
          expect { scraper.scrape }.to raise_error(ChessMatchScraper::MatchNotPlayedError, /has not been played yet/)
        end
      end

      context 'when network error occurs' do
        before do
          allow(agent).to receive(:get).and_raise(SocketError.new('Connection failed'))
        end

        it 'raises NetworkError' do
          expect { scraper.scrape }.to raise_error(ChessMatchScraper::NetworkError, /Failed to fetch/)
        end
      end

      context 'when match table is not found' do
        let(:mock_page) do
          html = '<html><body><p>No match data</p></body></html>'
          Nokogiri::HTML(html)
        end

        before do
          allow(agent).to receive(:get).and_return(mock_page)
        end

        it 'raises ParseError' do
          expect { scraper.scrape }.to raise_error(ChessMatchScraper::ParseError, /Match table not found/)
        end
      end

      context 'when table has no rows' do
        let(:mock_page) do
          html = <<~HTML
            <html>
              <body>
                <table class="team-match-table">
                  <tbody></tbody>
                </table>
              </body>
            </html>
          HTML
          Nokogiri::HTML(html)
        end

        before do
          allow(agent).to receive(:get).and_return(mock_page)
        end

        it 'raises ParseError' do
          expect { scraper.scrape }.to raise_error(ChessMatchScraper::ParseError, /No match data found/)
        end
      end
    end

    context 'with different result formats' do
      let(:mock_page) do
        html = <<~HTML
          <html>
            <body>
              <h1>Team X V Team Y</h1>
              <table class="team-match-table">
                <thead>
                  <tr>
                    <th>Board</th>
                    <th>Rating</th>
                    <th>Team X</th>
                    <th>V</th>
                    <th>Team Y</th>
                    <th>Rating</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td>1</td>
                    <td>1700</td>
                    <td>Player 1</td>
                    <td>1-0</td>
                    <td>Player 2</td>
                    <td>1700</td>
                  </tr>
                  <tr>
                    <td>2</td>
                    <td>1700</td>
                    <td>Player 3</td>
                    <td>0.5-0.5</td>
                    <td>Player 4</td>
                    <td>1700</td>
                  </tr>
                </tbody>
              </table>
            </body>
          </html>
        HTML
        Nokogiri::HTML(html)
      end

      before do
        allow(agent).to receive(:get).and_return(mock_page)
      end

      it 'calculates score with alternate draw format' do
        result = scraper.scrape
        expect(result[:home_score]).to eq(1.5)
        expect(result[:away_score]).to eq(0.5)
      end
    end
  end
end

RSpec.describe SnclMatchScraper do
  let(:url_fragment) { 's1.chess-results.com/tnr1280922.aspx?lan=1&art=3&rd=1&Snode=S0' }
  let(:agent) { double('Mechanize Agent') }
  let(:scraper) { described_class.new(url_fragment, agent: agent) }

  describe '#initialize' do
    it 'parses and builds the complete URL' do
      expect(scraper.url).to eq('https://s1.chess-results.com/tnr1280922.aspx?lan=1&art=3&rd=1&Snode=S0')
    end

    it 'handles URLs without server (defaults to s1)' do
      fragment = 'chess-results.com/tnr1280922.aspx?lan=1&art=3&rd=1&Snode=S0'
      scraper = SnclMatchScraper.new(fragment, agent: agent)
      expect(scraper.url).to eq('https://s1.chess-results.com/tnr1280922.aspx?lan=1&art=3&rd=1&Snode=S0')
    end

    it 'handles URLs without lan parameter (defaults to 1)' do
      fragment = 's3.chess-results.com/tnr1280922.aspx?art=3&rd=2&Snode=S0'
      scraper = SnclMatchScraper.new(fragment, agent: agent)
      expect(scraper.url).to eq('https://s3.chess-results.com/tnr1280922.aspx?lan=1&art=3&rd=2&Snode=S0')
    end

    it 'handles URLs without Snode parameter (defaults to S0)' do
      fragment = 's1.chess-results.com/tnr1280922.aspx?lan=1&art=3&rd=1'
      scraper = SnclMatchScraper.new(fragment, agent: agent)
      expect(scraper.url).to eq('https://s1.chess-results.com/tnr1280922.aspx?lan=1&art=3&rd=1&Snode=S0')
    end

    it 'raises error when tournament ID is missing' do
      fragment = 's1.chess-results.com/something.aspx?lan=1&art=3&rd=1'
      expect { SnclMatchScraper.new(fragment, agent: agent) }.to raise_error(ChessMatchScraper::ParseError, /Tournament ID not found/)
    end

    it 'raises error when art parameter is missing' do
      fragment = 's1.chess-results.com/tnr1280922.aspx?lan=1&rd=1'
      expect { SnclMatchScraper.new(fragment, agent: agent) }.to raise_error(ChessMatchScraper::ParseError, /art parameter not found/)
    end

    it 'raises error when rd parameter is missing' do
      fragment = 's1.chess-results.com/tnr1280922.aspx?lan=1&art=3'
      expect { SnclMatchScraper.new(fragment, agent: agent) }.to raise_error(ChessMatchScraper::ParseError, /rd parameter not found/)
    end
  end

  describe '#scrape' do
    context 'with Wandering Dragons as home team' do
      let(:mock_page) do
        html = <<~HTML
          <html>
            <body>
              <table>
                <tr class="CRg1b">
                  <th class="CRc">Bo.</th>
                  <th class="CRc">3</th>
                  <th class="CR">Wandering Dragons</th>
                  <th class="CRr">Rtg</th>
                  <th class="CRc">-</th>
                  <th class="CRc">1</th>
                  <th class="CR">Dundee City A</th>
                  <th class="CRr">Rtg</th>
                  <th class="CRc">3 : 2</th>
                </tr>
                <tr class="CRg2">
                  <td class="CRc">5.1</td>
                  <td></td>
                  <td class="CR"><a href="/player1">Leah, Tom</a></td>
                  <td class="CRr">2054</td>
                  <td class="CRc">-</td>
                  <td class="CRc">CM</td>
                  <td class="CR"><a href="/player2">Ophoff, Jacques</a></td>
                  <td class="CRr">2264</td>
                  <td class="CRc">1 - 0</td>
                </tr>
                <tr class="CRg1">
                  <td class="CRc">5.2</td>
                  <td></td>
                  <td class="CR"><a href="/player3">Minnican, Alan W</a></td>
                  <td class="CRr">2042</td>
                  <td class="CRc">-</td>
                  <td></td>
                  <td class="CR"><a href="/player4">Wright, Andrew G</a></td>
                  <td class="CRr">2124</td>
                  <td class="CRc">½ - ½</td>
                </tr>
                <tr class="CRg2">
                  <td class="CRc">5.3</td>
                  <td></td>
                  <td class="CR"><a href="/player5">Sloan, Elliot S</a></td>
                  <td class="CRr">1955</td>
                  <td class="CRc">-</td>
                  <td></td>
                  <td class="CR"><a href="/player6">Vayanos, George</a></td>
                  <td class="CRr">2095</td>
                  <td class="CRc">0 - 1</td>
                </tr>
                <tr class="CRg1">
                  <td class="CRc">5.4</td>
                  <td></td>
                  <td class="CR"><a href="/player7">Burnett, Walter</a></td>
                  <td class="CRr">1900</td>
                  <td class="CRc">-</td>
                  <td></td>
                  <td class="CR"><a href="/player8">Findlay, David J</a></td>
                  <td class="CRr">2110</td>
                  <td class="CRc">½ - ½</td>
                </tr>
                <tr class="CRg2">
                  <td class="CRc">5.5</td>
                  <td></td>
                  <td class="CR"><a href="/player9">Fleming, Neil</a></td>
                  <td class="CRr">1856</td>
                  <td class="CRc">-</td>
                  <td></td>
                  <td class="CR"><a href="/player10">Spencer, Edwin A</a></td>
                  <td class="CRr">2110</td>
                  <td class="CRc">1 - 0</td>
                </tr>
              </table>
            </body>
          </html>
        HTML
        Nokogiri::HTML(html)
      end

      before do
        allow(agent).to receive(:get).and_return(mock_page)
      end

      it 'extracts team names correctly' do
        result = scraper.scrape
        expect(result[:home_team]).to eq('Wandering Dragons')
        expect(result[:away_team]).to eq('Dundee City A')
      end

      it 'extracts all 5 games' do
        result = scraper.scrape
        expect(result[:games].length).to eq(5)
      end

      it 'extracts game details correctly' do
        result = scraper.scrape
        first_game = result[:games].first

        expect(first_game[:board]).to eq(1)
        expect(first_game[:home_player]).to eq('Leah, Tom')
        expect(first_game[:home_rating]).to eq('2054')
        expect(first_game[:result]).to eq('1 - 0')
        expect(first_game[:away_player]).to eq('Ophoff, Jacques')
        expect(first_game[:away_rating]).to eq('2264 CM')
      end

      it 'appends titles to ratings' do
        result = scraper.scrape
        expect(result[:games][0][:away_rating]).to eq('2264 CM')
        expect(result[:games][1][:away_rating]).to eq('2124')  # No title
      end

      it 'calculates scores correctly' do
        result = scraper.scrape
        expect(result[:home_score]).to eq(3.0)
        expect(result[:away_score]).to eq(2.0)
      end
    end

    context 'with Wandering Dragons as away team' do
      let(:mock_page) do
        html = <<~HTML
          <html>
            <body>
              <table>
                <tr class="CRg1b">
                  <th class="CRc">Bo.</th>
                  <th class="CRc">2</th>
                  <th class="CR">Hamilton A</th>
                  <th class="CRr">Rtg</th>
                  <th class="CRc">-</th>
                  <th class="CRc">3</th>
                  <th class="CR">Wandering Dragons</th>
                  <th class="CRr">Rtg</th>
                  <th class="CRc">3½ : 1½</th>
                </tr>
                <tr class="CRg2">
                  <td class="CRc">1.1</td>
                  <td class="CRc">IM</td>
                  <td class="CR"><a href="/p1">Hamilton Player 1</a></td>
                  <td class="CRr">2200</td>
                  <td class="CRc">-</td>
                  <td></td>
                  <td class="CR"><a href="/p2">Dragon Player 1</a></td>
                  <td class="CRr">2100</td>
                  <td class="CRc">1 - 0</td>
                </tr>
                <tr class="CRg1">
                  <td class="CRc">1.2</td>
                  <td></td>
                  <td class="CR"><a href="/p3">Hamilton Player 2</a></td>
                  <td class="CRr">2150</td>
                  <td class="CRc">-</td>
                  <td class="CRc">FM</td>
                  <td class="CR"><a href="/p4">Dragon Player 2</a></td>
                  <td class="CRr">2050</td>
                  <td class="CRc">½ - ½</td>
                </tr>
                <tr class="CRg2">
                  <td class="CRc">1.3</td>
                  <td></td>
                  <td class="CR"><a href="/p5">Hamilton Player 3</a></td>
                  <td class="CRr">2100</td>
                  <td class="CRc">-</td>
                  <td></td>
                  <td class="CR"><a href="/p6">Dragon Player 3</a></td>
                  <td class="CRr">2000</td>
                  <td class="CRc">1 - 0</td>
                </tr>
                <tr class="CRg1">
                  <td class="CRc">1.4</td>
                  <td></td>
                  <td class="CR"><a href="/p7">Hamilton Player 4</a></td>
                  <td class="CRr">2050</td>
                  <td class="CRc">-</td>
                  <td></td>
                  <td class="CR"><a href="/p8">Dragon Player 4</a></td>
                  <td class="CRr">1950</td>
                  <td class="CRc">0 - 1</td>
                </tr>
                <tr class="CRg2">
                  <td class="CRc">1.5</td>
                  <td></td>
                  <td class="CR"><a href="/p9">Hamilton Player 5</a></td>
                  <td class="CRr">2000</td>
                  <td class="CRc">-</td>
                  <td></td>
                  <td class="CR"><a href="/p10">Dragon Player 5</a></td>
                  <td class="CRr">1900</td>
                  <td class="CRc">1 - 0</td>
                </tr>
              </table>
            </body>
          </html>
        HTML
        Nokogiri::HTML(html)
      end

      before do
        allow(agent).to receive(:get).and_return(mock_page)
      end

      it 'finds Wandering Dragons when they are the away team' do
        result = scraper.scrape
        expect(result[:home_team]).to eq('Hamilton A')
        expect(result[:away_team]).to eq('Wandering Dragons')
      end

      it 'appends home player titles correctly' do
        result = scraper.scrape
        expect(result[:games][0][:home_rating]).to eq('2200 IM')
        expect(result[:games][1][:home_rating]).to eq('2150')
      end

      it 'appends away player titles correctly' do
        result = scraper.scrape
        expect(result[:games][1][:away_rating]).to eq('2050 FM')
      end

      it 'calculates scores correctly' do
        result = scraper.scrape
        expect(result[:home_score]).to eq(3.5)
        expect(result[:away_score]).to eq(1.5)
      end
    end

    context 'with default notation (+ - - and - - +)' do
      let(:mock_page) do
        html = <<~HTML
          <html>
            <body>
              <table>
                <tr class="CRg1b">
                  <th class="CRc">Bo.</th>
                  <th class="CRc">1</th>
                  <th class="CR">Wandering Dragons A</th>
                  <th class="CRr">Rtg</th>
                  <th class="CRc">-</th>
                  <th class="CRc">2</th>
                  <th class="CR">Test Team</th>
                  <th class="CRr">Rtg</th>
                  <th class="CRc">3 : 2</th>
                </tr>
                <tr class="CRg2">
                  <td class="CRc">1.1</td>
                  <td></td>
                  <td class="CR">Player A</td>
                  <td class="CRr">2000</td>
                  <td class="CRc">-</td>
                  <td></td>
                  <td class="CR">Player B</td>
                  <td class="CRr">1950</td>
                  <td class="CRc">+ - -</td>
                </tr>
                <tr class="CRg1">
                  <td class="CRc">1.2</td>
                  <td></td>
                  <td class="CR">Player C</td>
                  <td class="CRr">1900</td>
                  <td class="CRc">-</td>
                  <td></td>
                  <td class="CR">Player D</td>
                  <td class="CRr">1850</td>
                  <td class="CRc">- - +</td>
                </tr>
                <tr class="CRg2">
                  <td class="CRc">1.3</td>
                  <td></td>
                  <td class="CR">Player E</td>
                  <td class="CRr">1800</td>
                  <td class="CRc">-</td>
                  <td></td>
                  <td class="CR">Player F</td>
                  <td class="CRr">1750</td>
                  <td class="CRc">1 - 0</td>
                </tr>
                <tr class="CRg1">
                  <td class="CRc">1.4</td>
                  <td></td>
                  <td class="CR">Player G</td>
                  <td class="CRr">1700</td>
                  <td class="CRc">-</td>
                  <td></td>
                  <td class="CR">Player H</td>
                  <td class="CRr">1650</td>
                  <td class="CRc">1 - 0</td>
                </tr>
                <tr class="CRg2">
                  <td class="CRc">1.5</td>
                  <td></td>
                  <td class="CR">Player I</td>
                  <td class="CRr">1600</td>
                  <td class="CRc">-</td>
                  <td></td>
                  <td class="CR">Player J</td>
                  <td class="CRr">1550</td>
                  <td class="CRc">0 - 1</td>
                </tr>
              </table>
            </body>
          </html>
        HTML
        Nokogiri::HTML(html)
      end

      before do
        allow(agent).to receive(:get).and_return(mock_page)
      end

      it 'converts + - - to 1 * 0 (home default win)' do
        result = scraper.scrape
        expect(result[:games][0][:result]).to eq('1 * 0')
      end

      it 'converts - - + to 0 * 1 (away default win)' do
        result = scraper.scrape
        expect(result[:games][1][:result]).to eq('0 * 1')
      end

      it 'calculates scores correctly with default results' do
        result = scraper.scrape
        # Home: 1 default win + 2 normal wins = 3
        # Away: 1 default win + 1 normal win = 2
        expect(result[:home_score]).to eq(3.0)
        expect(result[:away_score]).to eq(2.0)
      end
    end

    context 'with player names without links (>5 days old)' do
      let(:mock_page) do
        html = <<~HTML
          <html>
            <body>
              <table>
                <tr class="CRg1b">
                  <th class="CRc">Bo.</th>
                  <th class="CRc">1</th>
                  <th class="CR">Wandering Dragons</th>
                  <th class="CRr">Rtg</th>
                  <th class="CRc">-</th>
                  <th class="CRc">2</th>
                  <th class="CR">Old Team</th>
                  <th class="CRr">Rtg</th>
                  <th class="CRc">2½ : 2½</th>
                </tr>
                <tr class="CRg2">
                  <td class="CRc">1.1</td>
                  <td></td>
                  <td class="CR">Plain Name One</td>
                  <td class="CRr">1800</td>
                  <td class="CRc">-</td>
                  <td></td>
                  <td class="CR">Plain Name Two</td>
                  <td class="CRr">1750</td>
                  <td class="CRc">½ - ½</td>
                </tr>
                <tr class="CRg1">
                  <td class="CRc">1.2</td>
                  <td></td>
                  <td class="CR">Plain Name Three</td>
                  <td class="CRr">1700</td>
                  <td class="CRc">-</td>
                  <td></td>
                  <td class="CR">Plain Name Four</td>
                  <td class="CRr">1650</td>
                  <td class="CRc">1 - 0</td>
                </tr>
                <tr class="CRg2">
                  <td class="CRc">1.3</td>
                  <td></td>
                  <td class="CR">Plain Name Five</td>
                  <td class="CRr">1600</td>
                  <td class="CRc">-</td>
                  <td></td>
                  <td class="CR">Plain Name Six</td>
                  <td class="CRr">1550</td>
                  <td class="CRc">0 - 1</td>
                </tr>
                <tr class="CRg1">
                  <td class="CRc">1.4</td>
                  <td></td>
                  <td class="CR">Plain Name Seven</td>
                  <td class="CRr">1500</td>
                  <td class="CRc">-</td>
                  <td></td>
                  <td class="CR">Plain Name Eight</td>
                  <td class="CRr">1450</td>
                  <td class="CRc">½ - ½</td>
                </tr>
                <tr class="CRg2">
                  <td class="CRc">1.5</td>
                  <td></td>
                  <td class="CR">Plain Name Nine</td>
                  <td class="CRr">1400</td>
                  <td class="CRc">-</td>
                  <td></td>
                  <td class="CR">Plain Name Ten</td>
                  <td class="CRr">1350</td>
                  <td class="CRc">1 - 0</td>
                </tr>
              </table>
            </body>
          </html>
        HTML
        Nokogiri::HTML(html)
      end

      before do
        allow(agent).to receive(:get).and_return(mock_page)
      end

      it 'extracts plain text player names correctly' do
        result = scraper.scrape
        expect(result[:games][0][:home_player]).to eq('Plain Name One')
        expect(result[:games][0][:away_player]).to eq('Plain Name Two')
        expect(result[:games][1][:home_player]).to eq('Plain Name Three')
      end

      it 'calculates scores correctly' do
        result = scraper.scrape
        # Home: 0.5 + 1 + 0 + 0.5 + 1 = 3.0
        # Away: 0.5 + 0 + 1 + 0.5 + 0 = 2.0
        expect(result[:home_score]).to eq(3.0)
        expect(result[:away_score]).to eq(2.0)
      end
    end

    context 'error handling' do
      context 'when Wandering Dragons team is not found' do
        let(:mock_page) do
          html = <<~HTML
            <html>
              <body>
                <table>
                  <tr class="CRg1b">
                    <th class="CRc">Bo.</th>
                    <th class="CRc">1</th>
                    <th class="CR">Some Team</th>
                    <th class="CRr">Rtg</th>
                    <th class="CRc">-</th>
                    <th class="CRc">2</th>
                    <th class="CR">Another Team</th>
                    <th class="CRr">Rtg</th>
                    <th class="CRc">3 : 2</th>
                  </tr>
                </table>
              </body>
            </html>
          HTML
          Nokogiri::HTML(html)
        end

        before do
          allow(agent).to receive(:get).and_return(mock_page)
        end

        it 'raises ParseError with helpful message' do
          expect { scraper.scrape }.to raise_error(
            ChessMatchScraper::ParseError,
            /Team 'Wandering Dragons' not found on page - please check the URL is correct/
          )
        end
      end

      context 'when network error occurs' do
        before do
          allow(agent).to receive(:get).and_raise(SocketError.new('Connection failed'))
        end

        it 'raises NetworkError' do
          expect { scraper.scrape }.to raise_error(ChessMatchScraper::NetworkError, /Failed to fetch/)
        end
      end
    end
  end
end
