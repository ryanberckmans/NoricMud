def resumption_exception(*args)
  # from internet
  raise *args
rescue Exception => e
  callcc do |cc|
    scls = class << e; self; end
    scls.send(:define_method, :resume, lambda { cc.call })
    raise
  end
end

def pov_scope(&block)
  povs = {}
  begin
    block.call
  rescue HadPov => e
    povs[e.subject] = e.pov unless povs.key? e.subject
    e.resume
  end
  povs.each_pair do |key,value|
    puts key + " pov << " + value
  end
end

class POV
  def initialize
    @first = nil
  end
  def first(first=nil)
    if first
      @first = first
      nil
    elsif @first
      @first
    else
      ""
    end
  end
  def third(third=nil)
    if third
      @third = third
      nil
    elsif @third
      @third
    else
      ""
    end
  end
end

def pov(*receivers, &block)
  receivers.each do |rc|
    had_pov rc, block.call
  end
end

class HadPov < Exception
  def pov=(msg)
    @msg = msg
  end
  def pov
    @msg
  end
  def subject=(subject)
    @subject=subject
  end
  def subject
    @subject
  end
end

def had_pov( subject, msg )
  h = HadPov.new
  h.subject = subject
  h.pov = msg
  resumption_exception h
end

class Weapon
  def initialize
    @pov = POV.new
    @pov.first "Lashmaw, the infinium crystal blade's slash"
    @pov.third "manificent crystal blade's slash"
  end

  def pov
    @pov
  end
end

weapon = Weapon.new

def m( weapon )
  pov_scope do
    everyone = %w[ Fred, Alice, Jim, Xheric ]
    pov("Fred","Alice") do
      "Your " + weapon.pov.first + " decimates Jim."
    end
    pov("Jim") do
      "Fred's " + weapon.pov.third + " decimates you."
    end
    pov(everyone) do
      "everyone else"
    end
  end
end

m weapon
