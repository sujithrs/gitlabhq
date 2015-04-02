module Backup
  class RemoteAzureStorage
    attr_reader :storage
    def initialize(config={})
      Azure.configure do |azure_config|
        azure_config.storage_account_name =  config[:storage_account_name]
        azure_config.storage_access_key   =  config[:storage_access_key]
      end
      @storage = Azure::BlobService.new
    end

    def upload(remote_directory, file_name)
      $progress.puts "Uploading #{file_name} to #{remote_directory} ... "
      File.open(file_name) do |file|
        @storage.create_block_blob(remote_directory, file_name, file.read)
      end
    end
  end
end
