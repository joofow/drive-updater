# drive-updater
CLI for uploading files to Google Drive

Based largely on Martin Fowlers workflow (http://martinfowler.com/articles/command-line-google.html)

# Example Usage

Pass in token_file (for refresh token storage) and google config params (get from https://console.developers.google.com/flows/enableapi?apiid=drive) for auth.

`ruby ./update auth --token_file './tokens.yaml' --config_file './config.json'

This gives you an url, which you need to follow and authorize to get the access token, which you then give back into the prompt. It is then saved into the token_file you passed as a param.

Same params are necessary for upload plus adding in file name and optional folder

`ruby ./update upload --token_file './tokens.yaml' --config_file './config.json' --file './tokens.yaml' --folder 'homes'`
