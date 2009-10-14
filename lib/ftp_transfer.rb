class FtpTransfer
  require 'net/ftp'

  #You need a YAML file   config/ftp_accounts.yml   with given structure
  #your_account_name:
  #   host: your_host
  #   login: your_login
  #   password: your_password
  def initialize(account_name)
    begin
      config = YAML::load(File.open("#{RAILS_ROOT}/config/ftp_accounts.yml"))
      @ftp = Net::FTP.new(config[account_name]["host"])
      @ftp.login(config[account_name]["login"],config[account_name]["password"])
      RAILS_DEFAULT_LOGGER.info "You have been succesfully connected to the ftp server"
    rescue Exception => e
      error_message(e)
    end
  end

  # put local file to server, remotefile is optional (it specify the name of sending file on the server)
  # return true if execute correctly
  # send_file("C:\Clawfinger.mp3")
  # send_file("C:\Clawfinger.mp3", "mp3\Clawfinger77.mp3")
  def send_file(file, remotefile = File.basename(file))
    begin
      @ftp.putbinaryfile(file, remotefile)
      return true
    rescue Exception => e
      error_message(e)
      return false
    end
  end
  
  # sending string to remote file on server
  # send_text("text text text text text", "file.txt")
  def send_text(text, remotefile)
    begin
      @ftp.put_text(text, remotefile)
      return true
    rescue
      return false
    end
  end

  # get file from a server
  # return true if execute correctly
  # retrieve_file("Clawfinger.mp3")
  def retrieve_file(file)
    begin
      @ftp.getbinaryfile(file)
      return true
    rescue Exception => e
      error_message(e)
      return false
    end
  end

  # read file directly from a server
  # return true if execute correctly
  # read_remote_file("readme.txt)
  def read_remote_file(file)
    begin
      result = ""
      @ftp.retrbinary("RETR #{file}", 1024) {|line| result += line if line != nil}
    rescue Exception => e
      error_message(e)
    ensure
      return result
    end
  end

  # delete file from a server
  # return true if execute correctly
  # remove_file("readme.txt")
  def remove_file(file)
    begin
      @ftp.delete(file)
      return true
    rescue Exception => e
      error_message(e)
      return false
    end
  end

  # creates a remote directory
  # make_dir("my_new_directory")
  def make_dir(dirname)
    begin
      @ftp.mkdir(dirname)
      return true
    rescue 
      return false
    end
  end

  # removes a file from the server to another location on the server (or just change name of the file)
  # rename("file.txt", "folder/new_name.txt")
  def rename(fromname, toname)
    begin
      @ftp.rename(fromname, toname)
      return true
    rescue
      return false
    end
  end

  # returns the size of the given (remote) filename
  def size(filename)
    begin
      @ftp.size(filename)
    rescue
      return false
    end
  end

  # returns an array of filenames in the remote directory
  # you can specify directory if you want
  # list
  # list("documents/")
  def list(directory = nil)
    @ftp.nlst(directory)
  end

  # closes the connection, further operations are impossible
  # return true if executed correctly
  def close
    @ftp.close
    @ftp.closed?
  end

  protected

  def error_message(e)
    RAILS_DEFAULT_LOGGER.error "Error has occured in FtpTransfer: #{e.message}"
  end

end