# just run with ruby lib/check_routes.rb from route directory

require_relative "../config/environment"

Rails.application.eager_load!

results =
  Rails.application.routes.routes.map(&:requirements).reject(&:empty?).map do |r|
    name = r[:controller].camelcase
    controller = "#{name}Controller"
    controller_with_action = "#{name}##{r[:action]}"

    if Object.const_defined?(controller)
      controller_instance = controller.constantize.new
    else
      next { controller_with_action => false }
    end

    next if name.start_with?("Rails")

    if controller_instance.respond_to?(r[:action])
      { controller_with_action => true }
    else
      { controller_with_action => Dir.glob(Rails.root.join("app", "views", name.downcase, "#{r[:action]}.*")).any? }
    end
  end

unused_controller_actions = results.reject(&:blank?).reject { |r| r.values.first }.uniq

if unused_controller_actions.empty?
  puts "#{Rails.application.routes.routes.size} total routes. No unused routes found!"
else
  puts "Unused routes found (#{unused_controller_actions.size})"

  unused_controller_actions.map(&:first).map(&:first).each { |name| puts " " + name }
end
