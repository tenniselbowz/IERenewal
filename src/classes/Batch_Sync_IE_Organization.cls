global class Batch_Sync_IE_Organization implements Database.Batchable<sObject>, Database.AllowsCallouts,  Database.Stateful{
    
	// static variables used in unit tests
    public static boolean crash_TestByResponseStatusCode = false;
    public static boolean crash_TestByException = false;

    global string processingStatus = 'Pending'; 
    global boolean hasErrors = false;
    
    global Batch_Sync_IE_Organization(string status)
    {
    	processingStatus = status;
    }
    
    global Database.querylocator start(Database.BatchableContext BC)
    { 
        //
        // Iterate over the objects of interest
        //
        return Database.getQueryLocator([select Name
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
        								  from Account  
        								 where IE_Sync_Status__c = :processingStatus
											and IE_Account__c = true]);
       
    }
 
    //Main execute method
    global void execute(Database.BatchableContext BC, List<	Account> accounts)
    {
    	TriggerUtility.limitIntegrationBatch = true;
       //populate the objects for integration
       IE_IntegrationObjects.IE_OrganizationList ieAccountPost = new IE_IntegrationObjects.IE_OrganizationList();
       IE_IntegrationObjects.IE_OrganizationList ieAccountPut = new IE_IntegrationObjects.IE_OrganizationList();
       ieAccountPost.Organizations = new list<IE_IntegrationObjects.IE_Organization>();
       ieAccountPut.Organizations = new list<IE_IntegrationObjects.IE_Organization>();
       
       IE_IntegrationObjects.IE_OrganizationListResponse ieAccountPostResponse = new IE_IntegrationObjects.IE_OrganizationListResponse();
       IE_IntegrationObjects.IE_OrganizationListResponse ieAccountPutResponse = new IE_IntegrationObjects.IE_OrganizationListResponse();
       
       map<Id, Account> accountMap = new map<Id, Account>();
       map<Id, Address__c> addressMap = new map<Id, Address__c>();
       list<Integration_Error__c> integrationErrorList = new list<Integration_Error__c>();
       
       for(Account a : accounts)
       { 
       		//get the address data
       		IE_IntegrationObjects.IE_Address address = new IE_IntegrationObjects.IE_Address();
       		for(Account_Address__c addr : a.Account_Addresses__r)
       		{
	       		address.AddressLine1 = addr.Address__r.Address_Line_1__c;
				address.AddressLine2 = addr.Address__r.Address_Line_2__c;
				address.AddressLine3 = addr.Address__r.Address_Line_3__c;
				address.AddressLine4 = addr.Address__r.Address_Line_4__c;
				address.City 		 = addr.Address__r.City__c;
				address.Country 	 = addr.Address__r.Country_ISO_Code__c;  
				address.StateCode 	 = addr.Address__r.State_Province_ISO_Code__c;
				address.ZipCode 	 = addr.Address__r.Postal_Code__c;
				address.SFDCId		 = addr.Address__r.Id;
				address.IEId		 = addr.Address__r.IE_ID__c;

				address.LastModifiedDate = Datetime.now(); // current date and time in the GMT time zone
				/*address.LastModifiedDate = DateTime.newInstance(addr.Address__r.LastModifiedDate.dateGmt()
															   ,addr.Address__r.LastModifiedDate.timeGmt());*/

				addressMap.put(addr.Address__r.Id, addr.Address__r);
				break;
       		}
   		    //create the Organization and add it to the list
       		IE_IntegrationObjects.IE_Organization ieAccount = new IE_IntegrationObjects.IE_Organization();
       		ieAccount.Address = address;
       		ieAccount.OrganizationName = a.Name;
       		ieAccount.PhoneNumber = a.Phone;
       		ieAccount.SFDCId = a.Id;
			ieAccount.IEId	= a.IE_ID__c;

			ieAccount.LastModifiedDate = Datetime.now(); // current date and time in the GMT time zone
			/*ieAccount.LastModifiedDate	= DateTime.newInstance(a.LastModifiedDate.dateGmt()
															   ,a.LastModifiedDate.timeGmt());*/
   		    if(a.IE_ID__c == null)
       			ieAccountPost.Organizations.add(ieAccount);
       		else
       			ieAccountPut.Organizations.add(ieAccount);
       		
       		//store the Account in the map to retrieve response status
       		accountMap.put(a.Id, a);	
       }
       
       //
       // call the service - Determine PUT or POST
       //
       
       String jsonPostResponse = '';
       String jsonPutResponse = '';
       
       //Process the POST
       try{
	       if(ieAccountPost.Organizations != null && ieAccountPost.Organizations.size() > 0)
	       {
		       system.debug(':::ieAccountPost:::'+JSON.serialize(ieAccountPost));
		       HTTPResponse response = IE_IntegrationObjects.sendIeRequest(IE_Service_Configuration__c.getInstance().OrganizationService__c
                                                                         , 'POST'
                                                                         , JSON.serialize(ieAccountPost));
		       
			   if (crash_TestByResponseStatusCode) {
					// Crash Test is running so mock a bad response code
					response.setStatusCode(999);
               }

		       if(response.getStatusCode() == 200)
		        { 
		            //iterate over the response checking for errors maybe we just return the body
		            if(Test.isRunningTest())
		            	jsonPostResponse = JSON.serialize(ieAccountPost);//for testing purposes since we can make a call-out
		            else
		            	jsonPostResponse = response.getBody();
		            	
		            system.debug(':::ieAccountPost Response:::'+jsonPostResponse);	
		            ieAccountPostResponse = (IE_IntegrationObjects.IE_OrganizationListResponse)JSON.deserialize(jsonPostResponse, IE_IntegrationObjects.IE_OrganizationListResponse.class);
		        }
		        else{ 
		        	//log the error
		        	integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
       															, Error_Description__c = 'Transmission Error ['+response.getStatusCode()+']'
       															, Integration_Object__c = 'Account'
       															, Integration_Point__c = 'IE'
       															, Request_Data__c = JSON.serialize(ieAccountPost) ));
       				hasErrors = true;
		        }
	       }
       }
       catch(Exception e)
       {
       		//log the error
       		integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
       															, Error_Description__c = 'CALLOUT_EXCEPTION'
       															, Integration_Object__c = 'Account'
       															, Integration_Point__c = 'IE'
       															, Request_Data__c = e.getMessage() ));
   			hasErrors = true;
       }
       
       //Process the PUT 
       try{
	       if(ieAccountPut.Organizations != null && ieAccountPut.Organizations.size() > 0)
	       {
		       system.debug(':::ieAccountPut:::'+JSON.serialize(ieAccountPut));
		       HTTPResponse response = IE_IntegrationObjects.sendIeRequest(IE_Service_Configuration__c.getInstance().OrganizationService__c
                                                                         , 'PUT'
                                                                         , JSON.serialize(ieAccountPut));
		       
			   if (crash_TestByResponseStatusCode) {
					// Crash Test is running so mock a bad response code
					response.setStatusCode(999);
               }

		       if(response.getStatusCode() == 200)
		        { 
		            //iterate over the response checking for errors maybe we just return the body
		            if(Test.isRunningTest())
		            	jsonPutResponse = JSON.serialize(ieAccountPut);//for testing purposes since we can make a call-out
		            else
		            	jsonPutResponse = response.getBody();
		            	
		            ieAccountPutResponse = (IE_IntegrationObjects.IE_OrganizationListResponse)JSON.deserialize(jsonPutResponse, IE_IntegrationObjects.IE_OrganizationListResponse.class);
		        }
		        else{ 
		        	//log the error
		        	integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
	       															, Error_Description__c = 'Transmission Error ['+response.getStatusCode()+' ] '//+response.getHeader()+']'
	       															, Integration_Object__c = 'Account'
	       															, Integration_Point__c = 'IE'
	       															, Request_Data__c = JSON.serialize(ieAccountPut) ));
       				hasErrors = true;
		        }
	       }
       }
       catch(Exception e)
       {
       		//log the error
       		integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
   															, Error_Description__c = 'CALLOUT_EXCEPTION'
   															, Integration_Object__c = 'Account'
   															, Integration_Point__c = 'IE'
   															, Request_Data__c = e.getMessage() ));
       		hasErrors = true;
       }
       
       
       if(!hasErrors)
       {
	       //process the responses adding IE Ids and/or Logging Errors
	       if(ieAccountPostResponse.Organizations != null && ieAccountPostResponse.Organizations.size() > 0)
	       		processResponse(ieAccountPostResponse, hasErrors, accountMap, addressMap, integrationErrorList);
	       if(ieAccountPutResponse.Organizations != null && ieAccountPutResponse.Organizations.size() > 0)
	       		processResponse(ieAccountPutResponse, hasErrors, accountMap, addressMap, integrationErrorList);
	       
	       //update the records with the IE Keys
		   if (accountMap.size() > 0)
				update accountMap.values();

		   if (addressMap.size() > 0)
				update addressMap.values();
       }
	       
       if(integrationErrorList.size() > 0)
       		insert integrationErrorList;
	        
        
    }
    
    global void finish(Database.BatchableContext BC)
    {
		if(! this.hasErrors || Test.isRunningTest())
		{
			//call the next batch in the chain if there are no fatal errors
			Database.executeBatch(new Batch_Sync_IE_Individual('Pending'));
		}
    }
    
    global void processResponse(IE_IntegrationObjects.IE_OrganizationListResponse AccountList, boolean hasErrors,  
                                 map<Id, Account> accountMap, map<Id, Address__c> addressMap, list<Integration_Error__c> integrationErrorList)
    {
    	list<IE_IntegrationObjects.IE_Organization> Accounts = AccountList.Organizations;
       	//Parse the response for errors
       	// retrieve the IE IDs and update the base as well as the child objects if they are null
       	// update the status to Processed
       
       	//log errors
       	//update the status to Error
       	for(IE_IntegrationObjects.IE_Organization account : Accounts)
       	{ 
       		
       		
       		if(account.Errors != null && account.errors.size() >0)
       		{
       			accountMap.get(account.SFDCId).IE_Sync_Status__c = 'Error';
       			integrationErrorList.add(new Integration_Error__c(Direction__c 			= 'Outbound'
       															, Error_Description__c 	= String.ValueOf(account.errors)
       															, Integration_Object__c = 'Account'
       															, Integration_Object_Id__c = account.SFDCId
       															, Integration_Point__c  = 'IE'
       															, Request_Data__c 		= JSON.serialize(account) ));
       		}
       		else
       		{
       			accountMap.get(account.SFDCId).IE_Sync_Status__c = 'Processed';

				if (String.isNotEmpty(account.IEId))
       				accountMap.get(account.SFDCId).IE_Id__c = account.IEId;

				accountMap.get(account.SFDCId).IE_Account__c = true;  // set this to true in case it wasn't set earlier
       		}
       		
       		if(account.Address != null && addressMap.containsKey(account.Address.SFDCId))
            {
                
                if(account.Address.errors != null && account.Address.errors.size() > 0)
                {
                    if(addressMap.containsKey(account.Address.SFDCId))
                      addressMap.get(account.Address.SFDCId).IE_Sync_Status__c = 'Error';
                        
                    integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
                                                                    , Error_Description__c = String.ValueOf(account.Address.errors)
                                                                    , Integration_Object__c = 'Address'
                                                                    , Integration_Object_Id__c = account.Address.SFDCId
                                                                    , Integration_Point__c = 'IE'
                                                                    , Request_Data__c = JSON.serialize(account) ));
                }
            
                else
                {
                    if(addressMap.containsKey(account.Address.SFDCId))
                    {
                        addressMap.get(account.Address.SFDCId).IE_Sync_Status__c = 'Processed';

						if (String.isNotEmpty(account.Address.IEId))
							addressMap.get(account.Address.SFDCId).IE_Id__c = account.Address.IEId;

						addressMap.get(account.Address.SFDCId).IE_Address__c = true;  // set this to true in case it wasn't set earlier
                    }
                }
            }

       	}
    }
    

}