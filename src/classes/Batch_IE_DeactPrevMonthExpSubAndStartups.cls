/***********************************************************************
 Author       :   Kent Roessler
 Created Date :   Feb 16, 2017
 Modified     :   
 Description  :   Monthly batch job that deactivates the SIM card for previous
 month's expired subscriptions and any orders with startup access-only that 
 are past their expiration grace period and any WiFi/LAN subscriptions that
 are past their startup period.  Also, handles cases where user switches from
 Cellular to WiFi/LAN.

 Call the AT&T CC Web Service API to deactivate the SIM card.

 Call the IE API/Service Portal Web Service to update SIM Card Active 
 Status of the IE Unit (asset) in the MS Azure Cloud IE database.

 Set the Asset.SIM_Card_Active__c field to false.
************************************************************************/
global class Batch_IE_DeactPrevMonthExpSubAndStartups implements Database.Batchable<sObject>, Database.AllowsCallouts,  Database.Stateful {
	
	Datetime currDateTime = Datetime.now(); // current date and time in the GMT time zone

	// Create custom exception to throw if there are any errors
    public class Batch_IE_DeactPrevMonthExpSubAndStartupsException extends Exception {}

	
	global Batch_IE_DeactPrevMonthExpSubAndStartups() {

	}
	

	global Database.QueryLocator start(Database.BatchableContext BC) {
		// Since we are processing the gateway asset for a subscription and their are usually 2 Subscription records (TechReadWrite, CustomRead) 
		// or just one of type Standard for an order, just query the subscriptions whose type is TechReadWrite or Standard since all of them are 
		// associated with the gateway asset.
		return Database.getQueryLocator([select Id
                                         , Name
                                         , Start_Date__c
                                         , End_Date__c
                                         , Asset__c
                                         , Type__c
                                         , Active__c
                                         , Serial_Number__c
                                         , IE_Subscription__c
                                         , Buyer_ID__c
                                         , IE_ID__c
                                         , LastModifiedDate
                                         , Connectivity_Type__c
                                         , Term_Years__c
										 , Asset__r.Name
                                         from Subscription__c
                                         where IE_Subscription__c = true AND (Type__c = 'TechReadWrite' OR Type__c = 'Standard') AND 
										 ((End_Date__c = LAST_MONTH AND Active__c = false) OR (Connectivity_Type__c = 'WiFi/LAN' AND Start_Date__c < LAST_N_MONTHS:6))]);
	}


   	global void execute(Database.BatchableContext BC, List<Subscription__c> subscriptions) {
   		boolean hasErrors = false;

   		map<Id, Asset> assetMap = new map<Id, Asset>();
	    map<Id, Address__c> addressMap = new map<Id, Address__c>();
    	list<Integration_Error__c> integrationErrorList = new list<Integration_Error__c>();
    	

   		try {
   			// Error message string that is used to collect any errors/exceptions information
    		String errorMsg = 'Batch_IE_DeactPrevMonthExpSubAndStartups errors: ';
    		

	   		// Pull the AT&T credentials from a custom setting 
			ATT_Jasper_API_REST_Services_Config__c serviceConfig = ATT_Jasper_API_REST_Services_Config__c.getInstance();

			IERenewal_ATTJasperAPIServiceResponseObj putDeviceRespObj = new IERenewal_ATTJasperAPIServiceResponseObj();
			IERenewal_ATTJasperAPIServiceAccess restPutDevice = new IERenewal_ATTJasperAPIServiceAccess(serviceConfig.Base_URL__c, serviceConfig.API_Key__c, 'devices', serviceConfig.User_Name__c, serviceConfig.Enterprise_Account_Id__c);

			list<Asset> inactiveSIMCardAssets = new list<Asset>();


			// Bulkify Parent Asset SOQL query
			map<Id, Asset> parentAssetMap = new map<Id, Asset>();
	        set<Id> parentAssetIds = new set<Id>();
	        for (Subscription__c s : subscriptions)
	        {
	            if ((s.Asset__c != null) && (s.Asset__r.Name != 'Dummy GWotGo Unit Asset') && (s.Asset__r.Name != 'Holding GWotGo Unit Asset'))
	                parentAssetIds.add(s.Asset__c);
	        }
	        for (Asset a : [SELECT Id, Order__c, AccountId, Product2.ProductCode, Product2.Name, SerialNumber, Tag__c from Asset where Id in :parentAssetIds])
	        	parentAssetMap.put(a.Id, a);


	        // Bulkify Gateway Asset SOQL query
			map<Id, Asset> gatewayAssetMap = new map<Id, Asset>();
	        set<Id> gatewayParentAssetIds = new set<Id>();
	        for (Asset a : parentAssetMap.values())
	        {
	            if (a.Id != null)
	                gatewayParentAssetIds.add(a.Id);
	        }
	        for (Asset a : [SELECT Id, Parent_Asset__c, SIM_Card_Active__c, SIM_Card_ICCID__c, MAC_Address__c, Device_ID__c, Status, GWotGo__c from Asset Where (Name = 'Intelligent Equipment Gateway' OR Product2.Name = 'Intelligent Equipment Gateway') AND Status != 'Obsolete' AND Parent_Asset__c in :gatewayParentAssetIds])
	        	gatewayAssetMap.put(a.Parent_Asset__c, a);



			for (Subscription__c s : subscriptions)
			{
				Asset parentAsset=null;
				Asset gatewayAsset=null;
				String simCardICCID = null;

				parentAsset = parentAssetMap.get(s.Asset__c);

				if (parentAsset != null) {
					gatewayAsset = gatewayAssetMap.get(parentAsset.Id);

					if (gatewayAsset != null) {
						gatewayAsset.SIM_Card_Active__c = false;
	                	inactiveSIMCardAssets.add(gatewayAsset);

	                	if (String.isNotBlank(gatewayAsset.SIM_Card_ICCID__c)) {
	                		if (!gatewayAsset.SIM_Card_ICCID__c.trim().isNumeric()) {
				                // Sim Card ICCID should be a 20 digit number, remove any leading or trailing text
				                // ASCII code integer values for characters '0' to '9' are 48 to 57
				                Integer[] chars = gatewayAsset.SIM_Card_ICCID__c.trim().getChars();
				                list<Integer> charArray = new List<Integer>();
				                for (Integer i : chars) {
				                  if ((i >= 48) && (i <= 57))
				                    charArray.add(i);
				                }

				                simCardICCID = String.fromCharArray(charArray);
				            }
				            else {
				              	simCardICCID = gatewayAsset.SIM_Card_ICCID__c.trim();
				            }
	                	}
	                	
			              
			            if (simCardICCID != null) {
			                if (!Test.isRunningTest()) {
			                    // Test isn't running so call the service
			                    putDeviceRespObj = restPutDevice.updateDeviceByICCID(simCardICCID, 'DEACTIVATED', null, null, null, null, null, integrationErrorList);

			                    if (putDeviceRespObj.getResponseCode() != 200) {
	                      			hasErrors = true;
			            			errorMsg = errorMsg + ' | ' + 'SIM Card ICCID = ' + simCardICCID + ', Response code = ' + putDeviceRespObj.getResponseCode() + ', from call to deactivate the sim card!';
	                      		}
			                }
			                else {
			                    // Test is running so mock a response
			                    putDeviceRespObj.setResponseCode(200);
			                    putDeviceRespObj.setResponseData('{"iccid":"89011704258018735310"}');
			                }
			            }
					}
				}
			}


			if (!hasErrors) {
				//update the inactive SIM Card assets
	      		if (inactiveSIMCardAssets.size() > 0) {
	      			IERenewal_ExtWebServiceCallouts.syncIeCloudSIMCardActiveStatus(inactiveSIMCardAssets, assetMap, addressMap, integrationErrorList);
	          		update inactiveSIMCardAssets;
	      		}
			}

			if (hasErrors) {
				throw new Batch_IE_DeactPrevMonthExpSubAndStartupsException(errorMsg);
			}
			
   		}
   		catch (Exception e) {
   			System.debug(logginglevel.error, 'Batch_IE_DeactPrevMonthExpSubAndStartups Exception: ' + e);
   			hasErrors = true;
   			integrationErrorList.add(new Integration_Error__c(Direction__c = ''
       															, Error_Description__c = 'General Exception from Batch_IE_DeactPrevMonthExpSubAndStartups'
       															, Integration_Object__c = 'Asset'
       															, Integration_Point__c = 'IE'
       															, Request_Data__c = e.getMessage() ));
   		}
   		finally {
   			if (!hasErrors) {
   				if (assetMap.size() > 0)
   					update assetMap.values();

   				if (addressMap.size() > 0)
   					update addressMap.values();
   			}

   			if(integrationErrorList.size() > 0) {
   				System.debug(logginglevel.error, 'Batch_IE_DeactPrevMonthExpSubAndStartups integrationErrorList: ' + integrationErrorList);
       			insert integrationErrorList;
       		}
   		}

	}

	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}