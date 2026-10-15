require 'rails_helper'

describe LmsFixture do
  describe ".import" do
    let(:events) do
      [
        { "id" => 32, "name" => "Premier",    "type" => "team_league" },
        { "id" => 33, "name" => "Division 1", "type" => "team_league" },
        { "id" => 34, "name" => "Division 2", "type" => "team_league" },
        { "id" => 35, "name" => "Division 3", "type" => "team_league" },
        { "id" => 36, "name" => "Allegro",    "type" => "team_league" },
      ]
    end
    let(:results) do
      {
        32 => [[1539, "Wandering Dragons 1", "Civil Service 1"], [1540, "Corstorphine 1", "Wandering Dragons 2"],
               [1541, "Edinburgh 1", "Civil Service 1"], [1542, "Old Wandering Dragons", "Edinburgh 2"]],
        33 => [[1600, "Edinburgh 2", "Wandering Dragons 3"]],
        34 => [[1700, "Wandering Dragons 4", "Bells 1"], [1701, "Bells 2", "Corstorphine 2"], [1702, "Bells 3", "Wandering Dragons 5"]],
        35 => [[1800, "Wandering Dragons 6", "Bells 4"]],
        36 => [[1900, "Wandering Dragons 1", "Bells 1"]],
      }
    end
    let(:api) do
      double("LmsApi").tap do |api|
        allow(api).to receive(:season_events).with(11).and_return(events)
        allow(api).to receive(:event_results) do |id|
          { "fixtures" => results.fetch(id).map { |f, home, away| { "fixture_id" => f, "home_team" => home, "away_team" => away } } }
        end
      end
    end

    it "stores fixtures for the league events only and returns counts" do
      counts = LmsFixture.import(11, api: api)
      expect(counts).to eq("Premier" => 2, "Division 1" => 1, "Division 2" => 2, "Division 3" => 1)
      expect(LmsFixture.find_by(fixture_id: 1539)).to have_attributes(season_id: 11, event_id: 32, event_name: "Premier")
      expect(LmsFixture.find_by(fixture_id: 1702).event_id).to eq 34
      expect(LmsFixture.exists?(fixture_id: 1900)).to be false
    end

    it "reports zero for a division with no club fixtures" do
      results[35] = [[1800, "Bells 4", "Bells 5"]]
      expect(LmsFixture.import(11, api: api)).to eq("Premier" => 2, "Division 1" => 1, "Division 2" => 2, "Division 3" => 0)
      expect(LmsFixture.where(season_id: 11).count).to eq 5
    end

    it "stores only fixtures where a team's name starts with Wandering Dragons" do
      LmsFixture.import(11, api: api)
      expect(LmsFixture.pluck(:fixture_id)).to contain_exactly(1539, 1540, 1600, 1700, 1702, 1800)
    end

    it "replaces existing fixtures for the season but leaves other seasons alone" do
      LmsFixture.create!(season_id: 11, event_id: 32, event_name: "Premier", fixture_id: 9999)
      LmsFixture.create!(season_id: 12, event_id: 41, event_name: "Premier", fixture_id: 8888)
      LmsFixture.import(11, api: api)
      expect(LmsFixture.exists?(fixture_id: 9999)).to be false
      expect(LmsFixture.exists?(fixture_id: 8888)).to be true
      expect(LmsFixture.where(season_id: 11).count).to eq 6
    end

    it "refuses when an expected event is missing and changes nothing" do
      LmsFixture.create!(season_id: 11, event_id: 32, event_name: "Premier", fixture_id: 9999)
      allow(api).to receive(:season_events).with(11).and_return(events.reject { |e| e["name"] == "Division 2" })
      expect { LmsFixture.import(11, api: api) }.to raise_error(LmsFixture::ImportError, /Division 2/)
      expect(LmsFixture.pluck(:fixture_id)).to eq [9999]
    end

    it "refuses when there are no fixtures yet" do
      results.transform_values! { [] }
      expect { LmsFixture.import(11, api: api) }.to raise_error(LmsFixture::ImportError, /no Wandering Dragons fixtures/)
    end

    it "leaves existing data alone when the API fails part way" do
      LmsFixture.create!(season_id: 11, event_id: 32, event_name: "Premier", fixture_id: 9999)
      allow(api).to receive(:event_results).with(34).and_raise(LmsApi::Error, "boom")
      expect { LmsFixture.import(11, api: api) }.to raise_error(LmsApi::Error)
      expect(LmsFixture.pluck(:fixture_id)).to eq [9999]
    end
  end

  it "does not allow a fixture to be stored twice" do
    LmsFixture.create!(season_id: 11, event_id: 32, event_name: "Premier", fixture_id: 1539)
    expect(LmsFixture.new(season_id: 11, event_id: 33, event_name: "Division 1", fixture_id: 1539)).not_to be_valid
  end

  describe "search" do
    before do
      (1..35).each { |n| LmsFixture.create!(season_id: 11, event_id: 32, event_name: "Premier", fixture_id: 1000 + n) }
      LmsFixture.create!(season_id: 12, event_id: 41, event_name: "Premier", fixture_id: 2000)
      LmsFixture.create!(season_id: 12, event_id: 42, event_name: "Division 1", fixture_id: 2001)
    end

    def search(params) = LmsFixture.search(LmsFixture.all, ActionController::Parameters.new(params), "/lms_fixtures", per_page: 30)

    it "shows only the requested season, a page at a time" do
      pager = search({season: "11"})
      expect(pager.matches.map(&:season_id).uniq).to eq [11]
      expect(pager.matches.size).to eq 30
      expect(search({season: "11", page: "2"}).matches.size).to eq 5
      expect(search({season: "12"}).matches.map(&:fixture_id)).to eq [2000]
    end

    it "shows only the requested event, defaulting to the Premier" do
      expect(search({season: "12", event: "Division 1"}).matches.map(&:fixture_id)).to eq [2001]
      expect(search({season: "12"}).matches.map(&:fixture_id)).to eq [2000]
      expect(search({season: "12", event: "Allegro"}).matches.map(&:fixture_id)).to eq [2000]
    end

    it "defaults to the latest season that has data" do
      expect(search({}).matches.map(&:season_id).uniq).to eq [12]
      expect(search({season: "999"}).matches.map(&:season_id).uniq).to eq [12]
    end

    it "defaults to the latest known season when there is no data" do
      LmsFixture.delete_all
      expect(LmsFixture.season_from({})).to eq LmsFixture::SEASONS.keys.max
    end
  end
end
