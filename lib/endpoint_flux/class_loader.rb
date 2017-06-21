module EndpointFlux
  module ClassLoader
    module_function

    def load_class(klass_name)
      return klass_name if klass_name.is_a?(Class)

      constantize('::' + string_to_class_name(klass_name.to_s))
    rescue NameError
      nil
    end

    def load_class!(klass_name)
      load_class(klass_name) ||
        raise("The [#{klass_name}] should be a string representing a class")
    end

    def string_to_class_name(klass_name)
      klass_name
        .sub(%r{^[a-z\d]*}) { $&.capitalize }
        .gsub(%r{(?:_|(\/))([a-z\d]*)}) do
          "#{Regexp.last_match[1]}#{Regexp.last_match[2].capitalize}"
        end
        .gsub('/', '::')
    end

    # File activesupport/lib/active_support/inflector/methods.rb, line 249
    def constantize(camel_cased_word)
      names = camel_cased_word.split('::')

      # Remove the first blank element in case of '::ClassName' notation.
      names.shift if names.size > 1 && names.first.empty?

      names.inject(Object) do |constant, name|
        if constant == Object
          constant.const_get(name)
        else
          candidate = constant.const_get(name)
          next candidate if constant.const_defined?(name, false)
          next candidate unless Object.const_defined?(name)

          # Go down the ancestors to check if it is owned directly. The check
          # stops when we reach Object or the end of ancestors tree.
          constant = constant.ancestors.inject do |const, ancestor|
            break const    if ancestor == Object
            break ancestor if ancestor.const_defined?(name, false)
            const
          end

          # owner is in Object, so raise
          constant.const_get(name, false)
        end
      end
    end
  end
end