require 'rails_helper'
require './lib/misc/chess_match_scraper'

RSpec.describe ChessMatchScraper do
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
        allow(agent).to receive(:get).with("#{ChessMatchScraper::BASE_URL}/#{fixture_id}").and_return(mock_page)
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
        expect(result[:games][2][:result]).to eq('1 - 0(def)')
        expect(result[:games][4][:home_player]).to eq('Default')
        expect(result[:games][4][:result]).to eq('0 - 1(def)')
      end

      it 'calculates scores correctly with default wins' do
        result = scraper.scrape
        # Home: 3 wins (1-0) + 1 default win (1-0(def)) - 1 default loss (0-1(def)) = 4-1
        expect(result[:home_score]).to eq(4.0)
        expect(result[:away_score]).to eq(1.0)
      end

      it 'handles ratings of 000 as nil' do
        result = scraper.scrape
        expect(result[:games][2][:home_rating]).to be_nil
        expect(result[:games][2][:away_rating]).to be_nil
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
          expect { scraper.scrape }.to raise_error(ChessMatchScraper::NetworkError, /Failed to fetch fixture/)
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

    context 'live test against real LMS website' do
      it 'successfully scrapes fixture 1539 from the live website' do
        live_scraper = ChessMatchScraper.new(1539)
        result = live_scraper.scrape

        # Verify the structure and data we got when the test was created (2025-12-03)
        expect(result[:home_team]).to eq('Civil Service 1')
        expect(result[:away_team]).to eq('Wandering Dragons 1')
        expect(result[:home_score]).to eq(1.0)
        expect(result[:away_score]).to eq(5.0)
        expect(result[:games].length).to eq(6)

        # Verify the first game to ensure detailed parsing still works
        first_game = result[:games].first
        expect(first_game[:board]).to eq(1)
        expect(first_game[:home_player]).to eq('Van Oijen, Marcel')
        expect(first_game[:home_rating]).to eq(1936)
        expect(first_game[:result]).to eq('0 - 1')
        expect(first_game[:away_player]).to eq('Orr, Mark J L')
        expect(first_game[:away_rating]).to eq(2116)
      end
    end
  end
end
