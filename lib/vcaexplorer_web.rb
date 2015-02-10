$:.unshift File.dirname(__FILE__)

require 'sinatra'
require 'httparty'
require 'xml-fu'
require 'modules/vcautilscore'
require 'gon-sinatra'
require 'json'

Sinatra::register Gon::Sinatra

set :port, 8080
#set :static, true
set :public_folder, "./lib/static"
set :views, "./lib/views"




get '/loginbasic' do
    erb :login_basic
end #get /loginbasic



get '/' do
    erb :login_advanced
end #get /



post '/vcaexplorer' do

	@@username = params[:username]
	@@password = params[:password]
	@@serviceroot = "https://vca.vmware.com"
	@@loginserviceroot = "https://iam.vchs.vmware.com"

	@@iam = Iam.new()

	@@sc = Sc.new()

	@@compute = Compute.new()
	
	@@billing = Billing.new()

	@@token = @@iam.login(@@username, @@password, @@loginserviceroot)
					
					
	gon.instancesarray = @@sc.instances(@@token, @@serviceroot)
	gon.plansarray = @@sc.plans(@@token, @@serviceroot)	
	gon.instancesarray = @@sc.instances(@@token, @@serviceroot)
	gon.usersarray = @@iam.users(@@token, @@serviceroot)
	gon.servicegroupsarray = @@billing.servicegroups(@@token, @@serviceroot)


################
##START Plans
################
    gon.plans_tree = {"name"=> "PlanList", "children" => [{}]}
    gon.plans_tree["children"][0] = {"name" => "plans", "children" => [{}]}
    gon.plansarray['PlanList']['plans'].length.times do |i| 
    											gon.plans_tree["children"][0]["children"][i] = {"name" => gon.plansarray['PlanList']['plans'][i]["name"] + " " + gon.plansarray['PlanList']['plans'][i]["region"],
    																							"attribute0" => "name        : " + gon.plansarray['PlanList']['plans'][i]["name"],
    																							"attribute1" => "id          : " + gon.plansarray['PlanList']['plans'][i]["id"],
    																							"attribute2" => "region      : " + gon.plansarray['PlanList']['plans'][i]["region"],
    																							"attribute3" => "planVersion : " + gon.plansarray['PlanList']['plans'][i]["planVersion"]
    																						} 
    															end												
################
##STOP Plans
################





################
##START Instances + VDCS
################
    gon.instances_tree = {"name"=> "InstanceList", "children" => [{}]}
    gon.instances_tree["children"][0] = {"name" => "instances", "children" => [{}]}
    gon.instancesarray["InstanceList"]["instances"].length.times do |i| 
    			gon.instances_tree["children"][0]["children"][i] = {"name" => gon.instancesarray["InstanceList"]["instances"][i]["name"], 
     																"attribute0" => "name   : " + gon.instancesarray["InstanceList"]["instances"][i]["name"],
     																"attribute1" => "id     : " + gon.instancesarray["InstanceList"]["instances"][i]["id"],
     																"attribute2" => "region : " + gon.instancesarray["InstanceList"]["instances"][i]["region"],
     																"attribute3" => "planId : " + gon.instancesarray["InstanceList"]["instances"][i]["planId"],
     																"attribute4" => "apiUrl : " + gon.instancesarray["InstanceList"]["instances"][i]["apiUrl"],
    																"children" => [{}]
    																}
    			gon.instances_tree["children"][0]["children"][i]["children"][0] = {"name" => "instanceAttributes",
    																			   "attribute0" => "orgName    : " + gon.instancesarray["InstanceList"]["instances"][i]["instanceAttributes"]["orgName"],
    																			   "attribute0" => "sessionUri : " + gon.instancesarray["InstanceList"]["instances"][i]["instanceAttributes"]["sessionUri"],
    																			  }
    																
    			orgname, sessionuri, apiUrl = @@compute.extractendpoint(gon.instancesarray["InstanceList"]["instances"][i]["instanceAttributes"])
     	  	  	computetoken = @@compute.login(@@username, @@password, orgname, sessionuri) 
    		    
    		    gon.vdcsarray = @@compute.instancedetails(computetoken, sessionuri, "/api/compute/api/admin/vdcs/query")
    			#puts JSON.pretty_generate(vdcsarray)
     	  	  	
     	  	  	gon.vdcsarray["QueryResultRecords"]["OrgVdcRecord"].length.times do |e|
     	  	  	     
								gon.instances_tree["children"][0]["children"][i]["children"][e] = {"name" => gon.vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["name"],
    																						       "attribute0" => "status        : " + gon.vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["status"],
    																						       "attribute1" => "numberOfVApps : " + gon.vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["numberOfVApps"],
    																						       "attribute2" => "cpuUsedMhz    : " + gon.vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["cpuUsedMhz"],
    																						       "attribute3" => "memoryUsedMB  : " + gon.vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["memoryUsedMB"],
    																						       "attribute4" => "storageUsedMB : " + gon.vdcsarray["QueryResultRecords"]["OrgVdcRecord"][e]["storageUsedMB"]
    																						      }
    																						          	  	  	 
     	  	  	end	# gon.vdcsarray["QueryResultRecords"]["OrgVdcRecord"].length.times do |e| 
												
	end #gon.instancesarray["InstanceList"]["instances"].length.times do |i|
    		
												
########################
##STOP Instances + VDCS
########################



################
##START Users
################
    gon.users_tree = {"name"=> "Users", "children" => [{}]}
    gon.users_tree["children"][0] = {"name" => "User", "children" => [{}]}
    gon.usersarray['Users']['User'].length.times do |i| 
    					gon.users_tree["children"][0]["children"][i] = {"name" => gon.usersarray['Users']['User'][i]["email"], 
    																	"attribute0" => "state    : " + gon.usersarray['Users']['User'][i]["state"],
    																	"attribute1" => "email    : " + gon.usersarray['Users']['User'][i]["email"],
    																	"attribute2" => "userName : " + gon.usersarray['Users']['User'][i]["userName"],
    																	"children" => [{}]
    																	}
    					gon.users_tree["children"][0]["children"][i]["children"][0] = {"name" => "id", 
    																				"attribute0" => "id       : " + gon.usersarray['Users']['User'][i]["id"],
    																				"attribute1" => "created  : " + gon.usersarray['Users']['User'][i]["meta"]["created"],
    																				"attribute2" => "modified : " + gon.usersarray['Users']['User'][i]["meta"]["modified"]
    																				}												
    					gon.users_tree["children"][0]["children"][i]["children"][1] = {"name" => "roles", 
    																				"children" => [{}]
    																				}												

						gon.usersarray['Users']['User'][i]["roles"]["role"].length.times do |x|
										gon.users_tree["children"][0]["children"][i]["children"][1]["children"][x] = {"name" => gon.usersarray['Users']['User'][i]["roles"]["role"][x]["name"],
																											    "attribute0" => "name        : " + gon.usersarray['Users']['User'][i]["roles"]["role"][x]["name"], 
																											    "attribute1" => "id          : " + gon.usersarray['Users']['User'][i]["roles"]["role"][x]["id"], 
																											    "attribute2" => "description : " + gon.usersarray['Users']['User'][i]["roles"]["role"][x]["description"] 
																											    }					
						end # gon.usersarray['Users']['User']["roles"]["role"].length.times do |x|					
    																	
    																	
	end # gon.usersarray['Users']['User'].length.times do |i|
    																										
################
##STOP Users
################



################
##START ServiceGroups
################

    gon.servicegroups_tree = {"name"=> "serviceGroupList", "children" => [{}]}
    gon.servicegroups_tree["children"][0] = {"name" => "serviceGroup", "children" => [{}]}
    
    gon.servicegroupsarray["serviceGroupList"]["serviceGroup"].length.times do |i| 	
    		gon.servicegroups_tree["children"][0]["children"][i] = {"name" => gon.servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["displayName"], 
    															"attribute0" => "id              : " + gon.servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["id"],
    															"attribute1" => "displayName     : " + gon.servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["displayName"],
    															"attribute2" => "billingCurrency : " + gon.servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["billingCurrency"],
    															"children" => [{}]
    															}
    	    gon.servicegroups_tree["children"][0]["children"][i]["children"][0] = {"name" => "availableBills", 
    	         														       	   "children" => [{}]
    	         														       	   }
    	    gon.servicegroups_tree["children"][0]["children"][i]["children"][0]["children"][0] = {"name" => "bill", 
    	         														       	   "children" => [{}]
    	         														       	   }
    	    gon.servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["availableBills"]["bill"].length.times do |x|
    	    			gon.servicegroups_tree["children"][0]["children"][i]["children"][0]["children"][0]["children"][x] = {"name" => "billingPeriod", 
    	         														       	   "children" => [{}]
    	         														       	   }
    	         		gon.servicegroups_tree["children"][0]["children"][i]["children"][0]["children"][0]["children"][x]["children"][0] = {"name" => gon.servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["availableBills"]["bill"][x]["billingPeriod"]["month"].to_s + "-" + gon.servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["availableBills"]["bill"][x]["billingPeriod"]["year"].to_s,
    	     																															   "attribute0" => "month     : " + gon.servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["availableBills"]["bill"][x]["billingPeriod"]["month"].to_s,
    	     																															   "attribute1" => "year      : " + gon.servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["availableBills"]["bill"][x]["billingPeriod"]["year"].to_s,
    	     																															   "attribute2" => "startDate : " + gon.servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["availableBills"]["bill"][x]["billingPeriod"]["startDate"].to_s,
    	     																															   "attribute3" => "endDate   : " + gon.servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["availableBills"]["bill"][x]["billingPeriod"]["endDate"].to_s
    	     																															   }    	     																															   
    	    end #gon.servicegroupsarray["serviceGroupList"]["serviceGroup"][i]["availableBills"]["bill"].length.times do |x|
    	         														       
    
    end #gon.servicegroupsarray["serviceGroupList"]["serviceGroup"].length.times do |i| 


################
## END ServiceGroups
################


##########################
## Assembling vCA root ###
##########################

gon.vcaroot_tree = {"name"=> "vCloud Air", "children" => [{}]}
gon.vcaroot_tree["children"][0] = gon.plans_tree
gon.vcaroot_tree["children"][1] = gon.instances_tree
gon.vcaroot_tree["children"][2] = gon.users_tree
gon.vcaroot_tree["children"][3] = gon.servicegroups_tree


#################################
## End of Assembling vCA root ###
#################################



	erb :vcaexplorer
end #post / 



get '/token' do
	erb :token, :locals => {'username' => @@username, 'serviceroot' => @@serviceroot, 'token' => @@token}
end #/token

