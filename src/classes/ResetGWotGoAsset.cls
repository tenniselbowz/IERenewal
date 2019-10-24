@RestResource(urlMapping='/ResetGWotGoAsset/*')
global with sharing class ResetGWotGoAsset  {
	@HttpPost
    global Static ResetResponse doPost()
    {
        return processRequest();
    }
    
	
    @httpPut
    global Static ResetResponse doPut()
    {
        return processRequest();
    }


	/*
	@httpPut
	global Static void doPut()
	{
		//Simulate a 5 minute wait
		sleep(60, 5); //60 seconds X 5

	}

	public static void sleep(Integer sleepSeconds, integer count) {
		// First you have to Configure a new Remote Site in SalesForce (Security Controls -> Remote Site Settings),
		// name it however you want but make sure the Remote Site URL matches the URL, http://1.cuzillion.com/bin/resource.cgi
		// and that the "Active" checkbox is checked.

		Long startTS = System.currentTimeMillis();
		HttpRequest req = new HttpRequest();
		req.setTimeOut(120000) ; // timeout in milliseconds - 2 minutes
		req.setEndpoint('http://1.cuzillion.com/bin/resource.cgi?sleep=' + sleepSeconds);
		req.setMethod('GET');
		Http http = new Http();

		for (integer i = 0; i < count; i++)
			HTTPResponse res = http.send(req);

		Long duration = System.currentTimeMillis() - startTS;
		System.debug('Duration: ' + duration + 'ms');
	}
	*/


	global Static ResetResponse processRequest()
    {
        //disable trigger functionality
        TriggerUtility.limitIeServiceIntegration = true;

		string unitSN = RestContext.request.params.get('UnitSerialNumber');
		string gatewayMACAddr = RestContext.request.params.get('GatewayMACAddr');
		string userEmail = RestContext.request.params.get('UserEmail');

		ResetResponse theResponse = new ResetResponse();
		theResponse.UnitSerialNumber = unitSN;  // New unit for GW to attach to
		theResponse.GatewayMACAddress = gatewayMACAddr;
		theResponse.UserEmail = userEmail;

		// Setup data structures to capture errors and results from web service callouts
		boolean hasErrors = false;
		boolean hasIETimeout = false;
		list<Integration_Error__c> integrationErrorList = new list<Integration_Error__c>();  //list of any errors that will be logged into the Integration_Error object
		map<Id, Asset> syncIeCloudUnitsAssetResultsMap = new map<Id, Asset>();
		map<Id, Address__c> syncIeCloudUnitsAddressMap = new map<Id, Address__c>();
		map<Id, Subscription__c> syncIeCloudSubResultsMap = new map<Id, Subscription__c>();
		map<Id, Contact> syncIeCloudIndividualsContactResultsMap = new map<Id, Contact>();
		map<Id, Address__c> syncIeCloudIndividualsAddressMap = new map<Id, Address__c>();
		map<Id, Account> syncIeCloudOrganizationsAccountResultsMap = new map<Id, Account>();
		map<Id, Address__c> syncIeCloudOrganizationsAddressMap = new map<Id, Address__c>();

		map<Id, Asset> syncIeCloudUnitResetAssetResultsMap = new map<Id, Asset>();
		map<Id, Address__c> syncIeCloudUnitResetAddressMap = new map<Id, Address__c>();

		map<Id, Asset> syncIeCloudUnitsAssetResultsMapTemp = new map<Id, Asset>();
		map<Id, Address__c> syncIeCloudUnitsAddressMapTemp = new map<Id, Address__c>();

		Asset gwAsset = null;
		Asset parentAssetOld = null;
		Asset parentAssetNew = null;

		Asset gwotgoForHolding = null;
		Asset holdingGWotGoUnitAsset = null;
		boolean parentAssetNewHasGWotGoAsset = false;
		string parentAssetNewGWotGoMACAddr = null;

		List<Subscription__c> subscriptionList = new List<Subscription__c>();

		// gets the subscription of type TechReadWrite OR Standard
		Subscription__c subn = null;

		List<Contact_Subscription__c> subscriptionContacts = new List<Contact_Subscription__c>();
		map<Id, Account> accountMap = new map<Id, Account>();
	    set<Id> accountIds = new set<Id>();
		map<Id, Contact> contactMap = new map<Id, Contact>();
	    set<Id> contactIds = new set<Id>();

		Datetime currDateTime = Datetime.now(); // current date and time in the GMT time zone
		Date currentDate = Date.today();

		try {
			System.debug(logginglevel.error, 'Unit Serial Number = ' + unitSN + ' GW MAC Address = ' + gatewayMACAddr + ' User Email = ' + userEmail);

			// First check if the new unit asset is an IE Asset and if it is, does it have a GWotGo asset or a permanent GW asset.
			// If its a permanent GW asset then return with an Error Response.
			Asset[] panl = [Select Id
					, Name
					, SerialNumber
					, Tag__c
					, SO_Number__c
					, Job_Name__c
					, Device_ID__c
					, SIM_Card_ICCID__c
					, SIM_Card_Active__c
					, Format_Number__c
					, Commissioned__c
					, IE_ID__c
					, IE_Asset__c
					, IE_Sync_Status__c
					, IE_Updated_Date__c
					, Current_Code_String_Breakdown__c
					, Code_String_Breakdown__c
					, LastModifiedDate
					, Product2.ProductCode
					, Product2.Name
					, Order__c
					, AccountId
					//address data
					, Asset_Address__c
					, Asset_Address__r.Country__c
					, Asset_Address__r.Postal_Code__c
					, Asset_Address__r.State_Province__c
					, Asset_Address__r.County__c
					, Asset_Address__r.State_Province_ISO_Code__c
					, Asset_Address__r.Country_ISO_Code__c
					, Asset_Address__r.City__c
					, Asset_Address__r.Address_Line_4__c 
					, Asset_Address__r.Address_Line_3__c
					, Asset_Address__r.Address_Line_2__c
					, Asset_Address__r.Address_Line_1__c
					, Asset_Address__r.Name
					, Asset_Address__r.IE_ID__c
					, Asset_Address__r.Id 
					, Asset_Address__r.LastModifiedDate
					//related assets (gateway and emm)
					,(Select Id
							, Name
							, Product2.Name
							, Parent_Asset__c
							, SerialNumber
							, Tag__c
							, SO_Number__c
							, Job_Name__c
							, Device_ID__c
							, SIM_Card_ICCID__c
							, SIM_Card_Active__c
							, MAC_Address__c
							, Status
							, GWotGo__c
							, Format_Number__c
							, Commissioned__c
							, IE_ID__c
							, IE_Updated_Date__c
							, LastModifiedDate
						From Assets__r
						where Status != 'Obsolete'
					)
				from Asset
				where SerialNumber = :unitSN];

			if (panl.size() > 0)
			{
				parentAssetNew = panl[0];
				if (parentAssetNew.IE_Asset__c == true) {
					List<Asset> relatedAssets = parentAssetNew.Assets__r;
					for (Asset ast: relatedAssets) {
						System.debug(logginglevel.error, 'Related Asset Info: Name = ' + ast.Name + ' GWotGo__c = ' + ast.GWotGo__c);
            			if (((ast.Product2.Name == 'Intelligent Equipment Gateway') || (ast.Name == 'Intelligent Equipment Gateway')) && 
							(ast.GWotGo__c == true)) {
							parentAssetNewHasGWotGoAsset = true;
							parentAssetNewGWotGoMACAddr = ast.MAC_Address__c;
            			}
					}
				}

				System.debug(logginglevel.error, 'New Unit Asset Info: Name = ' + parentAssetNew.Name + ' Serial Number = ' + parentAssetNew.SerialNumber + ' IE Asset = ' + parentAssetNew.IE_Asset__c + ' Has GWotGo asset = ' + parentAssetNewHasGWotGoAsset + ' LastModifiedDate = ' + parentAssetNew.LastModifiedDate);

				if (parentAssetNew.IE_Asset__c == true && parentAssetNewHasGWotGoAsset == false)
				{
					// Illegal condition where the new unit asset is an IE asset and has a permanent gateway associated with it.
					// Cannot assign a GWotGo asset to this unit!
					System.debug(logginglevel.error, 'ResetGWotGoAsset Illegal Condition: The new unit asset is an IE asset and has a permanent gateway associated with it.  Cannot assign a GWotGo asset to this unit!');
					theResponse.addError( 'ILLEGAL_CONDITION', 'ResetGWotGoAsset Illegal Condition: The new unit asset is an IE asset and has a permanent gateway associated with it.  Cannot assign a GWotGo asset to this unit!');
   					hasErrors = true;
				}
				else
				{
					// Get the GWotGo asset record via the MAC address
					Asset[] gwl = [SELECT Id, SerialNumber, Parent_Asset__c, SIM_Card_Active__c, SIM_Card_ICCID__c, MAC_Address__c, Status, GWotGo__c, Commissioned__c, Device_ID__c, ResetSuccessful__c, LastModifiedDate
						// Sub-queries used for GWotGo asset
						, (Select Id, Type__c, Name, Serial_Number__c, GWotGoAsset__c, Renewal_Counter__c, Connectivity_Type__c, Term_Years__c, Start_Date__c, End_Date__c, Buyer_ID__c, IE_ID__c, Active__c, LastModifiedDate, Asset__c From Subscriptions1__r)
						, (Select Id, Name, Role__c, Contact__r.Name, Contact__r.Email, Contact__r.Id, Contact__r.AccountId, GWotGoAsset__c, GWotGoPermAssoc__c, LastModifiedDate From Contact_Subscriptions1__r)
						from Asset Where (Name = 'Intelligent Equipment Gateway' OR Product2.Name = 'Intelligent Equipment Gateway') AND Status != 'Obsolete' AND MAC_Address__c = :gatewayMACAddr];
		
					if (gwl.size() > 0)
					{
						gwAsset = gwl[0];

						// Get the parent asset currently associated with the GW
						Asset[] paol = [Select Id
								, Name
								, SerialNumber
								, Tag__c
								, SO_Number__c
								, Job_Name__c
								, Device_ID__c
								, SIM_Card_ICCID__c
								, SIM_Card_Active__c
								, Format_Number__c
								, Commissioned__c
								, IE_ID__c
								, IE_Asset__c
								, IE_Sync_Status__c
								, IE_Updated_Date__c
								, Current_Code_String_Breakdown__c
								, Code_String_Breakdown__c
								, LastModifiedDate
								, Product2.ProductCode
								, Product2.Name
								, Order__c
								, AccountId
								//address data
								, Asset_Address__c
								, Asset_Address__r.Country__c
								, Asset_Address__r.Postal_Code__c
								, Asset_Address__r.State_Province__c
								, Asset_Address__r.County__c
								, Asset_Address__r.State_Province_ISO_Code__c
								, Asset_Address__r.Country_ISO_Code__c
								, Asset_Address__r.City__c
								, Asset_Address__r.Address_Line_4__c 
								, Asset_Address__r.Address_Line_3__c
								, Asset_Address__r.Address_Line_2__c
								, Asset_Address__r.Address_Line_1__c
								, Asset_Address__r.Name
								, Asset_Address__r.IE_ID__c
								, Asset_Address__r.Id 
								, Asset_Address__r.LastModifiedDate
								//related assets (gateway and emm)
								,(Select Id
										, Parent_Asset__c
										, SerialNumber
										, Tag__c
										, SO_Number__c
										, Job_Name__c
										, Device_ID__c
										, SIM_Card_ICCID__c
										, SIM_Card_Active__c
										, MAC_Address__c
										, Status
										, GWotGo__c
										, Format_Number__c
										, Commissioned__c
										, IE_ID__c
										, IE_Updated_Date__c
										, LastModifiedDate
									From Assets__r
									where Status != 'Obsolete'
								)
							from Asset
							where Id = :gwAsset.Parent_Asset__c];

						if (paol.size() > 0)
						{
							parentAssetOld = paol[0];

							// Get the subscription pair
							subscriptionList = gwAsset.Subscriptions1__r;
							for (Subscription__c s: subscriptionList) {
								System.debug(logginglevel.error, 'Subscription Pair: Name = ' + s.Name + ' Type = ' + s.Type__c + ' Id = ' + s.Id);
								if (s.Type__c == 'TechReadWrite' || s.Type__c == 'Standard') {
									subn = s;
									System.debug(logginglevel.error, 'Subscription: Name = ' + subn.Name + ' Type = ' + subn.Type__c + ' Id = ' + subn.Id);
								}
							}


							// Get the contact-subscription records
							subscriptionContacts = gwAsset.Contact_Subscriptions1__r;
							for (Contact_Subscription__c cs: subscriptionContacts) {
								System.debug(logginglevel.error, 'Contact Subscription: Name = ' + cs.Contact__r.Name + ' Email = ' + cs.Contact__r.Email + ' Contact Subscription Id = ' + cs.Id + ' Contact Id = ' + cs.Contact__r.Id + ' Account Id = ' + cs.Contact__r.AccountId + ' Perm Assoc = ' + cs.GWotGoPermAssoc__c + ', LastModifiedDate = ' + cs.LastModifiedDate);

								// Bulkify for SOQL query: Get the list of permanent contact ids and their account ids
								if (cs.GWotGoPermAssoc__c == true)
								{
									accountIds.add(cs.Contact__r.AccountId);
									contactIds.add(cs.Contact__r.Id);
								}
							}

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



							if (!subscriptionList.isEmpty())
							{
								// NOTE: All the web service callouts must be made before any DML operations are performed!

								// If the new unit asset is already an IE asset with another GWotGo asset already assigned to it
								// then before moving the GW to the Holding Asset call the IE unit create endpoint but set SN to SFDCID of the GW.
								// The IE side will clear out the original GW/unit asset association.
								// This is done just to get this GWotGo asset off the unit asset since we really don't want 2 GWs associated with the unit asset.
								if ((parentAssetNewHasGWotGoAsset == true) && (parentAssetOld.Id != parentAssetNew.Id))
								{
									// select the gateway record via the MAC address
									gwotgoForHolding = [SELECT Id, SerialNumber, Parent_Asset__c, SIM_Card_Active__c, SIM_Card_ICCID__c, MAC_Address__c, Status, GWotGo__c, Commissioned__c, Device_ID__c
										// Sub-queries used for GWotGo asset
										, (Select Id, Type__c, Name, Serial_Number__c, GWotGoAsset__c, Renewal_Counter__c, Connectivity_Type__c, Term_Years__c From Subscriptions1__r)
										, (Select Id, Name, Role__c, Contact__r.Name, Contact__r.Email, Contact__r.Id, Contact__r.AccountId, GWotGoAsset__c, GWotGoPermAssoc__c From Contact_Subscriptions1__r)
										from Asset Where (Name = 'Intelligent Equipment Gateway' OR Product2.Name = 'Intelligent Equipment Gateway') AND Status != 'Obsolete' AND MAC_Address__c = :parentAssetNewGWotGoMACAddr];

									System.debug(logginglevel.error, 'Invoke the Create Unit Service for this special case where we are moving an existing GWotGo asset from ' + parentAssetNew.SerialNumber + ' to the Holding unit Asset');
									IERenewal_ExtWebServiceCallouts.syncIeCloudUnitForGWotGo(parentAssetNew, gwotgoForHolding, 'Cellular', syncIeCloudUnitsAssetResultsMapTemp, syncIeCloudUnitsAddressMapTemp, integrationErrorList, true);  // Here we will do a PUT operation since the GW is not new
								}


								// Check if the GWotGo asset is associated with the "Dummy GWotGo Unit Asset"
								if (parentAssetOld.Name == 'Dummy GWotGo Unit Asset')
								{
									// First real unit that the GW will be assigned to.
									// Create/Sync the Unit & GW, Subscription Pair, Contacts & their Account with Coherent IE cloud via web services
									System.debug(logginglevel.error, 'First Reset Operation for MAC Address = ' + gatewayMACAddr + ' and new Unit Serial Number = ' + unitSN);

									IERenewal_ExtWebServiceCallouts.syncIeCloudUnitForGWotGo(parentAssetNew, gwAsset, 'Cellular', syncIeCloudUnitsAssetResultsMap, syncIeCloudUnitsAddressMap, integrationErrorList, false);  // Here we will do a POST operation since the GW is new
									for (Integration_Error__c err : integrationErrorList)
									{
										if ( (err.Error_Description__c == 'CALLOUT_EXCEPTION') && ((err.Request_Data__c == 'Read timed out') || (err.Request_Data__c == 'Exceeded maximum time allotted for callout (120000 ms)')) )
											hasIETimeout = true;
									}
									if (!hasIETimeout)
									{
										// Only call these IE services if the Unit Create service call didn't time out!
										IERenewal_ExtWebServiceCallouts.syncIeCloudSubscriptions(subscriptionList, syncIeCloudSubResultsMap, integrationErrorList);
										IERenewal_ExtWebServiceCallouts.syncIeCloudOrganizations2(accountMap.values(), syncIeCloudOrganizationsAccountResultsMap, syncIeCloudOrganizationsAddressMap, integrationErrorList);
										IERenewal_ExtWebServiceCallouts.syncIeCloudIndividuals2(contactMap.values(), syncIeCloudIndividualsContactResultsMap, syncIeCloudIndividualsAddressMap, integrationErrorList, gwAsset);  //If this call times out then we just continue since it is the last IE service call
									}
								}
								else
								{
									// Invoke the Coherent Unit Reset web service.
									System.debug(logginglevel.error, 'Invoke Unit Reset web service');
									
									IERenewal_ExtWebServiceCallouts.syncIeCloudUnitReset(parentAssetNew, gwAsset, syncIeCloudUnitResetAssetResultsMap, syncIeCloudUnitResetAddressMap, integrationErrorList);
									System.debug(logginglevel.error, 'syncIeCloudUnitResetAssetResultsMap.values() 1: ' + syncIeCloudUnitResetAssetResultsMap.values());
									
									// Not calling the Individual endpoint here since it will be called in the IEUnitResetCompletedService endpoint that Coherant IE will call
									//IERenewal_ExtWebServiceCallouts.syncIeCloudIndividuals2(contactMap.values(), syncIeCloudIndividualsContactResultsMap, syncIeCloudIndividualsAddressMap, integrationErrorList);
									
								}


								// If the new unit asset is already an IE asset with another GWotGo asset already assigned to it
								// then Update SIM card object GW information in the AT&T Jasper CC Cellular API and 
								// detach the GWotGo asset from it and attach it to the "Holding GWotGo Unit Asset" and
								// store the gateway asset history.
								if ((parentAssetNewHasGWotGoAsset == true) && (parentAssetOld.Id != parentAssetNew.Id))
								{
									// Get the subscription pair
									List<Subscription__c> subscriptionListForHolding = gwotgoForHolding.Subscriptions1__r;
									Subscription__c subnForHolding = null;
									for (Subscription__c s: subscriptionListForHolding) {
										if (s.Type__c == 'TechReadWrite' || s.Type__c == 'Standard')
											subnForHolding = s;
									}

									// Get the contact-subscription records
									List<Contact_Subscription__c> subscriptionContactsForHolding = gwotgoForHolding.Contact_Subscriptions1__r;

									// select the Holding GWotGo Unit Asset record
									holdingGWotGoUnitAsset = [Select Id
											, Name
											, SerialNumber
											, Tag__c
											, SO_Number__c
											, Job_Name__c
											, Device_ID__c
											, SIM_Card_ICCID__c
											, SIM_Card_Active__c
											, Format_Number__c
											, Commissioned__c
											, IE_ID__c
											, IE_Asset__c
											, IE_Sync_Status__c
											, IE_Updated_Date__c
											, Current_Code_String_Breakdown__c
											, Code_String_Breakdown__c
											, LastModifiedDate
											, Product2.ProductCode
											, Product2.Name
											, Order__c
											, AccountId
											//address data
											, Asset_Address__c
											, Asset_Address__r.Country__c
											, Asset_Address__r.Postal_Code__c
											, Asset_Address__r.State_Province__c
											, Asset_Address__r.County__c
											, Asset_Address__r.State_Province_ISO_Code__c
											, Asset_Address__r.Country_ISO_Code__c
											, Asset_Address__r.City__c
											, Asset_Address__r.Address_Line_4__c 
											, Asset_Address__r.Address_Line_3__c
											, Asset_Address__r.Address_Line_2__c
											, Asset_Address__r.Address_Line_1__c
											, Asset_Address__r.Name
											, Asset_Address__r.IE_ID__c
											, Asset_Address__r.Id 
											, Asset_Address__r.LastModifiedDate
											//related assets (gateway and emm)
											,(Select Id
													, Parent_Asset__c
													, SerialNumber
													, Tag__c
													, SO_Number__c
													, Job_Name__c
													, Device_ID__c
													, SIM_Card_ICCID__c
													, SIM_Card_Active__c
													, MAC_Address__c
													, Status
													, GWotGo__c
													, Format_Number__c
													, Commissioned__c
													, IE_ID__c
													, IE_Updated_Date__c
													, LastModifiedDate
												From Assets__r
												where Status != 'Obsolete'
											)
										from Asset
										where Name = 'Holding GWotGo Unit Asset'];

									// Update SIM card object GW information in the AT&T Jasper CC Cellular API for GWotGoForHolding
									System.debug(logginglevel.error, 'Calling updateSimCardObjectCellularInfo to put gateway in holding status');
									IERenewal_ExtWebServiceCallouts.updateSimCardObjectCellularInfo(gwotgoForHolding, holdingGWotGoUnitAsset, subnForHolding, integrationErrorList);

									// Update SIM card object GW information in the AT&T Jasper CC Cellular API for GWotGo
									// A Web Service Callout may not occur after a DML statement within the same transaction so
									// we need to do this callout here since the next statements perform DML operations.
									System.debug(logginglevel.error, 'Calling updateSimCardObjectCellularInfo');
									IERenewal_ExtWebServiceCallouts.updateSimCardObjectCellularInfo(gwAsset, parentAssetNew, subn, integrationErrorList);

									// Detach GW from its unit asset and attach to the "Holding GWotGo Unit Asset"
									System.debug(logginglevel.error, 'Calling ProcessDetachAndAttachOfGateway to put gateway in holding status');
									ProcessDetachAndAttachOfGateway(gwotgoForHolding, parentAssetNew, holdingGWotGoUnitAsset, subscriptionListForHolding, subscriptionContactsForHolding, theResponse);

									// Store GW asset history as it moves from its unit to the "Holding GWotGo Unit Asset"
									System.debug(logginglevel.error, 'Calling PersistGWAssetHistory to log gateway in holding status');
									PersistGWAssetHistory(userEmail, parentAssetNew.SerialNumber, holdingGWotGoUnitAsset.SerialNumber, gwotgoForHolding);
								}
								else {
									// Update SIM card object GW information in the AT&T Jasper CC Cellular API for GWotGo
									System.debug(logginglevel.error, 'Calling updateSimCardObjectCellularInfo');
									IERenewal_ExtWebServiceCallouts.updateSimCardObjectCellularInfo(gwAsset, parentAssetNew, subn, integrationErrorList);
								}

								// Reset the "ResetSuccessful" flag on the GWotGo asset to "None" so it is ready to be set after a unit reset call
								// to Coherant IE.  When their operation is completed they will invoke our SF endpoint, "IEUnitResetCompletedService",
								// which will set this flag to "True" or "False".
								// Before we set the flag to "None", if the current value is "True" or "False" then make sure it wasn't just set 
								// in the last 5 minutes or so. Just in case the endpoint got invoked before this piece of code is processed.
								// ********************************************************
								if (parentAssetOld.Name == 'Dummy GWotGo Unit Asset') {
									// Since this was a create and NOT a unit reset, just set the flag to true and update
									System.debug(logginglevel.error, 'Reset gwAsset ResetSuccessful__c flag to True');
									gwAsset.ResetSuccessful__c = 'True';
									update gwAsset;
								}
								else {
									Asset gwAssetTemp = [SELECT Id, MAC_Address__c, Status, ResetSuccessful__c, LastModifiedDate
										from Asset Where (Name = 'Intelligent Equipment Gateway' OR Product2.Name = 'Intelligent Equipment Gateway') AND Status != 'Obsolete' AND MAC_Address__c = :gatewayMACAddr]; // select the latest data for the gwAsset in case something got updated

									System.debug(logginglevel.error, 'gwAssetTemp.ResetSuccessful__c = ' + gwAssetTemp.ResetSuccessful__c + ', gwAssetTemp.LastModifiedDate = ' + gwAssetTemp.LastModifiedDate + ', currDateTime = ' + currDateTime);
									if (((gwAssetTemp.ResetSuccessful__c == 'True') || (gwAssetTemp.ResetSuccessful__c == 'False')) && (gwAssetTemp.LastModifiedDate <= currDateTime))  //LastModifiedDate is in GMT
									{
										// No changes have been made so reset the field to 'None'
										System.debug(logginglevel.error, 'Reset gwAsset ResetSuccessful__c flag to None');
										gwAssetTemp.ResetSuccessful__c = 'None';
										update gwAssetTemp;
										gwAsset.ResetSuccessful__c = 'None';  // set this field to 'None' too so later when its updated it doesn't change this field back to what it was previously
									}
								}
								// ********************************************************


								// Detach GW from the old unit asset and attach to the new unit and only preserve permanent contacts.
								System.debug(logginglevel.error, 'Calling ProcessDetachAndAttachOfGateway');
								ProcessDetachAndAttachOfGateway(gwAsset, parentAssetOld, parentAssetNew, subscriptionList, subscriptionContacts, theResponse);

								// Store GW asset history as it moves from unit to unit
								System.debug(logginglevel.error, 'Calling PersistGWAssetHistory');
								PersistGWAssetHistory(userEmail, parentAssetOld.SerialNumber, parentAssetNew.SerialNumber, gwAsset);
							}
							else
							{
								System.debug(logginglevel.error, 'No subscription pair found for Gateway asset with MAC Address = ' + gatewayMACAddr);
								theResponse.addError( 'SUBSCRIPTIONPAIR_NOT_FOUND', 'No subscription pair found for Gateway Asset with MAC Address ' + gatewayMACAddr );
								hasErrors = true;
							}
						}
						else {
							System.debug(logginglevel.error, 'Parent Unit not found for GWotGo asset with Serial Number = ' + gwAsset.SerialNumber);
							theResponse.addError( 'PARENTUNIT_NOT_FOUND', 'Parent Unit not found for GWotGo asset with Serial Number = ' + gwAsset.SerialNumber);
							hasErrors = true;
						}
					}
					else
					{
						System.debug(logginglevel.error, 'Gateway asset not found for MAC Address = ' + gatewayMACAddr + ', or the status is Obsolete');
						theResponse.addError( 'GWASSET_NOT_FOUND', 'Gateway Asset with MAC Address ' + gatewayMACAddr + ' not found in Salesforce or the status is Obsolete' );
						hasErrors = true;
					}
				}
			}
			else {
				System.debug(logginglevel.error, 'New Unit not found for Serial Number = ' + unitSN);
				theResponse.addError( 'NEWUNIT_NOT_FOUND', 'New Unit not found for Serial Number = ' + unitSN);
				hasErrors = true;
			}
		}
		catch (Exception e) {
			System.debug(logginglevel.error, 'ResetGWotGoAsset Exception: ' + e + ' | getTypeName = ' + e.getTypeName());
			theResponse.addError( 'UNIT_RESET_EXCEPTION', 'ResetGWotGoAsset Exception: ' + e + ' | Type Name = ' + e.getTypeName());
   			hasErrors = true;

   			String integrationObjectName = 'Unknown';
   			if (e.getTypeName() == 'IERenewal_ExtWebServiceCallouts.updateSimCardObjectCellularInfoException') integrationObjectName = 'AT&T Jasper API';
   			else if (e.getTypeName() == 'IERenewal_ExtWebServiceCallouts.syncIeCloudIndividualsException') integrationObjectName = 'Contact';
   			else if (e.getTypeName() == 'IERenewal_ExtWebServiceCallouts.syncIeCloudOrganizationsException') integrationObjectName = 'Account';
   			else if (e.getTypeName() == 'IERenewal_ExtWebServiceCallouts.syncIeCloudSubscriptionsException') integrationObjectName = 'Subscription__c';
   			else if (e.getTypeName() == 'IERenewal_ExtWebServiceCallouts.syncIeCloudUnitsException') integrationObjectName = 'Asset';
			else if (e.getTypeName() == 'IERenewal_ExtWebServiceCallouts.syncIeCloudUnitResetException') integrationObjectName = 'Asset';

   			integrationErrorList.add(new Integration_Error__c(Direction__c = ''
       															, Error_Description__c = 'General Exception from ResetGWotGoAsset'
       															, Integration_Object__c = integrationObjectName
       															, Integration_Point__c = 'IE'
       															, Request_Data__c = e.getMessage() ));
		}
		finally {
   			if (!hasErrors) {
   				if (syncIeCloudUnitsAssetResultsMap.size() > 0) {
					System.debug(logginglevel.error, 'update syncIeCloudUnitsAssetResultsMap.values()');
   					update syncIeCloudUnitsAssetResultsMap.values();
				}

   				if (syncIeCloudUnitsAddressMap.size() > 0) {
					System.debug(logginglevel.error, 'update syncIeCloudUnitsAddressMap.values()');
   					update syncIeCloudUnitsAddressMap.values();
				}

				if (syncIeCloudUnitResetAssetResultsMap.size() > 0) {
					System.debug(logginglevel.error, 'update syncIeCloudUnitResetAssetResultsMap.values(): ' + syncIeCloudUnitResetAssetResultsMap.values());
   					update syncIeCloudUnitResetAssetResultsMap.values();
				}

   				if (syncIeCloudUnitResetAddressMap.size() > 0) {
					System.debug(logginglevel.error, 'update syncIeCloudUnitResetAddressMap.values()');
   					update syncIeCloudUnitResetAddressMap.values();
				}

   				if (syncIeCloudSubResultsMap.size() > 0) {
					System.debug(logginglevel.error, 'update syncIeCloudSubResultsMap.values()');
   					update syncIeCloudSubResultsMap.values();
				}

   				if (syncIeCloudOrganizationsAccountResultsMap.size() > 0) {
					System.debug(logginglevel.error, 'update syncIeCloudOrganizationsAccountResultsMap.values()');
   					update syncIeCloudOrganizationsAccountResultsMap.values();
				}

				if (syncIeCloudOrganizationsAddressMap.size() > 0) {
					System.debug(logginglevel.error, 'update syncIeCloudOrganizationsAddressMap.values()');
					update syncIeCloudOrganizationsAddressMap.values();
				}

   				if (syncIeCloudIndividualsContactResultsMap.size() > 0) {
					System.debug(logginglevel.error, 'update syncIeCloudIndividualsContactResultsMap.values()');
   					update syncIeCloudIndividualsContactResultsMap.values();
				}

   				if (syncIeCloudIndividualsAddressMap.size() > 0) {
					System.debug(logginglevel.error, 'update syncIeCloudIndividualsAddressMap.values()');
   					update syncIeCloudIndividualsAddressMap.values();
				}
   			}

   			if(integrationErrorList.size() > 0) {
   				System.debug(logginglevel.error, 'ResetGWotGoAsset integrationErrorList: ' + integrationErrorList);
       			insert integrationErrorList;

				if (!hasErrors) {
					// Grab all the warnings generated by the web service callouts
					for (Integration_Error__c w : integrationErrorList)
					{
						String wMsg = null;

						wMsg = 'Direction: ' + w.Direction__c + ', Error Description: ' + w.Error_Description__c + ', Integration Object: ' + w.Integration_Object__c + ', Integration Object Id: ' + w.Integration_Object_Id__c + ', Integration Point: ' + w.Integration_Point__c + ', Request Data: ' + w.Request_Data__c;
						theResponse.addWarning(wMsg);
					}
				}
       		}
		}

		System.debug(logginglevel.error, 'ResetGWotGoAsset Service Response object = ' + theResponse);

		return theResponse;
	}


	public static void ProcessDetachAndAttachOfGateway(Asset gwAsset, Asset oldUnitAsset, Asset newUnitAsset, List<Subscription__c> subscriptions, List<Contact_Subscription__c> contact_subscriptions, ResetResponse resp)
	{
		// Detach GW asset from the old unit asset. Set IE Asset flag to false for the old unit asset (if not Dummy GWotGo Unit Asset or Holding GWotGo Unit Asset).
		// Attach GW asset to the new unit asset. Set IE Asset flag to true for the new unit asset.
		// If the old unit asset = new unit asset then nothing needs to be updated in salesforce.

		if (oldUnitAsset.Id != newUnitAsset.Id)
		{
			gwAsset.Parent_Asset__c = newUnitAsset.Id;
			update gwAsset;

			newUnitAsset.IE_Asset__c = true;
			update newUnitAsset;

			if ((oldUnitAsset.Name != 'Dummy GWotGo Unit Asset') && (oldUnitAsset.Name != 'Holding GWotGo Unit Asset')) {
				//!!! Don't update if the newUnitAsset is the 'Holding GWotGo Unit Asset' because in this case
				//!!! the GW asset is moving from the oldUnitAsset to the 'Holding GWotGo Unit Asset'.
				//!!! The oldUnitAsset will be getting the actual GW asset we are processing, so by updating this field to null 
				//!!! it actually clears out the new IE Id that is in the map structure, syncIeCloudUnitResetAssetResultsMap
				//!!! which is used to update the unit asset at the end of the run.  We don't want that!
				if (newUnitAsset.Name != 'Holding GWotGo Unit Asset')
				{
					oldUnitAsset.IE_ID__c = null;  // clear out the IE ID field of the old unit, since its not an IE asset anymore
					oldUnitAsset.IE_Asset__c = false;
					update oldUnitAsset;
				}
			}

			// Detach subscription pair from the old unit asset and attach to the new unit asset.
			for (Subscription__c s: subscriptions) {
				s.Asset__c = newUnitAsset.Id;
				update s;
			}

			// Delete Contact-Subscription records that are Temporary.
			// Detach Permanent Contact-Subscription records from the old unit asset and attach to the new unit asset.
			for (Contact_Subscription__c cs: contact_subscriptions) {
				if (cs.GWotGoPermAssoc__c == false)
				{
					delete cs;
				}
				else {
					cs.Asset__c = newUnitAsset.Id;
					update cs;
				}
			}
		}
		else {
			System.debug(logginglevel.error, 'The old unit asset is the same as the new unit asset!');
			resp.addWarning('The old unit asset is the same as the new unit asset!');
		}
	}


	public static void PersistGWAssetHistory(string resetInitiatorEmail, string oldUnitSN, string newUnitSN, Asset gwAsset)
	{
		Note n = new Note();
		Datetime currDateTime = Datetime.now(); // current date and time in the GMT time zone
		String sCurrDateTime = String.valueOf(currDateTime);

		n.body = 'Date/Time of the Reset: ' + sCurrDateTime + '\nUser Email who initiated the Reset: ' + resetInitiatorEmail + '\nPrevious Unit Serial Number: ' + oldUnitSN + '\nNew Unit Serial Number: ' + newUnitSN;
		n.Title = 'Gateway On the Go History';
		n.ParentId = gwAsset.Id;
		n.OwnerId = UserInfo.getUserId();
		insert n;
	}



	/* Response schemas */
	global class ResetResponse
    {
        public List<Response_Error> Errors;
		public List<Response_Warning> Warnings;
        public String UnitSerialNumber;
        public String GatewayMACAddress;
		public String UserEmail;

        public ResetResponse()
        {
            this.Errors = new List<Response_Error>();
			this.Warnings = new List<Response_Warning>();
        }

        public void addError( String errorCode, String errorMessage )
        {
            Response_Error newError = new Response_Error();
            newError.ErrorCode = errorCode;
            newError.ErrorMessage = errorMessage;
            this.Errors.add( newError );
        }

		public void addWarning(String warningMessage )
        {
            Response_Warning newWarning = new Response_Warning();
            newWarning.WarningMessage = warningMessage;
            this.Warnings.add( newWarning );
        }
    }

    global class Response_Error
    {
        public String ErrorMessage;
        public String ErrorCode;
    }

	global class Response_Warning
    {
        public String WarningMessage;
	}

}