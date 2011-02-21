module Util
  def self.md5( o )
    Digest::MD5.hexdigest(o)
  end

  def self.here( string )
    File.expand_path(File.join(File.dirname(caller[0].split(":")[0]), string))
  end

  def self.strip_newlines( string )
    string.gsub /\r?\n/, ", "
  end

  def self.resumption_exception(*args)
    # from internet
    raise *args
  rescue Exception => e
    callcc do |cc|
      scls = class << e; self; end
      scls.send(:define_method, :resume, lambda { cc.call })
      raise
    end
  end
end
