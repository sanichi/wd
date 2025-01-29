pin "application"
pin "jquery", to: "jquery3.min.js"
pin "popper", to: "popper.js"
pin "bootstrap", to: "bootstrap.min.js"
pin "chess", to: "chess.js", preload: false
pin "chessboard", to: "chessboard.js", preload: false
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
