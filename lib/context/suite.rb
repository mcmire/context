module Context
  module TestCase::ClassMethods
    # Tweaks to standard method so we don't get superclass methods and we don't
    # get weird default tests
    def context_suite # :nodoc:
      method_names = public_instance_methods - superclass.public_instance_methods
  
      tests = method_names.delete_if {|method_name| method_name !~ /^test./}
      suite = TestSuite.new(name)
      
      tests.sort.each do |test|
        catch(:invalid_test) do
          suite << new(test)
        end
      end
      
      suite
    end
  end

  class TestSuite < Test::Unit::TestSuite
    # Runs the tests and/or suites contained in this
    # TestSuite.
    def run(result, &progress_block) # :nodoc:
      yield(STARTED, name)
      ivars_from_callback = @tests.first.run_all_callbacks(:before) if @tests.first.is_a?(Context.core_class)
      @tests.each do |test|
        test.set_values_from_callbacks(ivars_from_callback) if ivars_from_callback
        test.run(result, &progress_block)
      end
      ivars_from_callback = @tests.first.run_all_callbacks(:after) if ivars_from_callback
      yield(FINISHED, name)
    end
  end
end