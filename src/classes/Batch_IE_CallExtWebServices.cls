/************************************************************************************
 Author       :   Kent Roessler
 Created Date :   March 16, 2017
 Modified     :   
 Description  :   Batch job that runs every 15 mins will process any new 
 subscriptions from the ETL, Renewal subscriptions from the web service, and 
 Expired/Deactivated subscriptions from "Batch_IE_DeactivateExpiredSubscriptions".

 -Call the AT&T CC Web Service API to set various properties.

 -Call the IE API/Service Portal Web Service to update the Connectivity Type 
 and SIM Card Active Status of the IE Unit (asset) in the MS Azure Cloud IE database.
 Also update the SIM Card Active Status on the GW asset in salesforce if the 
 connectivity type is Cellular then it's set to true else false.

 -Call the IE API/Service Portal Web Service to update the Active Status 
 of the IE Subscription in the MS Azure Cloud IE database.

 -Call the IE API/Service Portal Web Service to update Organizations (accounts).

 -Call the IE API/Service Portal Web Service to update Individuals (contacts).

 -Generate confirmation email for successful subscription renewals and new subscriptions
*************************************************************************************/
global class Batch_IE_CallExtWebServices implements Database.Batchable<sObject>, Database.AllowsCallouts,  Database.Stateful {

    //inner classes
    global class SubscriptionsConfirm
	{
		Id subscriptionId{get;set;}
		String salesOrderNumber{get;set;}
		Date orderEntryDate{get;set;}
        String jobName{get;set;}
        String orderTag{get;set;}
        String equipment{get;set;}
		
		global SubscriptionsConfirm(Id sId)
		{
            subscriptionId = sId;
            salesOrderNumber = null;
            orderEntryDate = null;
            jobName = null;
            orderTag = null;
            equipment = null;
		}
	}
    
    
    global class ContactsToEmail
    {
        Id contactId{get;set;}
        list<SubscriptionsConfirm> subscriptionsConfirm{get;set;}  //list of new/renewed subscriptions for a contact to email a confirmation
        
        global ContactsToEmail(Id cId)
        {
            contactId = cId;
            subscriptionsConfirm = new list<SubscriptionsConfirm>();
        }
    }


    global class SubscriptionsWithNoRA_SR
    {
		Id subscriptionId{get;set;}
        String name{get;set;}
        
        global SubscriptionsWithNoRA_SR(Id sId, String n)
		{
            subscriptionId = sId;
            name = n;
		}
    }


	
	Datetime currDateTime = Datetime.now(); // current date and time in the GMT time zone


	// static variables used in unit tests
	public static boolean crash_syncIeCloudIndividuals_TestByResponseStatusCode = false;
    public static boolean crash_syncIeCloudIndividuals_TestByException = false;
    public static boolean crash_syncIeCloudOrganizations_TestByResponseStatusCode = false;
    public static boolean crash_syncIeCloudOrganizations_TestByException = false;
    public static boolean crash_syncIeCloudSubscriptions_TestByResponseStatusCode = false;
    public static boolean crash_syncIeCloudSubscriptions_TestByException = false;
    public static boolean crash_syncIeCloudUnits_TestByResponseStatusCode = false;
    public static boolean crash_syncIeCloudUnits_TestByException = false;

	
	
	global Batch_IE_CallExtWebServices() {

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
                                         , IE_Sync_Status__c
                                         , Buyer_ID__c
                                         , IE_ID__c
                                         , Renewal_Counter__c
                                         , Connectivity_Type__c
                                         , Term_Years__c
                                         , TriggerInvokedByAPI__c
                                         , LastModifiedDate
										 , GWotGoAsset__c
                                         , (Select Id, Name, Role__c, Contact__c, Contact__r.Name, Contact__r.Email, Contact__r.Id, Contact__r.AccountId From Contact_Subscriptions__r)
                                         from Subscription__c
                                         where IE_Subscription__c = true AND TriggerInvokedByAPI__c = true AND (Type__c = 'TechReadWrite' OR Type__c = 'TechRead' OR Type__c = 'Standard')]);
	}


   	global void execute(Database.BatchableContext BC, List<Subscription__c> subscriptions) {
   		// First check if it's an Expired/Deactivated Subscription from the batch job, "Batch_IE_DeactivateExpiredSubscriptions".
   		// If it is then we only make a call to the IE API/Service Portal Web Services to update the 
   		// subscription active status in the MS Azure Cloud IE database.
   		
   		// For New and Renewed Subscriptions (ie, Not Expired/Active), all of the web service calls are made.

   		// NOTE: Since their are usually 2 Subscription records (TechReadWrite, CustomRead) or just "Standard" for an order, 
   		// just get the subscription where type is TechReadWrite or Standard, since they all have the same parent asset.

		// NOTE: All the web service callouts must be made before any DML operations are performed!

   		boolean hasErrors = false;
   		map<Id, Subscription__c> syncIeCloudExpSubResultsMap = new map<Id, Subscription__c>();
		map<Id, Subscription__c> syncIeCloudNotExpSubResultsMap = new map<Id, Subscription__c>();
		map<Id, Asset> syncIeCloudUnitsAssetResultsMap = new map<Id, Asset>();
		map<Id, Asset> syncIeCloudUnitsRelatedAssetResultsMap = new map<Id, Asset>();
		map<Id, Address__c> syncIeCloudUnitsAddressMap = new map<Id, Address__c>();
		map<Id, Contact> syncIeCloudIndividualsContactResultsMap = new map<Id, Contact>();
		map<Id, Address__c> syncIeCloudIndividualsAddressMap = new map<Id, Address__c>();
		map<Id, Account> syncIeCloudOrganizationsAccountResultsMap = new map<Id, Account>();
		map<Id, Address__c> syncIeCloudOrganizationsAddressMap = new map<Id, Address__c>();


		list<SubscriptionsConfirm> subscriptionsConfirmList = new list<SubscriptionsConfirm>();  //list of ALL new/renewed subscriptions
		map<Id, Subscription__c> subscriptionConfirmMap = new map<Id, Subscription__c>();
		list<ContactsToEmail> contactsToEmailList = new list<ContactsToEmail>();  //list of contacts to email about their new/renewed subscriptions
		list<SubscriptionsWithNoRA_SR> subscriptionsWithNoRA_SRList = new list<SubscriptionsWithNoRA_SR>();  //list of ALL new/renewed subscriptions that have no Renewal Administrator or Sales Rep defined
		list<Integration_Error__c> integrationErrorList = new list<Integration_Error__c>();  //list of any errors that will be logged into the Integration_Error object

		List<Subscription__c> expiredSubscriptions = new list<Subscription__c>();
   		List<Subscription__c> notExpiredSubscriptions = new list<Subscription__c>();

   			try {
   				TriggerUtility.limitIntegrationBatch = true; // set this to true to limit trigger functionality on some objects

				// list to contain the subscription pairs (TechReadWrite/CustomRead) or just subscriptions of type Standard
				List<Subscription__c> subscriptionList = new list<Subscription__c>();


				map<Id, Account> accountMap = new map<Id, Account>();
				set<Id> accountIds = new set<Id>();
				map<Id, Contact> contactMap = new map<Id, Contact>();
				set<Id> contactIds = new set<Id>();


   			
   				// Bulkify: Build up a list of Asset Ids, then use a selective soql query on that list to get a list of asset objects
				// we can put in a map structure.  Use the map structure inside the for-loop when retrieving the individual assets.
				map<Id, Asset> assetMap = new map<Id, Asset>();
				set<Id> assetIds = new set<Id>();
				for (Subscription__c s : subscriptions)
				{
					if ((s.Asset__c != null) && (s.Type__c == 'TechReadWrite' || s.Type__c == 'TechRead' || s.Type__c == 'Standard'))
					{
						assetIds.add(s.Asset__c);
						subscriptionList.add(s);
					}
				}
         
				//retrieve the associated Assets
				for (Asset a : [Select Id, Order__c, Order__r.SO_Number__c, Order__r.Order_Entry_Date__c, AccountId, Job_Name__c, Tag__c, Equipment_Description__c, Product_Description__c from Asset where Id in :assetIds])
					assetMap.put(a.Id, a);

				//retrieve associated CustomRead records for any corresponding TechReadWrite Subscription records
				map<Id, Subscription__c> customReadSubMap = new map<Id, Subscription__c>();
				for (Subscription__c s :[select Id
                                         , Name
                                         , Start_Date__c
                                         , End_Date__c
                                         , Asset__c
                                         , Type__c
                                         , Active__c
                                         , Serial_Number__c
                                         , IE_Subscription__c
                                         , IE_Sync_Status__c
                                         , Buyer_ID__c
                                         , IE_ID__c
                                         , Renewal_Counter__c
                                         , Connectivity_Type__c
                                         , Term_Years__c
                                         , TriggerInvokedByAPI__c
                                         , LastModifiedDate
										 , GWotGoAsset__c
                                         , (Select Id, Name, Role__c, Contact__c, Contact__r.Name, Contact__r.Email, Contact__r.Id, Contact__r.AccountId From Contact_Subscriptions__r)
                                         from Subscription__c
                                         where IE_Subscription__c = true AND TriggerInvokedByAPI__c = true AND Type__c = 'CustomRead' AND Asset__c in :assetIds])
					customReadSubMap.put(s.Id, s);

				for (Id s_id : customReadSubMap.keySet()) {
					Subscription__c s = customReadSubMap.get(s_id);
					subscriptionList.add(s);
				}


   				for (Subscription__c s: subscriptionList) {
   					if ((s.Active__c == true) && (s.Type__c == 'TechReadWrite' || s.Type__c == 'TechRead' || s.Type__c == 'Standard')) {
   						//Only need to email for the TechReadWrite or Standard subscription type
	   					//Store the Subscription__c object in the map for easy retrieval via Subscription Id
						subscriptionConfirmMap.put(s.Id, s);

						SubscriptionsConfirm sConfirm = new SubscriptionsConfirm(s.Id);
						Asset asset = assetMap.get(s.Asset__c);
						sConfirm.salesOrderNumber = asset.Order__r.SO_Number__c;
						sConfirm.orderEntryDate = asset.Order__r.Order_Entry_Date__c;
						sConfirm.jobName = asset.Job_Name__c;
						sConfirm.orderTag = asset.Tag__c;
						sConfirm.equipment = asset.Equipment_Description__c + ' | ' + asset.Product_Description__c;
						subscriptionsConfirmList.add(sConfirm);
					}

   					if (s.Active__c == false) {
   						// Expired/Deactivated Subscription
   						expiredSubscriptions.add(s);
   					}
   					else {
   						// Not Expired/Active Subscription (New and Renewed Subscriptions)
   						notExpiredSubscriptions.add(s);

						// loop thru CS records for the subscription and add the account & contact ids to each set (a set cannot have duplicates, this is handled automatically)
						for (Contact_Subscription__c cs: s.Contact_Subscriptions__r) {
							accountIds.add(cs.Contact__r.AccountId);
							contactIds.add(cs.Contact__r.Id);
						}
   					}
   				}


				// Query the ids and store in the map
				for (Account a : [select Name
									, (Select Address__r.Country__c
											, Address__r.Postal_Code__c
											, Address__r.State_Province__c
											, Address__r.County__c
											, Address__r.City__c
											, Address__r.Address_Line_4__c
											, Address__r.Address_Line_3__c
											, Address__r.Address_Line_2__c
											, Address__r.Address_Line_1__c
											, Address__r.Name
											, Address__r.IE_ID__c
											, Address__r.State_Province_ISO_Code__c
											, Address__r.Country_ISO_Code__c
											, Address__c 
											, Address__r.LastModifiedDate
										From Account_Addresses__r
										)
									,Phone
									,IE_ID__c
									,IE_Updated_Date__c
									,Id
									,LastModifiedDate
								from Account where Id in :accountIds])
				accountMap.put(a.Id, a);
				
				System.debug(logginglevel.error, 'accountMap: ' + accountMap.values());

				
				for (Contact c : [Select Id
												, FirstName
												, LastName
												, Middle_Name__c
												, Email
												, Phone
												, MobilePhone
												, IE_Username__c
												, IE_Accessed__c
												, IE_Inactive__c
												, LastModifiedDate
												, IE_Updated_Date__c
												, IE_ID__c
												, IE_Contact__c
												, AccountId
        										//address data
												, (Select Address__r.Country__c
														, Address__r.Postal_Code__c
														, Address__r.State_Province__c
														, Address__r.State_Province_ISO_Code__c
														, Address__r.Country_ISO_Code__c
														, Address__r.County__c
														, Address__r.City__c
														, Address__r.Address_Line_4__c
														, Address__r.Address_Line_3__c
														, Address__r.Address_Line_2__c
														, Address__r.Address_Line_1__c
														, Address__r.Name
														, Address__r.IE_ID__c
														, Address__c 
														, Address__r.LastModifiedDate
														From Contact_Addresses__r
												) 
        										//role data
        										//,(Select Role__c, Master_Admin__c, Asset__c From Contact_Subscriptions__r)
								from Contact where Id in :contactIds])
				contactMap.put(c.Id, c);

				System.debug(logginglevel.error, 'contactMap: ' + contactMap.values());


   				//Out of the subscriptions confirm list, build up a list of contacts that need to be emailed and for each contact
				//build up the list of subscriptions that are new or renewed.
				for (SubscriptionsConfirm sConfirm: subscriptionsConfirmList) {
            		Subscription__c sObj = subscriptionConfirmMap.get(sConfirm.subscriptionId); //get Subscription object
					List<Contact_Subscription__c> contactSubscriptionList = sObj.Contact_Subscriptions__r;

					//Get list of Contacts associated with the Subscription with Role of RenewalAdministrator or SalesRep to email
					boolean roleFound = false;
					for (Contact_Subscription__c cs: contactSubscriptionList) {
                		//check for role and add contacts to the list, contactsToEmailList, making sure there are no duplicates

                		if (String.isNotEmpty(cs.Role__c) && (cs.Role__c.containsIgnoreCase('RenewalAdministrator') || cs.Role__c.containsIgnoreCase('SalesRep'))) {
                			roleFound = true;

                			ContactsToEmail ce = new ContactsToEmail(cs.Contact__c);
							ce.subscriptionsConfirm.add(sConfirm);
							if (contactsToEmailList.isEmpty()) {
								contactsToEmailList.add(ce); //list is empty so add the new contact
							}
							else {
								//list isn't empty so check if contact is already in the list
								//if it exists then just add the new subscription to its list of subscriptions
								//else add the new contact
								boolean found = false;
								integer lIndex = -1;
								for (ContactsToEmail cte: contactsToEmailList) {
									if (!found) lIndex++;
									if (cte.contactId == ce.contactId) {
										found = true;
									}
								}
								if (found) {
									ContactsToEmail ce2 = new ContactsToEmail(cs.Contact__c);
									ce2.subscriptionsConfirm = contactsToEmailList[lIndex].subscriptionsConfirm;
									if (!ContainsSubscription(ce2.subscriptionsConfirm, sConfirm))
									{
										// Only add the subscription if it's not in the list already
										ce2.subscriptionsConfirm.add(sConfirm);
										contactsToEmailList.set(lIndex, ce2);
									}
								}
								else {
									contactsToEmailList.add(ce);
								}
							}
                		}
					}

					if (!roleFound) {
						// No contacts with Role of RenewalAdministrator or Sales Rep found for this subscription
						System.debug(LoggingLevel.ERROR,'no contacts with Role of RenewalAdministrator or Sales Rep defined for subscription for Id = ' + sObj.Id + ', name = ' + sObj.Name);
						SubscriptionsWithNoRA_SR sWithNoRA_SR = new SubscriptionsWithNoRA_SR(sObj.Id, sObj.Name);
						subscriptionsWithNoRA_SRList.add(sWithNoRA_SR);
					}
				}



   				if (!expiredSubscriptions.isEmpty()) {
            		IERenewal_ExtWebServiceCallouts.syncIeCloudSubscriptions(expiredSubscriptions, syncIeCloudExpSubResultsMap, integrationErrorList);
            		IERenewal_ExtWebServiceCallouts.resetAPIFlags(syncIeCloudExpSubResultsMap.values());
        		}

        		if (!notExpiredSubscriptions.isEmpty()) {
        			IERenewal_ExtWebServiceCallouts.processIESubscriptionOrder(notExpiredSubscriptions, integrationErrorList);
        			IERenewal_ExtWebServiceCallouts.syncIeCloudUnits(notExpiredSubscriptions, syncIeCloudUnitsAssetResultsMap, syncIeCloudUnitsRelatedAssetResultsMap, syncIeCloudUnitsAddressMap, integrationErrorList);
        			IERenewal_ExtWebServiceCallouts.syncIeCloudSubscriptions(notExpiredSubscriptions, syncIeCloudNotExpSubResultsMap, integrationErrorList);
					IERenewal_ExtWebServiceCallouts.syncIeCloudOrganizations2(accountMap.values(), syncIeCloudOrganizationsAccountResultsMap, syncIeCloudOrganizationsAddressMap, integrationErrorList);
					IERenewal_ExtWebServiceCallouts.syncIeCloudIndividuals(contactMap.values(), syncIeCloudIndividualsContactResultsMap, syncIeCloudIndividualsAddressMap, integrationErrorList, notExpiredSubscriptions);

        			IERenewal_ExtWebServiceCallouts.resetAPIFlags(syncIeCloudNotExpSubResultsMap.values());

        			// Send confirmation email
        			processEmails(BC, contactsToEmailList, subscriptionConfirmMap, integrationErrorList);

        			// Send email to IE team about subscriptions that have no contacts with the role of RenewalAdministrator or SalesRep
        			processEmailsForSubscriptionsWithNoRA_SR(BC, subscriptionsWithNoRA_SRList);
        		}


        		System.debug(logginglevel.error, 'Batch_IE_CallExtWebServices subscriptionsConfirmList: ' + subscriptionsConfirmList);
        		System.debug(logginglevel.error, 'Batch_IE_CallExtWebServices contactsToEmailList: ' + contactsToEmailList);
        		System.debug(logginglevel.error, 'Batch_IE_CallExtWebServices subscriptionsWithNoRA_SRList: ' + subscriptionsWithNoRA_SRList);
        	

   			}
   			catch (Exception e) {
   				System.debug(logginglevel.error, 'Batch_IE_CallExtWebServices Exception: ' + e + ' | getTypeName = ' + e.getTypeName());
   				hasErrors = true;

   				String integrationObjectName = 'Unknown';
   				if (e.getTypeName() == 'IERenewal_ExtWebServiceCallouts.processIESubscriptionOrderException') integrationObjectName = 'AT&T Jasper API';
   				else if (e.getTypeName() == 'IERenewal_ExtWebServiceCallouts.syncIeCloudIndividualsException') integrationObjectName = 'Contact';
   				else if (e.getTypeName() == 'IERenewal_ExtWebServiceCallouts.syncIeCloudOrganizationsException') integrationObjectName = 'Account';
   				else if (e.getTypeName() == 'IERenewal_ExtWebServiceCallouts.syncIeCloudSubscriptionsException') integrationObjectName = 'Subscription__c';
   				else if (e.getTypeName() == 'IERenewal_ExtWebServiceCallouts.syncIeCloudUnitsException') integrationObjectName = 'Asset';

   				integrationErrorList.add(new Integration_Error__c(Direction__c = ''
       																, Error_Description__c = 'General Exception from Batch_IE_CallExtWebServices'
       																, Integration_Object__c = integrationObjectName
       																, Integration_Point__c = 'IE'
       																, Request_Data__c = e.getMessage() ));

				// Call resetAPIFlags so subscriptions don't continue to be processed
				if (!expiredSubscriptions.isEmpty()) {IERenewal_ExtWebServiceCallouts.resetAPIFlags(expiredSubscriptions); update expiredSubscriptions;}
				if (!notExpiredSubscriptions.isEmpty()) {IERenewal_ExtWebServiceCallouts.resetAPIFlags(notExpiredSubscriptions); update notExpiredSubscriptions;}
   			}
   			finally {
   				//if (!hasErrors) {
   					if (syncIeCloudUnitsAssetResultsMap.size() > 0)
   						update syncIeCloudUnitsAssetResultsMap.values();

   					if (syncIeCloudUnitsRelatedAssetResultsMap.size() > 0)
   						update syncIeCloudUnitsRelatedAssetResultsMap.values();

   					if (syncIeCloudUnitsAddressMap.size() > 0)
   						update syncIeCloudUnitsAddressMap.values();

   					if (syncIeCloudExpSubResultsMap.size() > 0)
   						update syncIeCloudExpSubResultsMap.values();

   					if (syncIeCloudNotExpSubResultsMap.size() > 0)
   						update syncIeCloudNotExpSubResultsMap.values();

   					if (syncIeCloudOrganizationsAccountResultsMap.size() > 0)
   						update syncIeCloudOrganizationsAccountResultsMap.values();

					if (syncIeCloudOrganizationsAddressMap.size() > 0)
						update syncIeCloudOrganizationsAddressMap.values();

   					if (syncIeCloudIndividualsContactResultsMap.size() > 0)
   						update syncIeCloudIndividualsContactResultsMap.values();

   					if (syncIeCloudIndividualsAddressMap.size() > 0)
   						update syncIeCloudIndividualsAddressMap.values();
   				//}

   				if(integrationErrorList.size() > 0) {
   					System.debug(logginglevel.error, 'Batch_IE_CallExtWebServices integrationErrorList: ' + integrationErrorList);
       				insert integrationErrorList;
       			}
   			}
		
	}


	private Boolean ContainsSubscription(List<SubscriptionsConfirm> subConfirmList, SubscriptionsConfirm subConfirm)
    {
        Boolean subscriptionExists = false;
		for (SubscriptionsConfirm sc: subConfirmList) {
			if (sc.subscriptionId == subConfirm.subscriptionId) subscriptionExists = true;
		}

        System.debug(logginglevel.error, 'ContainsSubscription: subConfirmList = ' + subConfirmList + ' subConfirm = ' + subConfirm + ' subscriptionExists = ' + subscriptionExists);
        return subscriptionExists;
    }



	private void processEmails(Database.BatchableContext BC, list<ContactsToEmail> contactsToEmailList, map<Id, Subscription__c> subscriptionConfirmMap, list<Integration_Error__c> integrationErrorList) {
        String emailIntroNamePlaceholder = 'Dear {0},\n\n';
        String emailTableIntro1 = 'Thank you for renewing the subscription to your equipment in Intelligent Equipment®!  As a renewal customer, your Intelligent Equipment product will update automatically.  No download required.\n\n';
        String emailTableIntro2 = 'Details of your renewal order appear below.  Please save this email as a confirmation of your order.\n\n';
        String emailTableIntro3 = 'SUBSCRIPTION INFO\n\n';

        String emailBody1 = '\n\nYour Next Step:\n\n--------------------------------------------------\n\n';
        String emailBody2 = 'Verify Your Subscription\n\nLog into Intelligent Equipment to verify the expiration date for the subscriptions to the equipment above is correct:\n\n';
        String emailBody3 = 'https://ie.daikinapplied.com\n\nIf you have any questions about your renewal please contact your local Daikin Applied representative.\n\n--------------------------------------------------\n\n';
        String emailBody4 = 'Intelligent Equipment is a Software-as-a-Service solution that provides real-time remote access to scheduling, alarm notification, trending, energy monitoring, diagnostics, and setpoint control of your HVAC equipment from any computer, tablet, or mobile device.\n\n\n\n';
        String emailOutro = 'Regards,\nIntelligent Equipment Team\nDaikin Applied\nhttp://www.daikinapplied.com';
        


        String emailHtmlHead_Style = '<head><style>table {font-family: arial, sans-serif;border-collapse: collapse;width: 100%;}td, th {border: 1px solid #dddddd;text-align: left;padding: 8px;}</style></head>';
        String emailHtmlIntroNamePlaceholder = '<p>Dear {0},</p>';
        String emailHtmlTableIntro1 = '<p>Thank you for renewing the subscription to your equipment in Intelligent Equipment®!  As a renewal customer, your Intelligent Equipment product will update automatically.  No download required.</p>';
        String emailHtmlTableIntro2 = '<p>Details of your renewal order appear below.  Please save this email as a confirmation of your order.</p>';
        String emailHtmlTableIntro3 = '<p>SUBSCRIPTION INFO</p>';

        String emailHtmlBody1 = '<p>Your Next Step:<br><br>--------------------------------------------------<br><br></p>';
        String emailHtmlBody2 = '<p>Verify Your Subscription<br><br>Log into Intelligent Equipment to verify the expiration date for the subscriptions to the equipment above is correct:<br><br></p>';
        String emailHtmlBody3 = '<p>https://ie.daikinapplied.com<br><br>If you have any questions about your renewal please contact your local Daikin Applied representative.<br><br>--------------------------------------------------<br><br></p>';
        String emailHtmlBody4 = '<p>Intelligent Equipment is a Software-as-a-Service solution that provides real-time remote access to scheduling, alarm notification, trending, energy monitoring, diagnostics, and setpoint control of your HVAC equipment from any computer, tablet, or mobile device.</p>';
        String emailHtmlOutro = '<p><br>Regards,<br>Intelligent Equipment Team<br>Daikin Applied<br>http://www.daikinapplied.com</p>';
        
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        
        try {
            // Bulkify: Build up a list of Contact Ids, then use a selective soql query on that list to get a list of contact objects
            // we can put in a map structure.  Use the map structure inside the for-loop when retrieving the individual contacts.
            map<Id, Contact> contactMap = new map<Id, Contact>();
            set<Id> contactIds = new set<Id>();
            for (ContactsToEmail cte: contactsToEmailList)
            {
                if (cte.contactId != null)
                    contactIds.add(cte.contactId);
            }
         
            //retrieve the associated Contacts
            for (Contact c : [Select Id, Name, Email, Status__c From Contact where Id in :contactIds])
                contactMap.put(c.Id, c);


            for (ContactsToEmail cte: contactsToEmailList) {
                Contact contact = contactMap.get(cte.contactId);

                String emailAddress = null;
                String emailSubjectLine = null;
                if (contact.Status__c != 'Active') {
                    emailAddress = 'intelligentequipment@daikinapplied.com';
                    emailSubjectLine = 'Attention: Subscriptions Renewed/New for Contact whose Status is Not Active!';
                }
                else if (String.isBlank(contact.Email)) {
                    emailAddress = 'intelligentequipment@daikinapplied.com';
                    emailSubjectLine = 'Attention: Subscriptions Renewed/New for Contact but no email defined!';
                }
                else {
                    emailAddress = contact.Email; //'kent.roessler@daikinapplied.com', contact.Email
                    emailSubjectLine = 'Thank you for renewing your Daikin Intelligent Equipment subscription';
                }
                String [] email = new String[] {emailAddress};
                List<String> placeHolderFillerName = new String[]{contact.Name};
                
                
                String plainTextBody = String.format(emailIntroNamePlaceholder, placeHolderFillerName) + emailTableIntro1 + emailTableIntro2 + emailTableIntro3;
                String plainTextRenewedEquipmentTable = '';
                
                String htmlBody = emailHtmlHead_Style + '<body>' + String.format(emailHtmlIntroNamePlaceholder, placeHolderFillerName) + emailHtmlTableIntro1 + emailHtmlTableIntro2 + emailHtmlTableIntro3;
                String htmlRenewedEquipmentTable = '<table><tr style="background-color:green"><th>Order Number</th><th>Order Date</th><th>Job Name</th><th>Order Tag</th><th>Equipment</th><th>Serial Number</th><th>Expiration Date</th></tr>';
                
                boolean addContactToEmailList = false;

                for (SubscriptionsConfirm sd: cte.SubscriptionsConfirm) {
                	// Don't generate a confirmation email for this contact if all its subscriptions failed
                	boolean addSubscription = false;
                	if (integrationErrorList.size() > 0) {
						boolean found = false;
						for (Integration_Error__c err : integrationErrorList)
						{
							if ((err.Integration_Object__c == 'Subscription__c') && (err.Integration_Object_Id__c == String.valueOf(sd.subscriptionId)))
								found = true;
						}
						if (!found)
							addSubscription = true; // No errors for this subscription for the contact
					}
					else {
						addSubscription = true;
					}

					if (addSubscription)
					{
						addContactToEmailList = true;

						Subscription__c sObj = subscriptionConfirmMap.get(sd.subscriptionId);
	                    String expDate = sObj.End_Date__c.format('yyyy-MM-dd');

	                    Datetime dT;
	                	String sOrderEntryDate;
						if (String.isNotBlank(String.valueOf(sd.orderEntryDate))) {
							dT = datetime.newInstance(sd.orderEntryDate.year(), sd.orderEntryDate.month(), sd.orderEntryDate.day());
							sOrderEntryDate = dT.format('yyyy-MM-dd');
						}
						else {
							sOrderEntryDate = null;
						}
	                    
	                    String orderNumber = 'Order Number: ' + sd.salesOrderNumber;
	                    String orderDate = '\n\nOrder Date: ' + sOrderEntryDate;
	                    String jobName = '\n\nJob Name: ' + sd.jobName;
	                    String orderTag = '\n\nOrder Tag: ' + sd.orderTag;
	                    String equipment = '\n\nEquipment: ' + sd.equipment;
	                    String serialNumber = '\n\nSerial Number: ' + sObj.Serial_Number__c;
	                    String expirationDate = '\n\nExpiration Date: ' + expDate;
	                    String jobSeparator = '\n--------------------------------------------------\n';
	                    
	                    plainTextRenewedEquipmentTable = plainTextRenewedEquipmentTable + orderNumber + orderDate + jobName + orderTag + equipment + serialNumber + expirationDate + jobSeparator;
	                    
	                    htmlRenewedEquipmentTable = htmlRenewedEquipmentTable + '<tr><td>' + sd.salesOrderNumber + '</td><td>' + sOrderEntryDate + '</td><td>' + sd.jobName + '</td><td>' + sd.orderTag + '</td><td>' + sd.equipment + '</td><td>' + sObj.Serial_Number__c + '</td><td>' + expDate + '</td></tr>';
					}
                }
                
                plainTextBody = plainTextBody + plainTextRenewedEquipmentTable + emailBody1 + emailBody2 + + emailBody3 + emailBody4 + emailOutro;
                
                htmlBody = htmlBody + htmlRenewedEquipmentTable + '</table>' + emailHtmlBody1 + emailHtmlBody2 + emailHtmlBody3 + emailHtmlBody4 + emailHtmlOutro + '</body>';
                

                if (addContactToEmailList) {
	                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	                
	                mail.setToAddresses(email);
	                mail.setReplyTo('intelligentequipment@daikinapplied.com');
	                mail.setSenderDisplayName('Intelligent Equipment Team, Daikin Applied');
	                mail.setSubject(emailSubjectLine);
	                mail.setPlainTextBody(plainTextBody);
	                mail.setHtmlBody(htmlBody);
	                
	                emailList.add(mail);
            	}
                
            } // for-loop Contacts
            
            //send the emails
            if (!emailList.isEmpty()) {
            	System.debug(logginglevel.error, 'Batch_IE_CallExtWebServices | processEmails: ' + emailList);

                Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(emailList);
                for (Messaging.SendEmailResult r: emailResult) {
                    if (r.isSuccess()) {
                        System.debug(LoggingLevel.ERROR,'send email success');
                    }
                    else {
                        Messaging.SendEmailError[] err = r.getErrors();
                        for (Messaging.SendEmailError e: err) {
                            System.debug(LoggingLevel.ERROR, e.getMessage());
                        }
                    }
                }
            }
        }
        catch (QueryException e) {
            System.debug(LoggingLevel.ERROR, 'The following Query Exception occurred in the processEmails method: ' + e.getMessage());
            throw e;
        }
        catch (EmailException e) {
            System.debug(LoggingLevel.ERROR, 'The following Email Exception occurred in the processEmails method: ' + e.getMessage());
            throw e;
        }
		catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'The following Unknown Exception occurred in the processEmails method: ' + e.getMessage());
			e.setMessage('The following Unknown Exception occurred in the processEmails method: ' + e.getMessage() + ' | Line number where exception was thrown = ' + e.getLineNumber());
            throw e;
		}
        finally {
            
        }
        
    }


    private void processEmailsForSubscriptionsWithNoRA_SR(Database.BatchableContext BC, list<SubscriptionsWithNoRA_SR> subscriptionsWithNoRA_SRList) {
        try {
            if (!subscriptionsWithNoRA_SRList.isEmpty()) {
                String [] email = new String[] {'intelligentequipment@daikinapplied.com'}; //'kent.roessler@daikinapplied.com', 'intelligentequipment@daikinapplied.com'
                String [] email2 = new String[] {'salesforcehelp@daikinapplied.com'};
                List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
                String plainTextBody = 'During IE Subscription Renewal Batch Processing the following subscriptions were found to have No Contacts defined with a RenewalAdministrator Or SalesRep Role: ';
                
                for (SubscriptionsWithNoRA_SR s: subscriptionsWithNoRA_SRList) {
                    plainTextBody = plainTextBody + '\n\nSubscription Id = ' + s.subscriptionId + ', Subscription Name = ' + s.name;
                }
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(email);
                mail.setCcAddresses(email2);
                mail.setReplyTo('intelligentequipment@daikinapplied.com');
                mail.setSenderDisplayName('Intelligent Equipment Team, Daikin Applied');
                mail.setSubject('Attention: Subscriptions detected with no Contacts defined with a RenewalAdministrator Or SalesRep role!');
                mail.setPlainTextBody(plainTextBody);
                emailList.add(mail);

                System.debug(logginglevel.error, 'Batch_IE_CallExtWebServices | processEmailsForSubscriptionsWithNoRA_SR: ' + emailList);

                Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(emailList);
                for (Messaging.SendEmailResult r: emailResult) {
                    if (r.isSuccess()) {
                        System.debug(LoggingLevel.ERROR,'send email success');
                    }
                    else {
                        Messaging.SendEmailError[] err = r.getErrors();
                        for (Messaging.SendEmailError e: err) {
                            System.debug(LoggingLevel.ERROR, e.getMessage());
                        }
                    }
                }
            }
        }
        catch (EmailException e) {
            System.debug(LoggingLevel.ERROR, 'The following Email Exception occurred in the processEmailsForSubscriptionsWithNoRA_SR method: ' + e.getMessage());
            throw e;
        }
		catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'The following Unknown Exception occurred in the processEmailsForSubscriptionsWithNoRA_SR method: ' + e.getMessage());
            throw e;
		}
        finally {
            
        }
        
    }


	

	global void finish(Database.BatchableContext BC) {
		
	}
	
}