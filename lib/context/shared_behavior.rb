class Test::Unit::TestCase
  class << self
    def shared(name, &block)
      case name.class.name
      when "String"
        name = name.to_module_name
      when "Symbol"
        name = name.to_s.to_module_name
      else
        raise ArgumentError, "Provide a String or Symbol as the name of the shared behavior group"
      end
      
      Object.const_set(name, Module.new(&block))
    end
    
    %w(shared_behavior share_as share_behavior_as shared_examples_for).each {|m| alias_method m, :shared}
    
    def use(shared_name)
      case shared_name.class.name
      when "Module"
        include shared_name
      when "String"
        include Object.const_get(shared_name.to_module_name)
      when "Symbol"
        include Object.const_get(shared_name.to_s.to_module_name)
      else
        raise ArgumentError, "Provide a String or Symbol as the name of the shared behavior group or the module name"
      end
    end
    
    %w(uses it_should_behave_like behaves_like uses_examples_from).each {|m| alias_method m, :use}
  end
end