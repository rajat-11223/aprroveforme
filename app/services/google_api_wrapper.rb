class GoogleApiWrapper
  def initialize(options = {})
    @options = options
    @client = Google::APIClient.new(options.merge(user_agent: GoogleApiWrapper.user_agent))
  end

  delegate_missing_to :@client

  # Builds a custom user agent to prevent Google::APIClient to
  # use an invalid auto-generated one
  # @see https://github.com/google/google-api-ruby-client/blob/15853007bf1fc8ad000bb35dafdd3ca6bfa8ae26/lib/google/api_client.rb#L112
  def self.user_agent
    [
      "google-api-ruby-client/#{Google::APIClient::VERSION::STRING}",
      Google::APIClient::ENV::OS_VERSION,
      '(gzip)'
    ].join(' ').delete("\n")
  end

end
