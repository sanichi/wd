require 'rails_helper'
require './lib/misc/chess_match_scraper'

describe Blog do
  let(:blog1)  { create(:blog, title: " Title1\r\n  ", summary: "Para1\n\n\nPara2\r\n\r\n", story: " ") }
  let(:blog2)  { create(:blog, title: "Long\n\nTitle", summary: "Summary", story: " Para1a\nPara1b\n\nPara2\n\n") }
  let(:blog3)  { create(:blog, title: "Title", summary: "Mark Orr(2200)", story: "Jorge , Blanco") }

  it "normalisation" do
    expect(blog1.title).to eq "Title1"
    expect(blog1.summary).to eq "Para1\n\nPara2"
    expect(blog1.story).to be_nil
    expect(blog2.title).to eq "Long Title"
    expect(blog2.summary).to eq "Summary"
    expect(blog2.story).to eq "Para1a\nPara1b\n\nPara2"
    expect(blog3.summary).to eq "Mark Orr (2200)"
    expect(blog3.story).to eq "Jorge, Blanco"
  end

  describe "match data persistence" do
    let(:mock_scraper) { double('ChessMatchScraper') }
    let(:match_data) do
      {
        home_team: "Civil Service 1",
        away_team: "Wandering Dragons 1",
        home_score: 1.0,
        away_score: 5.0,
        games: [
          { board: 1, home_player: "Van Oijen, Marcel", home_rating: 1936, result: "0 - 1", away_player: "Orr, Mark J L", away_rating: 2116 },
          { board: 2, home_player: "Rounds, Matt", home_rating: 1875, result: "0 - 1", away_player: "Leah, Tom", away_rating: 2061 },
          { board: 3, home_player: "Grey, Tom", home_rating: 1635, result: "1 - 0", away_player: "O'Neil, Jim", away_rating: 1797 }
        ]
      }
    end

    before do
      allow(ChessMatchScraper).to receive(:new).with("1539").and_return(mock_scraper)
      allow(mock_scraper).to receive(:scrape).and_return(match_data)
    end

    it "persists markdown table in summary when saving blog with {LMS:nnnn}" do
      blog = Blog.new(title: "Match Report", summary: "Here is the match:\n\n{LMS:1539}")
      expect(blog.save).to be true

      blog.reload
      expect(blog.summary).not_to include("{LMS:1539}")
      expect(blog.summary).to include("|Civil Service 1")
      expect(blog.summary).to include("Wandering Dragons 1")
      expect(blog.summary).to include("Van Oijen, Marcel (1936)")
      expect(blog.summary).to include("|0-1|")
    end

    it "persists markdown table in story when saving blog with {LMS:nnnn}" do
      blog = Blog.new(title: "Match Report", summary: "Summary", story: "Story:\n\n{LMS:1539}")
      expect(blog.save).to be true

      blog.reload
      expect(blog.story).not_to include("{LMS:1539}")
      expect(blog.story).to include("|Civil Service 1")
      expect(blog.story).to include("|0-1|")
    end

    it "strips whitespace around {LMS:nnnn} and replaces with exactly 2 newlines" do
      blog = Blog.new(title: "Test", summary: "Before   \n  {LMS:1539}  \n   After")
      blog.save

      expect(blog.summary).to match(/Before\n\n.*\n\nAfter/m)
    end

    it "handles multiple {LMS:nnnn} patterns" do
      allow(ChessMatchScraper).to receive(:new).with("1234").and_return(mock_scraper)

      blog = Blog.new(title: "Test", summary: "{LMS:1539} and {LMS:1234}")
      blog.save

      expect(blog.summary.scan(/Civil Service 1/).length).to eq(2)
    end

    it "fails validation when scraper raises MatchNotPlayedError" do
      allow(mock_scraper).to receive(:scrape).and_raise(ChessMatchScraper::MatchNotPlayedError, "Match not played")

      blog = Blog.new(title: "Test", summary: "{LMS:1539}")
      expect(blog.save).to be false
      expect(blog.errors[:base]).to include("LMS fixture 1539: Match not played")
      expect(blog.summary).to eq("{LMS:1539}")
    end

    it "fails validation when scraper raises NetworkError" do
      allow(mock_scraper).to receive(:scrape).and_raise(ChessMatchScraper::NetworkError, "Network error")

      blog = Blog.new(title: "Test", summary: "{LMS:1539}")
      expect(blog.save).to be false
      expect(blog.errors[:base]).to include("LMS fixture 1539: Network error")
      expect(blog.summary).to eq("{LMS:1539}")
    end

    it "fails validation when scraper raises ParseError" do
      allow(mock_scraper).to receive(:scrape).and_raise(ChessMatchScraper::ParseError, "Parse error")

      blog = Blog.new(title: "Test", summary: "{LMS:1539}")
      expect(blog.save).to be false
      expect(blog.errors[:base]).to include("LMS fixture 1539: Parse error")
      expect(blog.summary).to eq("{LMS:1539}")
    end

    it "fails validation when scraper error occurs in story field" do
      allow(mock_scraper).to receive(:scrape).and_raise(ChessMatchScraper::NetworkError, "Network error")

      blog = Blog.new(title: "Test", summary: "Summary", story: "{LMS:1539}")
      expect(blog.save).to be false
      expect(blog.errors[:base]).to include("LMS fixture 1539: Network error")
      expect(blog.story).to eq("{LMS:1539}")
    end

    it "handles multiple LMS patterns with mixed success and failure" do
      working_scraper = instance_double(ChessMatchScraper)
      allow(working_scraper).to receive(:scrape).and_return(match_data)
      allow(ChessMatchScraper).to receive(:new).with("1539").and_return(working_scraper)
      allow(ChessMatchScraper).to receive(:new).with("9999").and_return(mock_scraper)
      allow(mock_scraper).to receive(:scrape).and_raise(ChessMatchScraper::NetworkError, "Not found")

      blog = Blog.new(title: "Test", summary: "{LMS:1539} and {LMS:9999}")
      expect(blog.save).to be false
      expect(blog.errors[:base]).to include("LMS fixture 9999: Not found")
      expect(blog.summary).to include("|Civil Service 1")
      expect(blog.summary).to include("{LMS:9999}")
    end

    it "does not modify summary if no {LMS:nnnn} pattern" do
      original_summary = "Just a regular blog post"
      blog = Blog.new(title: "Test", summary: original_summary)
      blog.save

      expect(blog.summary).to eq(original_summary)
    end
  end

  describe "format_player" do
    let(:blog) { create(:blog, title: "Test", summary: "Summary") }

    it "formats player with rating" do
      result = blog.send(:format_player, "Smith, John", 1800)
      expect(result).to eq("Smith, John (1800)")
    end

    it "formats player without rating" do
      result = blog.send(:format_player, "Smith, John", nil)
      expect(result).to eq("Smith, John")
    end

    it "handles empty player name" do
      result = blog.send(:format_player, "", 1800)
      expect(result).to eq("")
    end

    it "handles blank player name" do
      result = blog.send(:format_player, "  ", 1800)
      expect(result).to eq("")
    end
  end

  describe "format_score" do
    let(:blog) { create(:blog, title: "Test", summary: "Summary") }

    it "formats whole number scores as integers" do
      expect(blog.send(:format_score, 3.0)).to eq("3")
      expect(blog.send(:format_score, 0.0)).to eq("0")
      expect(blog.send(:format_score, 5.0)).to eq("5")
    end

    it "formats half-point scores with ½ symbol" do
      expect(blog.send(:format_score, 3.5)).to eq("3½")
      expect(blog.send(:format_score, 0.5)).to eq("0½")
      expect(blog.send(:format_score, 2.5)).to eq("2½")
    end
  end

  describe "match with draws" do
    let(:mock_scraper) { double('ChessMatchScraper') }
    let(:match_data_with_draws) do
      {
        home_team: "Team A",
        away_team: "Team B",
        home_score: 3.5,
        away_score: 2.5,
        games: [
          { board: 1, home_player: "Player A1", home_rating: 2000, result: "1 - 0", away_player: "Player B1", away_rating: 1950 },
          { board: 2, home_player: "Player A2", home_rating: 1900, result: "½ - ½", away_player: "Player B2", away_rating: 1920 },
          { board: 3, home_player: "Player A3", home_rating: 1850, result: "1 - 0", away_player: "Player B3", away_rating: 1880 },
          { board: 4, home_player: "Player A4", home_rating: 1800, result: "½ - ½", away_player: "Player B4", away_rating: 1820 },
          { board: 5, home_player: "Player A5", home_rating: 1750, result: "0 - 1", away_player: "Player B5", away_rating: 1800 },
          { board: 6, home_player: "Player A6", home_rating: 1700, result: "0 - 1", away_player: "Player B6", away_rating: 1750 }
        ]
      }
    end

    before do
      allow(ChessMatchScraper).to receive(:new).with("1555").and_return(mock_scraper)
      allow(mock_scraper).to receive(:scrape).and_return(match_data_with_draws)
    end

    it "displays match score with half-points when there are draws" do
      blog = Blog.new(title: "Match with Draws", summary: "{LMS:1555}")
      blog.save

      expect(blog.summary).to include("|Team A")
      expect(blog.summary).to include("|3½-2½|")
      expect(blog.summary).to include("|½-½|")
      expect(blog.summary).not_to include("|3-2|")
    end
  end
end
