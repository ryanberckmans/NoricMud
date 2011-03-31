require 'strscan'

class AbbrevMap
  def initialize( epsilon_value = nil, catchall_value = nil )
    raise "expected epsilon_value to be a Proc or nil" if epsilon_value and not epsilon_value.kind_of? Proc
    raise "expected catchall_value to be a Proc or nil" if catchall_value and not catchall_value.kind_of? Proc
    @epsilon_value = epsilon_value
    @catchall_value = catchall_value
    @root = TrieNode.new
  end

  def add( key, value )
    raise "expected key to be a string" unless key.kind_of? String
    @root.add key, value
    nil
  end

  def find( key )
    raise "expected key to be a string" unless key.kind_of? String
    if key.empty?
      return nil unless @epsilon_value
      return { value:@epsilon_value, match:"", rest:"" }
    end
    value = @root.find key
    value = { value:@catchall_value, match:"", rest:key } if @catchall_value and not value
    value
  end
end

class TrieNode
  attr_accessor :next_token_node, :value, :possible_next

  def initialize
    @value = nil
    @possible_next = {}
    @next_token_node = nil
  end
  
  def add( key, value )
    scanner = StringScanner.new key
    scanner.scan /\s+/
    return if scanner.eos?
    first_char = (scanner.scan /./).downcase
    all_but_first_char = scanner.rest
    scanner.scan /\S*\s*/
    all_but_first_token = scanner.rest

    if not @possible_next[ first_char ]
      @possible_next[ first_char ] = TrieNode.new
      @possible_next[ first_char ].value = value
    end
    
    if all_but_first_token.length > 0
      @possible_next[ first_char ].next_token_node ||= TrieNode.new
      @possible_next[ first_char ].next_token_node.add all_but_first_token, value
    end

    @possible_next[ first_char ].add all_but_first_char, value
  end
  
  def find( key )
    return nil if not key
    return find_from_next_token self, key
  end

  private
  def find_from_next_token( node, key )
    scanner = StringScanner.new key
    scanner.scan /\s+/
    return nil if scanner.eos? # next token was nothing
    first_token = (scanner.scan /\S+/).downcase
    scanner.scan /\s+/
    all_but_first_token = scanner.rest

    first_token.each_char do |char|
      if node.possible_next.key? char
        node = node.possible_next[char]
      else
        return nil
      end
    end

    if all_but_first_token.length > 0 and node.next_token_node
      result = find_from_next_token node.next_token_node, all_but_first_token
      if result
        result[ :match ] = "#{first_token} #{result[ :match ]}"
        return result
      end
    end

    return { :value => node.value, :rest => all_but_first_token, :match => first_token }
  end
end
