 ActiveRecordDoctor.configure do
  # Global settings affect all detectors.
  global :ignore_tables, [
    # Ignore internal Rails-related tables.
    "ar_internal_metadata",
    "schema_migrations",

    # Add project-specific tables here.
  ]

  # Detector-specific settings affect only one specific detector.
end
