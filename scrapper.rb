require './constants'
require 'watir'
require 'watir-scroll'
require 'csv'
require 'pry'
require 'sanitize'
require 'date'

def write_into_file(filename, array)
	CSV.open(filename, 	"ab") do |csv|
		csv << array
	end
end

def collect_links(browser, filename)
	browser.links(class: LISTING_LINK_CLASSES).each do |link|
		file = read_file(filename).nil? ? [] : read_file(filename)
		unless file.include?(link.href)
			write_into_file(filename, [link.href])
		end
	end
end

def read_file(filename)
	if File.exist?(filename)
		array = []
		CSV.foreach(filename) do |row|
			row.each do |cell|
				array << cell
			end
		end
		array
	end
end

def read_links_from_page(browser)
	puts "ICO BENCH SCRAPPING SCRIPT"
	puts "Do you want to enter custom url?"
	response = gets.chomp
	case response
	when 'y' || 'Y' || "yes" || "YES" || "Yes"
		puts "Enter the url for the ico listing"
		url = gets.chomp
		browser.goto(url)
		puts "The links will be saved in links.csv"
		collect_links(url, DEFAULT_LINKS_CSV_FILE_NAME)
	else
		puts "Collecting links from the default url"
		puts "Enter the starting page number"
		first_page = gets.chomp.to_i
		puts "Enter the last page number"
		last_page = gets.chomp.to_i
		(first_page..last_page).each do |page_number|
			url = "https://icobench.com/icos?page=#{page_number}&filterBonus=&filterBounty=&filterTeam=&filterExpert=&filterSort=&filterCategory=all&filterRating=any&filterStatus=ended&filterCountry=any&filterRegistration=0&filterExcludeArea=none&filterPlatform=any&filterCurrency=any&s=&filterStartAfter=&filterEndBefore="
			browser.goto(url)
			collect_links(browser, DEFAULT_LINKS_CSV_FILE_NAME)
		end
	end
end

def raise_not_found(browser, keyword)
	puts "#{keyword} not found for #{get_name(browser)}"
end

def collect_filename
	puts "Do you want to use the default file?"
	status = gets.chomp
	if status == "YES" || status == "yes" || status == "Y" || status == "y"
		read_file(DEFAULT_LINKS_CSV_FILE_NAME)
	else
		puts "Enter Filename for the links csv"
		filename = gets.chomp
		read_file(filename)
	end
end

def get_name(browser)
	if browser.div(class: NAME_CLASSES).h1.exist?
		browser.div(class: NAME_CLASSES).h1.text
	else
		raise_not_found(browser, "name")
	end	
end

def get_moto(browser)
	if browser.div(class: NAME_CLASSES).h2.exist?
		browser.div(class: NAME_CLASSES).h2.text
	else
		raise_not_found(browser, "moto")
	end
end

def get_about(browser)
	if browser.div(class: ICO_INFORMATION_CLASSES).p.exist?
		browser.div(class: ICO_INFORMATION_CLASSES).p.text
	else
		raise_not_found(browser, "about")
	end
end

def get_categories(browser)
	array = []
	if browser.div(class: CATEGORIES_CLASSES).exist?
		browser.div(class: CATEGORIES_CLASSES).links.each do |link|
			array << link.text
		end
	else
		raise_not_found(browser, "Categories Section")
	end
	array
end

def get_value_of_tokens(browser)
	if browser.div(class: VALUE_OF_TOKENS_SOLD_CLASSES).exist?
		browser.div(class: VALUE_OF_TOKENS_SOLD_CLASSES).text
	else
		raise_not_found(browser, "Value of Token")
	end
end

def get_token_information(browser)
	array = []
	if browser.div(class: TOKEN_INFORMATION_CLASSES).div(class: TOKEN_INFORMATION_ROW_CLASSES).exist?
		hash = {}
		browser.div(class: TOKEN_INFORMATION_CLASSES).divs(class: TOKEN_INFORMATION_ROW_CLASSES).each do|div|
			hash[div.divs[0].text] =  div.divs[1].text
		end
	else
		raise_not_found(browser, "Token information section")
	end
	hash
end

def get_social_links(browser)
	array = []
	if browser.div(class: FIXED_DATA_CLASSES).div(class: SOCIAL_LINKS_CLASSES).exist?
		browser.div(class: FIXED_DATA_CLASSES).div(class: SOCIAL_LINKS_CLASSES).links.each do |link|
			array << link.href
		end
	else
		raise_not_found(browser, "Social Links Section")
	end
	array
end

def get_description(browser)
	if browser.div(class: TAB_CONTENT_CLASSES, id: DESCRIPTION_ID).exist?
		browser.div(class: TAB_CONTENT_CLASSES, id: DESCRIPTION_ID).text
	else
		raise_not_found(browser, "Description")
	end
end

def get_team(browser)
	array = []
	if browser.div(class: TAB_CONTENT_CLASSES, id: TEAM_ID).div(class: MEMBER_ROW_CLASSES).exist?
		browser.div(class: TAB_CONTENT_CLASSES, id: TEAM_ID).divs(class: MEMBER_ROW_CLASSES).each do |row|
			if row.div(class: MEMBER_CLASSES).exist?
				row.divs(class: MEMBER_CLASSES).each do |member|
					hash = {}
					hash[:name] = member.h3.inner_html if member.h3.exist?
					hash[:designation] = member.h4.inner_html if member.h4.exist?
					hash[:social_links] = []
					if member.div(class: SOCIAL_LINKS_CLASSES).exist?
						member.div(class: SOCIAL_LINKS_CLASSES).links.each do |link|
							hash[:social_links] << link.href
						end
					else
						raise_not_found(browser, "linkedin for member")
					end
					array << hash
				end
			else
				raise_not_found(browser, "member")
			end
		end
	else
		raise_not_found(browser, "Team section")
	end
	array
end

def get_milestones(browser)
	array = []
	if browser.div(class: TAB_CONTENT_CLASSES, id: MILESTONES_ID).div(class: MILESTONES_ROW_CLASSES).exist?
		browser.div(class: TAB_CONTENT_CLASSES, id: MILESTONES_ID).divs(class: MILESTONES_ROW_CLASSES).each do |row|
			hash = {}
			hash[:time] = row.div(class: MILESTONE_BUBBLE_CLASSES).div(class: MILESTONE_YEAR_CLASSES).inner_html if row.div(class: MILESTONE_BUBBLE_CLASSES).div(class: MILESTONE_YEAR_CLASSES).exist?
			hash[:description] =  row.div(class: MILESTONE_BUBBLE_CLASSES).p.inner_html if row.div(class: MILESTONE_BUBBLE_CLASSES).p.exist?
			array << hash
		end
	else
		raise_not_found(browser, "Milestones Section")
	end
	array
end

def get_token_financial_information(browser)
	array = []
	if browser.div(class: TAB_CONTENT_CLASSES, id: FINANCES_ID).div(class: LEFT_FINANCIAL_BOX_CLASSES).div(class: FINANCIAL_ROW_CLASSES).exist?
		browser.div(class: TAB_CONTENT_CLASSES, id: FINANCES_ID).div(class: LEFT_FINANCIAL_BOX_CLASSES).divs(class: FINANCIAL_ROW_CLASSES).each do |row|
			hash = {}
			if row.div(class: FINANCIAL_ROW_LABEL_CLASSES).exist?
				label = row.div(class: FINANCIAL_ROW_LABEL_CLASSES).inner_html
			else
				raise_not_found(browser, "financial row label")
			end 
			if row.div(class: BONUS_TEXT_CLASSES).exist?
				hash["Bonus"] = Sanitize.fragment(row.div(class: BONUS_TEXT_CLASSES).inner_html)
			end
			if row.div(class: FINANCIAL_ROW_VALUE_CLASSES).exist?
				value = row.div(class: FINANCIAL_ROW_VALUE_CLASSES).inner_html
			else
				raise_not_found(browser, "Financial row value")
			end
			if value and label
				hash[label] = value
			end
			array << hash
		end
	else
		raise_not_found(browser, "financial row")
	end
	array.reduce({}, :merge)
end

def get_investment_information(browser)
	array = []
	if browser.div(class: TAB_CONTENT_CLASSES, id: FINANCES_ID).div(class: RIGHT_FINANCIAL_BOX_CLASSES).div(class: INVESTMENT_ROW_CLASSES).exist?
		browser.div(class: TAB_CONTENT_CLASSES, id: FINANCES_ID).div(class: RIGHT_FINANCIAL_BOX_CLASSES).divs(class: INVESTMENT_ROW_CLASSES).each do |row|
			hash = {}
			if row.div(class: INVESTMENT_ROW_LABEL_CLASSES).exist?
				label = row.div(class: INVESTMENT_ROW_LABEL_CLASSES).inner_html
			else
				raise_not_found(browser, "investment row label")
			end
			if row.div(class: INVESTMENT_ROW_VALUE_CLASSES).exist?
				value = []
				if row.div(class: INVESTMENT_ROW_VALUE_CLASSES).small.exist?
					row.div(class: INVESTMENT_ROW_VALUE_CLASSES).smalls.each do |small|
						value << small.inner_html
					end
				end
				value << row.div(class: INVESTMENT_ROW_VALUE_CLASSES).inner_html.gsub( /<small.+small>/m , "")
				value
			else
				raise_not_found(browser, "investment row value")
			end
			if label and value
				value.each_with_index do |currency, index|
					hash["#{label}_#{index}"] = currency
				end
			end
			array << hash
		end
	else
		raise_not_found(browser, "Investment row")
	end
	array.reduce({}, :merge)
end

def get_white_paper_link(browser)
	if browser.link(text: WHITE_PAPER_LINK_TEXT).exist?
		browser.link(text: WHITE_PAPER_LINK_TEXT).href
	else
		raise_not_found(browser, "White Paper Link")
	end
end

def collect_data(browser)
	hash = {}
	values = %i(
							name 
							moto 
							about 
							categories
							value_of_tokens 
							token_information 
							social_links 
							description 
							team 
							milestones 
							token_financial_information
							investment_information
							white_paper_link
						)
	values.each do |value|
		method = ("get_" + value.to_s).to_sym
		hash[value] = send(method, browser)
	end
	hash
end

def headers_for_master
	#anything added here has to be added as a key in the parsed hash
	%w{name one_liner description industry sale_raised 
	symbol price_in_preico price_in_ico country preico_start_date
	preico_end_date ico_start_date ico_end_date social_link_slack social_link_twitter 
	social_link_facebook social_link_vk social_link_github social_link_reddit social_link_bitcointalk 
	social_link_medium social_link_telegram social_link_youtube social_link_website about platform sale_supply
	accepted_currency ico_distribution soft_cap hard_cap raised_amount_usd
	raised_amount_eth raised_amount_btc raised_amount_ltc raised_amount_xrp bonus white_paper_link
	name_1 designation_1 linkedin_1 name_2 designation_2 linkedin_3 name_4 designation_4 
	linkedin_4 name_5 designation_5 linkedin_5 name_6 designation_7 linkedin_8 name_9 
	designation_9 linkedin_9 name_10 designation_10 linkedin_10 name_11 designation_11
	linkedin_11 name_12 designation_12 linkedin_12 name_13 designation_13 linkedin_13
	name_14 designation_14 linkedin_14 name_15 designation_15 linkedin_15 name_16
	designation_16 linkedin_16 name_17 designation_17 linkedin_17 name_18 designation_18
	linkedin_18 name_19 designation_19 linkedin_19 name_20 designation_20 linkedin_20
	name_21 designation_21 linkedin_21 name_22 designation_22 linkedin_22
	time_1 description_1 time_2 description_2 time_3 description_3 time_4 description_4 
	time_5 description_5 time_6 description_6 time_7 description_8 time_9 description_9
	time_10 description_10 time_11 description_11 time_12 description_12 time_13 description_13
	time_14 description_14 time_15 description_15 time_16 description_16 time_17 description_17
	time_18 description_18 time_19 description_19 time_20 description_20}
end

def parse_hash(input_hash)
	hash = {}
	hash[:name] = input_hash[:name].nil? ? "" : input_hash[:name] 
	hash[:one_liner] = input_hash[:moto].nil? ? "" : input_hash[:moto]
	hash[:description] = input_hash[:about].nil? ? "" : input_hash[:about]
	hash[:industry] = input_hash[:categories].nil? ? "" : input_hash[:categories].join(', ')
	hash[:sale_raised] = input_hash[:value_of_tokens].nil? ? "" : input_hash[:value_of_tokens]
	hash[:symbol] = input_hash[:token_information]["Token"].nil? ? "" : input_hash[:token_information]["Token"]
	hash[:price_in_preico] = input_hash[:token_information]["Price in preICO"].nil? ? "" : input_hash[:token_information]["Price in preICO"] 
	hash[:price_in_ico] = input_hash[:token_information]["Price in ICO"].nil? ? "" : input_hash[:token_information]["Price in ICO"]
	hash[:country] = input_hash[:token_information]["Country"].nil? ? "" : input_hash[:token_information]["Country"]
	hash[:preico_start_date] = input_hash[:token_information]["preICO start"].nil? ? "" : input_hash[:token_information]["preICO start"]
	hash[:preico_end_date] = input_hash[:token_information]["preICO end"].nil? ? "" : input_hash[:token_information]["preICO end"]
	hash[:ico_start_date] = input_hash[:token_information]["ICO start"].nil? ? "" : input_hash[:token_information]["ICO start"]
	hash[:ico_end_date] = input_hash[:token_information]["ICO end"].nil? ? "" : input_hash[:token_information]["ICO end"]

	slack_link = input_hash[:social_links].select {|u| u.include?('slack') }
	twitter_link = input_hash[:social_links].select {|u| u.include?('twitter') }
	facebook_link = input_hash[:social_links].select {|u| u.include?('facebook') }
	vk_link = input_hash[:social_links].select {|u| u.include?('vk') }
	github_link = input_hash[:social_links].select {|u| u.include?('github') }
	reddit_link = input_hash[:social_links].select {|u| u.include?('reddit') }
	bitcointalk_link = input_hash[:social_links].select {|u| u.include?('bitcointalk') }
	medium_link = input_hash[:social_links].select {|u| u.include?('medium.com') }
	telegram_link = input_hash[:social_links].select {|u| u.include?('t.me')}
	youtube_link = input_hash[:social_links].select {|u| u.include?('youtube')}
	website_link = input_hash[:social_links] - slack_link - twitter_link - facebook_link - vk_link - github_link - reddit_link - bitcointalk_link - medium_link - telegram_link - youtube_link
	
	hash[:social_link_slack] = slack_link.nil? ? "" : slack_link.first
	hash[:social_link_twitter] = twitter_link.nil? ? "" : twitter_link.first
	hash[:social_link_facebook] = facebook_link.nil? ? "" : facebook_link.first
	hash[:social_link_vk] = vk_link.nil? ? "" : vk_link.first
	hash[:social_link_github] = github_link.nil? ? "" : github_link.first
	hash[:social_link_reddit] = reddit_link.nil? ? "" : reddit_link.first
	hash[:social_link_bitcointalk] = bitcointalk_link.nil? ? "" : bitcointalk_link.first
	hash[:social_link_medium] = medium_link.nil? ? "" : medium_link.first
	hash[:social_link_telegram] = telegram_link.nil? ? "" : telegram_link.first
	hash[:social_link_youtube] = youtube_link.nil? ? "" : youtube_link.first
	hash[:social_link_website] = website_link.nil? || website_link.empty? ? "" : website_link
	hash[:about] = input_hash[:description].empty? ? "" : input_hash[:description]
	hash[:platform] = input_hash[:token_financial_information]["Platform"].nil? ? "" : input_hash[:token_financial_information]["Platform"]
	hash[:sale_supply] = input_hash[:token_financial_information]["Tokens for sale"].nil? ? "" : input_hash[:token_financial_information]["Tokens for sale"]
	hash[:accepted_currency] = input_hash[:investment_information]["Accepting_0"].nil? ? "" :  input_hash[:investment_information]["Accepting_0"]
	hash[:ico_distribution] = input_hash[:investment_information]["Distributed in ICO_0"].nil? ? "" :  input_hash[:investment_information]["Distributed in ICO_0"]
	hash[:soft_cap] = input_hash[:investment_information]["Soft cap_0"].nil? ? "" : input_hash[:investment_information]["Soft cap_0"]
	hash[:hard_cap] = input_hash[:investment_information]["Hard cap_0"].nil? ? "" : input_hash[:investment_information]["Hard cap_0"]

	raised_amount_array = []
	input_hash[:investment_information].each_with_index do |info, index|
		raised_amount_array << input_hash[:investment_information]["Raised_#{index}"]
	end
	raised_amount_array.compact!
	raised_usd = raised_amount_array.select {|u| u.include?('$')}
	raised_eth = raised_amount_array.select {|u| u.include?('ETH') || u.include?('eth')}
	raised_btc = raised_amount_array.select {|u| u.include?('BTC') || u.include?('btc')}
	raised_ltc = raised_amount_array.select {|u| u.include?('LTC') || u.include?('ltc')}
	raised_xrp = raised_amount_array.select {|u| u.include?('XRP') || u.include?('xrp')}

	hash[:raised_amount_usd] = raised_usd.nil? ? "" : raised_usd.first
	hash[:raised_amount_eth] = raised_eth.nil? ? "" : raised_eth.first
	hash[:raised_amount_btc] = raised_btc.nil? ? "" : raised_btc.first
	hash[:raised_amount_ltc] = raised_ltc.nil? ? "" : raised_ltc.first
	hash[:raised_amount_xrp] = raised_xrp.nil? ? "" : raised_xrp.first
	hash[:white_paper_link] = input_hash[:white_paper_link].nil? ? "" : input_hash[:white_paper_link]
	hash[:bonus] = input_hash[:token_financial_information]["Bonus"].nil? ? "" : input_hash[:token_financial_information]["Bonus"]
	(1..22).each do |member_number|
		hash["name_#{member_number}".to_sym] = input_hash[:team][member_number-1].nil? ? "" : input_hash[:team][member_number-1][:name]
		hash["designation_#{member_number}".to_sym] = input_hash[:team][member_number-1].nil? ? "" : input_hash[:team][member_number-1][:name]
		linkedin_link = []
		linkedin_link = input_hash[:team][member_number-1][:social_links].select {|u| u.include?('linkedin')} unless input_hash[:team][member_number-1].nil?
		hash["linkedin_#{member_number}".to_sym] = linkedin_link.empty? || linkedin_link.nil? ? "" : linkedin_link.first
	end
	(1..20).each do |milestone_number|
		hash["time_#{milestone_number}".to_sym] = input_hash[:milestones][milestone_number-1].nil? ? "" : input_hash[:milestones][milestone_number-1][:time]
		hash["description_#{milestone_number}".to_sym] = input_hash[:milestones][milestone_number-1].nil? ? "" : input_hash[:milestones][milestone_number-1][:description]
	end
	hash
end

def write_data(info_hash)
	master = []
	master = CSV.read(DEFAULT_OUTPUT_FILENAME) if File.exist?(DEFAULT_OUTPUT_FILENAME)
	if master.include?(headers_for_master)
		CSV.open(DEFAULT_OUTPUT_FILENAME, "ab") do |csv|
			array = []
			hash = parse_hash(info_hash)
			headers_for_master.each do |header|
				array << hash[header.to_sym]
			end
			csv << array
		end
	else
		CSV.open(DEFAULT_OUTPUT_FILENAME, "ab", write_headers: true, headers: headers_for_master) do |csv|
			array = []
			hash = parse_hash(info_hash)
			headers_for_master.each do |header|
				array << hash[header.to_sym]
			end
			csv << array
		end
	end
end

# the script could fail due to internet or some other reason
begin
	browser = Watir::Browser.new :chrome

	puts "1. collect links and scrape"
	puts "2. scrape using file"
	choice = gets.chomp.to_i

	links_array = []

	case choice
	when 1
		read_links_from_page(browser)
		links_array = read_file(DEFAULT_LINKS_CSV_FILE_NAME)
	when 2
		links_array = collect_filename
	else
		puts "Please select a valid option"
	end

	links_read = read_file(TEMP_FILE_NAME)

	links_array -= links_read unless links_read.nil?

	puts "found #{links_array.count} links"

	links_array.each_with_index do |link, index|
		puts "parsing link number #{index}"
		browser.goto(link)
		puts "Collecting Data"
		info_hash = collect_data(browser)
		puts "Writing Data into the excel"
		write_data(info_hash)
		puts "Writing link into temp file"
		write_into_file(TEMP_FILE_NAME, [link])
	end

	File.delete(TEMP_FILE_NAME) if File.exist?(TEMP_FILE_NAME)
rescue => error
	puts $!.message
	puts $!.backtrace
	puts "Something went wront, Please re run the script to continue from where it left"
	exit
end