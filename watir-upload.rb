#Required Libraries
require 'watir'
require 'rtml_parser'

#Setup Variables
@upload_folder = 'test-st51-ventura' #relative path

@files = Dir.open(@upload_folder)
Dir.chdir(@upload_folder)

#setup the browser
@browser = Watir::IE.find(:title, 'Yahoo! Store Editor')

puts 'Cannot find browser window' and exit if @browser.nil?

@files.each do |filename|
  unless filename.eql?('.') or filename.eql?('..')
    @rtml_template = RTMLParser::RTML.new(filename)
    @browser.link(:title, 'New Template').click
    @browser.text_fields[1].set(@rtml_template.name)
    @browser.button(:value, 'Create').click
    @browser.link(:title, 'Edit Parms').click
    @browser.text_fields[1].set(@rtml_template.params)
    @browser.button(:value, 'Submit').click
    @browser.link(:text, 'BODY').click
    @browser.link(:title, 'Cut').click
    @browser.link(:text, 'HEAD').click
    @browser.link(:title, 'New').click

    @rtml_template.elements.each do |line|
      line.split("\302\240").each do |element|
        if @rtml_template.operator?(element)
          puts "selecting #{element} and creating"
          #@browser.select_lists[1].select(element)
          #@browser.button(:value, 'Create').click
          if @rtml_template.index(line) == 0
            #@browser.link(:title, 'Replace').click
            puts "clicking replace"
          else
            if rtml_template.past_within?(element)
              puts "pasting #{element} within"
            elsif rtml_template.past_after?(element)
              puts "pasting #{element} after"
            end
          end
        elsif @rtml_template.variable?(element)
          puts "handeling variable"
        elsif @rtml_template.param?(element)
          puts "handeling param"
        else
          puts "Couldn't determin the element #{element}"
          exit
        end
      end
    end

    @browser.link(:title, 'Templates').click
  end
end
