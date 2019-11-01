class Journal < ApplicationRecord
  include Constrainable
  include Pageable

  MAX_ACTION    = 10
  MAX_HANDLE    = 30
  MAX_REMOTE_IP = 40
  MAX_RESOURCE  = 20

  before_validation :normalise_attributes

  def self.search(matches, params, path, opt={})
    matches = matches.order(created_at: :desc)
    if sql = cross_constraint(params[:query], %w{action handle remote_ip resource})
      matches = matches.where(sql)
    end
    paginate(matches, params, path, opt)
  end

  private

  def normalise_attributes
    self.action    = action.blank?    ? "unknown" : action.truncate(MAX_ACTION)
    self.handle    = handle.blank?    ? "UNKNOWN" : handle.truncate(MAX_HANDLE)
    self.remote_ip = remote_ip.blank? ? "_._._._" : remote_ip.truncate(MAX_REMOTE_IP)
    self.resource  = resource.blank?  ? "Unknown" : resource.truncate(MAX_RESOURCE)
  end
end
