#Required Libraries
require 'watir'
require 'rtml_parser'

#Setup Variables
@upload_folder = '' #relative path

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
    @browser.select_lists[1].select(@rtml_template.first_operator)
    @browser.button(:value, 'Create').click
    @browser.link(:title, 'Replace').click

    @browser.link(:title, 'Templates').click
  end
end
