#Require Libraries
require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'logger'
require 'rtml_parser'

#Setup variables
@login_url = 'http://smallbusiness.yahoo.com/services/index.php'
@store_list_url = 'http://store.yahoo.com/index4.html'
@login = ''
@password = ''
@security_key = ''
@store_id = ''
@store_manager_url = "http://us-dc1-edit.store.yahoo.com/RT/MGR.#{@store_id}/doNotRedirectToOFB"

#Setup Browser
@browser = WWW::Mechanize.new do |agent|
  agent.user_agent_alias = 'Windows Mozilla'
  agent.follow_meta_refresh = true
  agent.keep_alive = false
  #agent.log = Logger.new("scrape.log")
end

#Intro and grab starting time
puts 'Ventura RTML Transfer Util (beta)'
@start_time = Time.now
puts "Transfer started at #{@start_time.strftime('%H:%M:%S')}"

#Login to Yahoo or fail
puts 'Going to login page'
begin
  login_page = @browser.get(@login_url)
rescue Net::HTTPInternalServerError
  puts 'Could not connect to Yahoo!. Check your internet connection.'
  exit
end

#Fill Login form and submit
puts 'Attempting to login'
login_result_page = login_page.form_with(:name => 'login_form') do |form|
  form['login'] = @login
  form['passwd'] = @password
end.submit
sleep 3

if login_result_page.uri.to_s.include?('login')
  puts 'Invalid ID or password.'
  puts '*** Closing Application ***'
  exit
end

#Find Store or exit
puts "Searching for #{@store_id}"
store_list = @browser.get(@store_list_url)

unless store_list.links.text(@store_id)
  puts "Could not find #{@store_id}"
  puts '*** Closing Application ***'
  exit
end

#Grab current entry page
puts 'Logging into store'
entry_page = @browser.get(@store_manager_url)

if entry_page.title.eql?('Verify your Security Key')
  puts 'Verify your Security Key'
  @key_result_page = entry_page.form_with(:name => 'verifyForm') do |form|
    form['skey'] = @security_key
  end.submit
  sleep 3

  if @key_result_page.uri.to_s.include?('secure.login.yahoo.com')
    puts 'Unfortunately, that Security Key is not correct'
    puts '*** Closing Application ***'
    exit
  end

end

#Go to store manager
#This section still needs work.. Fails on some stores, but passes on others.
puts 'Going to store manager'
entry_page.links.each do |link|
  if link.text.eql?('Store Editor')
    puts 'Going to store editor'
    @result_page = RTMLParser::Parser.get_page_from_link(link, {'security_key' => @security_key})

    if @result_page.links.text('Store Editor').empty?
      @store_index = @result_page
    else
      @store_index = @result_page.links.text('Store Editor').click
    end
  end
end

#Go to 'types' page
puts 'Going to Types'
types_page = @store_index.links.text('Types').click

#Go to 'templates' page
puts 'Going to Templates'
templates_page = types_page.links.text('Templates').click

templates_page.links.each do |link|
  if link.text.eql?('New Template')
    puts 'On new template form page.'
    @new_template_form_page = link.click
  end
end

puts "Opening folder #{@store_id}"
@rtml_folder = Dir.open(@store_id)
Dir.chdir(@store_id)

@rtml_folder.each do |filename|
  unless filename.eql?('.') or filename.eql?('..')
    puts 'Creating new RTML object'
    @rtml_template = RTMLParser::RTML.new(filename)

    puts "Attempting to create new template called #{@rtml_template.name}"
    new_form = @new_template_form_page.forms[0]
    new_form.fields[1].value = @rtml_template.name
    @rtml_page = new_form.click_button

    #Can't click this link :(
    #The href for this link is javascript.
    #Mechanize currently doesn't handle javascript.
    #Ditching this project in favor of firewatir
    #
    puts 'Clicking on ()'
    #@params_form_page = @rtml_page.links.text('()').click

    puts 'Submitting params form'
    #param_form = @params_form_page.forms[0]
    #param_form.fields[1].value = @rtml_template.params
    #@rtml_page = param_form.click_button

  end
end

@end_time = Time.now
puts 'Done!'
puts "Transfer completed at #{@end_time.strftime('%H:%M:%S')}"
puts "Completed in #{(@end_time - @start_time).round} seconds."