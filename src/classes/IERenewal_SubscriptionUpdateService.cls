@RestResource(urlMapping='/IERenewalSubscriptionUpdateService/*')
global with sharing class IERenewal_SubscriptionUpdateService  {
    /*****************************************************************************************
    * This web service will be called after DST/OPS processing for IE Subscription-Only orders
    * and Renewal Subscription orders to update the existing subscription in
    * salesforce in order to provide immediate access to the IE UI.
    *
    * The ETL will process Kit & Factory Orders (with or without a subscription),
    * which will create the Parent (Equipment/Unit) and Related Assets (Gateway and EMM) and 
    * subscription hardware records.
    *
    ******************************************************************************************/

    global static RecordType contactRecordType = null;
    


    @HttpPut
    global static void doPut() {
        TriggerUtility.limitIeServiceIntegration = true;  // set this to true to limit trigger functionality on some objects

		list<Integration_Error__c> integrationErrorList = new list<Integration_Error__c>();  //list of any errors that will be logged into the Integration_Error object
		
		// Error message string that is used to collect any errors/exceptions information
    	String errorMsg = 'IERenewal_SubscriptionUpdateService.doPut() errors: ';

        RenewalOrderRequest theRequest = (RenewalOrderRequest)JSON.deserializeStrict(RestContext.request.requestBody.toString(), RenewalOrderRequest.class);
        System.debug(logginglevel.error, theRequest);

        RenewalOrderResponse theResponse = new RenewalOrderResponse();

        contactRecordType = [SELECT Id FROM RecordType WHERE Name='Daikin Applied' AND SObjectType='Contact'];


        System.debug(logginglevel.error, 'IERenewal_SubscriptionUpdateService.doPut(): Total Number of SOQL Queries allowed in this Apex code context: ' +  Limits.getLimitQueries());

        List<Subscription__c> subscriptionUpdateList = new List<Subscription__c>();

        // Loop through the asset serial numbers for the order and select the subscription(s) for the asset whose type is TechReadWrite OR Standard
        for (Asset_Unit assetUnit : theRequest.assetUnits) 
        {
			List<Subscription__c> subscriptionList = new List<Subscription__c>();
			List<Contact_Subscription__c> csList = new List<Contact_Subscription__c>();
			Asset gwAsset = null;
			boolean invalidGW = false;

			// Call the apex service, RetrieveAssetService to determine whether the asset serial number is for Equipment (Unit) asset or GWotGo asset
/*			RestRequest req = new RestRequest(); 
			RestResponse res = new RestResponse();
			req.requestURI = '';  
			req.httpMethod = 'GET';
			RestContext.request = req;
			RestContext.response = res;*/
			RestContext.request.params.put('SerialNumber',assetUnit.SerialNumber);
			RetrieveAssetService.ServiceAsset results = RetrieveAssetService.getAsset();


			if ((results.GWOnTheGo == true) && (results.SerialNumber.equalsIgnoreCase(results.GWSerialNumber)))
			{
				// GWotGo Asset Subscription Renewal
				Asset[] gwl = [SELECT Id, SerialNumber, Parent_Asset__c, SIM_Card_Active__c, SIM_Card_ICCID__c, MAC_Address__c, Status, GWotGo__c, Commissioned__c, Device_ID__c, ResetSuccessful__c, LastModifiedDate
						// Sub-queries used for GWotGo asset
						, (Select Id, Type__c, Name, Owner.Name, Serial_Number__c, GWotGoAsset__c, Renewal_Date__c, Renewal_Counter__c, Last_Renewal_Date__c, Connectivity_Type__c, Term_Years__c, Start_Date__c, End_Date__c, Buyer_ID__c, IE_ID__c, Active__c, LastModifiedDate, Asset__c, Renewal_Notice_Current_Month__c, Renewal_Notice_Last_Month__c, Renewal_Notice_Last_Month_Minus_1__c, Renewal_Notice_Next_Month__c, Renewal_Notice_Next_Month_Plus_1__c From Subscriptions1__r Where Type__c = 'TechReadWrite' OR Type__c = 'Standard')
						, (Select Id, Name, Role__c, Contact__c, Subscription__c, Serial_Number__c, Contact__r.Name, Contact__r.Email, Contact__r.Id, Contact__r.AccountId, GWotGoAsset__c, GWotGoPermAssoc__c, LastModifiedDate From Contact_Subscriptions1__r)
						from Asset Where (Name = 'Intelligent Equipment Gateway' OR Product2.Name = 'Intelligent Equipment Gateway') AND Status != 'Obsolete' AND SerialNumber = :assetUnit.SerialNumber];

				if (gwl.size() > 0)
				{
					// Get subscriptions associated with GW asset
					gwAsset = gwl[0];
					subscriptionList = gwAsset.Subscriptions1__r;
					csList = gwAsset.Contact_Subscriptions1__r;
				}

			}
			else if (!results.SerialNumber.equalsIgnoreCase(results.GWSerialNumber)) {
				// Unit Asset Subscription renewal
				subscriptionList = [ SELECT Id, Name, Owner.Name, Type__c, Active__c, Term_Years__c, Start_Date__c, End_Date__c, Asset__c,
						Renewal_Date__c, Renewal_Counter__c, Last_Renewal_Date__c, Connectivity_Type__c, Serial_Number__c,
						Renewal_Notice_Current_Month__c, Renewal_Notice_Last_Month__c,
						Renewal_Notice_Last_Month_Minus_1__c, Renewal_Notice_Next_Month__c,
						Renewal_Notice_Next_Month_Plus_1__c
					FROM Subscription__c WHERE Serial_Number__c = :assetUnit.SerialNumber AND (Type__c = 'TechReadWrite' OR Type__c = 'Standard') ];
			}
			else invalidGW = true; // Invalid Case: A regular GW asset SN was passed in


            if ( subscriptionList.isEmpty() )
            {
                Subscription_Update_Status subUpdateStatus = new Subscription_Update_Status();
				if (!invalidGW) {
					if ((results.GWOnTheGo == true) && (gwAsset == null)) {
						subUpdateStatus.addError( 'GWOTGO_NOT_FOUND', 'GWotGo asset Serial Number ' + assetUnit.SerialNumber + ' not found in Salesforce.' ); errorMsg = errorMsg + ' | ' + 'GWotGo asset Serial Number ' + assetUnit.SerialNumber + ' not found in Salesforce.';}

					subUpdateStatus.addError( 'SUBSCRIPTION_NOT_FOUND', 'Subscription with asset Serial Number ' + assetUnit.SerialNumber + ' not found in Salesforce.' ); errorMsg = errorMsg + ' | ' + 'Subscription with asset Serial Number ' + assetUnit.SerialNumber + ' not found in Salesforce.';
                }
				else {
					subUpdateStatus.addError( 'GW_INVALID', 'GW asset Serial Number ' + assetUnit.SerialNumber + ' is not a GWotGo.' ); errorMsg = errorMsg + ' | ' + 'GW asset Serial Number ' + assetUnit.SerialNumber + ' is not a GWotGo.';}

				theResponse.Statuses.add(subUpdateStatus);

            }
            else
            {
                // Loop through the subscriptions so they can be updated in salesforce
                for (Subscription__c subscription : subscriptionList)
                {
                    System.debug(logginglevel.error, subscription);

                    Subscription_Update_Status subUpdateStatus = new Subscription_Update_Status();
                    subUpdateStatus.SerialNumber = assetUnit.SerialNumber;
                    subUpdateStatus.SubscriptionOwner = subscription.Owner.Name;
                    subUpdateStatus.SubscriptionNumber = subscription.Name;
                    subUpdateStatus.IsActive = subscription.Active__c;

                    // Get the correct list of contacts from the asset subscriptions based on the current subscription's type (TechReadWrite OR Standard)
                    Boolean subscriptionTypeMatch = false;
                    for (Subscription_Info si : assetUnit.subscriptionInfoList)
                    {
                        if (si.subscriptionType.equalsIgnoreCase(subscription.Type__c) ||
							(si.subscriptionType.equalsIgnoreCase('Standard') && (subscription.Type__c.equalsIgnoreCase('TechReadWrite'))) ||
							(si.subscriptionType.equalsIgnoreCase('TechReadWrite') && (subscription.Type__c.equalsIgnoreCase('Standard'))))
                        {
							List<Contact_Info> ciList = new List<Contact_Info>();
							if (si.contactInfoList != null)
							{
								if (si.contactInfoList.size() > 0)
									ciList = si.contactInfoList;
							}

                            System.debug(logginglevel.error, 'Subscription Type in SF ' + subscription.Type__c + ', Contact Info List in RenewalOrderRequest ' + ciList + ', Subscription Info in RenewalOrderRequest ' + si);
                            subscriptionTypeMatch = true;
                            List<Response_Error> errors = updateSubscription(subscription, csList, results.GWOnTheGo, assetUnit, ciList, si, theRequest.orderTypeId, subscriptionUpdateList);

							for (Response_Error err : errors) errorMsg = errorMsg + ' | ' + err.ErrorMessage;


                            subUpdateStatus.Errors.addAll(errors);
                            theResponse.Statuses.add(subUpdateStatus);
                        }
                    }

                    if (!subscriptionTypeMatch) {
                        System.debug(logginglevel.error, 'No Subscription Type Match ' + 'For asset serial number ' + assetUnit.SerialNumber + ', no matches were found in the RenewalOrderRequest object for subscription type ' + subscription.Type__c);
                        errorMsg = errorMsg + ' | ' + 'No Subscription Type Match ' + 'For asset serial number ' + assetUnit.SerialNumber + ', no matches were found in the RenewalOrderRequest object for subscription type ' + subscription.Type__c;
						
						List<Response_Error> errors = new List<Response_Error>();
                        Response_Error err = new Response_Error();

                        err.ErrorCode = 'No Subscription Type Match';
                        err.ErrorMessage = 'For asset serial number ' + assetUnit.SerialNumber + ', no matches were found in the RenewalOrderRequest object for subscription type ' + subscription.Type__c;
                        errors.add(err);

                        subUpdateStatus.Errors.addAll(errors);
                        theResponse.Statuses.add(subUpdateStatus);
                    }
                    
                }
            }

            System.debug(logginglevel.error, 'IERenewal_SubscriptionUpdateService.doPut(): Number of Queries used in this Apex code so far: ' + Limits.getQueries());
        }

		// If there are any errors then log it to SF
		if (errorMsg.contains('|'))
			integrationErrorList.add(new Integration_Error__c(Direction__c = ''
									, Error_Description__c = errorMsg
									, Integration_Object__c = 'Subscription'
									, Integration_Point__c = 'IE'
									, Request_Data__c = 'IERenewal_SubscriptionUpdateService.doPut()'));


        if (subscriptionUpdateList.size() > 0) {
            System.debug(logginglevel.error, 'Update subscription records');
            update subscriptionUpdateList;
        }

		if (integrationErrorList.size() > 0) {
   			System.debug(logginglevel.error, 'IERenewal_SubscriptionUpdateService.doPut() integrationErrorList: ' + integrationErrorList);
       		insert integrationErrorList;
       	}
        

        System.debug(logginglevel.error, theResponse);
        RestContext.response.responseBody = Blob.valueOf( JSON.serialize(theResponse) );
        RestContext.response.addHeader( 'Content-Type', 'application/json' );
    }


    public static List<Response_Error> updateSubscription(Subscription__c theSubscription, List<Contact_Subscription__c> csList, Boolean gwotgo, Asset_Unit theAssetUnit, 
															List<Contact_Info> contactInfoList, Subscription_Info theSubscriptionInfo, 
                                                            String orderTypeID, List<Subscription__c> subscriptionUpdateList) {
        List<Response_Error> responseErrors = new List<Response_Error>();
        try {
            // Check if the Contact and Contact Account already exist in salesforce.
            // If it doesn't then add them and the Contact Subscription association.

            // Create a contact id to contact info object mapping for later retrieval
            map<Id, Contact_Info> contactInfoMap = new map<Id, Contact_Info>();


            for (Contact_Info ci: contactInfoList) {
                Contact[] cl = [SELECT Id, Email, LastName, FirstName, RecordTypeId, AccountId, Status__c, Middle_Name__c, IE_Contact__c, IE_Username__c, Record_Usage__c, IE_Sync_Status__c FROM Contact WHERE Email = :ci.email AND LastName = :ci.lastName AND FirstName = :ci.firstName limit 1];

                Contact c = null;
                if (cl.size()>0)
                {
                    System.debug(logginglevel.error, 'Contact found in salesforce');
                    // Found the contact in salesforce.
                    c = cl[0];

                    // Check if the account exists, if it doesn't then one will be created.
                    Id acctId = CheckAccount(ci);

                    // Make sure the contact is associated to the account.
                    if (c.AccountId != acctId)
                    {
                        System.debug(logginglevel.error, 'Update Contact with association to the account');
                        c.AccountId = acctId;
                        c.Status__c = 'Active';
                        c.IE_Contact__c = true;
                        c.IE_Username__c = ci.Email;
                        c.Record_Usage__c = 'IE';
                        c.IE_Sync_Status__c = 'Pending';
                        update c;  // Update trigger will set the IE_Sync_Status__c field to 'Pending'
                    }
                    else if ((c.Status__c != 'Active') || (c.IE_Contact__c != true) || (c.IE_Username__c != ci.Email) || (c.Record_Usage__c != 'IE') || (c.IE_Sync_Status__c != 'Pending'))
                    {
                        System.debug(logginglevel.error, 'Update the Status and some IE fields for the Contact');
                        c.Status__c = 'Active';
                        c.IE_Contact__c = true;
                        c.IE_Username__c = ci.Email;
                        c.Record_Usage__c = 'IE';
                        c.IE_Sync_Status__c = 'Pending';
                        update c;  // Update trigger will set the IE_Sync_Status__c field to 'Pending'
                    }

                    // Make sure there is a Contact_Subscription association
					List<Contact_Subscription__c> csl = new List<Contact_Subscription__c>();
					if (gwotgo == true) {
						for (Contact_Subscription__c cs: csList) {
							if (cs.Contact__c == c.Id && cs.Subscription__c == theSubscription.Id) csl.add(cs);
						}
					}
					else csl = [SELECT Id, Role__c, Contact__c, Subscription__c, Serial_Number__c From Contact_Subscription__c Where Contact__c = :c.Id AND Subscription__c = :theSubscription.Id AND Serial_Number__c = :theAssetUnit.SerialNumber];
                    //Contact_Subscription__c[] csl = [SELECT Id, Role__c, Contact__c, Subscription__c, Serial_Number__c From Contact_Subscription__c Where Contact__c = :c.Id AND Subscription__c = :theSubscription.Id AND Serial_Number__c = :theAssetUnit.SerialNumber];
                    
					if (csl.size() == 0)
                    {
                        System.debug(logginglevel.error, 'Contact Subscription association not found, so one is created');
                        // Create Contact Subscription record association
                        Contact_Subscription__c cs = new Contact_Subscription__c();
                        cs.Role__c = SetContactSubscriptionRoles(ci);
                        cs.Contact__c = c.Id;
                        cs.Subscription__c = theSubscription.Id;
                        cs.Asset__c = theSubscription.Asset__c;
                        insert cs;
                    }
                }
                else
                {
                    System.debug(logginglevel.error, 'Contact not found in salesforce, so create one and contact subscription association');
                    // Didn't find the contact in salesforce
                    // First check if the account exists, if it doesn't then one will be created.
                    Id acctId = CheckAccount(ci);

                    // Create the contact and associate it to the account
                    c = new Contact();
                    c.RecordTypeId = contactRecordType.Id;
                    c.AccountId = acctId;
                    c.Status__c = 'Active';
                    c.Email = ci.email;
                    c.FirstName = ci.firstName;
                    c.LastName = ci.lastName;
                    c.Middle_Name__c = ci.middleName;
                    c.IE_Contact__c = true;
                    c.IE_Username__c = ci.email;
                    c.Record_Usage__c = 'IE';
                    c.IE_Sync_Status__c = 'Pending';
                    insert c;  // Insert trigger will set the IE_Sync_Status__c field to 'Pending'

                    // Create Contact Subscription association
                    // Can't set these fields directly since they are formula text fields:
                    // > Serial_Number__c = Asset__r.SerialNumber
                    // > Subscription_Type__c = TEXT(Subscription__r.Type__c)
                    Contact_Subscription__c contSubTemp = new Contact_Subscription__c();
                    contSubTemp.Role__c = SetContactSubscriptionRoles(ci);
                    contSubTemp.Contact__c = c.Id;
                    contSubTemp.Subscription__c = theSubscription.Id;
                    contSubTemp.Asset__c = theSubscription.Asset__c;
                    insert contSubTemp;
                }
                contactInfoMap.put(c.Id, ci);
            }


            // Update fields on the Subscription__c, Contact_Subscription__c, Order, and Asset objects in salesforce.

            // Do a select for the parent asset so we can get the order and related asset (gateway asset)
            // Update the order type id if needed
			Asset parentAsset = [SELECT Id, Name, Order__c, AccountId from Asset Where Id = :theSubscription.Asset__c];

			// Section commented out on 9/8/17, since the Order Type Id should not be changed via this web service call
			/******
            Order__c theOrder = [SELECT Id, Order_Type_ID__c from Order__c Where Id = :parentAsset.Order__c];
            if (theOrder.Order_Type_ID__c != orderTypeID)
            {
                System.debug(logginglevel.error, 'Update the Order object');
                theOrder.Order_Type_ID__c = orderTypeID;
                update theOrder;
            }
			******/

            // Update the SIM card active status for the gateway asset if needed
			Asset gatewayAsset = null;
			if (gwotgo == true)
				gatewayAsset = [SELECT Id, SIM_Card_Active__c, Status, GWotGo__c, SerialNumber from Asset Where SerialNumber = :theAssetUnit.SerialNumber];
            else 
				gatewayAsset = [SELECT Id, SIM_Card_Active__c, Status, GWotGo__c from Asset Where (Name = 'Intelligent Equipment Gateway' OR Product2.Name = 'Intelligent Equipment Gateway') AND Status != 'Obsolete' AND Parent_Asset__c = :parentAsset.Id];
            
			if (theSubscriptionInfo.connectivityType.equalsIgnoreCase('Cellular') && gatewayAsset.SIM_Card_Active__c != true)
            {
                System.debug(logginglevel.error, 'Update the gateway asset object');
                gatewayAsset.SIM_Card_Active__c = true;
                update gatewayAsset;
            }
            else if (theSubscriptionInfo.connectivityType.equalsIgnoreCase('WiFi/LAN') && gatewayAsset.SIM_Card_Active__c != false)
            {
                System.debug(logginglevel.error, 'Update the gateway asset object');
                gatewayAsset.SIM_Card_Active__c = false;
                update gatewayAsset;
            }


            // Update any contact subscription role changes
            for (Id c_id : contactInfoMap.keySet()) {
                Contact_Info ci = contactInfoMap.get(c_id);

				List<Contact_Subscription__c> csl = new List<Contact_Subscription__c>();
				if (gwotgo == true) {
					for (Contact_Subscription__c cs: csList) {
						if (cs.Contact__c == c_Id && cs.Subscription__c == theSubscription.Id) csl.add(cs);
					}
				}
				else csl = [SELECT Id, Role__c, Contact__c, Subscription__c, Serial_Number__c From Contact_Subscription__c Where Contact__c = :c_id AND Subscription__c = :theSubscription.Id AND Serial_Number__c = :theAssetUnit.SerialNumber];
                //Contact_Subscription__c[] csl = [SELECT Id, Role__c, Contact__c, Subscription__c, Serial_Number__c From Contact_Subscription__c Where Contact__c = :c_id AND Subscription__c = :theSubscription.Id AND Serial_Number__c = :theAssetUnit.SerialNumber];
                
                String rolesOrig='';
                for (Integer i = 0; i < csl.size(); i++) {
                    // In case there are multiple contact_subscription records for a contact with multiple roles, gather up all the roles for each record and store in rolesOrig.
                    rolesOrig = rolesOrig + csl[i].Role__c;
                    if (i < (csl.size()-1)) rolesOrig = rolesOrig + ';';
                }
                List<String> roles = rolesOrig.Split(';'); // Split out the roles in a list. Since Role__c is a multiselect picklist the individual values are seperated by semicolons in one string.

                
                System.debug(logginglevel.error, 'Contact ' + ci.firstName + ' ' + ci.lastName + ' currently has roles ' + roles);

                String rolesNew='';

				if (ci.administrator == true)
                {
                    if (String.isEmpty(csl[0].Role__c))
                    {
                        csl[0].Role__c = 'Administrator';

                        if (String.isEmpty(rolesNew)) rolesNew = 'Administrator';
                        else rolesNew = rolesNew + ';Administrator';
                    }
                    else
                    {
                        if (!ContainsRole(roles, 'Administrator'))
                        {
                            csl[0].Role__c = csl[0].Role__c + ';Administrator';

                            if (String.isEmpty(rolesNew)) rolesNew = 'Administrator';
                            else rolesNew = rolesNew + ';Administrator';
                        }
                    }
                }
                if (ci.customerAdmin == true)
                {
                    if (String.isEmpty(csl[0].Role__c))
                    {
                        csl[0].Role__c = 'CustomerAdministrator';

                        if (String.isEmpty(rolesNew)) rolesNew = 'CustomerAdministrator';
                        else rolesNew = rolesNew + ';CustomerAdministrator';
                    }
                    else
                    {
                        if (!ContainsRole(roles, 'CustomerAdministrator'))
                        {
                            csl[0].Role__c = csl[0].Role__c + ';CustomerAdministrator';

                            if (String.isEmpty(rolesNew)) rolesNew = 'CustomerAdministrator';
                            else rolesNew = rolesNew + ';CustomerAdministrator';
                        }
                    }
                }
                if (ci.customer == true)
                {
                    if (String.isEmpty(csl[0].Role__c))
                    {
                        csl[0].Role__c = 'Customer';

                        if (String.isEmpty(rolesNew)) rolesNew = 'Customer';
                        else rolesNew = rolesNew + ';Customer';
                    }
                    else
                    {
                        if (!ContainsRole(roles, 'Customer'))
                        {
                            csl[0].Role__c = csl[0].Role__c + ';Customer';

                            if (String.isEmpty(rolesNew)) rolesNew = 'Customer';
                            else rolesNew = rolesNew + ';Customer';
                        }
                    }
                }
                if (ci.technicianAdmin == true)
                {
                    if (String.isEmpty(csl[0].Role__c))
                    {
                        csl[0].Role__c = 'TechnicianAdministrator';

                        if (String.isEmpty(rolesNew)) rolesNew = 'TechnicianAdministrator';
                        else rolesNew = rolesNew + ';TechnicianAdministrator';
                    }
                    else
                    {
                        if (!ContainsRole(roles, 'TechnicianAdministrator'))
                        {
                            csl[0].Role__c = csl[0].Role__c + ';TechnicianAdministrator';

                            if (String.isEmpty(rolesNew)) rolesNew = 'TechnicianAdministrator';
                            else rolesNew = rolesNew + ';TechnicianAdministrator';
                        }
                    }
                }
                if (ci.technician == true)
                {
                    if (String.isEmpty(csl[0].Role__c))
                    {
                        csl[0].Role__c = 'Technician';

                        if (String.isEmpty(rolesNew)) rolesNew = 'Technician';
                        else rolesNew = rolesNew + ';Technician';
                    }
                    else
                    {
                        if (!ContainsRole(roles, 'Technician'))
                        {
                            csl[0].Role__c = csl[0].Role__c + ';Technician';

                            if (String.isEmpty(rolesNew)) rolesNew = 'Technician';
                            else rolesNew = rolesNew + ';Technician';
                        }
                    }
                }
                if (ci.renewalAdmin == true)
                {
                    if (String.isEmpty(csl[0].Role__c))
                    {
                        csl[0].Role__c = 'RenewalAdministrator';

                        if (String.isEmpty(rolesNew)) rolesNew = 'RenewalAdministrator';
                        else rolesNew = rolesNew + ';RenewalAdministrator';
                    }
                    else
                    {
                        if (!ContainsRole(roles, 'RenewalAdministrator'))
                        {
                            csl[0].Role__c = csl[0].Role__c + ';RenewalAdministrator';

                            if (String.isEmpty(rolesNew)) rolesNew = 'RenewalAdministrator';
                            else rolesNew = rolesNew + ';RenewalAdministrator';
                        }
                    }
                }

                if (String.isNotEmpty(rolesNew))
                {
                    System.debug(logginglevel.error, 'Update contact subscription roles ' + rolesNew);
                    update csl[0];
                }

            }

            // *** Update any subscription changes ***
            // First determine if it's a Renewal Subscription Order OR First-time Subscription Order.
            // If the existing subscriptions have a Term >= 1.0 then the subscription
            // was purchased earlier so this would be a Renewal Subscription order.
            // If the existing subscriptions have a Term < 1.0 then hardware was purchased
            // without a subscription so this would be a First-time Subscription order.
            if (theSubscription.Term_Years__c >= 1.0)
            {
                // Renewal Subscription order
                theSubscription.Renewal_Counter__c = theSubscription.Renewal_Counter__c + 1;
                theSubscription.Last_Renewal_Date__c = theSubscription.Renewal_Date__c;
                theSubscription.Renewal_Date__c = Date.today();
            }
            else 
            {
                // First-time Subscription order
                theSubscription.Renewal_Counter__c = 0;
                theSubscription.Last_Renewal_Date__c = null;
                theSubscription.Renewal_Date__c = null;
            }

            theSubscription.Active__c = true;
            theSubscription.Term_Years__c = theSubscriptionInfo.termYears;
            theSubscription.Connectivity_Type__c = theSubscriptionInfo.connectivityType;
            theSubscription.Renewal_Notice_Current_Month__c = false;
            theSubscription.Renewal_Notice_Last_Month__c = false;
            theSubscription.Renewal_Notice_Last_Month_Minus_1__c = false;
            theSubscription.Renewal_Notice_Next_Month__c = false;
            theSubscription.Renewal_Notice_Next_Month_Plus_1__c = false;

			// Check if the subscription type on the request is not equal to the type queried from SF.
			// This means one of them is 'Standard' (new version) and the other is 'TechReadWrite' (old version).
			// If the one in SF is 'TechReadWrite' then set it to 'Standard'.
			if ((!theSubscriptionInfo.subscriptionType.equalsIgnoreCase(theSubscription.Type__c)) &&
				(theSubscription.Type__c.equalsIgnoreCase('TechReadWrite')))  theSubscription.Type__c = 'Standard';

			// Only set the trigger fields on the subscriptions whose asset is not the Dummy Unit and Holding Unit.
			// The 15 min apex job should only process subscriptions with assets that should sync with the IE site.
			if ((parentAsset.Name != 'Dummy GWotGo Unit Asset') && (parentAsset.Name != 'Holding GWotGo Unit Asset'))  theSubscription.TriggerInvokedByAPI__c = true;

            // Since the startDate and endDate values from the Request object have no time component it defaults to 00:00:00 (GMT).
            // We add 12 hours to it so the time component is now at noon of the day (GMT).
            // The reason we do this is because the DateTime values get stored in the salesforce database in GMT but
            // the time is corrected to the users time zone when displaying it on the UI.
            // Since CST is either 6 hours (Std Time) or 5 hours (DST) behind GMT, setting the time to noon will keep 
            // the day/month/year looking consistent when the user views the subscription in salesforce UI.
            
            // Note: ignore the start date for renewals. We will keep the start date from the original order.
            //theSubscription.Start_Date__c = (theSubscriptionInfo.startDate).addHours(12);
            theSubscription.End_Date__c = (theSubscriptionInfo.endDate).addHours(12);


            subscriptionUpdateList.add(theSubscription);
            //update theSubscription;

        }
        catch (QueryException ex) {
            Response_Error err = new Response_Error();
            err.ErrorCode = 'Query Exception';
            err.ErrorMessage = ex.getMessage();
            responseErrors.add(err);
        }
        catch (DMLException ex) {
            for ( Integer errorIndex = 0; errorIndex < ex.getNumDml(); errorIndex++ ) {
                Response_Error err = new Response_Error();
                err.ErrorCode = 'INVALID_SUBSCRIPTION';
                err.ErrorMessage = 'Subscription Update Error ['+ex.getDmlMessage(errorIndex)+']';
                responseErrors.add(err);
            }
        }
        catch (Exception ex) {
            Response_Error err = new Response_Error();
            err.ErrorCode = 'General Exception';
            err.ErrorMessage = ex.getMessage();
            responseErrors.add(err);
        }
        finally {

        }

        return responseErrors;
    }


    public static Id CheckAccount(Contact_Info ci)
    {
        Id acctId = null;
        Account acct = null;
        List<Account> acctList = [SELECT Id, Name, Physical_Address__c, IE_Account__c, Record_Usage__c, IE_Sync_Status__c
                            , (Select Id, Physical__c, Active__c, Account__c, Address__c from Account_Addresses__r)
                            FROM Account 
                            WHERE Name = :ci.orgName];

        if (acctList.isEmpty())
        {
            System.debug(logginglevel.error, 'CheckAccount: Account name not found in salesforce, so create one');
            // Didn't find the account name in salesforce, so create one
            acctId = CreateAccount(ci);
        }
        else
        {
            System.debug(logginglevel.error, 'CheckAccount: Account name found in salesforce, check address');
            // Found the account name(s) now check if the address matches any of them
            // Note: In order to have a match the Country and Address Line1 must have a match plus 1 or more of the other fields, ie, State, City or Zip
            Boolean addressFound = false;
            for (Account a : acctList)
            {
				if (a.Physical_Address__c != null)
				{
					Address__c addrTemp = [SELECT Id, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Address_Line_4__c, Postal_Code__c, City__c, Country__c, State_Province__c 
											FROM Address__c WHERE id = :a.Physical_Address__c];
					if (String.isNotEmpty(addrTemp.Country__c) && (addrTemp.Country__c.equalsIgnoreCase(ci.orgCountry))) {
						if (String.isNotEmpty(addrTemp.Address_Line_1__c) && (addrTemp.Address_Line_1__c.equalsIgnoreCase(ci.orgAddress))) {
							if ((String.isNotEmpty(addrTemp.State_Province__c) && (addrTemp.State_Province__c.equalsIgnoreCase(ci.orgState))) ||
								(String.isNotEmpty(addrTemp.City__c) && (addrTemp.City__c.equalsIgnoreCase(ci.orgCity))) ||
								(String.isNotEmpty(addrTemp.Postal_Code__c) && (addrTemp.Postal_Code__c.equalsIgnoreCase(ci.orgZip))))
							{
								System.debug(logginglevel.error, 'CheckAccount: Account address found in salesforce');
								addressFound = true;
								acctId = a.Id;
								acct = a;
								break;
							}
						}
					}
				}
            }
            if (!addressFound) acctId = CreateAccount(ci);
            else if ((acct.IE_Account__c != true) || (acct.Record_Usage__c != 'IE') || (acct.IE_Sync_Status__c != 'Pending'))
            {
                System.debug(logginglevel.error, 'Update some IE fields for the existing Account');
                acct.IE_Account__c = true;
                acct.Record_Usage__c = 'IE';
                acct.IE_Sync_Status__c = 'Pending';
                update acct;  // Update trigger will set the IE_Sync_Status__c field to 'Pending'
                acctId = acct.Id;
            }
        }

        return acctId;
    }


    public static Id CreateAccount(Contact_Info ci)
    {
        System.debug(logginglevel.error, 'CreateAccount: Create account in salesforce');

        Account acctTemp = null;
        Address__c addrTemp = null;
        Account_Address__c acctAddrJunctionObj = null;

        addrTemp = new Address__c();
        addrTemp.Address_Line_1__c = ci.orgAddress;  // Each address line has a string max size of 255
        addrTemp.Address_Line_2__c = null;
        addrTemp.Address_Line_3__c = null;
        addrTemp.Address_Line_4__c = null;
        addrTemp.City__c = ci.orgCity;
        addrTemp.Postal_Code__c = ci.orgZip;
        addrTemp.Country__c = ci.orgCountry;
        addrTemp.State_Province__c = ci.orgState;
        insert addrTemp;

        acctTemp = new Account();
        acctTemp.Name = ci.orgName;
        acctTemp.Physical_Address__c = addrTemp.Id;
        acctTemp.IE_Account__c = true;
        acctTemp.Record_Usage__c = 'IE';
        acctTemp.IE_Sync_Status__c = 'Pending';
        insert acctTemp;  // Insert trigger will set the IE_Sync_Status__c field to 'Pending'
        
        acctAddrJunctionObj = new Account_Address__c();
        acctAddrJunctionObj.Account__c = acctTemp.Id;
        acctAddrJunctionObj.Address__c = addrTemp.Id;
        acctAddrJunctionObj.Active__c = true;
        acctAddrJunctionObj.Physical__c = true;
        insert acctAddrJunctionObj;

        return acctTemp.Id;
    }


    public static String SetContactSubscriptionRoles(Contact_Info ci)
    {
        String roles = null;

		if (ci.administrator == true)
        {
            if (String.isEmpty(roles)) roles = 'Administrator';
            else roles = roles + ';Administrator';
        }
        if (ci.customerAdmin == true)
        {
            if (String.isEmpty(roles)) roles = 'CustomerAdministrator';
            else roles = roles + ';CustomerAdministrator';
        }
        if (ci.customer == true)
        {
            if (String.isEmpty(roles)) roles = 'Customer';
            else roles = roles + ';Customer';
        }
        if (ci.technicianAdmin == true)
        {
            if (String.isEmpty(roles)) roles = 'TechnicianAdministrator';
            else roles = roles + ';TechnicianAdministrator';
        }
        if (ci.technician == true)
        {
            if (String.isEmpty(roles)) roles = 'Technician';
            else roles = roles + ';Technician';
        }
        if (ci.renewalAdmin == true)
        {
            if (String.isEmpty(roles)) roles = 'RenewalAdministrator';
            else roles = roles + ';RenewalAdministrator';
        }

        System.debug(logginglevel.error, 'SetContactSubscriptionRoles: roles = ' + roles + ' for Contact ' + ci.firstName + ' ' + ci.lastName);
        return roles;
    }


    public static Boolean ContainsRole(List<String> roleList, String role)
    {
        Boolean roleExists = false;
        for (String r: roleList)
            if (r.trim().equalsIgnoreCase(role)) roleExists = true;

        System.debug(logginglevel.error, 'ContainsRole: roleList = ' + roleList + ' role = ' + role + ' roleExists = ' + roleExists);
        return roleExists;
    }


/*
    @HttpGet
    global static SObject show() {

        SObject obj;

        return obj;

    }

    @HttpPost
    global static SObject create() {

        SObject obj;

        return obj;

    }

    @HttpDelete
    global static void remove() {

    }
*/

    /* Request schemas */
    public class RenewalOrderRequest
    {
        public String orderTypeId; // Domestic or International
        public List<Asset_Unit> assetUnits;
    }

    public class Asset_Unit
    {
        public String serialNumber;
        public List<Subscription_Info> subscriptionInfoList;
    }

    public class Subscription_Info
    {
        public Datetime startDate;
        public Datetime endDate;
        public String connectivityType; // Cellular or WiFi/LAN
        public Decimal termYears;
        public String subscriptionType; // TechReadWrite OR Standard
        public List<Contact_Info> contactInfoList;
    }

    public class Contact_Info
    {
        public String email;
        public String firstName;
        public String middleName;
        public String lastName;

        // Roles: A contacts subscription role may be different for each subscription type they are associated to
		public Boolean administrator;
        public Boolean customerAdmin;
        public Boolean technicianAdmin;
        public Boolean customer;
        public Boolean technician;
        public Boolean renewalAdmin;
        
        // Organization (Account) information
        public String orgName;
        public String orgAddress;
        public String orgCity;
        public String orgState;
        public String orgCountry;
        public String orgZip;
    }



    /* Response schemas */
    global class RenewalOrderResponse
    {
        public List<Subscription_Update_Status> Statuses;

        public RenewalOrderResponse()
        {
            this.Statuses = new List<Subscription_Update_Status>();
        }
    }

    public class Subscription_Update_Status
    {
        public Boolean IsActive;
        public List<Response_Error> Errors;
        public String SubscriptionNumber;
        public String SubscriptionOwner;
        public String SerialNumber;

        public Subscription_Update_Status()
        {
            this.Errors = new List<Response_Error>();
        }

        public void addError( String errorCode, String errorMessage )
        {
            Response_Error newError = new Response_Error();
            newError.ErrorCode = errorCode;
            newError.ErrorMessage = errorMessage;
            this.Errors.add( newError );
        }
    }

    public class Response_Error
    {
        public String ErrorMessage;
        public String ErrorCode;
    }
}

// ***Testing the webservice in Workbench REST Explorer***
// Use the Put HTTP method on the following REST API Service URI: /services/apexrest/IERenewalSubscriptionUpdateService
/* Request Body (in json format):
{
"orderTypeId" : "Domestic",
"assetUnits" : [
    {"serialNumber" : "FBOU150900980",
    "subscriptionInfoList" : [
        {"startDate" : "2016-11-14",
        "endDate" : "2017-11-14",
        "connectivityType" : "Cellular",
        "termYears" : 1.25,
        "subscriptionType" : "TechReadWrite",
        "contactInfoList" : [
            {"email" : "tenniselbowz@yahoo.com",
            "firstName" : "Joe",
            "middleName" : "",
            "lastName" : "Johnson",
			"administrator" : true,
            "customerAdmin" : false,
            "technicianAdmin" : true,
            "customer" : false,
            "technician" : false,
            "renewalAdmin" : false,
            "orgName" : "Daikin Applied Americas Corporate",
            "orgAddress" : "13600 Industrial Park Blvd",
            "orgCity" : "Minneapolis",
            "orgState" : "Minnesota",
            "orgCountry" : "United States",
            "orgZip" : "55441"},
            {"email" : "kent.roessler@daikinapplied.com",
            "firstName" : "Mary",
            "middleName" : "",
            "lastName" : "Shelly",
			"administrator" : true,
            "customerAdmin" : false,
            "technicianAdmin" : false,
            "customer" : false,
            "technician" : false,
            "renewalAdmin" : false,
            "orgName" : "Daikin Applied Americas Corporate",
            "orgAddress" : "13600 Industrial Park Blvd",
            "orgCity" : "Minneapolis",
            "orgState" : "Minnesota",
            "orgCountry" : "United States",
            "orgZip" : "55441"},
            {"email" : "kent.roessler@daikinapplied.com",
            "firstName" : "Mike",
            "middleName" : "",
            "lastName" : "Anderson",
			"administrator" : false,
            "customerAdmin" : true,
            "technicianAdmin" : false,
            "customer" : false,
            "technician" : false,
            "renewalAdmin" : true,
            "orgName" : "Daikin Applied Americas Corporate",
            "orgAddress" : "13600 Industrial Park Blvd",
            "orgCity" : "Minneapolis",
            "orgState" : "Minnesota",
            "orgCountry" : "United States",
            "orgZip" : "55441"}
        ]
        },
        {"startDate" : "2016-11-14",
        "endDate" : "2017-11-14",
        "connectivityType" : "Cellular",
        "termYears" : 1.25,
        "subscriptionType" : "CustomRead",
        "contactInfoList" : [
            {"email" : "tenniselbowz@yahoo.com",
            "firstName" : "Joe",
            "middleName" : "",
            "lastName" : "Johnson",
			"administrator" : true,
            "customerAdmin" : false,
            "technicianAdmin" : true,
            "customer" : false,
            "technician" : false,
            "renewalAdmin" : true,
            "orgName" : "Daikin Applied Americas Corporate",
            "orgAddress" : "13600 Industrial Park Blvd",
            "orgCity" : "Minneapolis",
            "orgState" : "Minnesota",
            "orgCountry" : "United States",
            "orgZip" : "55441"},
            {"email" : "kent.roessler@daikinapplied.com",
            "firstName" : "Mike",
            "middleName" : "",
            "lastName" : "Anderson",
			"administrator" : true,
            "customerAdmin" : false,
            "technicianAdmin" : false,
            "customer" : false,
            "technician" : false,
            "renewalAdmin" : false,
            "orgName" : "Daikin Applied Americas Corporate",
            "orgAddress" : "13600 Industrial Park Blvd",
            "orgCity" : "Minneapolis",
            "orgState" : "Minnesota",
            "orgCountry" : "United States",
            "orgZip" : "55441"}
        ]
        }
    ]
    },
    {"serialNumber" : "STNU110700041",
    "subscriptionInfoList" : [
        {"startDate" : "2016-11-14",
        "endDate" : "2017-11-14",
        "connectivityType" : "Cellular",
        "termYears" : 1.25,
        "subscriptionType" : "TechReadWrite",
        "contactInfoList" : [
            {"email" : "tenniselbowz@yahoo.com",
            "firstName" : "Joe",
            "middleName" : "",
            "lastName" : "Johnson",
			"administrator" : true,
            "customerAdmin" : false,
            "technicianAdmin" : true,
            "customer" : false,
            "technician" : false,
            "renewalAdmin" : true,
            "orgName" : "Daikin Applied Americas Corporate",
            "orgAddress" : "13600 Industrial Park Blvd",
            "orgCity" : "Minneapolis",
            "orgState" : "Minnesota",
            "orgCountry" : "United States",
            "orgZip" : "55441"}
        ]
        },
        {"startDate" : "2016-11-14",
        "endDate" : "2017-11-14",
        "connectivityType" : "Cellular",
        "termYears" : 1.25,
        "subscriptionType" : "CustomRead",
        "contactInfoList" : [
            {"email" : "kent.roessler@daikinapplied.com",
            "firstName" : "Mike",
            "middleName" : "",
            "lastName" : "Anderson",
			"administrator" : true,
            "customerAdmin" : true,
            "technicianAdmin" : false,
            "customer" : false,
            "technician" : false,
            "renewalAdmin" : true,
            "orgName" : "Daikin Applied Americas Corporate",
            "orgAddress" : "13600 Industrial Park Blvd",
            "orgCity" : "Minneapolis",
            "orgState" : "Minnesota",
            "orgCountry" : "United States",
            "orgZip" : "55441"}
        ]
        },
        {"startDate" : "2016-12-30",
        "endDate" : "2017-12-30",
        "connectivityType" : "Cellular",
        "termYears" : 1.25,
        "subscriptionType" : "Daikin",
        "contactInfoList" : [
            {"email" : "kent.roessler@daikinapplied.com",
            "firstName" : "Kent",
            "middleName" : "Steven",
            "lastName" : "Roessler",
			"administrator" : true,
            "customerAdmin" : false,
            "technicianAdmin" : false,
            "customer" : false,
            "technician" : false,
            "renewalAdmin" : false,
            "orgName" : "Kents Account",
            "orgAddress" : "13600 Industrial Park Blvd",
            "orgCity" : "Minneapolis",
            "orgState" : "Minnesota",
            "orgCountry" : "United States",
            "orgZip" : "55441"}
        ]
        }
    ]
    }
]
}
*/