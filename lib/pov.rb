require 'continuation'
require 'ostruct'

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
  Util.resumption_exception h
end

$POV_send_func = ->(key,value){ puts key + " pov << " + value  }

# public

def pov_send(send_func)
  $POV_send_func = send_func
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
    $POV_send_func[key,value]
  end
end

def pov_static(*params)
  all_params = {}
  params.flatten.each do |param|
    raise "pov_static expects each param as hash pov_label:pov_string" unless param.kind_of? Hash
    all_params.merge! param
  end
  OpenStruct.new all_params
end

def pov(*receivers, &block)
  receivers.flatten.each do |rc|
    had_pov rc, block.call
  end
end

# example

first = "Lashmaw, the infinium crystal blade's slash"
third = "manificent crystal blade's slash"

weapon = OpenStruct.new
weapon.pov = pov_static first:first, third:third

def m( weapon )
  pov_scope do
    everyone = ["Fred","Alice","Jim","Bob"]
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

#m weapon
