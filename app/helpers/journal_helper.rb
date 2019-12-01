module JournalHelper
  def resource_link(journal)
    return nil unless journal.resource_id.present?
    return journal.resource_id unless journal.resource.match?(/\A(Blog|Book|Game|Player|User)\z/)
    link_to journal.resource_id, "/#{journal.resource.downcase.pluralize}/#{journal.resource_id}"
  end
end
