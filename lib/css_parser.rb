require 'rubygems'
require 'dsl_accessor'
require 'hpricot'
require 'nkf'
require 'pathname'

class CssParser
  dsl_accessor :stored_css, proc{{}}

  ######################################################################
  ### Exceptions

  class ReservedCss   < StandardError; end
  class InvalidFormat < StandardError; end

  ######################################################################
  ### StoredCss

  StoredCss = Struct.new(:key, :pattern, :options)
  class StoredCss
    def formatter
      Formatter.guess(options[:as])
    end
  end

  ######################################################################
  ### Formatters

  module Formatter
    def self.guess(type)
      name = type.to_s.capitalize
      if name.empty?
        Base
      else
        Formatter.const_get(name)
      end
    rescue
      raise InvalidFormat, type.inspect
    end

    class Base
      def initialize(element)
        @element = element
      end

      def execute
        raise NotImplementedError, "subclass responsibility"
      end
    end

    class Html < Base
      def execute
        @element.inner_html
      end
    end

    class Text < Base
      def execute
        @element.inner_text
      end
    end
  end

  ######################################################################
  ### InstanceMethods

  def initialize(html = nil, filename = nil)
    @html     = html.to_s
    @filename = filename
  end

  def parser
    @parser ||= Hpricot(@html)
  end

  def attributes(keys = nil)
    keys ||= self.class.my_stored_css.keys
    keys.inject({}){|h,key| h[key] = __send__(key); h}
  end

  ######################################################################
  ### Class Methods

  def self.file(file)
    html = NKF.nkf('-w', Pathname(file).read)
    new(html, file)
  end

  def self.css(key, pattern, options = {})
    key = key.to_s.intern
    options[:as] ||= :html
    guard_from_overridden(key)
    define_css(key, pattern, options)
  end

  private
    def self.css_module
      @css_module ||= (include (mod = Module.new); mod)
    end

    # stored_css object for this class
    def self.my_stored_css
      @my_stored_css ||= (stored_css.dup rescue stored_css)
    end

    def self.define_css(key, pattern, options)
      stored = StoredCss.new(key, pattern, options)

      # when the instance method is not defined yet
      unless instance_methods.include?(key.to_s)
        css_module.module_eval do
          define_method(key) do
            stored  = self.class.my_stored_css[key]
            element = parser.search(stored.pattern).first
            element ? stored.formatter.new(element).execute : nil
          end
        end
      end

      # update stored
      my_stored_css[key] = stored
    end

    def self.guard_from_overridden(key)
      return if my_stored_css.has_key?(key)

      if instance_methods(true).include?(key.to_s)
        raise ReservedCss, "#{key} is reserved for #{self.to_s}##{key}"
      end
      if %w( attributes parser ).include?(key.to_s)
        raise ReservedCss, "#{key} is reserved for CssParser module"
      end
    end
end
