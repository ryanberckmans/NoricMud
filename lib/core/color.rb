

COLORS = {
  "{@"    =>     "\033[m", #reset
  # styles
  "{!"       =>     "\033[1m", #bold
  "underlineZZ"  =>     "\033[4m",
  "blinkZZ"      =>     "\033[5m",
  "reverseZZ"    =>     "\033[7m",
  "concealedZZZ"  =>     "\033[8m",
  # font colors
  "{FB"      =>     "\033[30m", 
  "{FR"        =>     "\033[31m",
  "{FG"      =>     "\033[32m",
  "{FY"     =>     "\033[33m",
  "{FU"       =>     "\033[34m",
  "{FM"    =>     "\033[35m",
  "{FC"       =>     "\033[36m",
  "{FW"      =>     "\033[37m",
  # background colors
  "{BB"   =>     "\033[40m", 
  "{BR"     =>     "\033[41m",
  "{BG"   =>     "\033[42m",
  "{BY"  =>     "\033[43m",
  "{BU"    =>     "\033[44m",
  "{BM" =>     "\033[45m",
  "{BC"    =>     "\033[46m",
  "{BW"   =>     "\033[47m" 
}

def color( msg )
  COLORS.each do |color,code|
    msg.gsub! color, code
  end
  msg
end
