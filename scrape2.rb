#Require Libraries
require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'logger'
require 'rtml_parser'

#Setup variable
@login_url = 'http://smallbusiness.yahoo.com/services/index.php'
@store_list_url = 'http://store.yahoo.com/index4.html'
@login = 'vwdjeremy'
@password = 'mar56jux8'
@security_key = 'super88dizl'
@store_id = 'test-st51-ventura'
@store_manager_url = "http://us-dc1-edit.store.yahoo.com/RT/MGR.#{@store_id}/doNotRedirectToOFB"

#Setup Browser
@browser = WWW::Mechanize.new do |agent|
  agent.user_agent_alias = 'Windows Mozilla'
  agent.follow_meta_refresh = true
  agent.keep_alive = false
  #agent.log = Logger.new("scrape.log")
end

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

puts 'Going to store manager'
entry_page.links.each do |link|
  if link.text.eql?('Store Editor')
    puts 'Going to store editor'
    @result_page = RTMLParser::Parser.get_page_from_link(link, {'security_key' => @security_key})

    if @result_page.links.text('Store Editor')
      @store_index = @result_page.links.text('Store Editor').click
    else
      @store_index = @result_page
    end
  end
end

#Go to 'types' page
puts 'Going to Types'
types_page = @store_index.links.text('Types').click

#Go to 'templates' page
puts 'Going to Templates'
templates_page = types_page.links.text('Templates').click

#Grab templates
puts 'Grabbing templates'
templates = templates_page.search('/html//body/p/table[2]/tr[2]/td//a')

#Create files
unless templates.nil?
  templates.each do |hpricot_link|
    template_page = @browser.click(hpricot_link)
    RTMLParser::Parser.parse_page(template_page)
  end

end
@end_time = Time.now
puts 'Done!'
puts "Transfer completed at #{@end_time.strftime('%H:%M:%S')}"
puts "Completed in #{(@end_time - @start_time).round} seconds."