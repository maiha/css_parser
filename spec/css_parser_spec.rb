require File.join( File.dirname(__FILE__), "spec_helper" )

describe CssParser do
  it "should provide .file" do
    CssParser.should respond_to(:file)
  end

  describe ".file" do
    it "should return a CssParser" do
      CssParser.file(__FILE__).class.should == CssParser
    end
  end

  it "should provide .css" do
    CssParser.should respond_to(:css)
  end

  describe ".css" do
    it "should create an instance-level accessor to the argument" do
      lambda {CssParser.foo2    }.should raise_error(NoMethodError)
      lambda {CssParser.new.foo2}.should raise_error(NoMethodError)
      CssParser.css :foo2, "pattern"
      lambda {CssParser.foo2    }.should raise_error(NoMethodError)
      lambda {CssParser.new.foo2}.should_not raise_error(NoMethodError)
    end

    describe " should raise" do
      it "when an existing instance method is specified" do
        lambda {
          CssParser.css :send, "pattern"
        }.should raise_error(CssParser::ReservedCss)
      end

      it "when reserved methods are specified" do
        lambda {
          CssParser.css :attributes, "pattern"
        }.should raise_error(CssParser::ReservedCss)
        lambda {
          CssParser.css :parser, "pattern"
        }.should raise_error(CssParser::ReservedCss)
      end

    end

    it "should parse" do
      class CssParser
        css :foo, "div"
      end

      foo = CssParser.new('<div>maiha</div>')
      foo.foo.should == "maiha"
    end

    it "should respect css selector" do
      class Foo < CssParser
        css :name, "div.name"
      end

      foo = Foo.new('<div>xxx</div><div class=name>maiha</div>')
      foo.name.should == "maiha"
    end

    it "should define instance method as module" do
      class CssParser
        css :foo, "div"

        def foo
          "[#{super}]"
        end
      end

      foo = CssParser.new('<div>a</div>')
      foo.foo.should == "[a]"
    end
  end

  it "should provide #parser" do
    CssParser.new.should respond_to(:parser)
  end

  it "should provide #attributes" do
    CssParser.new.should respond_to(:attributes)
  end

  describe "#attributes" do
    it "should return composed hash" do
      class Foo < CssParser
        css :name, "#name"
        css :age , "#age"
      end

      Foo.new('').attributes.should == {:age=>nil, :name=>nil}
    end
  end

end
