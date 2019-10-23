class CreatePlayers < ActiveRecord::Migration[6.0]
  def up
    create_table :players do |t|
      t.boolean  :contact, default: false
      t.string   :email, limit: Player::MAX_EMAIL
      t.string   :federation, limit: Player::MAX_FEDERATION, default: "SCO"
      t.integer  :fide_id
      t.integer  :fide_rating, limit: 2
      t.string   :first_name, limit: Player::MAX_NAME
      t.string   :last_name, limit: Player::MAX_NAME
      t.string   :phone, limit: Player::MAX_PHONE
      t.integer  :rank, limit: 1
      t.string   :roles, array: true, limit: Player::MAX_ROLE, default: ["member"]
      t.integer  :sca_id
      t.integer  :sca_rating, limit: 2
      t.string   :title, limit: Player::MAX_TITLE

      t.timestamps
    end

    Player.create!(contact: true, email: "mark.j.l.orr@googlemail.com", federation: "IRL", fide_id: 2500035, fide_rating: 2099, first_name: "Mark", last_name: "Orr", phone: "079685370101", roles: ["captain_s", "player_s", "player_nl1", "player_el1", "webmaster"], sca_id: 5555, sca_rating: 2142, title: "IM")
    Player.create!(contact: false, email: "elliotsloan@yahoo.co.uk", federation: "SCA", fide_id: 2403625, fide_rating: 1941, first_name: "Elliot", last_name: "Sloan", phone: "07906760759", roles: ["captain_el1", "player_el1", "player_nl1", "player_s"], sca_id: 6012, sca_rating: 1853)
  end

  def down
    drop_table :players
  end
end
