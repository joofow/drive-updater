require_relative 'google_authorizer'
require 'google/apis/drive_v3'

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

  def upload file, folder = nil
  	@driveservice = Google::Apis::DriveV3::DriveService.new
		@driveservice.authorization = authorization
		if folder
			file_metadata = {
				name: folder,
				mime_type: 'application/vnd.google-apps.folder'
			}
			response = @driveservice.list_files(q: "mimeType='application/vnd.google-apps.folder' and name='#{folder}'",
                                    spaces: 'drive',
                                    fields:'nextPageToken, files(id, name)',
                                    page_token: nil)
			folder = if response.files.length > 0
				response.files.first
			else
				@driveservice.create_file(file_metadata, fields: 'id')
			end
			file_metadata = {
				name: File.basename(file),
				parents: [folder.id]
			}
			puts "Folder Id: #{folder.id}"
		end
		file_metadata = {name: File.basename(file) } unless file_metadata
		metadata = @driveservice.create_file(file_metadata, fields: 'id', upload_source: "#{file}", content_type: 'text/plain')
  end
end