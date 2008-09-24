module RTMLParser

  # Required libraries
  require 'rubygems'
  require 'open-uri'
  require 'mechanize'
  require 'builder'

  #RTML class
  # defines the elements of the RTML language
  class RTML

    def is_param?(item)
      return item[0,1].eql?("|") ? true : false
    end

    def is_operator?(item)
      return item.match(/[A-Z]/) ? true : false
    end

    def is_variable?(item)
      return (item.match(/[a-z]/) and !item[0,1].eql?("|")) ? true : false
    end

  end

  #Parser class
  # parse and generate the RTML from XML or XML to RTML
  class Parser

    def self.load_file(file)
      @rtml_doc = File.open(file, File::RDONLY)
    end

    # setup the xml file to be created when files are downloaded
    def self.setup_xml_file(filename = "test.xml")
      file = File.new(filename, "w+")
      @xml = Builder::XmlMarkup.new(:target => file, :indent => 2)
      @xml.instruct!(:xml, :version => "1.1", :encoding => "US-ASCII")
    end

    # takes the RTML page and pulls the information it needs from it.
    def self.parse_page(page)
      template_name = page.search('/html//body/form/p/b')
      

      setup_xml_file("#{template_name}.xml")

    end
  end

end