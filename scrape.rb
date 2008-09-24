require 'rubygems'
require 'open-uri'
require 'mechanize'
require 'logger'
require 'rtml_parser'

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
  #This returns some odd page with a single link on it.
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
    @store_front = page.links.text(@store_id).click
  else
    puts "Could not find #{@store_id}"
    exit
  end

  #Found the store, now we need to get to the store manager
  puts 'Looking for Manager'

  #NOTE:
  # Currently the form hangs up on the security key form. Only in Windows....... (vista)
  # It just locks up compeltely, not sure why. As long as there isn't a security key form then we are ok.
  # seems on a *nix system it's ok.
  if @store_front.forms.length > 0 && @store_front.uri.to_s.include?("edit.secure.yahoo.com")
    puts "Need to verify security key."
    sleep 1
    @store_front.forms.each do |form|
      case form.name
      when 'login_form'
        form['passwd'] = @password
        puts 'submitting login_form'
        @temp_page = form.click_button
        sleep 4
        break
      when 'a'
        form['passwd'] = @security_key
        puts 'submitting a form'
        @temp_page = form.click_button
        sleep 4
        break
      else
        puts form.name
      end
    end

    #not displaying errors.... There may be an issue with how the form is submitted.
    #You will be locked out if the security key is entered wrong 3 times.
    #If the URL has edit.secure.yahoo.com then it failed.
    if @temp_page.uri.to_s.include?("edit.secure.yahoo.com")
      puts 'Failed security key'
      @temp_page.search("ul font li") do |error|
        puts "*** " + error
      end
      exit
    else
      puts 'Security key verified.'
      puts "We are in #{@temp_page.uri.to_s}"
      @store_variable_page = @temp_page
    end

    puts "waiting on redirect..."
    sleep 4
  else
    #The store variable page could be one of a few different pages
    # 1. An ad for a store upgrade
    # 2. The Store manager
    # THIS SECTION NOT IN USE....
    @store_front.links.each do |link|
      case link.text
      when "Store Editor"
        puts "Found store editor link"
        @true_index = link.click
        break
      when "Store Manager"
        puts "Found store manager link, going to store manager"
        @store_manager = link.click
        sleep 2
        puts 'Going to Store Editor'
        @true_index = @store_manager.links.text("Store Editor").click
        break
      else
        puts "*"
      end
    end
  end
=begin
  @store_variable_page.links.each do |link|
    if link.text.eql?("Store Manager")
      puts @store_variable_page.title
      @new_page = link.click
      sleep 4
      puts "we are now at #{@new_page.uri.to_s}"

      @new_page.links.each do |l|
        if l.text.eql?("Store Editor")
          puts "found the real index page."
          @true_index = l.click
          sleep 4
          puts "we are now at #{@true_index.uri.to_s}"
        end
      end
    end
  end
=end
  puts 'Going to try to get to the contents page'
  @true_index.links.each do |link|
    if link.text.eql?("Contents")
      puts 'on index, found contents!'
      @store_contents = link.click
      puts 'going to look for the templates page'
      sleep 4
      @store_contents.links.each do |l|
        if l.text.eql?("Templates")
          puts 'gathering templates....'
          @store_templates = l.click
          sleep 2
        end
      end
    elsif link.text.eql?("Templates")
      puts "on contents, found templates!"
      @store_templates = link.click
      sleep 2
    end
  end

  puts 'We should have the templates. Trying to list them now....'

  sleep 2
  # As long as we are on the templates page,
  # we can grab all of them and start the next process.
  unless @store_templates.nil?
    @templates = @store_templates.search('/html//body/p/table[2]/tr[2]/td//a')

    # This is the xpath Firebug returns. Doesn't seem to work in here...
    # /html/body/p/table[2]/tbody/tr[2]/td[2]//a

    unless @templates.nil?
      @templates.each do |hpricot_link|
        puts "."
        template_page = @browser.click(hpricot_link)
        RTMLParser::Parser.parse_page(template_page)
        #puts hpricot_link
      end
    end
  end

  puts "done."
end