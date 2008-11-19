#Required Libraries
require 'watir'
require 'rtml_parser'

#Setup Variables
@store_list_url = 'http://store.yahoo.com/index4.html'
@store_manager_url = "http://us-dc1-edit.store.yahoo.com/RT/MGR.#{@store_id}/doNotRedirectToOFB"

#setup the browser
@browser = Watir::IE.find(:title, 'Yahoo! Store Editor')

if @browser.nil?
  puts 'Cannot find browser window'
  exit
end

@browser.link(:title, 'New Template').click

@browser.text_field("/html/body/form/input[2]").set("j-test")