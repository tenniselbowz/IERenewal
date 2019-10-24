trigger Contact_Subscription_Trigger on Contact_Subscription__c (after insert, after update) {

/*********************************************************************
	  * NOTE: The following set of Test Classes will test this trigger.
	  * These would all need to be run to get > 75% code coverage.
	  * 
	  * TestRetrieveAssetService
	  * ResetGWotGoAsset_Test
**********************************************************************/


	if(TriggerUtility.limitIeServiceIntegration || TriggerUtility.limitIntegrationBatch){
			system.debug(':::::::Contact_Subscription_Trigger: TriggerUtility flag set so exiting...');
			return;
	} 
	

	boolean gwotgo_processed = false;
	list<Contact> ieContacts = new list<Contact>();
	set<Id> ContactIds = new set<Id>();
	map<Id, Contact_Subscription__c> csMap = new map<Id, Contact_Subscription__c>();
	
	for(Contact_Subscription__c aa : trigger.new)
	{
		system.debug(':::::::Contact_Subscription_Trigger: ' + aa);
		ContactIds.add(aa.Contact__c);
		csMap.put(aa.Contact__c, aa);
	}

	
	for(Contact a : [Select Id, IE_Sync_Status__c from Contact where Ie_Contact__c = true and Id in :ContactIds])
	{
		if (csMap.get(a.Id).GWotGoAsset__c != null) {
			// Processing a GWotGo asset
			Asset unitAsset = [SELECT Id, Name, IE_Sync_Status__c from Asset Where Id = :csMap.get(a.Id).Asset__c];

			if ((unitAsset.Name != 'Dummy GWotGo Unit Asset') && (unitAsset.Name != 'Holding GWotGo Unit Asset')) {
				if ((csMap.get(a.Id).GWotGoAsset__c != null) 
					&& (Trigger.oldMap == null || (Trigger.oldMap.get(csMap.get(a.Id).Id).Asset__c != csMap.get(a.Id).Asset__c)))
				{
					// This contact-subscription is associated with a GWotGo asset that just moved from one unit to another from a Reset operation
					// Set status to 'Processed' so the hourly IE batch job ignores it
					system.debug(':::::::Contact_Subscription_Trigger set status to Processed for GWotGo');
					a.IE_Sync_Status__c = 'Processed';
					ieContacts.add(a);
					TriggerUtility.limitIntegrationBatch = true; // set this to true so contact trigger handler doesn't set status to Pending
					gwotgo_processed = true;
				}
				else {
					system.debug(':::::::Contact_Subscription_Trigger set status to Pending for GWotGo');
					if (a.IE_Sync_Status__c != 'Pending') {
						a.IE_Sync_Status__c = 'Pending';
						ieContacts.add(a);
					}
				}
			}
			else {
				system.debug(':::::::Contact_Subscription_Trigger unit asset equals Dummy or Holding set status to Processed');
				a.IE_Sync_Status__c = 'Processed';
				ieContacts.add(a);
				TriggerUtility.limitIntegrationBatch = true; // set this to true so contact trigger handler doesn't set status to Pending
				gwotgo_processed = true;
			}
		}
		else {
			if (a.IE_Sync_Status__c != 'Pending') {
				system.debug(':::::::Contact_Subscription_Trigger set status to Pending');
				a.IE_Sync_Status__c = 'Pending';
				ieContacts.add(a);
			}
		}

	}
	
	if (ieContacts.size() > 0)
		update ieContacts;

	// reset this back to false if it was set here for GWotGo processed
	if (gwotgo_processed) {
		system.debug(':::::::Contact_Subscription_Trigger: reset TriggerUtility flag to false');
		TriggerUtility.limitIntegrationBatch = false;
	}
}