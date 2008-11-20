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

@browser.text_field(:xpath, "/html/body/form/input[2]").set("j-test")

@browser.button(:value, 'Create').click

@browser.link(:title, 'Edit Parms').click

@browser.text_field(:xpath, "/html/body/form/input[2]").set("x y z")

@browser.button(:value, 'Submit').click

@browser.link(:xpath, '/html/body/form/pre/font/a[4]').click

@browser.link(:title, 'Cut').click

@browser.link(:xpath, '/html/body/form/pre/font/a').click

@browser.link(:title, 'New').click

@browser.select_list(:xpath, '/html/body/form/table/tbody/tr[2]/td[2]/select').select("DIV")

@browser.button(:value, 'Create').click

@browser.link(:title, 'Replace').click