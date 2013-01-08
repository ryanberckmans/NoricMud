module NoricMud
  module Persistence
    module Util
      OBJECT_CLASS_MAGIC_ATTRIBUTE_NAME = :__reserved__object_class # serialized objects set this attribute containing their class name, for construction during deserialization. The attribute name mustn't conflict with any existing attributes.

      class << self
        # Serialize the passed data
        def serialize data
          Marshal.dump data
        end

        # Deserialize the passed serialized data
        def deserialize data
          Marshal.load data
        end

        # constantize taken from Ruby on Rails
        
        # Ruby 1.9 introduces an inherit argument for Module#const_get and
        # #const_defined? and changes their default behavior.
        if Module.method(:const_get).arity == 1
          # Tries to find a constant with the name specified in the argument string:
          #
          #   "Module".constantize     # => Module
          #   "Test::Unit".constantize # => Test::Unit
          #
          # The name is assumed to be the one of a top-level constant, no matter whether
          # it starts with "::" or not. No lexical context is taken into account:
          #
          #   C = 'outside'
          #   module M
          #     C = 'inside'
          #     C               # => 'inside'
          #     "C".constantize # => 'outside', same as ::C
          #   end
          #
          # NameError is raised when the name is not in CamelCase or the constant is
          # unknown.
          def constantize(camel_cased_word)
            names = camel_cased_word.split('::')
            names.shift if names.empty? || names.first.empty?

            constant = Object
            names.each do |name|
              constant = constant.const_defined?(name) ? constant.const_get(name) : constant.const_missing(name)
            end
            constant
          end
        else
          def constantize(camel_cased_word) #:nodoc:
            names = camel_cased_word.split('::')
            names.shift if names.empty? || names.first.empty?

            constant = Object
            names.each do |name|
              constant = constant.const_defined?(name, false) ? constant.const_get(name) : constant.const_missing(name)
            end
            constant
          end
        end

        # Tries to find a constant with the name specified in the argument string:
        #
        #   "Module".safe_constantize     # => Module
        #   "Test::Unit".safe_constantize # => Test::Unit
        #
        # The name is assumed to be the one of a top-level constant, no matter whether
        # it starts with "::" or not. No lexical context is taken into account:
        #
        #   C = 'outside'
        #   module M
        #     C = 'inside'
        #     C                    # => 'inside'
        #     "C".safe_constantize # => 'outside', same as ::C
        #   end
        #
        # nil is returned when the name is not in CamelCase or the constant (or part of it) is
        # unknown.
        #
        #   "blargle".safe_constantize  # => nil
        #   "UnknownModule".safe_constantize  # => nil
        #   "UnknownModule::Foo::Bar".safe_constantize  # => nil
        #
        def safe_constantize(camel_cased_word)
          begin
            constantize(camel_cased_word)
          rescue NameError => e
            raise unless e.message =~ /(uninitialized constant|wrong constant name) #{const_regexp(camel_cased_word)}$/ ||
              e.name.to_s == camel_cased_word.to_s
          rescue ArgumentError => e
            raise unless e.message =~ /not missing constant #{const_regexp(camel_cased_word)}\!$/
          end
        end
      end
    end
  end
end
