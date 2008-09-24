module RTMLParser

  # Required libraries
  require 'rubygems'
  require 'open-uri'
  require 'mechanize'
  require 'builder'

  #RTML class
  # defines the elements of the RTML language
  class RTML

    def initialize(page)
      @current_page = page
    end

    # An operator is an element that can be clicked on
    # and it can be edited.
    # takes a string, and returns true if it's an operator.
    def operator?(item)
      return (item.is_a?(Hpricot::Elem) and self.respond_to_link?("Edit")) ? true : false
    end

    # An variable is an element that can be clicked on
    # but it doesn't do anything.
    # takes a string, and returns true if it's a variable.
    def variable?(item)
      return (item.is_a?(Hpricot::Elem) and not self.respond_to_link?("Edit")) ? true : false
    end

    # A param is not a variable or an operator.
    # they are Hpricot::Text objects
    def param?(item)
      return (!self.operator?(item) and !self.variable?(item)) ? true : false
    end

    def respond_to_link?(link)
      return true if @current_page.links.text(link)
      false
    end

  end

  #Parser class
  # parse and generate the RTML from XML or XML to RTML
  class Parser

    # currently not in use.
    def self.load_file(file)
      @rtml_doc = File.open(file, File::RDONLY)
    end

    # setup the xml file to be created when files are downloaded
    def self.setup_xml_file(filename = "test.xml")
      file = File.open(filename, "w+")
      @xml = Builder::XmlMarkup.new(:target => file, :indent => 2)
      @xml.instruct!(:xml, :version => "1.1", :encoding => "US-ASCII")
    end

    # takes the RTML page and pulls the information it needs from it.
    def self.parse_page(page)
      @rtml = RTML.new(page)
      template_name = page.search('/html//body/form/p/b').text
      template_parameters = page.search('/html//body/form/p/tt').text.sub(/(\()/,"").sub(/(\))/, "")
      setup_xml_file("#{template_name}.xml")
      @xml.rtml do
        @xml.head do
          @xml.title(template_name)
          @xml.parameters(template_parameters)
        end
      end

    end

  end

end