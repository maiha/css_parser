require 'rubygems'
require 'dsl_accessor'
require 'hpricot'

class CssParser
  dsl_accessor :stored_css, proc{{}}

  ######################################################################
  ### Exceptions

  class ReservedCss < StandardError; end

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
    keys.inject({}){|h,key| h[key] = send(key); h}
  end

  ######################################################################
  ### Class Methods

  def self.file(file)
    html = NKF.nkf('-w', Pathname(file).read)
    new(html, file)
  end

  def self.css(key, pattern)
    key = key.to_s.intern
    guard_from_overridden(key)
    define_css(key, pattern)
  end

  private
    def self.css_module
      @css_module ||= (include (mod = Module.new); mod)
    end

    # stored_css object for this class
    def self.my_stored_css
      @my_stored_css ||= (stored_css.dup rescue stored_css)
    end

    def self.define_css(key, pattern)
      # not defined yet
      unless instance_methods.include?(key.to_s)
        css_module.module_eval do
          define_method(key) do
            pattern = self.class.my_stored_css[key]
            element = parser.search(pattern).first
            element ? element.inner_html : nil
          end
        end
      end

      my_stored_css[key] = pattern
    end

    def self.guard_from_overridden(key)
      return if my_stored_css.has_key?(key)

      if instance_methods(true).include?(key.to_s)
        raise ReservedCss, "#{key} is reserved for #{self.to_s.classify}##{key}"
      end
      if %w( attributes parser ).include?(key.to_s)
        raise ReservedCss, "#{key} is reserved for CssParser module"
      end
    end
end
