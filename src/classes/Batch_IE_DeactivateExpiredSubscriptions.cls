/********************************************************************************************
 Author       :   Kent Roessler
 Created Date :   Feb 14, 2017
 Modified     :   
 Description  :   Nightly batch job that checks all subscriptions whose End Date has expired.

 For expired subscriptions the Active__c field is set to false.

 The batch job, "Batch_IE_CallExtWebServices" will process these expired/deactivated 
 subscriptions by making a call to the IE API/Service Portal Web Services 
 to update the subscription active status in the MS Azure Cloud IE database.
**********************************************************************************************/
global class Batch_IE_DeactivateExpiredSubscriptions implements Database.Batchable<sObject>, Database.AllowsCallouts,  Database.Stateful{
	
	Datetime currDateTime = Datetime.now(); // current date and time in the GMT time zone

	
	global Batch_IE_DeactivateExpiredSubscriptions() {
		
	}
	

	global Database.QueryLocator start(Database.BatchableContext BC) {
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
										 , TriggerInvokedByAPI__c
                                         , LastModifiedDate
                                         from Subscription__c
                                         where IE_Subscription__c = true AND Active__c = true AND End_Date__c < :currDateTime]);
	}


   	global void execute(Database.BatchableContext BC, List<Subscription__c> subscriptions) {

		List<Subscription__c> updatedSubscriptions = new list<Subscription__c>();

		try {
			for (Subscription__c s : subscriptions)
	        {
				Asset parentAsset = [SELECT Id, Name from Asset Where Id = :s.Asset__c];

	        	s.Active__c = false;

				// Only set the trigger field on the subscription if its asset is not the Dummy Unit and Holding Unit.
				if ((parentAsset.Name != 'Dummy GWotGo Unit Asset') && (parentAsset.Name != 'Holding GWotGo Unit Asset'))
	        		s.TriggerInvokedByAPI__c = true;

	        	updatedSubscriptions.add(s);

	        }

	        if (!updatedSubscriptions.isEmpty()) {
	            update updatedSubscriptions;
	        }
		}
		catch (Exception e) {
   			System.debug(logginglevel.error, 'Batch_IE_DeactivateExpiredSubscriptions Exception: ' + e);
   		}
   		finally {

   		}

	}

	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}