CarrierWave.configure do |config|
  config.fog_provider = 'fog/aws'                        # required
  config.fog_credentials = {
      provider:              'AWS',                        # required
      aws_access_key_id:     ENV['fog_key'],                        # required
      aws_secret_access_key: ENV['fog_secret'],                        # required
      region:                'ap-northeast-2',             # optional, defaults to 'us-east-1'
  }
  config.fog_directory  = '94yb'            # required
end