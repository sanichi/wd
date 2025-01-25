# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

Rails.application.config.assets.precompile += %w( jquery3.min.js )
Rails.application.config.assets.precompile += %w( bootstrap.min.js popper.js )
Rails.application.config.assets.precompile += %w( @rails--ujs.js )
Rails.application.config.assets.precompile += %w( my_utils.js game.js )
Rails.application.config.assets.precompile += %w( chess.js chessboard.js )
