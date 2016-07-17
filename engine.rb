require './google_authorizer'
require 'google/apis/drive_v2'

class Engine

	def initialize(token_file: nil, config_file: nil)
    @auth = GoogleAuthorizer.new(
      token_key: 'api-drive',
      application_name: 'Google Drive Interaction',
      application_version: '0.1',
      token_file: token_file,
      config_file: config_file
      )
  end
  def authorization_url
    @auth.authorization_url 'https://www.googleapis.com/auth/drive'
  end
  def renew_refresh_token auth_code
    @auth.renew_refresh_token auth_code
  end

  def authorization
    @authorization ||= @auth.authorization
    return @authorization
  end

  def upload file
  	@caller = Google::Apis::DriveV2::DriveService.new
			@caller.authorization = authorization
  	metadata = Google::Apis::DriveV2::File.new(title: "test")
			metadata = @caller.insert_file(metadata, upload_source: file, content_type: 'text/plain')
  end
end