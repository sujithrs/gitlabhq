require 'zlib'

module Backup
  class RemoteStorage
    attr_reader :config, :connection
    def initialize(config)
      @config = config
      @connection = Hash[config.connection]
    end

    def storage
      return @storage if @storage
      case connection[:provider]
      when "AWS"
        @storage = RemoteAwsStorage.new(connection)
      when "AZURE"
        @storage = RemoteAzureStorage.new(connection)
      else
        $progress.puts "unsupported provider: #{connection[:provider]}".yellow
        return
      end
    end

    def upload(tar_file)
      $progress.puts "Uploading backup archive to remote storage #{connection[:provider]} ... "
      return $progress.puts "skipped".yellow if storage.nil?
      gzip_tar_file = gzip(tar_file)
      if storage.upload(config.remote_directory, gzip_tar_file)
        $progress.puts "done".green
      else
        puts "uploading backup to #{connection[:provider]} failed".red
        abort 'Backup failed'
      end
      # Remove gzip tar file
      FileUtils.rm_f(gzip_tar_file)
    end

    def gzip(f)
      gzip_file = "#{f}.gz"
      $progress.puts "Compressing #{f} ... "
      Zlib::GzipWriter.open(gzip_file) do |gz|
        gz.mtime = File.mtime(f)
        gz.orig_name = File.basename(f) #filename without path
        gz.write IO.binread(f)
      end
      gzip_file
    end
  end
end
