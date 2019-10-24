/************************************************************************************
 Author       :   Kent Roessler
 Created Date :   July 19, 2016
 Modified     :   December 5, 2016 - Bulkified code to avoid hitting governor limits
 Description  :   Monthly Batch job for processing email notifications for 
 upcoming or late IE subscriptions.
*************************************************************************************/
global class Batch_IE_Subscription_Notification implements Database.Batchable<sobject> {
    global list<SubscriptionsDue> subscriptionsDueList;  //list of ALL subscriptions that are due
    global list<ContactsToEmail> contactsToEmailList;  //list of contacts to email about their subscriptions that are due
    global list<SubscriptionsWithNoEndDate> subscriptionsWithNoEndDateList;  //list of ALL subscriptions that have no end date defined
    global list<SubscriptionsWithNoContact> subscriptionsWithNoContactList;  //list of ALL subscriptions that have no contacts defined with the desired roles
    global list<SubscriptionsWithNoRA> subscriptionsWithNoRA_List;  //list of ALL subscriptions that have no Renewal Administrator defined
	global list<Integration_Error__c> integrationErrorList;  //list of any errors that will be logged into the Integration_Error object
    
    global boolean crashTest{get;set;}
    
    
    //inner classes
    global class SubscriptionsDue
	{
		Id subscriptionId{get;set;}
		Boolean currentMonth{get;set;}
        Boolean nextMonth{get;set;}
        Boolean nextMonth_Plus1{get;set;}
        Boolean lastMonth{get;set;}
        Boolean lastMonth_Minus1{get;set;}
        
        String jobName{get;set;}
        String orderTag{get;set;}
        String equipment{get;set;}
		String gatewaySN{get;set;}
		
		global SubscriptionsDue(Id sId)
		{
            subscriptionId = sId;
			currentMonth = false;
            nextMonth = false;
            nextMonth_Plus1 = false;
            lastMonth = false;
            lastMonth_Minus1 = false;
            jobName = null;
            orderTag = null;
            equipment = null;
			gatewaySN = null;
		}
	}
    
    
    global class ContactsToEmail
    {
        Id contactId{get;set;}
        list<SubscriptionsDue> subscriptionsDue{get;set;}  //list of subscriptions due for a contact
        
        global ContactsToEmail(Id cId)
        {
            contactId = cId;
            subscriptionsDue = new list<SubscriptionsDue>();
        }
    }
    
    
    global class SubscriptionsWithNoEndDate
    {
		Id subscriptionId{get;set;}
        String name{get;set;}
        
        global SubscriptionsWithNoEndDate(Id sId, String n)
		{
            subscriptionId = sId;
            name = n;
		}
    }
    
    
    global class SubscriptionsWithNoContact
    {
		Id subscriptionId{get;set;}
        String name{get;set;}
        
        global SubscriptionsWithNoContact(Id sId, String n)
		{
            subscriptionId = sId;
            name = n;
		}
    }


	global class SubscriptionsWithNoRA
    {
		Id subscriptionId{get;set;}
        String name{get;set;}
        
        global SubscriptionsWithNoRA(Id sId, String n)
		{
            subscriptionId = sId;
            name = n;
		}
    }

    

    global Batch_IE_Subscription_Notification()
    {
    	subscriptionsDueList = new list<SubscriptionsDue>();
        contactsToEmailList = new list<ContactsToEmail>();
        subscriptionsWithNoEndDateList = new list<SubscriptionsWithNoEndDate>();
        subscriptionsWithNoContactList = new list<SubscriptionsWithNoContact>();
		subscriptionsWithNoRA_List = new list<SubscriptionsWithNoRA>();
        integrationErrorList = new list<Integration_Error__c>();
        crashTest = false;
    }
    

    //Start Method
    global Database.Querylocator start (Database.BatchableContext BC) {
        return Database.getQueryLocator([select Id
                                         , Name
                                         , Start_Date__c
                                         , End_Date__c
                                         , Asset__c
                                         , Type__c
                                         , Active__c
                                         , Serial_Number__c
										 , Connectivity_Type__c
										 , GWotGoAsset__c
                                         , Renewal_Notice_Current_Month__c
                                         , Renewal_Notice_Last_Month__c
                                         , Renewal_Notice_Last_Month_Minus_1__c
                                         , Renewal_Notice_Next_Month__c
                                         , Renewal_Notice_Next_Month_Plus_1__c
                                         , (Select Id, Role__c, Contact__c From Contact_Subscriptions__r Where Role__c includes ('RenewalAdministrator', 'SalesRep', 'Administrator', 'TechnicianAdministrator'))
                                         from Subscription__c
                                         where (Type__c = 'TechReadWrite' OR Type__c = 'Standard') AND Active__c = true AND ((End_Date__c >= LAST_N_MONTHS:2 AND End_Date__c <= NEXT_N_MONTHS:2) OR (End_Date__c = null))]);

    }
    
    
    //Execute method
    global void execute (Database.BatchableContext BC, List<Subscription__c> subscriptions) {
        map<Id, Subscription__c> subscriptionMap = new map<Id, Subscription__c>();
        Date currentDate = Date.today();
        
        try {
            // Bulkify: Build up a list of Asset Ids, then use a selective soql query on that list to get a list of asset objects
            // we can put in a map structure.  Use the map structure inside the for-loop when retrieving the individual assets.
            map<Id, Asset> assetMap = new map<Id, Asset>();
            set<Id> assetIds = new set<Id>();
            for (Subscription__c s : subscriptions)
            {
                if (s.Asset__c != null)
                    assetIds.add(s.Asset__c);
            }
         
            //retrieve the associated Assets
            for (Asset a : [Select Id, Name, Job_Name__c, Tag__c, Equipment_Description__c, Product_Description__c from Asset where Id in :assetIds])
                assetMap.put(a.Id, a);


			// Bulkify Gateway Asset SOQL query
			map<Id, Asset> gatewayAssetMap = new map<Id, Asset>();
			for (Asset a : [SELECT Id, Name, Parent_Asset__c, SerialNumber, Job_Name__c, Tag__c, Equipment_Description__c, Product_Description__c, GWotGo__c from Asset Where (Name = 'Intelligent Equipment Gateway' OR Product2.Name = 'Intelligent Equipment Gateway') AND Parent_Asset__c in :assetIds])
	        	gatewayAssetMap.put(a.Parent_Asset__c, a);


            for (Subscription__c s: subscriptions) {
                //Store the Subscription__c object in the map for easy retrieval via Subscription Id
                subscriptionMap.put(s.Id, s);
                
                //System.debug(LoggingLevel.ERROR,'Value of Subscription Object: ' + s);
                
                //Determine if subscription is due based on current date and subscription end date and what bucket it falls into
                //Current Month: monthsBetween = 0
                //Next Month: monthsBetween = 1
                //Next Month + 1: monthsBetween = 2
                //Last Month: monthsBetween = -1
                //Last Month - 1: monthsBetween = -2
                if (s.End_Date__c != null)
                {
                    Datetime endDateTime = s.End_Date__c;
                    Date endDate = endDateTime.date();
                    Integer monthsBetween = currentDate.monthsBetween(endDate);
                    SubscriptionsDue sDue = new SubscriptionsDue(s.Id);
                    
                    Asset asset = null;
					Asset gwAsset = gatewayAssetMap.get(s.Asset__c);
					if (gwAsset != null) sDue.gatewaySN = String.isNotEmpty(gwAsset.SerialNumber) ? gwAsset.SerialNumber : '-';
					else sDue.gatewaySN = '-';

                    if (Test.isRunningTest() && crashTest) {
                        asset = [Select a.Job_Name__c, a.Tag__c, a.Equipment_Description__c, a.Product_Description__c From Asset a Where Id = null];
                    }
                    else {
                        asset = assetMap.get(s.Asset__c);
						//asset = [Select a.Job_Name__c, a.Tag__c, a.Equipment_Description__c, a.Product_Description__c From Asset a Where Id = :s.Asset__c];
                    }
                    
					if ((asset.Name != 'Dummy GWotGo Unit Asset') && (asset.Name != 'Holding GWotGo Unit Asset'))
					{
						sDue.jobName = String.isNotEmpty(asset.Job_Name__c) ? asset.Job_Name__c : '-';
						sDue.orderTag = String.isNotEmpty(asset.Tag__c) ? asset.Tag__c : '-';

						if (String.isNotEmpty(asset.Equipment_Description__c) && String.isNotEmpty(asset.Product_Description__c)) sDue.equipment = asset.Equipment_Description__c + ' | ' + asset.Product_Description__c;
						else if (String.isNotEmpty(asset.Equipment_Description__c)) sDue.equipment = asset.Equipment_Description__c;
						else if (String.isNotEmpty(asset.Product_Description__c)) sDue.equipment = asset.Product_Description__c;
						else sDue.equipment = '-'; // Both fields are empty
					}
					else {
						sDue.jobName = String.isNotEmpty(gwAsset.Job_Name__c) ? gwAsset.Job_Name__c : '-';
						sDue.orderTag = String.isNotEmpty(gwAsset.Tag__c) ? gwAsset.Tag__c : '-';
						sDue.equipment = String.isNotEmpty(gwAsset.Product_Description__c) ? gwAsset.Product_Description__c : '-';
					}
                    
                    if (monthsBetween == 0)
                    {
                        sDue.currentMonth = true;
                        if (s.Renewal_Notice_Current_Month__c == false) subscriptionsDueList.add(sDue); //No email renewal notice for current month was previously sent for the subscription, so add to the list that are due
                    }
                    else if (monthsBetween == 1)
                    {
                        sDue.nextMonth = true;
                        if (s.Renewal_Notice_Next_Month__c == false) subscriptionsDueList.add(sDue); //No email renewal notice for next month was previously sent for the subscription, so add to the list that are due
                    }
                    else if (monthsBetween == 2)
                    {
                        sDue.nextMonth_Plus1 = true;
                        if (s.Renewal_Notice_Next_Month_Plus_1__c == false) subscriptionsDueList.add(sDue); //No email renewal notice for next month+1 was previously sent for the subscription, so add to the list that are due
                    }
                    else if (monthsBetween == -1)
                    {
                        sDue.lastMonth = true;
                        if (s.Renewal_Notice_Last_Month__c == false) subscriptionsDueList.add(sDue); //No email renewal notice for last month was previously sent for the subscription, so add to the list that are due
                    }
                    else if (monthsBetween == -2)
                    {
                        sDue.lastMonth_Minus1 = true;
                        if (s.Renewal_Notice_Last_Month_Minus_1__c == false) subscriptionsDueList.add(sDue); //No email renewal notice for last month-1 was previously sent for the subscription, so add to the list that are due
                    }
                    else
                    {
                        System.debug(LoggingLevel.ERROR,'subscription not due for Id = ' + s.Id);
                    }
                }
                else
                {
                    System.debug(LoggingLevel.ERROR,'subscription end date is null for Id = ' + s.Id + ', name = ' + s.Name);
                    SubscriptionsWithNoEndDate sNoEndDate = new SubscriptionsWithNoEndDate(s.Id, s.Name);
                    subscriptionsWithNoEndDateList.add(sNoEndDate);
                }
                
            }
            
            
            //Out of the subscriptions that are due, build up a list of contacts that need to be emailed and for each contact
            //build up the list of subscriptions that are due.
            for (SubscriptionsDue sDue: subscriptionsDueList) {
                Subscription__c sObj = subscriptionMap.get(sDue.subscriptionId); //get Subscription object
                List<Contact_Subscription__c> contactSubscriptionList = sObj.Contact_Subscriptions__r; //get list of Contacts associated with the Subscription
				
                
                //System.debug(LoggingLevel.ERROR,'subscription id = ' + sDue.subscriptionId + ', has contact count of ' + contactSubscriptionList.size());
                
				//flag to determine if there is a contact with the RenewalAdministrator role for the subscription
				boolean RA_roleFound = false;

				//flag to determine if there is a contact with the SalesRep role for the subscription
				boolean SR_roleFound = false;

				//flag to determine if there is a contact with the Administrator or TechnicianAdministrator role for the subscription
				boolean Admin_roleFound = false;

				//first pass through all the CS records for this subscription to determine what roles are found
				for (Contact_Subscription__c cs: contactSubscriptionList) {
					if (String.isNotEmpty(cs.Role__c) && cs.Role__c.containsIgnoreCase('RenewalAdministrator')) RA_roleFound = true;
					if (String.isNotEmpty(cs.Role__c) && cs.Role__c.containsIgnoreCase('SalesRep')) SR_roleFound = true;
					if (String.isNotEmpty(cs.Role__c) && (cs.Role__c.containsIgnoreCase('Administrator') || cs.Role__c.containsIgnoreCase('TechnicianAdministrator'))) Admin_roleFound = true;
				}

				if (RA_roleFound || SR_roleFound)
				{
					// RA and/or SR roles found so email those contacts for this subscription
					for (Contact_Subscription__c cs: contactSubscriptionList) {
						//add contacts to the list, contactsToEmailList, making sure there are no duplicates

						if (String.isNotEmpty(cs.Role__c) && (cs.Role__c.containsIgnoreCase('RenewalAdministrator') || cs.Role__c.containsIgnoreCase('SalesRep')))
						{
							ContactsToEmail ce = new ContactsToEmail(cs.Contact__c);
							ce.subscriptionsDue.add(sDue);
							if (contactsToEmailList.isEmpty()) {
								//System.debug(LoggingLevel.ERROR, 'is empty');
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
									//System.debug(LoggingLevel.ERROR,'found');
									ContactsToEmail ce2 = new ContactsToEmail(cs.Contact__c);
									ce2.subscriptionsDue = contactsToEmailList[lIndex].subscriptionsDue;
									if (!ContainsSubscription(ce2.subscriptionsDue, sDue))
									{
										// Only add the subscription if it's not in the list already
										ce2.subscriptionsDue.add(sDue);
										contactsToEmailList.set(lIndex, ce2);
									}
								}
								else {
									//System.debug(LoggingLevel.ERROR,'not found');
									contactsToEmailList.add(ce);
								}
							}
						}
					} // for loop cs records
				}


				if (!RA_roleFound && !SR_roleFound && Admin_roleFound)
				{
					// No RA or SR roles so email the TA contacts for this subscription
					for (Contact_Subscription__c cs: contactSubscriptionList) {
						//add contacts to the list, contactsToEmailList, making sure there are no duplicates

						if (String.isNotEmpty(cs.Role__c) && (cs.Role__c.containsIgnoreCase('Administrator') || cs.Role__c.containsIgnoreCase('TechnicianAdministrator')))
						{
							ContactsToEmail ce = new ContactsToEmail(cs.Contact__c);
							ce.subscriptionsDue.add(sDue);
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
									ce2.subscriptionsDue = contactsToEmailList[lIndex].subscriptionsDue;
									if (!ContainsSubscription(ce2.subscriptionsDue, sDue))
									{
										// Only add the subscription if it's not in the list already
										ce2.subscriptionsDue.add(sDue);
										contactsToEmailList.set(lIndex, ce2);
									}
								}
								else {
									contactsToEmailList.add(ce);
								}
							}
						}
					} // for loop cs records
				}

                
				if (!RA_roleFound) {
					// No contacts with Role of RenewalAdministrator found for this subscription
					System.debug(LoggingLevel.ERROR,'no contacts with Role of RenewalAdministrator defined for subscription for Id = ' + sObj.Id + ', name = ' + sObj.Name);
					SubscriptionsWithNoRA sWithNoRA = new SubscriptionsWithNoRA(sObj.Id, sObj.Name);
					subscriptionsWithNoRA_List.add(sWithNoRA);
				}


                if (contactSubscriptionList.isEmpty()) {
                    // No contacts with the desired roles defined for this subscription
                    System.debug(LoggingLevel.ERROR,'no contacts with the desired roles defined for subscription for Id = ' + sObj.Id + ', name = ' + sObj.Name);
                    SubscriptionsWithNoContact sNoContact = new SubscriptionsWithNoContact(sObj.Id, sObj.Name);
                    subscriptionsWithNoContactList.add(sNoContact);
                }
            } // for loop sDue records
            
            System.debug(LoggingLevel.ERROR,'List of Subscriptions count: ' + subscriptionsDueList.size());
            //System.debug(LoggingLevel.ERROR,'List of Subscriptions due: ' + subscriptionsDueList);
            /*for (SubscriptionsDue s: subscriptionsDueList) {
                System.debug(LoggingLevel.ERROR,'subscription id = ' + s.subscriptionId);
            }*/
            System.debug(LoggingLevel.ERROR,'List of Contacts count: ' + contactsToEmailList.size());
            //System.debug(LoggingLevel.ERROR,'List of Contacts to email: ' + contactsToEmailList);
            /*for (ContactsToEmail cte: contactsToEmailList) {
                System.debug(LoggingLevel.ERROR,'----------------');
                System.debug(LoggingLevel.ERROR,'contact id = ' + cte.contactId);
                for (SubscriptionsDue sd: cte.subscriptionsDue) {
                    System.debug(LoggingLevel.ERROR,'subscription id = ' + sd.subscriptionId);
                    System.debug(LoggingLevel.ERROR,'job name = ' + sd.jobName);
                    System.debug(LoggingLevel.ERROR,'order tag = ' + sd.orderTag);
                    System.debug(LoggingLevel.ERROR,'equipment = ' + sd.equipment);
                }
            }*/
            
            processEmails(BC, subscriptionMap);
            setSubscriptionCriteriaBucketFlags(BC, subscriptionMap);
            
            processEmailsForSubscriptionsWithNoEndDate(BC);
            processEmailsForSubscriptionsWithNoContact(BC);
			processEmailsForSubscriptionsWithNoRA(BC);
        }
        catch (QueryException e) {
            System.debug(LoggingLevel.ERROR, 'The following Query Exception occurred in the Execute method: ' + e.getMessage());
            integrationErrorList.add(new Integration_Error__c(Direction__c = ''
       															, Error_Description__c = 'Query Exception'
       															, Integration_Object__c = 'Subscription__c'
       															, Integration_Point__c = 'IE'
       															, Request_Data__c = e.getMessage() ));
        }
        catch (DMLException e) {
            System.debug(LoggingLevel.ERROR, 'The following DML Exception occurred in the Execute method: ' + e.getMessage());
            integrationErrorList.add(new Integration_Error__c(Direction__c = ''
       															, Error_Description__c = 'DML Exception'
       															, Integration_Object__c = 'Subscription__c'
       															, Integration_Point__c = 'IE'
       															, Request_Data__c = e.getMessage() ));
        }
        catch (EmailException e) {
            System.debug(LoggingLevel.ERROR, 'The following Email Exception occurred in the Execute method: ' + e.getMessage());
            integrationErrorList.add(new Integration_Error__c(Direction__c = ''
       															, Error_Description__c = 'Email Exception'
       															, Integration_Object__c = 'Subscription__c'
       															, Integration_Point__c = 'IE'
       															, Request_Data__c = e.getMessage() ));
        }
        catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'The following General Exception occurred in the Execute method: ' + e.getMessage());
            integrationErrorList.add(new Integration_Error__c(Direction__c = ''
       															, Error_Description__c = 'General Exception'
       															, Integration_Object__c = 'Subscription__c'
       															, Integration_Point__c = 'IE'
       															, Request_Data__c = e.getMessage() ));
        }
        finally {
            if(integrationErrorList.size() > 0)
       			insert integrationErrorList;
        }
        
    }


	private Boolean ContainsSubscription(List<SubscriptionsDue> subDueList, SubscriptionsDue subDue)
    {
        Boolean subscriptionExists = false;
		for (SubscriptionsDue sd: subDueList) {
			if (sd.subscriptionId == subDue.subscriptionId) subscriptionExists = true;
		}

        System.debug(logginglevel.error, 'ContainsSubscription: subDueList = ' + subDueList + ' subDue = ' + subDue + ' subscriptionExists = ' + subscriptionExists);
        return subscriptionExists;
    }
    
    
    private void processEmails(Database.BatchableContext BC, map<Id, Subscription__c> sMap) {
        String emailIntroNamePlaceholder = 'Hi {0},\n\n';
        String emailTableIntro = 'Your Intelligent Equipment® subscription is going to expire, or has recently expired for the equipment listed below. To avoid any disruption to your remote access to this equipment please contact your Daikin Applied representative and ask to have your subscription renewed.  This is an automated message generated by Salesforce - Please do not reply using the Salesforce email.  If you have any questions you can contact the team at intelligentequipment@daikinapplied.com.\n\n';
        //String emailBody1 = '\n\nTo avoid any disruption to your remote access to this equipment please contact your Daikin Applied representative and ask to have your annual subscription renewed.\n\n';
        //String emailBody2 = 'If you monitor other equipment with Intelligent Equipment at this job you may want to consider renewing those subscriptions as well.\n\n';
        String emailBody3 = 'Intelligent Equipment is a Software-as-a-Service solution that provides real-time remote access to scheduling, alarm notification, trending, energy monitoring, diagnostics, and setpoint control of your HVAC equipment from any computer, tablet, or mobile device.\n\n\n\n';
        String emailOutro = 'Regards,\nIntelligent Equipment Team\nDaikin Applied\n\nintelligentequipment@daikinapplied.com';
        
        String emailHtmlHead_Style = '<head><style>table {font-family: arial, sans-serif;border-collapse: collapse;width: 100%;}td, th {border: 1px solid #dddddd;text-align: left;padding: 8px;}</style></head>';
        String emailHtmlIntroNamePlaceholder = '<p>Hi {0},</p>';
        String emailHtmlTableIntro = '<p>Your Intelligent Equipment® subscription is going to expire, or has recently expired for the equipment listed below. To avoid any disruption to your remote access to this equipment please contact your Daikin Applied representative and ask to have your subscription renewed.  This is an automated message generated by Salesforce - Please do not reply using the Salesforce email.  If you have any questions you can contact the team at intelligentequipment@daikinapplied.com.</p>';
        //String emailHtmlBody1 = '<p>To avoid any disruption to your remote access to this equipment please contact your Daikin Applied representative and ask to have your annual subscription renewed.</p>';
        //String emailHtmlBody2 = '<p>If you monitor other equipment with Intelligent Equipment at this job you may want to consider renewing those subscriptions as well.</p>';
        String emailHtmlBody3 = '<p>Intelligent Equipment is a Software-as-a-Service solution that provides real-time remote access to scheduling, alarm notification, trending, energy monitoring, diagnostics, and setpoint control of your HVAC equipment from any computer, tablet, or mobile device.</p>';
        String emailHtmlOutro = '<p><br>Regards,<br>Intelligent Equipment Team<br>Daikin Applied<br>intelligentequipment@daikinapplied.com</p>';
        
        integer tempEmailCnt = 0;
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
                //Contact contact = [Select c.Name, c.Email, c.Status__c From Contact c Where Id = :cte.contactId];

                String emailAddress = null;
                String emailSubjectLine = null;
                if (contact.Status__c != 'Active') {
                    emailAddress = 'intelligentequipment@daikinapplied.com';
                    emailSubjectLine = 'Attention: Subscriptions due for Contact whose Status is Not Active!';
                }
                else if (String.isBlank(contact.Email)) {
                    emailAddress = 'intelligentequipment@daikinapplied.com';
                    emailSubjectLine = 'Attention: Subscriptions due for Contact but no email defined!';
                }
                else {
                    emailAddress = contact.Email; //'kent.roessler@daikinapplied.com', contact.Email
                    emailSubjectLine = 'Renewal Notice: IMPORTANT information about your Daikin Intelligent Equipment';
                }
                String [] email = new String[] {emailAddress};
                List<String> placeHolderFillerName = new String[]{contact.Name};
                
                //System.debug(LoggingLevel.ERROR,'%%%%%%%%%%%%%%%%%%%%');
                //System.debug(LoggingLevel.ERROR,'CONTACT NAME = ' + contact.Name);
                //System.debug(LoggingLevel.ERROR,'CONTACT EMAIL = ' + contact.Email);
                
                String plainTextBody = String.format(emailIntroNamePlaceholder, placeHolderFillerName) + emailTableIntro;
                String plainTextExpiredEquipmentTable = '';
                
                String htmlBody = emailHtmlHead_Style + '<body>' + String.format(emailHtmlIntroNamePlaceholder, placeHolderFillerName) + emailHtmlTableIntro;
                String htmlExpiredEquipmentTable = '<table><tr style="background-color:red"><th>Job Name</th><th>Order Tag</th><th>Equipment</th><th>Equipment Serial Number</th><th>Gateway Serial Number</th><th>Connectivity Type</th><th>Expiration Date</th></tr>';
                
                for (SubscriptionsDue sd: cte.subscriptionsDue) {
                    Subscription__c sObj = sMap.get(sd.subscriptionId);
                    String expDate = sObj.End_Date__c.format('yyyy-MM-dd');
                                    
                    String jobName = 'Job Name: ' + sd.jobName;
                    String orderTag = '\n\nOrder Tag: ' + sd.orderTag;
                    String equipment = '\n\nEquipment: ' + sd.equipment;
                    String serialNumber = '\n\nEquipment Serial Number: ' + sObj.Serial_Number__c;
					String gwSerialNumber = '\n\nGateway Serial Number: ' + sd.gatewaySN;
					String connectivityType = '\n\nConnectivity Type: ' + sObj.Connectivity_Type__c;
                    String expirationDate = '\n\nExpiration Date: ' + expDate;
                    String jobSeparator = '\n--------------------------------------------------\n';
                    
                    plainTextExpiredEquipmentTable = plainTextExpiredEquipmentTable + jobName + orderTag + equipment + serialNumber + gwSerialNumber + connectivityType + expirationDate + jobSeparator;
                    
                    htmlExpiredEquipmentTable = htmlExpiredEquipmentTable + '<tr><td>' + sd.jobName + '</td><td>' + sd.orderTag + '</td><td>' + sd.equipment + '</td><td>' + sObj.Serial_Number__c + '</td><td>' + sd.gatewaySN + '</td><td>' + sObj.Connectivity_Type__c + '</td><td>' + expDate + '</td></tr>';
                    
                    System.debug(LoggingLevel.ERROR,'--------------------');
                    System.debug(LoggingLevel.ERROR,'job name = ' + sd.jobName);
                    System.debug(LoggingLevel.ERROR,'order tag = ' + sd.orderTag);
                    System.debug(LoggingLevel.ERROR,'equipment = ' + sd.equipment);
                    System.debug(LoggingLevel.ERROR,'serial number = ' + sObj.Serial_Number__c);
					System.debug(LoggingLevel.ERROR,'gw SN = ' + sd.gatewaySN);
					System.debug(LoggingLevel.ERROR,'connectivity type = ' + sObj.Connectivity_Type__c);
                    System.debug(LoggingLevel.ERROR,'expiration date = ' + sObj.End_Date__c);
                }
                
                plainTextBody = plainTextBody + plainTextExpiredEquipmentTable + /*emailBody1 + emailBody2 +*/ emailBody3 + emailOutro;
                //System.debug(LoggingLevel.ERROR, plainTextBody);
                
                htmlBody = htmlBody + htmlExpiredEquipmentTable + '</table>' + /*emailHtmlBody1 + emailHtmlBody2 +*/ emailHtmlBody3 + emailHtmlOutro + '</body>';
                //System.debug(LoggingLevel.ERROR, htmlBody);
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                //fetch the job Id
                //AsyncApexJob a = [Select a.TotalJobItems, a.Status, a.NumberOfErrors, a.JobType, a.JobItemsProcessed, a.ExtendedStatus, a.CreatedById, a.CompletedDate From AsyncApexJob a WHERE id = :BC.getJobId()];
                //System.debug(LoggingLevel.ERROR,'$$$ Jobid is '+ BC.getJobId());
                
                
                mail.setToAddresses(email);
                mail.setReplyTo('intelligentequipment@daikinapplied.com');
                mail.setSenderDisplayName('Intelligent Equipment Team, Daikin Applied');
                mail.setSubject(emailSubjectLine);
                mail.setPlainTextBody(plainTextBody);
                mail.setHtmlBody(htmlBody);
                
                emailList.add(mail);
                
                /*
                if ((emailAddress == 'michael.lyga@daikinapplied.com') || (emailAddress == 'marian.mohamed@daikinapplied.com')) {
                    emailList.add(mail);
                }*/
                
                /*
                if (tempEmailCnt <= 2) {
                    emailList.add(mail);
                }
                tempEmailCnt++;*/
                
            } // for-loop Contacts
            
            //send the emails
            if (!emailList.isEmpty()) {
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
        finally {
            
        }
        
    }
    
    
    private void setSubscriptionCriteriaBucketFlags(Database.BatchableContext BC, map<Id, Subscription__c> sMap) {
        try {
            // limit trigger functionality on the Subscription object so it doesn't set the IE_Sync_Status__c = 'Pending'
            TriggerUtility.limitIntegrationBatch = true;


            // Bulkify List of Subscriptions before the Update DML operation
            List<Subscription__c> subs = new list<Subscription__c>();

            for (SubscriptionsDue sDue: subscriptionsDueList) {
                Subscription__c sObj = sMap.get(sDue.subscriptionId); //get Subscription object
                List<Contact_Subscription__c> contactSubscriptionList = sObj.Contact_Subscriptions__r; //get list of Contacts associated with the Subscription
                
                if (!contactSubscriptionList.isEmpty()) {
                    if (sDue.currentMonth) {
                        sObj.Renewal_Notice_Current_Month__c = true;
                        subs.add(sObj);
                        //update sObj;
                    }
                    else if (sDue.nextMonth) {
                        sObj.Renewal_Notice_Next_Month__c = true;
                        subs.add(sObj);
                        //update sObj;
                    }
                    else if (sDue.lastMonth) {
                        sObj.Renewal_Notice_Last_Month__c = true;
                        subs.add(sObj);
                        //update sObj;
                    }
                    else if (sDue.nextMonth_Plus1) {
                        sObj.Renewal_Notice_Next_Month_Plus_1__c = true;
                        subs.add(sObj);
                        //update sObj;
                    }
                    else if (sDue.lastMonth_Minus1) {
                        sObj.Renewal_Notice_Last_Month_Minus_1__c = true;
                        subs.add(sObj);
                        //update sObj;
                    }
                }
            }
            if (!subs.isEmpty()) {
                update subs;
            }
        }
        catch (DMLException e) {
            System.debug(LoggingLevel.ERROR, 'The following DML Exception occurred in the setSubscriptionCriteriaBucketFlags method: ' + e.getMessage());
            throw e;
        }
        finally {
            
        }
        
    }
    
    
    private void processEmailsForSubscriptionsWithNoEndDate(Database.BatchableContext BC) {
        try {
            if (!subscriptionsWithNoEndDateList.isEmpty()) {
                String [] email = new String[] {'intelligentequipment@daikinapplied.com'}; //'kent.roessler@daikinapplied.com', 'intelligentequipment@daikinapplied.com'
                String [] email2 = new String[] {'salesforcehelp@daikinapplied.com'};
                List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
                String plainTextBody = 'During monthly processing of IE Subscription renewals the following subscriptions were detected with No End Date defined: ';
                
                for (SubscriptionsWithNoEndDate s: subscriptionsWithNoEndDateList) {
                    plainTextBody = plainTextBody + '\n\nSubscription Id = ' + s.subscriptionId + ', Subscription Name = ' + s.name;
                }
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(email);
                mail.setCcAddresses(email2);
                mail.setReplyTo('intelligentequipment@daikinapplied.com');
                mail.setSenderDisplayName('Intelligent Equipment Team, Daikin Applied');
                mail.setSubject('Attention: Subscriptions detected with no End Date defined!');
                mail.setPlainTextBody(plainTextBody);
                emailList.add(mail);
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
            System.debug(LoggingLevel.ERROR, 'The following Email Exception occurred in the processEmailsForSubscriptionsWithNoEndDate method: ' + e.getMessage());
            throw e;
        }
        finally {
            
        }

    }
    
    
    private void processEmailsForSubscriptionsWithNoContact(Database.BatchableContext BC) {
        try {
            if (!subscriptionsWithNoContactList.isEmpty()) {
                String [] email = new String[] {'intelligentequipment@daikinapplied.com'}; //'kent.roessler@daikinapplied.com', 'intelligentequipment@daikinapplied.com'
                String [] email2 = new String[] {'salesforcehelp@daikinapplied.com'};
                List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
                String plainTextBody = 'During monthly processing of IE Subscription renewals the following subscriptions were detected with No Contacts with desired roles defined: ';
                
                for (SubscriptionsWithNoContact s: subscriptionsWithNoContactList) {
                    plainTextBody = plainTextBody + '\n\nSubscription Id = ' + s.subscriptionId + ', Subscription Name = ' + s.name;
                }
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(email);
                mail.setCcAddresses(email2);
                mail.setReplyTo('intelligentequipment@daikinapplied.com');
                mail.setSenderDisplayName('Intelligent Equipment Team, Daikin Applied');
                mail.setSubject('Attention: Subscriptions detected with no Contacts with desired roles defined!');
                mail.setPlainTextBody(plainTextBody);
                emailList.add(mail);
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
            System.debug(LoggingLevel.ERROR, 'The following Email Exception occurred in the processEmailsForSubscriptionsWithNoContact method: ' + e.getMessage());
            throw e;
        }
        finally {
            
        }
        
    }


	private void processEmailsForSubscriptionsWithNoRA(Database.BatchableContext BC) {
        try {
            if (!subscriptionsWithNoRA_List.isEmpty()) {
                String [] email = new String[] {'intelligentequipment@daikinapplied.com'}; //'kent.roessler@daikinapplied.com', 'intelligentequipment@daikinapplied.com'
                String [] email2 = new String[] {'salesforcehelp@daikinapplied.com'};
                List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
                String plainTextBody = 'During monthly processing of IE Subscription renewals the following subscriptions were found to have No Contacts defined with a RenewalAdministrator Role: ';
                
                for (SubscriptionsWithNoRA s: subscriptionsWithNoRA_List) {
                    plainTextBody = plainTextBody + '\n\nSubscription Id = ' + s.subscriptionId + ', Subscription Name = ' + s.name;
                }
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(email);
                mail.setCcAddresses(email2);
                mail.setReplyTo('intelligentequipment@daikinapplied.com');
                mail.setSenderDisplayName('Intelligent Equipment Team, Daikin Applied');
                mail.setSubject('Attention: Subscriptions detected with no Contacts defined with a RenewalAdministrator role!');
                mail.setPlainTextBody(plainTextBody);
                emailList.add(mail);

                System.debug(logginglevel.error, 'Batch_IE_Subscription_Notification | processEmailsForSubscriptionsWithNoRA: ' + emailList);

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
            System.debug(LoggingLevel.ERROR, 'The following Email Exception occurred in the processEmailsForSubscriptionsWithNoRA method: ' + e.getMessage());
            throw e;
        }
		catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'The following Unknown Exception occurred in the processEmailsForSubscriptionsWithNoRA method: ' + e.getMessage());
            throw e;
		}
        finally {
            
        }
        
    }
    
    
    //Finish Method
    global void finish(Database.BatchableContext BC) {
        
    }

}

// Some useful queries:
// Fetching child records (Contact_Subscription) from the parent record (Subscription)
// SELECT Id, Name, Asset__c, End_Date__c, Start_Date__c, Active__c, Type__c, Serial_Number__c, Renewal_Notice_Current_Month__c, Renewal_Notice_Last_Month__c, Renewal_Notice_Last_Month_Minus_1__c, Renewal_Notice_Next_Month__c, Renewal_Notice_Next_Month_Plus_1__c, (Select Id, Role__c, Contact__c From Contact_Subscriptions__r Where Role__c includes ('RenewalAdministrator', 'SalesRep', 'Administrator', 'TechnicianAdministrator')) FROM Subscription__c where Type__c = 'TechReadWrite'
// 
// Fetching parent record (Subscription) from the child record (Contact_Subscriptions)
// SELECT Id, Name, Subscription__c, Contact__c, Role__c, Subscription__r.Name, Subscription__r.Type__c, Subscription__r.End_Date__c FROM Contact_Subscription__c
//
//
//***Run this in Execute Anonymous window to start the batch job
/*
Batch_IE_Subscription_Notification bp1 = new Batch_IE_Subscription_Notification();
Database.executeBatch(bp1);
*/
//
//
//
//***Run this to reset all email criteria buckets to false in Execute Anonymous window***
/*
list<Subscription__c> subs = [select Id, Name, Start_Date__c, End_Date__c, Asset__c, Type__c, Active__c, Serial_Number__c, Renewal_Notice_Current_Month__c, Renewal_Notice_Last_Month__c,Renewal_Notice_Last_Month_Minus_1__c, Renewal_Notice_Next_Month__c, Renewal_Notice_Next_Month_Plus_1__c, (Select Id, Role__c, Contact__c From Contact_Subscriptions__r Where Role__c includes ('RenewalAdministrator', 'SalesRep', 'Administrator', 'TechnicianAdministrator')) from Subscription__c where Type__c = 'TechReadWrite'];

for (Subscription__c s: subs) {
	s.Renewal_Notice_Current_Month__c = false;
	s.Renewal_Notice_Next_Month__c = false;
	s.Renewal_Notice_Last_Month__c = false;
	s.Renewal_Notice_Next_Month_Plus_1__c = false;
	s.Renewal_Notice_Last_Month_Minus_1__c = false;
	update s;
}
*/
//
//
//
//***Use this for testing that the trigger gets run on an update to end_date
/*
Subscription__c s = [select Id, Name, Start_Date__c, End_Date__c, Renewal_Notice_Current_Month__c, Renewal_Notice_Last_Month__c,Renewal_Notice_Last_Month_Minus_1__c, Renewal_Notice_Next_Month__c, Renewal_Notice_Next_Month_Plus_1__c from Subscription__c where Name = 'S-000000172'];
s.End_Date__c = DateTime.newinstance(2017, 08, 03); //new date in the future
//s.End_Date__c = DateTime.newinstance(2016, 08, 03); //original date
update s;
*/
//
// In order to write scalable code and avoid hitting governor limits, we need to bulkify the apex code 
// (structured to handle processing of multiple records). 
// Move all your DML statements (selects, insert, update, delete) outside of all the loops. 
// Use Apex Map, List, and Set variables and methods to work with the records you retrieve.
// Create the map, list or set variable outside the for-loop and then inside the loop instead of doing a 
// select for each individual record, get it from the map, list or set variable.
// If you are doing an update or insert then instead of doing the operation for each record in a loop,
// build up a list of the records to be updated or inserted and perform one update or insert on that list.