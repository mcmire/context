require File.dirname(__FILE__) + '/test_helper.rb'

class TestCoreExt < Test::Unit::TestCase
  context "A string" do
    it "should be converted to method name" do
      assert_equal 'this_is_fun', "this is fun".to_method_name
    end

    it "should be converted to class name" do
      assert_equal 'ThisIsFunYes_', "this is fun... - (yes)??!".to_class_name
    end
    
    it "should be downcased when converted" do
      assert_equal 'this_is_a_blast', "THIS is A BlASt".to_method_name
    end
    
    it "should change spaces to _" do
      assert_equal 'this_has_been_great', "This has been great".to_method_name
    end

    it "should change dangerous punctuation to _" do
      assert_equal 'no_really_this_was_good_', "No, really; this was #good!".to_method_name
    end
  end
end
