require 'rails_helper'

describe LmsMatchScraper do
  let(:api) { double("LmsApi") }
  let(:scraper) { described_class.new(1539, api: api) }

  def player(name, rating) = { "lms_id" => 1, "rating_code" => nil, "name" => name, "rating" => rating, "secondary_rating" => nil }

  def game(board, result, home: player("Home #{board}", 1900), away: player("Away #{board}", 1800))
    { "board" => board, "home_colour" => "W", "result" => result, "home_player" => home, "away_player" => away }
  end

  let(:games) { [game(1, "away_win"), game(2, "draw"), game(3, "home_win")] }
  let(:fixture) do
    { "fixture_id" => 1539, "round" => 1, "date" => "2025-12-01", "time" => "19:00", "home_team" => "Civil Service 1",
      "away_team" => "Wandering Dragons 1", "home_score" => 1.5, "away_score" => 1.5, "winner" => "draw", "board_count" => 3, "games" => games }
  end
  let(:other) { fixture.merge("fixture_id" => 1540, "home_team" => "Other") }

  before do
    LmsFixture.create!(season_id: 11, event_id: 32, event_name: "Premier", fixture_id: 1539)
    allow(api).to receive(:event_results).with(32).and_return("event_name" => "Premier", "fixtures" => [other, fixture])
  end

  it "returns the match in the format used by the other scrapers" do
    expect(scraper.scrape).to eq(
      home_team: "Civil Service 1", away_team: "Wandering Dragons 1", home_score: 1.5, away_score: 1.5,
      games: [
        { board: 1, home_player: "Home 1", home_rating: 1900, result: "0 - 1", away_player: "Away 1", away_rating: 1800 },
        { board: 2, home_player: "Home 2", home_rating: 1900, result: "½ - ½", away_player: "Away 2", away_rating: 1800 },
        { board: 3, home_player: "Home 3", home_rating: 1900, result: "1 - 0", away_player: "Away 3", away_rating: 1800 },
      ]
    )
  end

  it "accepts the fixture ID as the string captured from a blog" do
    expect(described_class.new("1539", api: api).scrape[:home_team]).to eq "Civil Service 1"
  end

  it "maps default results to the * notation" do
    games.replace([game(1, "home_default_win"), game(2, "away_default_win"), game(3, "double_default")])
    expect(scraper.scrape[:games].map { |g| g[:result] }).to eq ["1 * 0", "0 * 1", "0 * 0"]
  end

  it "copes with empty boards and missing ratings" do
    games.replace([game(1, "home_default_win", away: player(nil, nil)), game(2, "draw", home: player("A", 0))])
    first, second = scraper.scrape[:games]
    expect(first).to include(away_player: nil, away_rating: nil)
    expect(second).to include(home_player: "A", home_rating: nil)
  end

  it "uses placeholders for adjourned and adjudicated boards instead of failing" do
    games.replace([game(1, "draw"), game(2, "adjourned"), game(3, "adjudicated")])
    expect(scraper.scrape[:games].map { |g| g[:result] }).to eq ["½ - ½", "adj", "adjud"]
  end

  it "marks boards without a result as N when others have one" do
    games.replace([game(1, "draw"), game(2, nil)])
    expect(scraper.scrape[:games].map { |g| g[:result] }).to eq ["½ - ½", "N"]
  end

  describe "errors" do
    it "reports a fixture that is not in the table, without calling the API" do
      LmsFixture.delete_all
      expect(api).not_to receive(:event_results)
      expect { scraper.scrape }.to raise_error(ChessMatchScraper::UnknownFixtureError, /Unknown fixture/)
    end

    it "reports a fixture missing from its event's results" do
      allow(api).to receive(:event_results).with(32).and_return("fixtures" => [other])
      expect { scraper.scrape }.to raise_error(ChessMatchScraper::ParseError, /not found in the Premier results/)
    end

    it "reports a match with no games yet" do
      games.clear
      expect { scraper.scrape }.to raise_error(ChessMatchScraper::MatchNotPlayedError)
    end

    it "reports a match where no board has a result" do
      games.replace([game(1, nil), game(2, nil)])
      expect { scraper.scrape }.to raise_error(ChessMatchScraper::MatchNotPlayedError)
    end

    it "refuses a result code it doesn't know rather than guess" do
      games.replace([game(1, "draw"), game(2, "forfeit")])
      expect { scraper.scrape }.to raise_error(ChessMatchScraper::ParseError, /Board 2 has an unrecognised result: forfeit/)
    end

    it "reports API failures as network errors" do
      allow(api).to receive(:event_results).and_raise(LmsApi::Error, "LMS API event/32/results: 401 Invalid key")
      expect { scraper.scrape }.to raise_error(ChessMatchScraper::NetworkError, /401 Invalid key/)
    end

    it "reports an unexpected response shape as a parse error" do
      allow(api).to receive(:event_results).and_return("something" => "else")
      expect { scraper.scrape }.to raise_error(ChessMatchScraper::ParseError, /Failed to parse/)
    end
  end
end
