module Backup
  class RemoteAwsStorage
    attr_reader :storage
    def initialize(config)
      @storage = ::Fog::Storage.new(config)
    end

    def upload(remote_directory, file_name)
      if storage
        directory = storage.directories.get(remote_directory)
        directory.files.create(key: file_name, body: File.open(file_name), public: false)
      end
    end
  end
end
