module RTMLParser

  class RTML

    require 'rubygems'
    require 'open-uri'
    require 'mechanize'

    def self.load_file(file)
      @rtml_doc = File.open(file, File::RDONLY)
    end

    def self.parse_page(page)
      
    end

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

end