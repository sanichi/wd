module JournalHelper
  def resource_link(journal)
    id = journal.resource_id
    return nil unless id.present?
    resource = journal.resource
    return id unless resource.match?(/\A(Blog|Book|Game|Player|User)\z/)
    object = resource.constantize.find_by(id: id)
    return id unless object
    link_to id, object
  end
end
