/***********************************************************************
 Author       :   Kent Roessler
 Created Date :   March 16, 2017
 Modified     :   
 Description  :   Daily batch job that deactivates the SIM card for 
 for a GW Asset status set to 'Obsolete'.

 Call the AT&T CC Web Service API to deactivate the SIM card.

 Call the IE API/Service Portal Web Service to update SIM Card Active 
 Status of the IE Unit (asset) in the MS Azure Cloud IE database.

 Set the Asset.SIM_Card_Active__c field to false.
************************************************************************/
global class Batch_IE_ProcObsGWAssets implements Database.Batchable<sObject>, Database.AllowsCallouts,  Database.Stateful {
	
	Datetime currDateTime = Datetime.now(); // current date and time in the GMT time zone


	// static variables used in unit tests
    public static boolean crash_syncIeCloudSIMCardActiveStatus_TestByResponseStatusCode = false;
    public static boolean crash_syncIeCloudSIMCardActiveStatus_TestByException = false;
    

	// Create custom exception to throw if there are any errors
    public class Batch_IE_ProcObsGWAssetsException extends Exception {}
    
	
	global Batch_IE_ProcObsGWAssets() {
		
	}
	

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([SELECT Id, 
			Parent_Asset__c, 
			SIM_Card_Active__c, 
			SIM_Card_ICCID__c, 
			MAC_Address__c,
			Device_ID__c,
			GWotGo__c
			from Asset Where (Name = 'Intelligent Equipment Gateway' OR Product2.Name = 'Intelligent Equipment Gateway') AND Status = 'Obsolete' AND SIM_Card_Active__c = true]);
	}


   	global void execute(Database.BatchableContext BC, List<Asset> assets) {
   		boolean hasErrors = false;

    	map<Id, Asset> assetMap = new map<Id, Asset>();
	    map<Id, Address__c> addressMap = new map<Id, Address__c>();
    	list<Integration_Error__c> integrationErrorList = new list<Integration_Error__c>();


   		try {
   			// Error message string that is used to collect any errors/exceptions information
    		String errorMsg = 'Batch_IE_ProcObsGWAssets errors: ';
    		

	      	// Pull the AT&T credentials from a custom setting 
	      	ATT_Jasper_API_REST_Services_Config__c serviceConfig = ATT_Jasper_API_REST_Services_Config__c.getInstance();

	      	IERenewal_ATTJasperAPIServiceResponseObj putDeviceRespObj = new IERenewal_ATTJasperAPIServiceResponseObj();
	      	IERenewal_ATTJasperAPIServiceAccess restPutDevice = new IERenewal_ATTJasperAPIServiceAccess(serviceConfig.Base_URL__c, serviceConfig.API_Key__c, 'devices', serviceConfig.User_Name__c, serviceConfig.Enterprise_Account_Id__c);

	      	list<Asset> obsoleteAssets = new list<Asset>();

		    for (Asset a : assets)
		    {
		        String simCardICCID = null;

				a.SIM_Card_Active__c = false;
				obsoleteAssets.add(a);

	            if (String.isNotBlank(a.SIM_Card_ICCID__c)) {
	              	if (!a.SIM_Card_ICCID__c.trim().isNumeric()) {
	                  // Sim Card ICCID should be a 20 digit number, remove any leading or trailing text
	                  // ASCII code integer values for characters '0' to '9' are 48 to 57
	                  Integer[] chars = a.SIM_Card_ICCID__c.trim().getChars();
	                  list<Integer> charArray = new List<Integer>();
	                  for (Integer i : chars) {
	                    if ((i >= 48) && (i <= 57))
	                      charArray.add(i);
	                  }

	                  simCardICCID = String.fromCharArray(charArray);
	                }
	                else {
	                  simCardICCID = a.SIM_Card_ICCID__c.trim();
	                }
	            }
	              
	            if (simCardICCID != null) {
	                if (!Test.isRunningTest()) {
	                    // Test isn't running so call the service

						// Before calling the service to deactivate the sim card, check if the GW
						// asset has been associated to another unit.
						Asset[] gatewayAssets = [SELECT Id, Parent_Asset__c, SIM_Card_Active__c, SIM_Card_ICCID__c, MAC_Address__c, Device_ID__c, GWotGo__c from Asset Where (Name = 'Intelligent Equipment Gateway' OR Product2.Name = 'Intelligent Equipment Gateway') AND Status != 'Obsolete' AND SIM_Card_Active__c = true AND SIM_Card_ICCID__c = :a.SIM_Card_ICCID__c AND Parent_Asset__c != :a.Parent_Asset__c];
						if (gatewayAssets.size() == 0) {
							// GW is not associated with any other units, so deactivate it.
							putDeviceRespObj = restPutDevice.updateDeviceByICCID(simCardICCID, 'DEACTIVATED', null, null, null, null, null, integrationErrorList);
						  
							if (putDeviceRespObj.getResponseCode() != 200) {
								hasErrors = true;
								errorMsg = errorMsg + ' | ' + 'SIM Card ICCID = ' + simCardICCID + ', Response code = ' + putDeviceRespObj.getResponseCode() + ', from call to deactivate the sim card!';
							}
						}
						else {
							// GW is associated with another unit, so leave it activated
							// Log this event
							integrationErrorList.add(new Integration_Error__c(Direction__c = 'Batch_IE_ProcObsGWAssets Job'
       												, Error_Description__c = 'Gateway Asset not deactivated!'
       												, Integration_Object__c = 'Asset'
       												, Integration_Point__c = 'IE'
       												, Request_Data__c = 'Gateway with sim iccid ' + a.SIM_Card_ICCID__c + ' was not deactivated since it is associated with another unit' ));
						}
	                }
	                else {
	                    // Test is running so mock a response
	                    putDeviceRespObj.setResponseCode(200);
	                    putDeviceRespObj.setResponseData('{"iccid":"89011704258018735310"}');
	                }
	            }
		    }

		    if (!hasErrors) {
			    //update the obsolete assets
		        if (obsoleteAssets.size() > 0) {
		        	IERenewal_ExtWebServiceCallouts.syncIeCloudSIMCardActiveStatus(obsoleteAssets, assetMap, addressMap, integrationErrorList);
		            update obsoleteAssets;
		        }
	    	}

	    	if (hasErrors) {
				throw new Batch_IE_ProcObsGWAssetsException(errorMsg);
			}
   		}
   		catch (Exception e) {
   			System.debug(logginglevel.error, 'Batch_IE_ProcObsGWAssets Exception: ' + e);
   			hasErrors = true;
   			integrationErrorList.add(new Integration_Error__c(Direction__c = ''
       															, Error_Description__c = 'General Exception from Batch_IE_ProcObsGWAssets'
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
   				System.debug(logginglevel.error, 'Batch_IE_ProcObsGWAssets integrationErrorList: ' + integrationErrorList);
       			insert integrationErrorList;
       		}
   		}
		
	}
	

	global void finish(Database.BatchableContext BC) {
		
	}
	
}