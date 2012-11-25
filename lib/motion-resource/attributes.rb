module RemoteModule
  class RemoteModel
    class << self
      def attributes
        @attributes ||= []
      end
      
      def attributes=(value)
        @attributes = value
      end
      
      def attribute(*fields)
        attr_reader *fields
        fields.each do |field|
          define_method "#{field}=" do |value|
            if value.is_a?(Hash) || value.is_a?(Array)
              instance_variable_set("@#{field}", value.dup)
            else
              instance_variable_set("@#{field}", value)
            end
          end
        end
        self.attributes += fields
      end
    end
    
    def initialize(params = {})
      update_attributes(params)
    end

    def update_attributes(params = {})
      attributes = self.methods - Object.methods
      params.each do |key, value|
        if attributes.member?((key.to_s + "=:").to_sym)
          self.send((key.to_s + "=:").to_sym, value)
        end
      end
    end
    
    def attributes
      self.class.attributes.inject({}) do |hash, attr|
        hash[attr] = send(attr)
        hash
      end
    end
  end
end