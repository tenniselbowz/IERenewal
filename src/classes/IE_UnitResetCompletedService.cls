@RestResource(urlMapping='/IEUnitResetCompletedService/*')
global with sharing class IE_UnitResetCompletedService { 
 
	@HttpPut
    global Static IE_IntegrationObjects.IE_UnitResetCompletedResponse doPut(list<IE_IntegrationObjects.IE_UnitResetCompleted> Units)
    {
    	//disable trigger functionality
        TriggerUtility.limitIeServiceIntegration = true;

		IE_IntegrationObjects.IE_UnitResetCompleted unit = new IE_IntegrationObjects.IE_UnitResetCompleted();
		IE_IntegrationObjects.IE_UnitResetCompletedResponse response = new IE_IntegrationObjects.IE_UnitResetCompletedResponse();

		boolean unitResetError = false;
		boolean hasErrors = false;
		string unitResetErrors = 'IE_UnitResetCompletedService.doPut() Errors: ';
		list<Integration_Error__c> integrationErrorList = new list<Integration_Error__c>();  //list of any errors that will be logged into the Integration_Error object
		map<Id, Contact> syncIeCloudIndividualsContactResultsMap = new map<Id, Contact>();
		map<Id, Address__c> syncIeCloudIndividualsAddressMap = new map<Id, Address__c>();
		map<Id, Contact> contactMap = new map<Id, Contact>();
	    set<Id> contactIds = new set<Id>();
		List<Contact_Subscription__c> subscriptionContacts = new List<Contact_Subscription__c>();
		Asset gwAsset = null;


		try {
    		response.errors = new list<IE_IntegrationObjects.IE_Error>();

			// The list of units will only contain 1 unit, so get it
			for (IE_IntegrationObjects.IE_UnitResetCompleted u : Units)
				unit = u;

    		response.unit = unit;

			System.debug(logginglevel.error, 'IE_UnitResetCompletedService.doPut(): Unit SN = ' +  unit.SerialNumber + ', MAC Address = ' + unit.MACAddress + ', IEId = ' + unit.IEId + ', SFDCId = ' + unit.SFDCId + ', LastModifiedDate = ' + unit.LastModifiedDate);
			if (unit.Errors != null)
			{
				for (IE_IntegrationObjects.IE_Error e : unit.Errors)
				{
					unitResetError = true;
					unitResetErrors = unitResetErrors + ' ErrorCode = ' +  e.ErrorCode + ', ErrorMessage = ' + e.ErrorMessage + '; ';
					System.debug(logginglevel.error, 'IE_UnitResetCompletedService.doPut() Error: ErrorCode = ' +  e.ErrorCode + ', ErrorMessage = ' + e.ErrorMessage);
				}
			}


			// Get the GWotGo asset record via the MAC address
			Asset[] gwl = [SELECT Id, SerialNumber, Parent_Asset__c, SIM_Card_Active__c, SIM_Card_ICCID__c, MAC_Address__c, Status, GWotGo__c, Commissioned__c, Device_ID__c, ResetSuccessful__c, LastModifiedDate
				// Sub-queries used for GWotGo asset
				, (Select Id, Type__c, Name, Serial_Number__c, GWotGoAsset__c, Renewal_Counter__c, Connectivity_Type__c, Term_Years__c, Start_Date__c, End_Date__c, Buyer_ID__c, IE_ID__c, Active__c, LastModifiedDate, Asset__c From Subscriptions1__r)
				, (Select Id, Name, Role__c, Contact__r.Name, Contact__r.Email, Contact__r.Id, Contact__r.AccountId, GWotGoAsset__c, GWotGoPermAssoc__c, LastModifiedDate From Contact_Subscriptions1__r)
				from Asset Where (Name = 'Intelligent Equipment Gateway' OR Product2.Name = 'Intelligent Equipment Gateway') AND Status != 'Obsolete' AND Device_ID__c = :unit.MACAddress]; // use Device_ID__c instead of MAC_Address__c since that's what Coherant IE sends back

			if (gwl.size() > 0)
			{
				gwAsset = gwl[0];
				gwAsset.ResetSuccessful__c = 'False';  //default it to 'False'

				// If there are no errors in the request object "unit" then call the Coherant IE Individual service to process the contacts for the GWotGo asset,
				// and set the "ResetSuccessful" flag on the GWotGo asset to "True"
				// Else if there are errors in the request object "unit" then log an error to the Integration Error object,
				// and set the "ResetSuccessful" flag on the GWotGo asset to "False"
				if (unitResetError == false)
				{
					// Get the contact-subscription records
					subscriptionContacts = gwAsset.Contact_Subscriptions1__r;
					for (Contact_Subscription__c cs: subscriptionContacts) {
						System.debug(logginglevel.error, 'Contact Subscription: Name = ' + cs.Contact__r.Name + ' Email = ' + cs.Contact__r.Email + ' Contact Subscription Id = ' + cs.Id + ' Contact Id = ' + cs.Contact__r.Id + ' Account Id = ' + cs.Contact__r.AccountId + ' Perm Assoc = ' + cs.GWotGoPermAssoc__c + ', LastModifiedDate = ' + cs.LastModifiedDate);

						// Get the list of permanent contact ids
						if (cs.GWotGoPermAssoc__c == true)
							contactIds.add(cs.Contact__r.Id);
					}

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

					IERenewal_ExtWebServiceCallouts.syncIeCloudIndividuals2(contactMap.values(), syncIeCloudIndividualsContactResultsMap, syncIeCloudIndividualsAddressMap, integrationErrorList, gwAsset);
					gwAsset.ResetSuccessful__c = 'True';
				}
				else {
					System.debug(logginglevel.error, 'Unit Reset failed on IE side');
					gwAsset.ResetSuccessful__c = 'False';

					integrationErrorList.add(new Integration_Error__c(Direction__c = ''
       										, Error_Description__c = 'Unit Reset failed on IE side with errors: ' + unitResetErrors
       										, Integration_Object__c = 'Asset'
       										, Integration_Point__c = 'IE'
       										, Request_Data__c = 'IE_UnitResetCompletedService.doPut(): Unit SN = ' +  unit.SerialNumber + ', MAC Address = ' + unit.MACAddress ));

					IE_IntegrationObjects.IE_Error err = new IE_IntegrationObjects.IE_Error('UNIT_RESET_ERRORS', 'Unit Reset failed on IE side with errors: ' + unitResetErrors);
					response.errors.add(err);
				}
			}
			else {
				System.debug(logginglevel.error, 'Gateway asset not found for MAC Address = ' + unit.MACAddress + ', or the status is Obsolete');
				integrationErrorList.add(new Integration_Error__c(Direction__c = ''
       									, Error_Description__c = 'Gateway asset not found for MAC Address = ' + unit.MACAddress + ', or the status is Obsolete'
       									, Integration_Object__c = 'Asset'
       									, Integration_Point__c = 'IE'
       									, Request_Data__c = 'IE_UnitResetCompletedService.doPut(): Unit SN = ' +  unit.SerialNumber + ', MAC Address = ' + unit.MACAddress ));

				IE_IntegrationObjects.IE_Error err = new IE_IntegrationObjects.IE_Error('GWASSET_NOT_FOUND', 'Gateway Asset with MAC Address ' + unit.MACAddress + ' not found in Salesforce or the status is Obsolete');
				response.errors.add(err);
			}
		}
		catch (Exception e) {
			System.debug(logginglevel.error, 'IE_UnitResetCompletedService Exception: ' + e + ' | getTypeName = ' + e.getTypeName());
			IE_IntegrationObjects.IE_Error err = new IE_IntegrationObjects.IE_Error('UNIT_RESET_EXCEPTION', 'IE_UnitResetCompletedService Exception: ' + e + ' | Type Name = ' + e.getTypeName());
			response.errors.add(err);

   			hasErrors = true;

   			String integrationObjectName = 'Unknown';
   			if (e.getTypeName() == 'IERenewal_ExtWebServiceCallouts.syncIeCloudIndividualsException') integrationObjectName = 'Contact';

   			integrationErrorList.add(new Integration_Error__c(Direction__c = ''
       															, Error_Description__c = 'General Exception from IE_UnitResetCompletedService'
       															, Integration_Object__c = integrationObjectName
       															, Integration_Point__c = 'IE'
       															, Request_Data__c = e.getMessage() ));
		}
		finally {
			if (!hasErrors) {
   				if (syncIeCloudIndividualsContactResultsMap.size() > 0) {
					System.debug(logginglevel.error, 'update syncIeCloudIndividualsContactResultsMap.values()');
   					update syncIeCloudIndividualsContactResultsMap.values();
				}

   				if (syncIeCloudIndividualsAddressMap.size() > 0) {
					System.debug(logginglevel.error, 'update syncIeCloudIndividualsAddressMap.values()');
   					update syncIeCloudIndividualsAddressMap.values();
				}
			}

			if (gwAsset != null) {
				System.debug(logginglevel.error, 'update gwAsset');
				update gwAsset;
			}

			if(integrationErrorList.size() > 0) {
   				System.debug(logginglevel.error, 'IE_UnitResetCompletedService integrationErrorList: ' + integrationErrorList);
       			insert integrationErrorList;
       		}

		}


		System.debug(logginglevel.error, 'IE_UnitResetCompletedService Response object = ' + response);
		return response;
	}
}

// ***Testing the webservice in Workbench REST Explorer***
// Use the Put HTTP method on the following REST API Service URI: /services/apexrest/IEUnitResetCompletedService
/* Request Body (in json format):
{
"Units" : [{
"SerialNumber" : "FBOU111111111",
"MACAddress" : "00000000-00000000-00600CFF-FF816F55",
"LastModifiedDate":"2017-12-04T12:09:19.947Z",
"IEId":null,
"SFDCId":"TestUpdate1",
"Errors" : [
	{"ErrorCode" : "some error code",
	"ErrorMessage" : "some error message"
	}
]
}]
}
*/

// Since the request is now in the parameter "Units" of the doPut method, the string "Units" needs to start the Request Body and all the fields inside {} are inside
// [] since Coherent IE will be sending a list of 1 unit object.
// Note that the MACAddress value contains the long version of the value which is the Device_ID__c field on the asset. THis is what Coherent IE will be sending in the request.