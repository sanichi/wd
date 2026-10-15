require "net/http"

# Read-only client for the LMS v2 REST API. See
# https://lms.englishchess.org.uk/lms/lmsrest/v2 for the documentation.
class LmsApi
  class Error < StandardError; end

  BASE_URL = "https://lms.playchess.org.uk/lmsrest/v2"
  TIMEOUT = 20

  def initialize(key: Rails.application.credentials.lms_key)
    raise Error, "No LMS API key: set lms_key in the Rails credentials" if key.blank?
    @key = key
  end

  def season_events(season_id) = get("season/#{season_id}/events").fetch("events")

  def event_results(event_id) = get("event/#{event_id}/results")

  private

  def get(path)
    uri = URI("#{BASE_URL}/#{path}")
    request = Net::HTTP::Get.new(uri, "Authorization" => "Bearer #{@key}", "Accept" => "application/json")
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: TIMEOUT, read_timeout: TIMEOUT) { |http| http.request(request) }
    raise Error, "LMS API #{path}: #{response.code} #{error_message(response)}" unless response.is_a?(Net::HTTPSuccess)
    JSON.parse(response.body)
  rescue SocketError, SystemCallError, Timeout::Error, OpenSSL::SSL::SSLError, JSON::ParserError => e
    raise Error, "LMS API #{path}: #{e.message}"
  end

  def error_message(response)
    JSON.parse(response.body).fetch("error")
  rescue JSON::ParserError, KeyError
    response.message
  end
end
