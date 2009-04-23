require 'test/unit'

module Context
  class << self
    attr_accessor :core_class
  end

  def self.setup(test_case)
    if core_class
      if core_class == test_case
        return
      else
        raise ArgumentError, "Currently, you're not allowed to run Context.setup again and clobber '#{core_class.name}'.  Require 'context/core' and pick ONE class."
      end
    end

    self.core_class = test_case
    test_case.class_eval do
      include TestCase
      extend  TestCase::ClassMethods

      # for some reason, Test::Unit::TestCase won't let me cleanly override
      # #suite with an extended module :(
      def self.suite
        context_suite
      end
    end
  end

  module TestCase
    module ClassMethods
      # Test::Unit uses ObjectSpace to figure out what Test::Unit:TestCase instances are running
      # Contexts are not named and therefore sometimes get garbage collected.
      # Think of #context_list as the shelter for nameless contexts
      attr_accessor :context_list

      def context_name #:nodoc:
        @context_name ||= ""
        if superclass.respond_to?(:context_name)
          return "#{superclass.context_name} #{@context_name}".gsub(/^\s+/, "")
        end
      end

      def context_name=(val) #:nodoc:
        @context_name = val
      end

      # Add a context to a set of tests.
      # 
      #   context "A new account" do
      #     it "should not have users"
      #       assert Account.new.users.empty?
      #     end
      #   end
      # 
      # The context name is prepended to the test name, so failures look like this:
      # 
      #   1) Failure:
      #   test_a_new_account_should_not_have_users() [./test/test_accounts.rb:4]:
      #   <false> is not true.
      # 
      # Contexts can also be nested like so:
      # 
      #   context "A new account" do
      #     context "created by the web application" do
      #       it "should have web as its vendor" do
      #         assert_equal "web", users(:web_user).vendor
      #       end
      #     end
      #   end
      # 
      # Since contexts create a singleton instance of a class, each one must have its own before/after blocks.  This
      # will be tweaked in future releases to allow you to chain these blocks from its parent contexts.
      #
      def context(name, &block)
        cls = Class.new(self)
        cls.context_name = name
      
        # Care about Rails tests in nested contexts
        cls.tests($1.constantize) if defined?(Rails) && 
          self.name =~ /^(.*(Controller|Helper|Mailer))Test/ && 
            self < ActiveSupport::TestCase

        cls.class_eval(&block)
        (self.context_list ||= []) << cls
        const_set("Test#{name.to_class_name}#{cls.object_id.abs}", cls)
        cls
      end

      %w(contexts describe describes group specify specifies).each {|m| alias_method m, :context}
    end
  end
end

require 'context/core_ext/string'
require 'context/core_ext/rails_hacks'

require 'context/version'
require 'context/suite'
require 'context/test'
require 'context/lifecycle'
require 'context/shared_behavior'