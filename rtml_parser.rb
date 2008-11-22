module RTMLParser

  # Required libraries
  require 'rubygems'
  require 'mechanize'
  require 'nokogiri'

  #RTML class
  # defines the elements of the RTML language
  class RTML

    attr_accessor :name
    attr_accessor :active_file
    attr_accessor :doc

    def initialize(filename)
      @name = filename.sub('.rtml', '')
      @active_file = File.open(filename, 'r+')
      @doc = @active_file.readlines
    end

    def params
      line = @doc[0]
      params = line[line.index('('), line.length]
      params = params.gsub(/[\(\)\n]/, '')
      params
    end

    def first_operator
      line = @doc[1]
      return line.split("\302\240")[0]
      #line.scan(/./u)
    end

    ## An operator is an element that can be clicked on
    ## and it can be edited.
    ## takes a string, and returns true if it's an operator.
    #def operator?(item)
    #  return (item.is_a?(Hpricot::Elem) and self.respond_to_link?("Edit")) ? true : false
    #end
    #
    ## An variable is an element that can be clicked on
    ## but it doesn't do anything.
    ## takes a string, and returns true if it's a variable.
    #def variable?(item)
    #  return (item.is_a?(Hpricot::Elem) and not self.respond_to_link?("Edit")) ? true : false
    #end
    #
    ## A param is not a variable or an operator.
    ## they are Hpricot::Text objects
    #def param?(item)
    #  return (!self.operator?(item) and !self.variable?(item)) ? true : false
    #end
    #
    #def respond_to_link?(link)
    #  return true if @current_page.links.text(link)
    #  false
    #end

  end

  #Parser class
  # grabs the html on RTML template pages, and returns the RTML
  # then writes it to a file
  class Parser

    attr_accessor :open_file
    attr_accessor :rtml_doc

    @@open_file = false

    #creates a file to be written to
    def self.load_file(filename, access)
      @rtml_doc = File.open(filename, access)
    end

    # setup the rtml file to be created when files are downloaded
    def self.setup_file(filename = "test.rtml")
      load_file(filename, "w+")
      @@open_file = true
    end

    # close the file.
    def self.close_file
      if @@open_file
        @@open_file = false
        @rtml_doc.close
      end
    end

    # takes the RTML page and pulls the information it needs from it.
    def self.parse_page(page)
      template_name = page.search('/html//body/form/p/b').text
      template_parameters = page.search('/html//body/form/p/tt').text.sub(/(\()/,"").sub(/(\))/, "")
      template_body = page.search('/html//body/form//pre')
      doc = Nokogiri::HTML(<<-eohtml)
        #{template_body.to_html}
      eohtml

      setup_file("#{template_name}.rtml")
      @rtml_doc.write("#{template_name} (#{template_parameters})\n")
      (doc/'pre').first.inner_text.split("\n").each do |line|
        @rtml_doc.write("#{line}\n")
      end
      close_file

    end

    # Returns a specified page.
    # Should always return the page you are looking for based off the link you pass it.
    # Options is a hash. I'm passing the security key.
    def self.get_page_from_link(link, options)
      temp_page = link.click
      sleep 1
      if temp_page.title.eql?('Verify your Security Key')
        form = temp_page.form_with(:name => 'verifyForm')
        form['skey'] = options['security_key']
        @key_result_page = form.click_button
        sleep 3

        if @key_result_page.title.eql?('Verify your Security Key')
          puts 'Unfortunately, that Security Key is not correct'
          puts '*** Closing Application ***'
          exit
        end
        temp_page = @key_result_page
      end

      temp_page
    end
  end

end