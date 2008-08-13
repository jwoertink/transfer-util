require 'rubygems'
require 'open-uri'
require 'mechanize'
require 'logger'

#setup variables
#requires Yahoo Small Business account.
@url = 'http://smallbusiness.yahoo.com/ecommerce/'
@store_list = 'http://store.yahoo.com/index4.html'
@login = ''
@password = ''
@security_key = ''
@store_id = ''

#setup the browser
@browser = WWW::Mechanize.new do |agent|
  agent.user_agent_alias = 'Windows Mozilla'
  agent.follow_meta_refresh = true
  agent.log = Logger.new("scrape.log")
  agent.keep_alive = false
end

#go to the specified URL
@browser.get(@url) do |page|

  #find the link that goes to the small business area and click it.
  #This returns the new login page
  if page.links.text("Small Business")
    puts "Found Small Business link"
    @login_page = page.links.text("Small Business").click
  else
    puts "Could not find small business link."
    exit
  end

  puts "Going to login"
  #Find the login form and fill in the input values.
  #This returns some odd page with a single link on it?????
  temp_page = @login_page.form_with(:name => 'login_form') do |form|
    form['login'] = @login
    form['passwd'] = @password
  end.submit

  #give it time to login.
  puts "waiting for redirect..."
  sleep 4

  #temp_page will either be a blank page with a single link
  #or redirect you back to the login page because login failed.
  if temp_page.uri.to_s.include?("login")
    puts "Not logged in."
    puts "an error occured."
    exit
  else
    puts "logged in"
    puts "Redirected to: " + temp_page.uri.to_s
  end

end

#We should be logged in at this point
#Just go to the store list.
@browser.get(@store_list) do |page|

  #We are looking for a particular store
  if page.links.text(@store_id)
    puts "Found #{@store_id}"
    @store_manager = page.links.text(@store_id).click
  else
    puts "Could not find #{@store_id}"
    exit
  end

  puts 'Looking for Store Editor'
  @store_manager.links.each do |link|
    if link.text.eql?("Store Editor")
      puts "Found store editor link"
      @store_index = @store_manager.links.text("Store Editor").click
    elsif link.text.eql?("Store Manager")
      puts "Found store manager link, going to store manager"
      @store_manager = @store_manager.links.text("Store Manager").click
      sleep 2
      puts 'Going to Store Editor'
      @store_index = @store_manager.links.text("Store Editor").click
    end
  end

  #NOTE:
  # Currently the form hangs up on the security key form. Only in Windows....... (vista)
  # It just locks up compeltely, not sure why. As long as there isn't a security key form then we are ok.
  # seems on a *nix system it just doesn't pass validation......
  if @store_manager.forms.length > 0 && @store_manager.uri.to_s.include?("edit.secure.yahoo.com")
    puts "Uh oh, need to enter in the security key"
    @store_manager.forms.each do |form|
      case form.name
      when 'login_form'
        form['passwd'] = @password
        puts 'submitting login_form'
        @temp_page = form.click_button
        break
      when 'a'
        form['passwd'] = @security_key
        puts 'submitting a form'
        @temp_page = form.click_button
        break
      else
        puts form.name
      end
    end
    
    #not displaying errors.... There may be an issue with how the form is submitted.
    #it locked me out after "supposedly" entering the wrong SK 3 times.
    #Verified it was the correct one. There might be a time delay, and that is what is causing 
    if @temp_page.uri.to_s.include?("edit.secure.yahoo.com")
      puts 'Failed security key'
      @temp_page.search("ul font li") do |error|
        puts "*** " + error
      end
      #exit
      @temp_page.search("html") do |html|
        puts html.inner_html
      end
    else
      puts 'Passed security key'
      @store_index = temp_page
    end

    puts "waiting on redirect..."
    sleep 4
  else
    @store_index = @store_manager.links.text("Store Editor").click
  end

  #TESTING SECURITY KEY FORM
=begin
  puts 'Inside index'
  puts 'Going to contents page'
  #@store_contents = @store_index.links.text("Contents").click
  @store_index.links.each do |link|
    puts link.text
  end
  
  puts 'gathering templates....'
  sleep 2
  #@store_templates = @store_contents.links.text("Templates").click
  #@store_contents.links.each do |link|
  #  puts link.text
  #end
  
  #template_page = Hpricot(open(@store_templates.uri.to_s))
  #puts template_page.search('a').each do |link|
  #  puts link
  #end
=end
  puts "done."
end
