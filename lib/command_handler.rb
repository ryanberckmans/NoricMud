
class CommandHandler
  def initialize( default_callback=nil)
    raise "expected default_callback to be a Proc or nil" if default_callback and not default_callback.kind_of? Proc
    @abbrev_map = AbbrevMap.new
    @default_callback = default_callback
  end

  def add( cmd, callback )
    @abbrev_map.add cmd, callback
  end

  def find( cmd )
    raise "expected cmd to be a string" unless cmd.kind_of? String
    return {value:@default_callback, match:"", rest:""} if cmd.empty?
    @abbrev_map.find cmd
  end
end
