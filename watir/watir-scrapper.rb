require 'watir'

#setup variables
#requires Yahoo Small Business account.
@url = 'http://smallbusiness.yahoo.com/ecommerce/'
@store_list = 'http://store.yahoo.com/index4.html'
@login = ''
@password = ''
@security_key = ''
@store_id = ''

#setup the browser
@browser = Watir::IE.start(@url)

@browser.links.each do |link|
  if link.text.eql?('Small Business')
    link.click
  end
end

#smallbusiness_link.click
#login_form = @browser.form(:name, 'login_form')
#
#login_form.input(:name, 'login').set(@login)
#login_form.input(:name, 'passwd').set_trace_func(@password)
#login_form.submit