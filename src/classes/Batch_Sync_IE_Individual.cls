global class Batch_Sync_IE_Individual implements Database.Batchable<sObject>, Database.AllowsCallouts,  Database.Stateful{
    /**!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!**
     ** THIS IS INTENDED TO BE RUN IN BATCHES OF 10 ONLY **
     **!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!**/ 


    // static variables used in unit tests
    public static boolean crash_TestByResponseStatusCode = false;
    public static boolean crash_TestByException = false;

     
    global string processingStatus = 'Pending'; 
    global boolean hasErrors = false;
    public static Integer CONTACT_BATCH_SIZE = 10;


    map<Id, Contact> contactMap = new map<Id, Contact>();
    map<Id, Address__c> addressMap = new map<Id, Address__c>();
    list<Integration_Error__c> integrationErrorList = new list<Integration_Error__c>();
    

    global Batch_Sync_IE_Individual(string status)
    {
    	processingStatus = status;
    }

    
    global Database.querylocator start(Database.BatchableContext BC)
    { 
        //
        // Iterate over the objects of interest
        //
        /*
          
        */
        return Database.getQueryLocator([Select Id
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
												    //where Primary_Mail_To__c = true 
												      ) 
        									 //role data
        									 //,(Select Role__c, Master_Admin__c, Asset__c From Contact_Subscriptions__r)
        								  from Contact  
        								 where IE_Sync_Status__c = :processingStatus
        								   and IE_Contact__c = true]);
       
    }


    //Main execute method
    global void execute(Database.BatchableContext BC, List<SObject> contacts)
    {
    	TriggerUtility.limitIntegrationBatch = true;

      // Check if the number of contacts in the list is > CONTACT_BATCH_SIZE and break it up into multiple chunks and
      // call the ie service for each chunk to avoid any timeouts processing a large Request object.
      integer numOfContacts = contacts.size();
      if (numOfContacts > CONTACT_BATCH_SIZE) {
        integer loopCnt = numOfContacts/CONTACT_BATCH_SIZE;
        integer rem = Math.mod(numOfContacts, CONTACT_BATCH_SIZE);
        integer startIdx = 0;

        for (Integer i = 0; i < loopCnt; i++) {
          List<SObject> tempContactList = new list<SObject>();
          integer endIdx = startIdx + CONTACT_BATCH_SIZE;
          for (Integer j = startIdx; j < endIdx; j++) {
            tempContactList.add(contacts[j]);
          }
          // Process each chunk of contacts
          if (rem > 0)
            // There is a remaining chunk so we don't save result on this call
            processContacts(tempContactList, false);
          else if (i == loopCnt-1)
            // There is no remaining chunk and this is the final iteration of the loop so we want to save result on this final call
            processContacts(tempContactList, true);
          else
            // There is no remaining chunk and this is not the final iteration of the loop so we don't save result on this call
            processContacts(tempContactList, false);

          startIdx = startIdx + CONTACT_BATCH_SIZE;
        }
        if (rem > 0) {
          // Process the remaining chunk of contacts
          List<SObject> tempContactList = new list<SObject>();
          integer endIdx = startIdx + rem;
          for (Integer i = startIdx; i < endIdx; i++) {
            tempContactList.add(contacts[i]);
          }
          // This is the remaining chunk so we want to save result on this final call
          processContacts(tempContactList, true);
        }
      }
      else {
        // Only one chunk to process so we want to save result on this final call
        processContacts(contacts, true);
      }
    }
    

    global void finish(Database.BatchableContext BC)
    {
  		/*if(! this.hasErrors  || Test.isRunningTest())
  		{
  			//call the next batch in the chain if there are no fatal errors
  			Database.executeBatch(new Batch_Sync_IE_Subscription('Pending'));
  		}*/
    }


    global void processContacts(List<SObject> contacts, Boolean saveResults)
    {
      //populate the objects for integration
       IE_IntegrationObjects.IE_UserList IndividualsPost = new IE_IntegrationObjects.IE_UserList();
       IndividualsPost.Individuals = new list<IE_IntegrationObjects.IE_User>();
       IE_IntegrationObjects.IE_UserList IndividualsPut = new IE_IntegrationObjects.IE_UserList();
       IndividualsPut.Individuals = new list<IE_IntegrationObjects.IE_User>();
       
       //define the response objects
       IE_IntegrationObjects.IE_UserListResponse IndividualsPostResponse = new IE_IntegrationObjects.IE_UserListResponse();
       IE_IntegrationObjects.IE_UserListResponse IndividualsPutResponse = new IE_IntegrationObjects.IE_UserListResponse();
       
       
       //get the greater of the two - most recently modified contact_subscription record or the last modified date on the contact record
       map<Id, DateTime> maxSubscriptionDate = new map<Id, DateTime>();
       for(AggregateResult ar : [Select Contact__c, max(LastModifiedDate) dt from Contact_Subscription__c where Contact__c in :(List<Contact>)contacts group by Contact__c])
       {
          maxSubscriptionDate.put(String.ValueOf(ar.get('Contact__c')), (DateTime)ar.get('dt'));
       }

       for(SObject s : contacts)
       {
          Contact c = (Contact)s;
          Contact_Address__c[] caList = c.getSObjects('Contact_Addresses__r');
          IE_IntegrationObjects.IE_Address address = new IE_IntegrationObjects.IE_Address();
          if (caList != null)
          {
            //get the address data
          
              for(Contact_Address__c addr : caList)
              {
                address.AddressLine1 = addr.Address__r.Address_Line_1__c;
                address.AddressLine2 = addr.Address__r.Address_Line_2__c;
                address.AddressLine3 = addr.Address__r.Address_Line_3__c;
                address.AddressLine4 = addr.Address__r.Address_Line_4__c;
                address.City     = addr.Address__r.City__c;
                address.Country    = addr.Address__r.Country_ISO_Code__c;  
                address.StateCode    = addr.Address__r.State_Province_ISO_Code__c;
                address.ZipCode    = addr.Address__r.Postal_Code__c;
                address.SFDCId     = addr.Address__r.Id;
                address.IEId     = addr.Address__r.IE_ID__c;

				address.LastModifiedDate = Datetime.now(); // current date and time in the GMT time zone
                /*address.LastModifiedDate = DateTime.newInstance(addr.Address__r.LastModifiedDate.dateGmt()
                                         ,addr.Address__r.LastModifiedDate.timeGmt());*/

                addressMap.put(addr.Address__r.Id, addr.Address__r);
                break;
              }
          }

          
          //Contact_Subscription__c[] csList = c.getSObjects('Contact_Subscriptions__r');
          list<Contact_Subscription__c> csList = [Select Role__c, Master_Admin__c, Asset__c, GWotGoAsset__c, Asset__r.Name, Asset__r.IE_Asset__c From Contact_Subscription__c where Contact__c = :c.Id and Asset__r.Name != 'Dummy GWotGo Unit Asset' and Asset__r.Name != 'Holding GWotGo Unit Asset' and Asset__r.IE_Asset__c = true];
          System.debug('csList = ' + csList);
		  list<IE_IntegrationObjects.IE_Role> ieRoles = new list<IE_IntegrationObjects.IE_Role>();
          if (csList != null)
          {
            //get the Roles
          
            for(Contact_Subscription__c sub : csList)
            {
			  System.debug('sub = ' + sub);
              list<String> equipmentRoles = sub.Role__c.split(';');
			  System.debug('equipmentRoles = ' + equipmentRoles);
              for(String r : equipmentRoles)
              {
				System.debug('r = ' + r);
				// Only add the role if it is Administrator.
				// NOTE: The following roles will still be supported but will eventually be obsoleted {CustomerAdministrator,TechnicianAdministrator,Customer,Technician,EquipmentAdministrator}
				// IE service ignores the roles {SalesRep, Engineer, RenewalAdministrator}
				if (r.equalsIgnoreCase('Administrator') ||
					r.equalsIgnoreCase('CustomerAdministrator') || r.equalsIgnoreCase('Customer') ||
					r.equalsIgnoreCase('TechnicianAdministrator') || r.equalsIgnoreCase('Technician') ||
					r.equalsIgnoreCase('EquipmentAdministrator'))
				{
					IE_IntegrationObjects.IE_Role role = new IE_IntegrationObjects.IE_Role();
					role.Type      = r;

					if (sub.GWotGoAsset__c != null)
						role.UnitSFDCId = sub.GWotGoAsset__c;  // Here we set the SFDCId to the Id of the GWotGo asset
					else
						role.UnitSFDCId = sub.Asset__c;

					role.MasterAdmin = String.valueOf(sub.Master_Admin__c); 
					if(role.MasterAdmin == null) role.MasterAdmin = 'false';
					System.debug('Add to ieRoles');
					ieRoles.add(role);
				}
              }
            }
          }
          
          if (!ieRoles.isEmpty())
		  {
				// Contact contains 1 or more valid IE Roles, so go ahead and process this contact.

				//create the Individual and add it to the list
				DateTime maxDate = c.LastModifiedDate;
				if(maxSubscriptionDate.containsKey(c.Id))
				{
					if(maxSubscriptionDate.get(c.Id) > maxDate)
						maxDate = maxSubscriptionDate.get(c.Id);
				}
				IE_IntegrationObjects.IE_User ieUser = new IE_IntegrationObjects.IE_User();
				ieUser.FirstName  = c.FirstName;
				ieUser.MiddleName   = c.Middle_Name__c;
				ieUser.LastName   = c.LastName;
				ieUser.EmailAddress = c.email;
				ieUser.Roles    = ieRoles;
				ieUser.Address    = address;
				ieUser.CellPhone  = c.MobilePhone;
				ieUser.WorkPhone  = c.Phone;
				ieUser.SFDCId     = c.Id;
				ieUser.UserName   = c.IE_Username__c;
				ieUser.OrganizationSFDCId = c.AccountId;
				ieUser.IEId     = c.IE_ID__c;

				ieUser.LastModifiedDate = Datetime.now(); // current date and time in the GMT time zone
				/*ieUser.LastModifiedDate = DateTime.newInstance(maxDate.dateGmt()
									,maxDate.timeGmt());*/
          
				if(c.IE_ID__c == null)
					IndividualsPost.Individuals.add(ieUser);
				else
					IndividualsPut.Individuals.add(ieUser);
          }
		  else {
			// There are no ie roles so set the status to 'Processed' so its not 'Pending' anymore and if the IE Id is -1 then set to empty string
			c.IE_Sync_Status__c = 'Processed';
			if (c.IE_ID__c == '-1') c.IE_ID__c = '';
		  }

          //store the contact in the map to retrieve response status
          contactMap.put(c.Id, c);  
       }
       
       //
       // call the service - Determine PUT or POST
       //
       
       String jsonPostResponse = '';
       String jsonPutResponse = '';
       //Process the POST
       try{
         if(IndividualsPost.Individuals != null && IndividualsPost.Individuals.size() > 0)
         {
           System.debug('::::::INDIVIDUALS POST::::::'+JSON.serialize(IndividualsPost));
           
           HTTPResponse response = null;
           if (!Test.isRunningTest()) {
              // Test isn't running so call the service
              response = IE_IntegrationObjects.sendIeRequest(IE_Service_Configuration__c.getInstance().IndividualService__c
                                                                    , 'POST'
                                                                    , JSON.serialize(IndividualsPost));
           }
           else {
              // Test is running so mock a response
              response = new HTTPResponse();
              if (crash_TestByResponseStatusCode) {
                response.setStatusCode(999);
              }
              else {
                response.setStatusCode(200);
                response.setBody(JSON.serialize(IndividualsPost));
              }
           }
           
           if(response.getStatusCode() == 200)
            { 
                //iterate over the response checking for errors maybe we just return the body
                if(Test.isRunningTest())
                  jsonPostResponse = JSON.serialize(IndividualsPost);//for testing purposes since we can make a call-out
                else
                  jsonPostResponse = response.getBody();
                system.debug(':::: INDIVIDUALS jsonPostResponse:::::'+jsonPostResponse);
                IndividualsPostResponse = (IE_IntegrationObjects.IE_UserListResponse)JSON.deserialize(jsonPostResponse, IE_IntegrationObjects.IE_UserListResponse.class);
            }
            else{ 
              //log the error

              // Request_Data__c is a Long Text Area(131072) Field, make sure data added is not too large
              String reqData = JSON.serialize(IndividualsPost);
              if (reqData.length() > 131072) {
                reqData = reqData.substring(0, 131071);
              }

              integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound POST'
                                    , Error_Description__c = 'Transmission Error ['+response.getStatusCode()+']'
                                    , Integration_Object__c = 'Contact'
                                    , Integration_Point__c = 'IE'
                                    , Request_Data__c =  reqData));
              hasErrors = true;
            }
         }
       }
       catch(Exception e)
       {
          //log the error

          // Request_Data__c is a Long Text Area(131072) Field, make sure data added is not too large
          String reqData = JSON.serialize(IndividualsPost);
          if (reqData.length() > 131072) {
            reqData = reqData.substring(0, 131071);
          }

          integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound POST'
                                    , Error_Description__c = 'CALLOUT_EXCEPTION ' + e.getMessage()
                                    , Integration_Object__c = 'Contact'
                                    , Integration_Point__c = 'IE'
                                    , Request_Data__c = reqData ));
        hasErrors = true;
       }
       
       //Process the PUT ** Sales_Rep_Quota__c.Current_Quota__c = true **
       
       try{
         if(IndividualsPut.Individuals != null && IndividualsPut.Individuals.size() > 0)
         {
           System.debug(':::::INDIVIDUALS PUT:::::'+JSON.serialize(IndividualsPut));

           HTTPResponse response = null;
           if (!Test.isRunningTest()) {
              // Test isn't running so call the service
              response = IE_IntegrationObjects.sendIeRequest(IE_Service_Configuration__c.getInstance().IndividualService__c
                                                                    , 'PUT'
                                                                    , JSON.serialize(IndividualsPut));
           }
           else {
              // Test is running so mock a response
              response = new HTTPResponse();
              if (crash_TestByResponseStatusCode) {
                response.setStatusCode(999);
              }
              else {
                response.setStatusCode(200);
                response.setBody(JSON.serialize(IndividualsPut));
              }
           }
           
           if(response.getStatusCode() == 200)
            { 
                //iterate over the response checking for errors maybe we just return the body
                if(Test.isRunningTest())
                  jsonPutResponse = JSON.serialize(IndividualsPut);//for testing purposes since we can make a call-out
                else
                  jsonPutResponse = response.getBody();
                  
                system.debug(':::: INDIVIDUALS jsonPutResponse:::::'+jsonPutResponse);
                IndividualsPutResponse = (IE_IntegrationObjects.IE_UserListResponse)JSON.deserialize(jsonPutResponse, IE_IntegrationObjects.IE_UserListResponse.class);
            }
            else{ 
              //log the error

              // Request_Data__c is a Long Text Area(131072) Field, make sure data added is not too large
              String reqData = JSON.serialize(IndividualsPut);
              if (reqData.length() > 131072) {
                reqData = reqData.substring(0, 131071);
              }

              integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound PUT'
                                    , Error_Description__c = 'Transmission Error ['+response.getStatusCode()+' ] '//+response.getHeader()+']'
                                    , Integration_Object__c = 'Contact'
                                    , Integration_Point__c = 'IE'
                                    , Request_Data__c = reqData));
              hasErrors = true;
            }
         }
       }
       catch(Exception e)
       {
          //log the error

          // Request_Data__c is a Long Text Area(131072) Field, make sure data added is not too large
          String reqData = JSON.serialize(IndividualsPut);
          if (reqData.length() > 131072) {
            reqData = reqData.substring(0, 131071);
          }

          integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound PUT'
                                    , Error_Description__c = 'CALLOUT_EXCEPTION '+ e.getMessage()
                                    , Integration_Object__c = 'Contact'
                                    , Integration_Point__c = 'IE'
                                    , Request_Data__c =  reqData));
          hasErrors = true;
       }
       
       if(!hasErrors)
       {
         if(IndividualsPostResponse.Individuals != null && IndividualsPostResponse.Individuals.size() > 0)
            processResponse(IndividualsPostResponse);
         if(IndividualsPutResponse.Individuals != null && IndividualsPutResponse.Individuals.size() > 0)
            processResponse(IndividualsPutResponse);

          if (saveResults) {
            //update the records with the IE Keys
			if (contactMap.size() > 0)
				update contactMap.values();

            if (addressMap.size() > 0)
				update addressMap.values();
          }
       }
       
       if (saveResults && integrationErrorList.size() > 0)
          insert integrationErrorList;

    }
    

    global void processResponse(IE_IntegrationObjects.IE_UserListResponse Individuals)
    {
    	
       	//Parse the response for errors
       	// retrieve the IE IDs and update the base as well as the child objects if they are null
       	// update the status to Processed
       
       	//log errors
       	//update the status to Error
       	
       	TriggerUtility.limitIntegrationBatch = true;
       	for(IE_IntegrationObjects.IE_User individual : Individuals.Individuals)
       	{

       		if(Test.isRunningTest()) {
            //For testing purposes only
            individual.errors = new list<IE_IntegrationObjects.IE_Error>();
            IE_IntegrationObjects.IE_Error err = new IE_IntegrationObjects.IE_Error('error code', 'error msg');
            individual.errors.add(err);

            individual.Address.errors = new list<IE_IntegrationObjects.IE_Error>();
            individual.Address.errors.add(err);
          }
       		
       			
       		if(individual.errors != null && individual.errors.size() > 0 )
       		{
            // Request_Data__c is a Long Text Area(131072) Field, make sure data added is not too large
            String reqData = JSON.serialize(individual);
            if (reqData.length() > 131072) {
              reqData = reqData.substring(0, 131071);
            }

       			contactMap.get(individual.SFDCId).IE_Sync_Status__c = 'Error';
       			integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
       															, Error_Description__c = String.ValueOf(individual.errors)
       															, Integration_Object__c = 'Contact'
       															, Integration_Object_Id__c = individual.SFDCId
       															, Integration_Point__c = 'IE'
       															, Request_Data__c = reqData ));
       		}
       		else
       		{
       			contactMap.get(individual.SFDCId).IE_Sync_Status__c = 'Processed';

				if (String.isNotEmpty(individual.IEId))
       				contactMap.get(individual.SFDCId).IE_Id__c = individual.IEId;

				contactMap.get(individual.SFDCId).IE_Contact__c = true;  // set this to true in case it wasn't set earlier
       		}
       		
       		if(individual.Address != null && addressMap.containsKey(individual.Address.SFDCId))
       		{
       			if(individual.Address.errors != null && individual.Address.errors.size() > 0)
	       		{
              // Request_Data__c is a Long Text Area(131072) Field, make sure data added is not too large
              String reqData = JSON.serialize(individual);
              if (reqData.length() > 131072) {
                reqData = reqData.substring(0, 131071);
              }

	       			addressMap.get(individual.Address.SFDCId).IE_Sync_Status__c = 'Error';
	       			integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
	       															, Error_Description__c = String.ValueOf(individual.Address.errors)
	       															, Integration_Object__c = 'Address'
	       															, Integration_Object_Id__c = individual.Address.SFDCId
	       															, Integration_Point__c = 'IE'
	       															, Request_Data__c = reqData ));
	       		}
	       		else
	       		{
	       			if(addressMap.containsKey(individual.Address.SFDCId))
	       			{
       					addressMap.get(individual.Address.SFDCId).IE_Sync_Status__c = 'Processed';

						if (String.isNotEmpty(individual.Address.IEId))
							addressMap.get(individual.Address.SFDCId).IE_Id__c = individual.Address.IEId;

						addressMap.get(individual.Address.SFDCId).IE_Address__c = true;  // set this to true in case it wasn't set earlier
	       			}
	       		
	       		}
       		}
       	}
    }
    

}