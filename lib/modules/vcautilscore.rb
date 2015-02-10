#################################################################################
####                           Massimo Re Ferre'                             ####
####                             www.it20.info                               ####
#### vCATree, a tool that allows you to navigate through the service objects ####
################################################################################# 


class Iam
	include HTTParty
  	format :xml
    #debug_output $stderr
    
    
    
  def hashtoarray(structure)
  	 #this function work arounds an issue of httparty (and other REST clients apparently) that do not comply to the XML Schema correctly
  	 #in some circumstances the httparty response contains a hash whereas it should be an array of hash with one item 
  	 #this function takes input a JSON structure and check if it's a hash. If it is, it will turn it into an array of hash with one element
  	 #if the input is already an Array of hash it will do nothing
  	 #for further reference:  http://stackoverflow.com/questions/28282125/httparty-response-interpretation-in-ruby/ 
  	 structure = [structure] unless structure.is_a? Array
  	 return structure
  end #hashtoarray
  
  
    
  def login(username, password, serviceroot)
    self.class.base_uri serviceroot
  	#Avoid setting the basic_auth as (due to an httparty problem) it propagates and gets retained for other calls inside the class 
  	#self.class.basic_auth username, password
  	auth_token = Base64.encode64(username + ":" + password)
  	self.class.default_options[:headers] = {"Accept" => "application/xml;version=5.7", "Authorization" => "Basic " + auth_token}
    response = self.class.post('/api/iam/login')
    token = response.headers['vchs-authorization']
    return token
  end  

  
   
  def users(token, serviceroot)
    self.class.base_uri serviceroot
  	self.class.default_options[:headers] = { "Accept" => "application/xml;class=com.vmware.vchs.iam.api.schema.v2.classes.user.Users;version=5.7", "Authorization" => "Bearer " + token }
    usersarray = self.class.get('/api/iam/Users')
	usersarray['Users']['User'] = hashtoarray(usersarray['Users']['User'])
    usersarray['Users']['User'].length.times do |e|
    	usersarray['Users']['User'][e]["roles"]["role"] = hashtoarray(usersarray['Users']['User'][e]["roles"]["role"])
    end
	return usersarray
  end #users 


  def logout
    self.class.delete('/api/session')
  end
    
  def links
    response = self.class.get('/api/session')
    response['Session']['Link'].each do |link|
      puts link['href']
    end
  end 
 
 
end #Iam
 
 
 

class Sc
	include HTTParty
  	format :xml
  	#debug_output $stderr

 
 
  def plans(token, serviceroot)
    self.class.base_uri serviceroot
  	self.class.default_options[:headers] = { "Accept" => "application/xml;version=5.7", "Authorization" => "Bearer " + token }
    plansarray = self.class.get('/api/sc/plans')
    return plansarray
  end #plans


  def instances(token, serviceroot)
    self.class.base_uri serviceroot
  	self.class.default_options[:headers] = { "Accept" => "application/xml;version=5.7", "Authorization" => "Bearer " + token }
    instancesarray = self.class.get('/api/sc/instances')
	return instancesarray
  end #instances

end #Sc


class Compute
	include HTTParty
  	format :xml
  	#debug_output $stderr


  def hashtoarray(structure)
  	 #this function work arounds an issue of httparty (and other REST clients apparently) that do not comply to the XML Schema correctly
  	 #in some circumstances the httparty response contains a hash whereas it should be an array of hash with one item 
  	 #this function takes input a JSON structure and check if it's a hash. If it is, it will turn it into an array of hash with one element
  	 #if the input is already an Array of hash it will do nothing
  	 #for further reference:  http://stackoverflow.com/questions/28282125/httparty-response-interpretation-in-ruby/ 
  	 structure = [structure] unless structure.is_a? Array
  	 return structure
  end #hashtoarray
  

  def extractendpoint(instanceattributes) 
     #I turn the string into a hash 
     attributes = JSON.parse(instanceattributes)
     #I return the orgname and sessionuri values in the hash (note that I clean the uri to only provide the FQDN)
     return attributes["orgName"], attributes["sessionUri"][0..-26]
  end #extract 


  def login(username, password, orgname, sessionuri)
  	credentials = username + "@" + orgname
    self.class.base_uri sessionuri
  	self.class.basic_auth credentials, password
  	self.class.default_options[:headers] = {"Accept" => "application/*+xml;version=5.7"}
    response = self.class.post('/api/compute/api/sessions')
    computetoken = response.headers['x-vcloud-authorization']
    return computetoken 
  end #login
  
  
  def instancedetails(computetoken, sessionuri, query)
	self.class.default_options[:headers] = { "Accept" => "application/*+xml;version=5.7", "x-vcloud-authorization" => computetoken }    
	instancedetails = self.class.get(sessionuri + query)
    return instancedetails 
  end #login

  
  def vdcs (computetoken, sessionuri)
     vdcsarray = instancedetails(computetoken, sessionuri, "/api/compute/api/admin/vdcs/query")
     return vdcsarray
  end #vdcs
    
    
  def orgvms (computetoken, sessionuri)
     orgvmsarray = instancedetails(computetoken, sessionuri, "/api/compute/api/vms/query")
     return orgvmsarray
  end #orgvms
  

  def orgvapps (computetoken, sessionuri)
     orgvappsarray = instancedetails(computetoken, sessionuri, "/api/compute/api/vApps/query")
     return orgvappsarray
  end #orgvapps

    
  def networks (computetoken, vdchref)
     vdcdetails = instancedetails(computetoken, vdchref, "")
     networksarray = vdcdetails["Vdc"]["AvailableNetworks"]
     networksarray["Network"] = hashtoarray(networksarray["Network"])
     return networksarray
  end #networks


  def networkdetails (computetoken, networkhref)
     networkdetails = instancedetails(computetoken, networkhref, "")
     networkdetails["OrgVdcNetwork"]["Configuration"]["IpScopes"]["IpScope"]["IpRanges"]["IpRange"] = hashtoarray(networkdetails["OrgVdcNetwork"]["Configuration"]["IpScopes"]["IpScope"]["IpRanges"]["IpRange"]) 
     return networkdetails
  end #networkdetails




  
end #Compute  





class Billing
	include HTTParty
  	format :json
  	#debug_output $stderr

  def servicegroups(token, serviceroot)
    self.class.base_uri serviceroot
  	self.class.default_options[:headers] = { "Accept" => "application/json;version=5.7", "Authorization" => "Bearer " + token }
    servicegroupsarray = self.class.get('/api/billing/service-groups')
    return servicegroupsarray 
  end #servicegroups 



def billedcosts(token, serviceroot, servicegroupid)
    self.class.base_uri serviceroot
  	self.class.default_options[:headers] = { "Accept" => "application/json;version=5.7", "Authorization" => "Bearer " + token }
    billedcostsarray = self.class.get('/api/billing/service-group/' + servicegroupid + '/billed-costs')
    return billedcostsarray
  end #billedcosts




def billedusage(token, serviceroot, servicegroupid)
    self.class.base_uri serviceroot
  	self.class.default_options[:headers] = { "Accept" => "application/json;version=5.7", "Authorization" => "Bearer " + token }
    billedusagearray = self.class.get('/api/billing/service-group/' + servicegroupid + '/billed-usage')
  end #billedusage




end #Billing 






class Metering
	include HTTParty
  	format :json
  	#debug_output $stderr


def billablecosts(token, serviceroot, servicegroupid)
    self.class.base_uri serviceroot
  	self.class.default_options[:headers] = { "Accept" => "application/json;version=5.7", "Authorization" => "Bearer " + token }
    billablecostsarray = self.class.get('/api/metering/service-group/' + servicegroupid + '/billable-costs')
    return billablecostsarray
  end #billablecosts



def billableusage(token, serviceroot, instanceid)
    self.class.base_uri serviceroot
  	self.class.default_options[:headers] = { "Accept" => "application/json;version=5.7", "Authorization" => "Bearer " + token }
    billableusagearray = self.class.get('/api/metering/service-instance/' + instanceid + '/billable-usage')
    return billableusagearray
  end #billableusage




end #Metering 




class Custom
	include HTTParty
  	format :xml
  	#debug_output $stderr
 
  def customquery(token, serviceroot, customapicall, acceptcontentspecific)
  	if acceptcontentspecific != nil 
  		acceptcontent = "application/xml" + ";class=" + acceptcontentspecific + ";version=5.7"
  	end
    self.class.base_uri serviceroot
    puts acceptcontent
  	self.class.default_options[:headers] = { "Accept" => acceptcontent, "Authorization" => "Bearer " + token }
    customresult = self.class.get(customapicall)
    return customresult
  end #customquery


end #Custom










