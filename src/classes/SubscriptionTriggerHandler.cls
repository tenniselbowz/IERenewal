public without sharing class SubscriptionTriggerHandler {
	/*********************************************************************
	* NOTE: The following set of Test Classes will test this trigger code.
	* These would all need to be run to get > 75% code coverage.
	* 
	* IERenewal_SubscriptionUpdateServiceTest
	* Batch_IE_Subscription_NotificationTest
	* Batch_IE_DeactivateExpiredSubscrip_Test
	* ResetGWotGoAsset_Test
	**********************************************************************/
	
	public static void onBeforeUpdate(map<Id, Subscription__c> newMap, map<Id, Subscription__c> oldMap)
	{
		resetEmailCriteriaBucketFlags(newMap.values(), oldMap);
		setIeSyncStatus(newMap.values(), oldMap);
	}
	
    
	public static void onBeforeInsert(list<Subscription__c> newList)
	{
		//setStartEndSubscriptionDates(newList); //Don't need to call since these fields will be set in the Renewal Service and ETL
		setIeSyncStatus(newList, null);
	}
	
    
	public static void onBeforeDelete(map<Id, Subscription__c> oldMap)
	{
		for(Subscription__c s : oldMap.values())
		{
			if( s.Record_Usage__c != null)
				s.addError('This record cannot be deleted because it is integrated with other systems or tied to other critical information within Salesforce.');
				
		}
	}


	public static void setIeSyncStatus(list<Subscription__c> newlist, map<Id, Subscription__c> oldMap)
	{
		for(Subscription__c a : newList)
		{
			if (a.IE_Subscription__c 
			   && (oldMap == null || oldMap.get(a.Id).TriggerInvokedByAPI__c == false)
			   && a.TriggerInvokedByAPI__c == false
			   && !(TriggerUtility.limitIeServiceIntegration || TriggerUtility.limitIntegrationBatch))
		    {
				if (a.GWotGoAsset__c != null) {
					// Processing a GWotGo asset
					Asset unitAsset = [SELECT Id, Name, IE_Sync_Status__c from Asset Where Id = :a.Asset__c];

					if ((unitAsset.Name != 'Dummy GWotGo Unit Asset') && (unitAsset.Name != 'Holding GWotGo Unit Asset')) {
						if ((a.GWotGoAsset__c != null) && (oldMap == null || (oldMap.get(a.Id).Asset__c != a.Asset__c)))
						{
							// This subscription is associated with a GWotGo asset that just moved from one unit to another from a Reset operation
							// Set status to 'Processed' so the IE batch job ignores it
							a.IE_Sync_Status__c = 'Processed';
						}
						else {
							a.IE_Sync_Status__c = 'Pending';
							a.TriggerInvokedByAPI__c = true;  // set to true so 15 min apex job processes it
						}
					}
					else {
						a.IE_Sync_Status__c = 'Processed';
					}
				}
				else {
					a.IE_Sync_Status__c = 'Pending';
					a.TriggerInvokedByAPI__c = true;  // set to true so 15 min apex job processes it
				}
		    }

			/*if (a.IE_Subscription__c 
			   && (oldMap == null || oldMap.get(a.Id).IE_Sync_Status__c != 'Pending')
			   && a.IE_Sync_Status__c != 'Pending'
			   && !(TriggerUtility.limitIeServiceIntegration || TriggerUtility.limitIntegrationBatch))
		    {
				if (a.GWotGoAsset__c != null) {
					// Processing a GWotGo asset
					Asset unitAsset = [SELECT Id, Name, IE_Sync_Status__c from Asset Where Id = :a.Asset__c];

					if ((unitAsset.Name != 'Dummy GWotGo Unit Asset') && (unitAsset.Name != 'Holding GWotGo Unit Asset')) {
						if ((a.GWotGoAsset__c != null) && (oldMap == null || (oldMap.get(a.Id).Asset__c != a.Asset__c)))
						{
							// This subscription is associated with a GWotGo asset that just moved from one unit to another from a Reset operation
							// Set status to 'Processed' so the hourly IE batch job ignores it
							a.IE_Sync_Status__c = 'Processed';
						}
						else {
							a.IE_Sync_Status__c = 'Pending';
							a.TriggerInvokedByAPI__c = true;  // set to true so 15 min apex job processes it
						}
					}
					else {
						a.IE_Sync_Status__c = 'Processed';
					}
				}
				else {
					a.IE_Sync_Status__c = 'Pending';
					a.TriggerInvokedByAPI__c = true;  // set to true so 15 min apex job processes it
				}
		    }*/
		    
		    if(a.IE_Subscription__c)
		    {
				if(a.Record_Usage__c != null && !a.Record_Usage__c.contains('IE'))
					a.Record_Usage__c +=  ';IE';
				else if(a.Record_Usage__c == null)
					a.Record_Usage__c =  'IE';
		    }
		}
	}


    
    
    public static void resetEmailCriteriaBucketFlags(list<Subscription__c> newlist, map<Id, Subscription__c> oldMap)
    {
		// Normally these fields will be reset in the Renewal Update Service and ETL inserts.
		// This is here for the case where a user updates the End Date manually causing the update trigger to fire.
        for(Subscription__c s : newList)
        {
            // if the subscription is being renewed (ie, new end_date) then reset all the email criteria bucket flags to false
            if (s.End_Date__c > oldMap.get(s.Id).End_Date__c)
            {
				System.debug(LoggingLevel.ERROR,'in subscription trigger handler: new end date = ' + s.End_Date__c + ', old end date = '+ oldMap.get(s.Id).End_Date__c);

                s.Renewal_Notice_Current_Month__c = false;
                s.Renewal_Notice_Next_Month__c = false;
                s.Renewal_Notice_Last_Month__c = false;
                s.Renewal_Notice_Next_Month_Plus_1__c = false;
                s.Renewal_Notice_Last_Month_Minus_1__c = false;
            }
        }
    }
	
    
    /*
	public static void setStartEndSubscriptionDates(list<Subscription__c> subscriptions)
	{
			//Asset.Commissioned__c = true
			//Asset.Commissioned__c was previously true
			//Asset.Subscription__c.StartDate__c = null
			//Asset.Subscription__c.Type__c  != 'Daikin'
			
		 map<Id, Asset> assetMap = new map<Id, Asset>(); 
		 set<Id> assetIds = new set<Id>();
		 for(Subscription__c s : subscriptions)
		 {
		 	if(s.Asset__c != null && s.Type__c  != 'Daikin' && s.Start_Date__c == null)
		 		assetIds.add(s.Asset__c);
		 }
		 
		 //retrieve the associated Assets
		 for(Asset a : [Select Id from Asset where Id in :assetIds and Commissioned__c = true])
		 	assetMap.put(a.Id, a);
		 
		 for(Subscription__c s : subscriptions)
		 {
		 	if(assetMap.containsKey(s.Asset__c))
		 	{
		 		s.Start_Date__c = system.today();
				s.End_Date__c = system.today().addDays( Integer.ValueOf(365 * (s.Term_Years__c==null ? 1 :s.Term_Years__c) ));
				s.Active__c = true;
		 	}
		 		
		 }
	}
	*/

}