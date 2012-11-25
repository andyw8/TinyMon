module RemoteModule
  class RemoteModel
    class << self
      def has_one(name)
        define_method name do
          instance_variable_get("@#{name}")
        end
        
        define_method "#{name}=" do |value|
          klass = Object.const_get(name.to_s.classify)
          value = klass.new(value) if value.is_a?(Hash)
          instance_variable_set("@#{name}", value)
        end
        
        define_method "reset_#{name}" do
          instance_variable_set("@#{name}", nil)
        end
      end

      def has_many(name, params = lambda { nil })
        backwards_association = self.name.underscore
        
        define_method name do |&block|
          if block.nil?
            instance_variable_get("@#{name}") || []
          else
            cached = instance_variable_get("@#{name}")
            block.call(cached) and return if cached
          
            Object.const_get(name.to_s.classify).find_all(params.call(self)) do |results|
              if results
                results.each do |result|
                  result.send("#{backwards_association}=", self)
                end
              end
              instance_variable_set("@#{name}", results)
              block.call(results)
            end
          end
        end
        
        define_method "#{name}=" do |array|
          klass = Object.const_get(name.to_s.classify)
          instance_variable_set("@#{name}", []) if instance_variable_get("@#{name}").blank?
          
          array.each do |value|
            value = klass.new(value) if value.is_a?(Hash)
            instance_variable_get("@#{name}") << value
          end
        end
        
        define_method "reset_#{name}" do
          instance_variable_set("@#{name}", nil)
        end
      end

      def belongs_to(name, params = lambda { nil })
        define_method name do |&block|
          if block.nil?
            instance_variable_get("@#{name}")
          else
            cached = instance_variable_get("@#{name}")
            block.call(cached) and return if cached
          
            Object.const_get(name.to_s.classify).find(self.send("#{name}_id"), params.call(self)) do |result|
              instance_variable_set("@#{name}", result)
              block.call(result)
            end
          end
        end
        
        define_method "#{name}=" do |value|
          klass = Object.const_get(name.to_s.classify)
          value = klass.new(value) if value.is_a?(Hash)
          instance_variable_set("@#{name}", value)
        end
        
        define_method "reset_#{name}" do
          instance_variable_set("@#{name}", nil)
        end
      end
    end

    class << self
      def scope(name)
        metaclass.send(:define_method, name) do |&block|
          fetch_collection(send("#{name}_url"), &block)
        end
      end
    end
  end
end
