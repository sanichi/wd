 ActiveRecordDoctor.configure do
  # Global settings affect all detectors.
  global :ignore_tables, [
    # Ignore internal Rails-related tables.
    "ar_internal_metadata",
    "schema_migrations",

    # Add project-specific tables here.
  ]

  # Detector-specific settings affect only one specific detector.

  # Journal entries are only ever created, never edited, so no updated_at.
  detector :table_without_timestamps,
    ignore_tables: ["journals"]

  # event_id is the LMS site's own identifier, not a foreign key, and is never
  # used to look fixtures up.
  detector :unindexed_foreign_keys,
    ignore_columns: ["lms_fixtures.event_id"]

  # These are constrained more tightly than by a length validator: inclusion
  # lists, truncation before validation, generated secrets or fixed role lists.
  # Game.pgn is a text column, so its validator is the only limit.
  detector :incorrect_length_validation,
    ignore_attributes: [
      "Blog.tag",
      "Game.difficulty",
      "Game.pgn",
      "Journal.action",
      "Journal.handle",
      "Journal.remote_ip",
      "Journal.resource",
      "Player.roles",
      "Player.title",
      "User.otp_secret",
      "User.roles"
    ]
end
