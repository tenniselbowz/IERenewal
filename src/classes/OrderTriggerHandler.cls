public with sharing class OrderTriggerHandler {
    public static void onAfterUpdate(map<Id, Order__c> newMap, map<Id, Order__c> oldMap)
    {
        //doIntelSync(newMap, oldMap);
    }

    /*
    public static void doIntelSync(map<Id, Order__c> newMap, map<Id, Order__c> oldMap) {
        List<Id> ordersChanged = AssetIntegrationService.filterOrdersWhoseAssetsToSync(newMap.values(), oldMap, new List<String>{'Vertical_Market__c'});
        List<Asset> assetsToSync = [ SELECT Id FROM Asset WHERE Order__c in :ordersChanged ];
        for (Asset ast : assetsToSync) {
            ID jobID = System.enqueueJob(new SendAssetToIntel(ast.Id));
            System.debug('jobbbbb: ' + jobID);
        }
    }*/

    public static void onBeforeInsert(list<Order__c> newList)
    {
        // Before an Order record is inserted do the following:
        // 1. Query for the address record in the Address__c table via the known job address fields on the order
        // 2. If no job address is found then create a new Address__c record, setting the Address_Type__c field to 'Building' and the Name field to the Order Job Name

		//if(TriggerUtility.limitIeServiceIntegration || TriggerUtility.limitIntegrationBatch) return;


        for (Order__c o : newList)
        {
            // Query for the address.  NOTE: SOQL queries are case insensitive
			// Check if any of the following job address fields on the Order are null or empty before doing the query:
			// Country, State, City, Zip code, Address Line 1
			// Since Address Line 2 is not required it will not be checked.
			if ((String.isNotEmpty(o.Job_Country_new__c)) && (String.isNotEmpty(o.Job_State_Province_new__c)) &&
				(String.isNotEmpty(o.Job_City_new__c)) && (String.isNotEmpty(o.Job_Zip_Postal_Code_new__c)) &&
				(String.isNotEmpty(o.Job_Address_Line_1new__c)))
			{
				List<Address__c> addrList = [SELECT Id, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Address_Line_4__c, Postal_Code__c, City__c, Country__c, State_Province__c 
					FROM Address__c WHERE Country__c = :o.Job_Country_new__c.trim() AND State_Province__c = :o.Job_State_Province_new__c.trim() AND City__c = :o.Job_City_new__c.trim() AND Postal_Code__c = :o.Job_Zip_Postal_Code_new__c.trim() AND Address_Line_1__c = :o.Job_Address_Line_1new__c.trim()];

				if (addrList.isEmpty())
				{
					// Create the address
					System.debug(logginglevel.error, 'OrderTriggerHandler: Job Address not found in salesforce, so create one');
					Address__c addrTemp = new Address__c();
					addrTemp.Name = o.Job_Name__c;
					addrTemp.Address_Type__c = 'Building';
					addrTemp.Address_Line_1__c = o.Job_Address_Line_1new__c.trim();  // Each address line has a string max size of 255
					addrTemp.Address_Line_2__c = o.Job_Address_Line_2new__c.trim();
					addrTemp.Address_Line_3__c = null;
					addrTemp.Address_Line_4__c = null;
					addrTemp.City__c = o.Job_City_new__c.trim();
					addrTemp.Postal_Code__c = o.Job_Zip_Postal_Code_new__c.trim();
					addrTemp.Country__c = o.Job_Country_new__c.trim();
					addrTemp.State_Province__c = o.Job_State_Province_new__c.trim();
					insert addrTemp;
				}

				//TriggerUtility.limitIeServiceIntegration = true;
			}
        }

    }
}