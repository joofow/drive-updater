require 'googleauth/stores/file_token_store'
require 'googleauth'

class GoogleAuthorizer

  def initialize application_name: nil, application_version: "unknown", token_key: nil, token_file: nil, config_file: nil
    raise 'Missing token storeage file' if token_file.nil?
    raise 'Missing config file' if config_file.nil?
    @application_name = application_name
    @token_store = Google::Auth::Stores::FileTokenStore.new(:file => token_file)
    @application_version = application_version
    @client_id = Google::Auth::ClientId.from_file(config_file)
  end

  def authorization_url scope
    params = {
      scope: scope,
      redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
      response_type: 'code',
      client_id: @client_id.id
    }
    url = {
      host: 'accounts.google.com',
      path: '/o/oauth2/auth',
      query: URI.encode_www_form(params)
    }

    return URI::HTTPS.build(url)
  end

  def renew_refresh_token auth_code
    client = get_client_with_new_tokens(auth_code)
    token = client.refresh_token
    puts "new token: #{token}"
    @token_store.store 'refresh_token', token
  end

  def get_client_with_new_tokens auth_code
    authorization = Signet::OAuth2::Client.new(
      token_credential_uri: 'https://www.googleapis.com/oauth2/v3/token',
      code: auth_code,
      client_id: @client_id.id,
      client_secret: @client_id.secret,
      redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
      grant_type: 'authorization_code'
      )
    authorization.fetch_access_token!
    return authorization
  end

  def authorization
    authorization = Signet::OAuth2::Client.new(
      token_credential_uri: 'https://www.googleapis.com/oauth2/v3/token',
      client_id: @client_id.id,
      client_secret: @client_id.secret,
      refresh_token: @token_store.load('refresh_token'),
      grant_type: 'refresh_token'
      )
    authorization.fetch_access_token!
    return authorization
  end
end