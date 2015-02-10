



#################################################################################
####                           Massimo Re Ferre'                             ####
####                             www.it20.info                               ####
####     vcaexplorer, a vCloud Air utility for developers and sysadmin       ####
################################################################################# 


  
#################################################################################
#### vcaexplorer.rb is the front end program that presents a CLI interface   ####
####              It leverages the vcautils library                          ####
#################################################################################


#################################################################################
####                              IMPORTANT !!                               ####
####  The program reads a file called vcautils.yml in the working directory  ####
####        If the file does not exist the program will abort                ####
####  The file is used to provide the program with connectivity parameters   ####
#################################################################################

# This is the format of the vcautils.yml file:
# :username: email@domain@OrgName
# :password: password
# :serviceroot: https://vca.vmware.com
# :mode: admin | developer 

# These are the additional modules/gems required to run the program 

require 'httparty'
require 'yaml'
require 'xml-fu'
require 'pp'
require 'json'
require 'awesome_print' #optional - useful for debugging

require 'modules/vcautilscore'


#=begin
class String
	def black;          "\033[30m#{self}\033[0m" end
	def red;            "\033[31m#{self}\033[0m" end
	def green;          "\033[32m#{self}\033[0m" end
	def brown;          "\033[33m#{self}\033[0m" end
	def blue;           "\033[34m#{self}\033[0m" end
	def magenta;        "\033[35m#{self}\033[0m" end
	def cyan;           "\033[36m#{self}\033[0m" end
	def gray;           "\033[37m#{self}\033[0m" end
	def bg_black;       "\033[40m#{self}\033[0m" end
	def bg_red;         "\033[41m#{self}\033[0m" end
	def bg_green;       "\033[42m#{self}\033[0m" end
	def bg_brown;       "\033[43m#{self}\033[0m" end
	def bg_blue;        "\033[44m#{self}\033[0m" end
	def bg_magenta;     "\033[45m#{self}\033[0m" end
	def bg_cyan;        "\033[46m#{self}\033[0m" end
	def bg_gray;        "\033[47m#{self}\033[0m" end
	def bold;           "\033[1m#{self}\033[22m" end
	def reverse_color;  "\033[7m#{self}\033[27m" end
end #String
#=end

# We stole this piece of code (silence_warnings) from the Internet.
# We am using it to silence the warnings of the certificates settings (below)


def silence_warnings(&block)
  warn_level = $VERBOSE
  $VERBOSE = nil
  result = block.call
  $VERBOSE = warn_level
  result
end





# This bypass certification checks...  NOT a great idea for production but ok
# for test / dev This will be handy for when this script will work with vanilla
# vCD setups (not just vCHS)

silence_warnings do
	OpenSSL::SSL::VERIFY_NONE = OpenSSL::SSL::VERIFY_NONE
end 


# This is what the program accepts as input

def usage
	#puts "\nUsage: #{$0} operation [vapp-name] [snap-name]\n"
	#puts "\n\toperation: list|get|poweron|poweroff|shutdown|reset|suspend|createsnapshot|removesnapshot"
	puts "\te.g. vcaexplorer token".green
	puts "\te.g. vcaexplorer plans".green
	puts "\te.g. vcaexplorer instances".green
	puts "\te.g. vcaexplorer instance".green + " <instance id>".magenta 
	puts "\te.g. vcaexplorer instance".green + " <instance id>".magenta + " computetoken".green
	puts "\te.g. vcaexplorer instance".green + " <instance id>".magenta + " catalogs".green
	puts "\te.g. vcaexplorer instance".green + " <instance id>".magenta + " catalog".green + " <catalog id>".magenta
	puts "\te.g. vcaexplorer instance".green + " <instance id>".magenta + " vms".green
	puts "\te.g. vcaexplorer instance".green + " <instance id>".magenta + " vapps".green
	puts "\te.g. vcaexplorer instance".green + " <instance id>".magenta + " vdcs".green
	puts "\te.g. vcaexplorer instance".green + " <instance id>".magenta + " vdc".green + " <vdc id>".magenta
	puts "\te.g. vcaexplorer instance".green + " <instance id>".magenta + " vdc".green + " <vdc id>".magenta + " networks".green
	puts "\te.g. vcaexplorer users".green
	puts "\te.g. vcaexplorer servicegroups".green
	puts "\te.g. vcaexplorer billedcosts".green
	puts "\te.g. vcaexplorer billablecosts".green
	puts "\te.g. vcaexplorer customquery".green + " <REST GET query>".magenta + " <ContentType>".magenta
	puts "\n"

end #usage

#################################################################################
####        The following functions are standard functions to login          ####
####                     and logout from the tenant                          ####
####        They can be used to interact generically with vCloud Air         ####
#################################################################################





def appendstructure(number)
	puts number
end 




# These are the variables the program accept as inputs (see the usage section for more info)

 

	$input0 = ARGV[0]

	$input1 = ARGV[1]

	$input2 = ARGV[2]

	$input3 = ARGV[3]

	$input4 = ARGV[4]


# The if checks if the user called an operation. If not the case, we print the text on how to use the CLI  


if $input0
  
# We login (the login method is in vcautilscore)  

file_path = "vcautils.yml"
raise "no file #{file_path}" unless File.exists? file_path
configuration = YAML.load_file(file_path)
username = configuration[:username]
password = configuration[:password]
serviceroot = configuration[:serviceroot]
mode = configuration[:mode]
loginserviceroot = "https://iam.vchs.vmware.com"
acceptheadercompute = "application/*+xml;version=5.7"

puts
puts "Logging in ...\n\n"

iam = Iam.new()

sc = Sc.new()

compute = Compute.new()

billing = Billing.new()

metering = Metering.new()

token = iam.login(username, password, loginserviceroot)


case $input0.chomp
   

  when 'token'  
  	  puts "OAuth token:\n".green + "Bearer " + token


			
  when 'users'
 	 usersarray = iam.users(token, serviceroot)
 	 if mode == "developer" then puts JSON.pretty_generate(usersarray) end
	 usersarray['Users']['User'].length.times do |i|
	  	  		puts "id           : ".green + usersarray['Users']['User'][i]["id"].blue
	  	  		puts "state        : ".green + usersarray['Users']['User'][i]["state"].blue
	  	  		puts "email        : ".green + usersarray['Users']['User'][i]["email"].blue
	  	  		puts "metacreated  : ".green + usersarray['Users']['User'][i]["meta"]["created"].blue
	  	  		puts "metamodified : ".green + usersarray['Users']['User'][i]["meta"]["modified"].blue
	  	  		puts 
				end #do   	  

 	  
  when 'plans'  
	plansarray = sc.plans(token, serviceroot)	
 	if mode == "developer" then puts JSON.pretty_generate(plansarray) end
	plansarray['PlanList']['plans'].length.times do |i|
	  	  		puts "id      : ".green + plansarray['PlanList']['plans'][i]["id"].blue
	  	  		puts "name    : ".green + plansarray['PlanList']['plans'][i]["name"].blue
	  	  		puts "region  : ".green + plansarray['PlanList']['plans'][i]["region"].blue
	  	  		puts 
				end #do 

			      
   
  when 'instances'
    instancesarray = sc.instances(token, serviceroot)
 	if mode == "developer" then puts JSON.pretty_generate(instancesarray) end
	instancesarray["InstanceList"]["instances"].length.times do |i|
	  	  		puts "name               : ".green + instancesarray["InstanceList"]["instances"][i]["name"].blue
	  	  		puts "id                 : ".green + instancesarray["InstanceList"]["instances"][i]["id"].blue
	  	  		puts "region             : ".green + instancesarray["InstanceList"]["instances"][i]["region"].blue
	  	  		puts "apiUrl             : ".green + instancesarray["InstanceList"]["instances"][i]["apiUrl"].blue
	  	  		puts "dashboardUrl       : ".green + instancesarray["InstanceList"]["instances"][i]["dashboardUrl"].blue
	  	  		puts "instanceAttributes : ".green + instancesarray["InstanceList"]["instances"][i]["instanceAttributes"].blue
	  	  		puts 
				end #do 
   
   
   
  when 'instance'  
      instancesarray = sc.instances(token, serviceroot)
      if $input1
       instanceexists = false	
       instancesarray["InstanceList"]["instances"].length.times do |i|
	         if instancesarray["InstanceList"]["instances"][i]["id"] == $input1
	  	  	    		orgname, sessionuri, apiUrl = compute.extractendpoint(instancesarray["InstanceList"]["instances"][i]["instanceAttributes"])
     	  	  	    	computetoken = compute.login(username, password, orgname, sessionuri)
     	  	  	    	#right now I am not using the apiUrl 
     	  	  	    	#ideally that should be the starting point 
     	  	  	    	#however to speed up things I am using sessionuri + the specific (packaged) query I need directly
     	  	  	    	apiUrl = instancesarray["InstanceList"]["instances"][i]["apiUrl"]
     	  	  	    	if $input2 == nil 
     	  	  	    			apiUrlarray = compute.instancedetails(computetoken, "", apiUrl)
     	  	  	    			puts "The API URL for this service is : ".bold.green + apiUrl.bold.blue
     	  	  	    			puts
     	  	  	    	else
     	  	  	    	
						case $input2.chomp
     	  	  	    		when 'computetoken'
     	  	  	    		  	puts "To start consuming this instance right away use the following parameters: ".green
     	  	  	    		    puts " - login url              : ".green + "GET ".blue + apiUrl.blue
     	  	  	    		  	puts " - x-vcloud-authorization : ".green + computetoken.blue
     	  	  	    		  	puts " - Accept                 : ".green + acceptheadercompute.blue
     	  	  	    		  	puts
     	  	  	    			
     	  	  	    		when 'vdcs'
     	  	  	    			vdcsarray = compute.vdcs(computetoken, sessionuri)
 								if mode == "developer" then puts JSON.pretty_generate(vdcsarray) end
     	  	  	    			vdcsarray["QueryResultRecords"]["OrgVdcRecord"].length.times do |e|     
     	  	  	    				puts "name    : ".green + vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["name"].blue
     	  	  	    				puts "status  : ".green + vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["status"].blue
     	  	  	    				puts "href    : ".green + vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["href"].blue
     	  	  	    				puts "orgName : ".green + vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["orgName"].blue
     	  	  	    				puts
     	  	  	    			end	  	  
     	  	  	    			  
     	  	  	    		when 'vapps' 
     	  	  	    			orgvappsarray = compute.orgvapps(computetoken, sessionuri)
 								if mode == "developer" then puts JSON.pretty_generate(orgvappsarray) end
    							if orgvappsarray["QueryResultRecords"]["VAppRecord"] == nil
	         								puts "The are no vApps in this instance".red
	         								puts
	         					else
     	  	  	    			            orgvappsarray["QueryResultRecords"]["VAppRecord"].length.times do |e|     
     	  	  	    							puts "name           : ".green + orgvappsarray["QueryResultRecords"]["VAppRecord"][e]["name"].blue
     	  	  	    							puts "isVAppTemplate : ".green + orgvappsarray["QueryResultRecords"]["VAppRecord"][e]["href"].blue
     	  	  	    							puts "numberOfVMs    : ".green + orgvappsarray["QueryResultRecords"]["VAppRecord"][e]["numberOfVMs"].blue
     	  	  	    							puts "vdcName        : ".green + orgvappsarray["QueryResultRecords"]["VAppRecord"][e]["vdcName"].blue
     	  	  	    							puts
     	  	  	    						end	  
     	  	  	    			end 
	  	  	    		
     	  	  	    		when 'vms' 
     	  	  	    			orgvmsarray = compute.orgvms(computetoken, sessionuri)
 								if mode == "developer" then puts JSON.pretty_generate(orgvmsarray) end
    							if orgvmsarray["QueryResultRecords"]["VMRecord"] == nil
    								        puts "The are no vApps in this instance".red
	         								puts
	         					else
	         								puts
     	  	  	    						orgvmsarray["QueryResultRecords"]["VMRecord"].length.times do |e|     
     	  	  	    							puts "name            : ".green + orgvmsarray["QueryResultRecords"]["VMRecord"][e]["name"].blue
     	  	  	    							puts "isVAppTemplate  : ".green + orgvmsarray["QueryResultRecords"]["VMRecord"][e]["isVAppTemplate"].blue
     	  	  	    							puts "containerName   : ".green + orgvmsarray["QueryResultRecords"]["VMRecord"][e]["containerName"].blue
     	  	  	    							puts
     	  	  	    						end
     	  	  	    						puts "Please be aware that this list also contains all VM templates in all catalogs. See attribute <isVAppTemplate>.".magenta
											puts
     	  	  	    			end	
     	  	  	    			
     	  	  	    		when 'catalogs' 
     	  	  	    		   	catalogsarray = compute.instancedetails(computetoken, sessionuri, "/api/compute/api/catalogs/query")
 								if mode == "developer" then puts JSON.pretty_generate(catalogsarray) end
	     	  	  	    		catalogsarray["QueryResultRecords"]["CatalogRecord"].length.times do |e|     
    	 	  	  	    				puts "name                  : ".green + catalogsarray["QueryResultRecords"]["CatalogRecord"][e]["name"].blue
     		  	  	    				puts "isPublished           : ".green + catalogsarray["QueryResultRecords"]["CatalogRecord"][e]["isPublished"].blue
     	  		  	    				puts "isShared              : ".green + catalogsarray["QueryResultRecords"]["CatalogRecord"][e]["isShared"].blue
     	  	  		    				puts "numberOfMedia         : ".green + catalogsarray["QueryResultRecords"]["CatalogRecord"][e]["numberOfMedia"].blue
     	  	  	    					puts "numberOfVAppTemplates : ".green + catalogsarray["QueryResultRecords"]["CatalogRecord"][e]["numberOfVAppTemplates"].blue
     	  	  	    					puts "href                  : ".green + catalogsarray["QueryResultRecords"]["CatalogRecord"][e]["href"].blue
     	  	  	    					puts
     	  	  	    			end # catalogsarray["QueryResultRecords"]["CatalogRecord"].length.times
     	  	  	    			
     	 					when 'catalog' 
     	  	  	    		   	if $input3 != nil 
     	  	  	    		   	catalogsarray = compute.instancedetails(computetoken, sessionuri, "/api/compute/api/catalogs/query")
	         					catalogexists = false
								catalogsarray["QueryResultRecords"]["CatalogRecord"].length.times do |e|
	         						if catalogsarray["QueryResultRecords"]["CatalogRecord"][e]["name"] == $input3
	         							catalogitemsarray = compute.instancedetails(computetoken, "", catalogsarray["QueryResultRecords"]["CatalogRecord"][e]["href"])
 										if mode == "developer" then puts JSON.pretty_generate(catalogitemsarray) end
	         							if catalogitemsarray["Catalog"]["CatalogItems"] == nil
	         								puts "The catalog ".red + $input3.blue + " is empty".red
	         								puts
	         							 else
	         							 catalogitemsarray["Catalog"]["CatalogItems"]["CatalogItem"].length.times do |x|
	         								puts "CatalogItem name : ".green + catalogitemsarray["Catalog"]["CatalogItems"]["CatalogItem"][x]["name"].blue
	         								puts "CatalogItem id   : ".green + catalogitemsarray["Catalog"]["CatalogItems"]["CatalogItem"][x]["id"].blue
	         								catalogitemdetails = compute.instancedetails(computetoken, "",catalogitemsarray["Catalog"]["CatalogItems"]["CatalogItem"][x]["href"])
	         								#puts JSON.pretty_generate(catalogitemdetails)
	         								puts "         - Entity name  : ".green + catalogitemdetails["CatalogItem"]["Entity"]["name"].blue
	         								puts "         - Entity href  : ".green + catalogitemdetails["CatalogItem"]["Entity"]["href"].blue
	         								puts
	         							 end #catalogitemsarray["Catalog"]["CatalogItems"]["CatalogItem"].length.times do |x|
	         							end #if catalogitemsarray["Catalog"]["CatalogItems"] == "null"
										catalogexists = true
	         						end #if catalogsarray["QueryResultRecords"]["CatalogRecord"][e] == $input3
								end #catalogsarray["QueryResultRecords"]["CatalogRecord"].length.times
								if catalogexists == false
	         						puts "The catalog ".red + $input3.blue + " does not exist".red 
	         						puts
	         					end #if catalogexists == false
     	  	  	    		   	else #if $input3 != nil 
								puts "please provide a catalog name to query".red
								puts
     	  	  	    		   	end #if $input3 != nil 




							when 'vdc'
							    if $input3 != nil 
     	  	  	    		   	  vdcsarray = compute.vdcs(computetoken, sessionuri)
 								  if mode == "developer" then puts JSON.pretty_generate(vdcsarray) end
	         					  vdcexists = false
								  vdcsarray["QueryResultRecords"]["OrgVdcRecord"].length.times do |e|
	         					  	if vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["name"] == $input3
	         							if $input4 == nil 
	         								#puts JSON.pretty_generate(vdcsarray)
	         								puts "status              : ".bold.green + vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["status"].bold.blue
	         								puts "numberOfVApps       : ".bold.green + vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["numberOfVApps"].bold.blue
	         								puts "cpuLimitMhz         : ".green + vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["cpuLimitMhz"].blue
	         								puts "cpuUsedMhz          : ".green + vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["cpuUsedMhz"].blue
	         								puts "memoryLimitMB       : ".green + vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["memoryLimitMB"].blue
	         								puts "memoryUsedMB        : ".green + vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["memoryUsedMB"].blue
	         								puts "storageLimitMB      : ".green + vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["storageLimitMB"].blue
	         								puts "storageUsedMB       : ".green + vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["storageUsedMB"].blue
	         								puts "pvdcHardwareVersion : ".green + vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["pvdcHardwareVersion"].blue
	         								puts
	         							else #if $input4 == nil 
	         							case $input4.chomp	         								
	         								when 'networks'
	         									networksarray = compute.networks(computetoken, vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["href"])
 								  				if mode == "developer" then puts JSON.pretty_generate(networksarray) end
												networksarray["Network"].length.times do |x| 
												   		networkdetails = compute.networkdetails(computetoken, networksarray["Network"][x]["href"])
 								  						if mode == "developer" then puts JSON.pretty_generate(networkdetails) end
												   		puts "name          : ".green + networkdetails["OrgVdcNetwork"]["name"].blue
    	 	  	  	    								puts "href          : ".green + networkdetails["OrgVdcNetwork"]["href"].blue
     	  	  	    									puts "Configuration : ".green
     	  	  	    									puts " - IpScopes : ".green
     	  	  	    									puts "   - IpScope : ".green
     	  	  	    									puts "      - Gateway : ".green + networkdetails["OrgVdcNetwork"]["Configuration"]["IpScopes"]["IpScope"]["Gateway"].blue
     	  	  	    									puts "      - Netmask : ".green + networkdetails["OrgVdcNetwork"]["Configuration"]["IpScopes"]["IpScope"]["Netmask"].blue
     	  	  	    									puts "      - IsEnabled : ".green + networkdetails["OrgVdcNetwork"]["Configuration"]["IpScopes"]["IpScope"]["IsEnabled"].blue
     	  	  	    									puts "            - IpRanges : ".green
     	  	  	    									puts "                - IpRange : ".green
     	  	  	    									networkdetails["OrgVdcNetwork"]["Configuration"]["IpScopes"]["IpScope"]["IpRanges"]["IpRange"].length.times do |y|
     	  	  	    										puts "                     - StartAddress : ".green + networkdetails["OrgVdcNetwork"]["Configuration"]["IpScopes"]["IpScope"]["IpRanges"]["IpRange"][y]["StartAddress"].blue
     	  	  	    										puts "                     - EndAddress   : ".green + networkdetails["OrgVdcNetwork"]["Configuration"]["IpScopes"]["IpScope"]["IpRanges"]["IpRange"][y]["EndAddress"].blue
     	  	  	    									end #networkdetails["OrgVdcNetwork"]["Configuration"]["IpScopes"]["IpScope"]["IpRanges"]["IpRange"].length do |y|
     	  	  	    									puts "   - FenceMode : ".green + networkdetails["OrgVdcNetwork"]["Configuration"]["FenceMode"].blue
     	  	  	    									puts "   - RetainNetInfoAcrossDeployments : ".green + networkdetails["OrgVdcNetwork"]["Configuration"]["RetainNetInfoAcrossDeployments"].blue
     	  	  	    									puts "IsShared : ".green + networkdetails["OrgVdcNetwork"]["IsShared"].blue
     	  	  	    									puts
     	  	  	    									puts
												end # networksarray["Network"].length.times do |x| 
	         								else #case $input4.chomp
	         								puts "The operation ".red + $input4.blue + " against the vdc is not recognized as a valid operation".red
	         							end #case $input4.chomp         								
	         							end  #if $input4 == nil 
	         							vdcexists = true
	         						end #if vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["name"] == $input3
	         					  end #vdcsarray["QueryResultRecords"]["OrgVdcRecord"].length.times do |e|
								
								if vdcexists == false
	         						puts "The vdc ".red + $input3.blue + " does not exist".red 
	         						puts
	         					end #if vdcexists == false
     	  	  	    		   	
     	  	  	    		   	else #if $input3 != nil 
								puts "please provide a vdc name to query".red
								puts
     	  	  	    		   	end #if $input3 != nil 


     	  	  	    	else #case
     	  	  	    			puts "The operation ".red + $input2.blue + " against the instance is not recognized as a valid operation".red
     	  	  	    			puts   	    	
     	  	  	    	end #case $input2.chomp
     	  	  	    	end #if
     	  	  	    	
     	  	  	    	instanceexists = true 
     	     end #instancearray check 
	   end #do
	   if instanceexists == false
    	     puts "Sorry the instance ".red + $input1 + " doesn't exist".red 
			 puts
	   end #if instance exists
    end #main if
   
   
   
   

 ##### This is done  ########
  when 'servicegroups'
    servicegroupsarray = billing.servicegroups(token, serviceroot)
    if mode == "developer" then puts JSON.pretty_generate(servicegroupsarray) end
	servicegroupsarray["serviceGroupList"]["serviceGroup"].length.times do |i|
				puts
	  	  		puts "id              : ".green + servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["id"].blue
	  	  		puts "displayName     : ".green + servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["displayName"].blue
	  	  		puts "billingCurrency : ".green + servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["billingCurrency"].blue
	  	  		puts "availableBills  : ".green 
	  	  		puts "       - bill:".green
				servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["availableBills"]["bill"].length.times do |e|
						puts "              - billingPeriod:".green
						puts "                - month     :".green + servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["availableBills"]["bill"][e]["billingPeriod"]["month"].to_s.blue
						puts "                - year      :".green + servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["availableBills"]["bill"][e]["billingPeriod"]["year"].to_s.blue
						puts "                - sartDate  :".green + servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["availableBills"]["bill"][e]["billingPeriod"]["startDate"].blue
						puts "                - endDate   :".green + servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["availableBills"]["bill"][e]["billingPeriod"]["endDate"].blue
						puts				
				end #do e	
				puts
				puts
	end #do i 
 
 
 
 
 
 
 
 ##### This is done  ########
   when 'billedcosts'
   	if $input1
   	servicegroupexists = false	
       servicegroupsarray.length.times do |i|
	         if servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["id"] == $input1
	  	  	    		billedcostsarray = billing.billedcosts(token, serviceroot, servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["id"])
						if billedcostsarray["status"] 
							puts "Sorry, there is no billing yet for this servicegroup".red
							puts 			
						else
							#I need to convert cost to string as if it's nil it will complain
    						puts "cost        : " +  billedcostsarray["cost"].to_s
    						puts "currency    : " +  billedcostsarray["currency"]
    						puts "month       : " +  billedcostsarray["month"].to_s
    						puts "year        : " +  billedcostsarray["year"].to_s
    				    	puts "startTime   : " +  billedcostsarray["startTime"]
    				    	puts "endTime     : " +  billedcostsarray["endTime"]
    						#puts JSON.pretty_generate(billedcostsarray)
	  	  	    			#servicegrouparray.length.times do |i|
							#end #do
						end		
     	  	  	    	servicegroupexists = true 
     	     end #servicegroup check 
	   end #do
	   if servicegroupexists == false
    	     puts "Sorry the servicegroup ".red + $input1 + " doesn't exist".red 
			 puts
	   end #if servicegroup exists    
    end #main if







##### vCA RESPONDS WITH "NOT IMPLEMENTED" ########
   when 'billedusage'
   	if $input1
   	servicegroupexists = false	
       servicegroupsarray["serviceGroupList"]["serviceGroup"].length.times do |i|
	         if servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["id"] == $input1
	  	  	    		billedusagearray = billing.billedusage(token, serviceroot, servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["id"])
	  	  	    		#servicegrouparray.length.times do |i|
						#end #do		
     	  	  	    	servicegroupexists = true 
     	     end #servicegroup check 
	   end #do
	   if servicegroupexists == false
    	     puts "Sorry the servicegroup ".red + $input1 + " doesn't exist".red 
			 puts
	   end #if servicegroup exists    
    end #main if







 ##### This is done  ########
   when 'billablecosts'
   	if $input1
   	servicegroupexists = false	
       servicegroupsarray["serviceGroupList"]["serviceGroup"].length.times do |i| 
	         if servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["id"] == $input1
	  	  	    		billablecostsarray = metering.billablecosts(token, serviceroot, servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["id"])
	  	  	    		puts "currency       : " + billablecostsarray["currency"]
	  	  	    		puts "lastUpdateTime : " + billablecostsarray["lastUpdateTime"]
	  	  	    		billablecostsarray["cost"].length.times do |e|
	  	  	    				puts "    - type     : " + billablecostsarray["cost"][e]["type"]
	  	  	    				puts "    - costItem : "
	  	  	    				billablecostsarray["cost"][e]["costItem"].length.times do |n|
	  	  	    						puts "         - properties : "
	  	  	    						puts "               - property : "
	  	  	    						billablecostsarray["cost"][e]["costItem"][n]["properties"]["property"].length.times do |m|
	  	  	    								puts "                       - value : " + billablecostsarray["cost"][e]["costItem"][n]["properties"]["property"][m]["value"]
	  	  	    								puts "                       - name  : " + billablecostsarray["cost"][e]["costItem"][n]["properties"]["property"][m]["name"]
										end #do
								end #do
	  	  	    				puts
	  	  	    				puts
						end #do		
     	  	  	servicegroupexists = true 
     	     end #servicegroup check 
	   end #do
	   if servicegroupexists == false
    	     puts "Sorry the servicegroup ".red + $input1 + " doesn't exist".red 
			 puts
	   end #if servicegroup exists    
    end #main if





 ##### doesn't work   ########
  when 'billableusage'
   	if $input1
   	instanceexists = false	
       instancesarray.length.times do |i|
	         if instancesarray[i]["Id"] == $input1
	  	  	    		billableusagearray = metering.billableusage(token, serviceroot, instancesarray[i]["Id"])
	  	  	    		puts "currency       : " + billablecostsarray["currency"]
	  	  	    		puts "lastUpdateTime : " + billablecostsarray["lastUpdateTime"]
	  	  	    		billablecostsarray["cost"].length.times do |e|
	  	  	    				puts "    - type     : " + billablecostsarray["cost"][e]["type"]
	  	  	    				puts "    - costItem : "
	  	  	    				billablecostsarray["cost"][e]["costItem"].length.times do |n|
	  	  	    						puts "         - properties : "
	  	  	    						puts "               - property : "
	  	  	    						billablecostsarray["cost"][e]["costItem"][n]["properties"]["property"].length.times do |m|
	  	  	    								puts "                       - value : " + billablecostsarray["cost"][e]["costItem"][n]["properties"]["property"][m]["value"]
	  	  	    								puts "                       - name  : " + billablecostsarray["cost"][e]["costItem"][n]["properties"]["property"][m]["name"]
										end #do
								end #do
	  	  	    				puts
	  	  	    				puts
						end #do		
     	instanceexists = true 
     	end #instance check 
	   end #do
	   if instanceexists == false
    	     puts "Sorry the instance ".red + $input1 + " doesn't exist".red 
			 puts
	   end #if servicegroup exists    
    end #main if





  when 'custom'
  	custom = Custom.new()
   	if $input1
		customresult = custom.customquery(token, serviceroot, $input1, $input2)
		puts JSON.pretty_generate(customresult)
	else
		puts "Please provide a valid API call path (with proper Content Type) to run a GET against https://vca.vmware.com".green
		puts "Example: /api/iam/Users".green
		puts 
    end #main if





 ##### TEMPORARY PLACE TO EXPERIMENT With D3 layout ########
 ##### Eventually this section can be thrown out   #########
  when 'd3'
  
	
################
##START Plans
################
	plansarray = sc.plans(token, serviceroot)	
    plans_tree = {"name"=> "PlanList", "children" => [{}]}
    plans_tree["children"][0] = {"name" => "plans", "children" => [{}]}
    plansarray['PlanList']['plans'].length.times do |i| 
    											plans_tree["children"][0]["children"][i] = {"name" => plansarray['PlanList']['plans'][i]["name"] + " " + plansarray['PlanList']['plans'][i]["region"],
    																							"attribute0" => "name        : " + plansarray['PlanList']['plans'][i]["name"],
    																							"attribute1" => "id          : " + plansarray['PlanList']['plans'][i]["id"],
    																							"attribute2" => "region      : " + plansarray['PlanList']['plans'][i]["region"],
    																							"attribute3" => "planVersion : " + plansarray['PlanList']['plans'][i]["planVersion"]
    																						} 
    															end												
################
##STOP Plans
################





################
##START Instances + VDCS
################
    instancesarray = sc.instances(token, serviceroot)
    instances_tree = {"name"=> "InstanceList", "children" => [{}]}
    instances_tree["children"][0] = {"name" => "instances", "children" => [{}]}
    instancesarray["InstanceList"]["instances"].length.times do |i| 
    			instances_tree["children"][0]["children"][i] = {"name" => instancesarray["InstanceList"]["instances"][i]["name"], 
     																"attribute0" => "name   : " + instancesarray["InstanceList"]["instances"][i]["name"],
     																"attribute1" => "id     : " + instancesarray["InstanceList"]["instances"][i]["id"],
     																"attribute2" => "region : " + instancesarray["InstanceList"]["instances"][i]["region"],
     																"attribute3" => "planId : " + instancesarray["InstanceList"]["instances"][i]["planId"],
     																"attribute4" => "apiUrl : " + instancesarray["InstanceList"]["instances"][i]["apiUrl"],
    																"children" => [{}]
    																}
    			instances_tree["children"][0]["children"][i]["children"][0] = {"name" => "instanceAttributes",
    																			   "attribute0" => "orgName    : " + instancesarray["InstanceList"]["instances"][i]["instanceAttributes"]["orgName"],
    																			   "attribute0" => "sessionUri : " + instancesarray["InstanceList"]["instances"][i]["instanceAttributes"]["sessionUri"],
    																			  }
    																
    			orgname, sessionuri, apiUrl = compute.extractendpoint(instancesarray["InstanceList"]["instances"][i]["instanceAttributes"])
     	  	  	computetoken = compute.login(username, password, orgname, sessionuri) 
    		    
    		    vdcsarray = compute.instancedetails(computetoken, sessionuri, "/api/compute/api/admin/vdcs/query")
    			#puts JSON.pretty_generate(vdcsarray)
     	  	  	
     	  	  	vdcsarray["QueryResultRecords"]["OrgVdcRecord"].length.times do |e|
     	  	  	     
								instances_tree["children"][0]["children"][i]["children"][e] = {"name" => vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["name"],
    																						       "attribute0" => "status        : " + vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["status"],
    																						       "attribute1" => "numberOfVApps : " + vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["numberOfVApps"],
    																						       "attribute2" => "cpuUsedMhz    : " + vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["cpuUsedMhz"],
    																						       "attribute3" => "memoryUsedMB  : " + vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["memoryUsedMB"],
    																						       "attribute4" => "storageUsedMB : " + vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["storageUsedMB"]
    																						      }
    																						          	  	  	 
     	  	  	end	# vdcsarray["QueryResultRecords"]["OrgVdcRecord"].length.times do |e| 
												
	end #instancesarray["InstanceList"]["instances"].length.times do |i|
    		
												
########################
##STOP Instances + VDCS
########################



################
##START Users
################
 	usersarray = iam.users(token, serviceroot)
    users_tree = {"name"=> "Users", "children" => [{}]}
    users_tree["children"][0] = {"name" => "User", "children" => [{}]}
    usersarray['Users']['User'].length.times do |i| 
    					users_tree["children"][0]["children"][i] = {"name" => usersarray['Users']['User'][i]["email"], 
    																	"attribute0" => "state    : " + usersarray['Users']['User'][i]["state"],
    																	"attribute1" => "email    : " + usersarray['Users']['User'][i]["email"],
    																	"attribute2" => "userName : " + usersarray['Users']['User'][i]["userName"],
    																	"children" => [{}]
    																	}
    					users_tree["children"][0]["children"][i]["children"][0] = {"name" => "id", 
    																				"attribute0" => "id       : " + usersarray['Users']['User'][i]["id"],
    																				"attribute1" => "created  : " + usersarray['Users']['User'][i]["meta"]["created"],
    																				"attribute2" => "modified : " + usersarray['Users']['User'][i]["meta"]["modified"]
    																				}												
    					users_tree["children"][0]["children"][i]["children"][1] = {"name" => "roles", 
    																				"children" => [{}]
    																				}												

						usersarray['Users']['User'][i]["roles"]["role"].length.times do |x|
										users_tree["children"][0]["children"][i]["children"][1]["children"][x] = {"name" => usersarray['Users']['User'][i]["roles"]["role"][x]["name"],
																											    "attribute0" => "name        : " + usersarray['Users']['User'][i]["roles"]["role"][x]["name"], 
																											    "attribute1" => "id          : " + usersarray['Users']['User'][i]["roles"]["role"][x]["id"], 
																											    "attribute2" => "description : " + usersarray['Users']['User'][i]["roles"]["role"][x]["description"] 
																											    }					
						end # usersarray['Users']['User']["roles"]["role"].length.times do |x|					
    																	
    																	
	end # usersarray['Users']['User'].length.times do |i|
    																										
################
##STOP Users
################



################
##START ServiceGroups
################
    servicegroupsarray = billing.servicegroups(token, serviceroot)
    servicegroups_tree = {"name"=> "serviceGroupList", "children" => [{}]}
    servicegroups_tree["children"][0] = {"name" => "serviceGroup", "children" => [{}]}
    
    servicegroupsarray["serviceGroupList"]["serviceGroup"].length.times do |i| 	
    		servicegroups_tree["children"][0]["children"][i] = {"name" => servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["displayName"], 
    															"attribute0" => "id              : " + servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["id"],
    															"attribute1" => "displayName     : " + servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["displayName"],
    															"attribute2" => "billingCurrency : " + servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["billingCurrency"],
    															"children" => [{}]
    															}
    	    servicegroups_tree["children"][0]["children"][i]["children"][0] = {"name" => "availableBills", 
    	         														       	   "children" => [{}]
    	         														       	   }
    	    servicegroups_tree["children"][0]["children"][i]["children"][0]["children"][0] = {"name" => "bill", 
    	         														       	   "children" => [{}]
    	         														       	   }
    	    servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["availableBills"]["bill"].length.times do |x|
    	    			servicegroups_tree["children"][0]["children"][i]["children"][0]["children"][0]["children"][x] = {"name" => "billingPeriod", 
    	         														       	   "children" => [{}]
    	         														       	   }
    	         		servicegroups_tree["children"][0]["children"][i]["children"][0]["children"][0]["children"][x]["children"][0] = {"name" => servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["availableBills"]["bill"][x]["billingPeriod"]["month"].to_s + "-" + servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["availableBills"]["bill"][x]["billingPeriod"]["year"].to_s,
    	     																															   "attribute0" => "month     : " + servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["availableBills"]["bill"][x]["billingPeriod"]["month"].to_s,
    	     																															   "attribute1" => "year      : " + servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["availableBills"]["bill"][x]["billingPeriod"]["year"].to_s,
    	     																															   "attribute2" => "startDate : " + servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["availableBills"]["bill"][x]["billingPeriod"]["startDate"].to_s,
    	     																															   "attribute3" => "endDate   : " + servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["availableBills"]["bill"][x]["billingPeriod"]["endDate"].to_s
    	     																															   }    	     																															   
    	    end #servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["availableBills"]["bill"].length.times do |x|
    	         														       
    
    end #servicegroupsarray["serviceGroupList"]["serviceGroup"].length.times do |i| 
    

################
## END ServiceGroups
################


##########################
## Assembling vCA root ###
##########################

vcaroot_tree = {"name"=> "vCloud Air", "children" => [{}]}
vcaroot_tree["children"][0] = plans_tree
vcaroot_tree["children"][1] = instances_tree
vcaroot_tree["children"][2] = users_tree
vcaroot_tree["children"][3] = servicegroups_tree


#################################
## End of Assembling vCA root ###
#################################

puts JSON.pretty_generate(vcaroot_tree)









       							       		  
else #case $input0
  puts "\n" 
  puts "Noooooope!".red
  puts "\n" 
  usage()
  puts "\n" 
  
end 


# If the user did not specify an operation at all we suggest how to properly use the CLI 

else #if $input0
  puts "\n" 
  puts "Use any of the following operations".red
  puts "\n" 
  usage()
  puts "\n" 



end #main if












































