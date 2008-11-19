#Required Libraries
require 'firewatir'
require 'rtml_parser'

#Setup Variables

@store_list_url = 'http://store.yahoo.com/index4.html'
@store_manager_url = "http://us-dc1-edit.store.yahoo.com/RT/MGR.#{@store_id}/doNotRedirectToOFB"

#Setup Browser
@browser = FireWatir::Firefox.new.attach(:title, 'Yahoo! Store Editor - Mozilla Firefox')

@browser.link(:name, 'New Template').click

#Fill Login form and submit
