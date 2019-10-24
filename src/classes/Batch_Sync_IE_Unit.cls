global class Batch_Sync_IE_Unit implements Database.Batchable<sObject>, Database.AllowsCallouts,  Database.Stateful{
    /**!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!**
     ** THIS IS INTENDED TO BE RUN IN BATCHES OF 10 ONLY **
     **!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!**/ 
    
	// static variables used in unit tests
    public static boolean crash_TestByResponseStatusCode = false;
    public static boolean crash_TestByException = false;


    global string processingStatus = 'Pending';
    global boolean hasErrors = false;
    global Date lastUpdatedDate = System.Today();
   
    global Batch_Sync_IE_Unit(string status)
    { 
        this.processingStatus = status;
    }
    
    global Batch_Sync_IE_Unit(string status, Date lastUpdated)
    {
        this.processingStatus = status;
        this.lastUpdatedDate = lastUpdated;
    }
    
    global Database.querylocator start(Database.BatchableContext BC)
    { 
        
        //
        // Iterate over the objects of interest
        //
        return Database.getQueryLocator([Select Id
                                              , SerialNumber
                                              , Tag__c
                                              , SO_Number__c
                                              , Job_Name__c
                                              , Device_ID__c
                                              , SIM_Card_ICCID__c
                                              , Format_Number__c
                                              //,   Code_String_Breakdown__c
                                              , Commissioned__c
                                              , IE_ID__c
                                              , IE_Updated_Date__c
                                              , Current_Code_String_Breakdown__c
                                              , Code_String_Breakdown__c
                                              , LastModifiedDate
                                             //address data
											  ,Asset_Address__c
                                              ,Asset_Address__r.Country__c
                                              ,Asset_Address__r.Postal_Code__c
                                              ,Asset_Address__r.State_Province__c
                                              ,Asset_Address__r.County__c
                                              ,Asset_Address__r.State_Province_ISO_Code__c
                                              ,Asset_Address__r.Country_ISO_Code__c
                                              ,Asset_Address__r.City__c
                                              ,Asset_Address__r.Address_Line_4__c 
                                              ,Asset_Address__r.Address_Line_3__c
                                              ,Asset_Address__r.Address_Line_2__c
                                              ,Asset_Address__r.Address_Line_1__c
                                              ,Asset_Address__r.Name
                                              ,Asset_Address__r.IE_ID__c
                                              ,Asset_Address__r.Id 
                                              //,Asset_Address__r.Building_Identifier__c
                                              ,Asset_Address__r.LastModifiedDate
                                             , (Select Id
                                                      , SerialNumber
                                                      , Tag__c
                                                      , SO_Number__c
                                                      , Job_Name__c
                                                      , Device_ID__c
                                                      , SIM_Card_ICCID__c
                                                      , Format_Number__c
                                                      , Commissioned__c
                                                      , IE_ID__c
                                                      , IE_Updated_Date__c
                                                      , LastModifiedDate
													  , Name
													  , GWotGo__c
                                                     //address data
                                                  From Assets__r
                                                 where Status != 'Obsolete'
                                                 )
                                          from Asset  
                                         where IE_Sync_Status__c = :processingStatus
                                           and IE_Asset__c = true
                                           and LastModifiedDate >=:lastUpdatedDate]);
       
    }

    //Main execute method
    global void execute(Database.BatchableContext BC, List<Asset> assets)
    {
       TriggerUtility.limitIntegrationBatch = true;
        
       //populate the objects for integration 
       IE_IntegrationObjects.IE_UnitList UnitsPost = new IE_IntegrationObjects.IE_UnitList ();
       UnitsPost.Units = new list<IE_IntegrationObjects.IE_Unit>();
       IE_IntegrationObjects.IE_UnitList UnitsPut = new IE_IntegrationObjects.IE_UnitList ();
       UnitsPut.Units = new list<IE_IntegrationObjects.IE_Unit>();
       
       IE_IntegrationObjects.IE_UnitListResponse UnitsPostResponse = new IE_IntegrationObjects.IE_UnitListResponse();
       IE_IntegrationObjects.IE_UnitListResponse UnitsPutResponse = new IE_IntegrationObjects.IE_UnitListResponse();
       
       map<Id, Asset> assetMap = new map<Id, Asset>();
       map<Id, Address__c> addressMap = new map<Id, Address__c>();
       list<Integration_Error__c> integrationErrorList = new list<Integration_Error__c>();

	   // Mapping structure for GWotGo to its unit asset
		map<Id, Id> GWotGo_unitAssetMap = new map<Id, Id>();
       
       for (Asset a : assets)
       {
			if (a.Asset_Address__c != null)
			{
				// Asset needs an address otherwise coherent sync will fail

				//get the address data
				IE_IntegrationObjects.IE_Address address = new IE_IntegrationObjects.IE_Address();
            
				address.AddressLine1 = a.Asset_Address__r.Address_Line_1__c;
				address.AddressLine2 = a.Asset_Address__r.Address_Line_2__c;
				address.AddressLine3 = a.Asset_Address__r.Address_Line_3__c;
				address.AddressLine4 = a.Asset_Address__r.Address_Line_4__c;
				address.City         = a.Asset_Address__r.City__c;
				address.Country      = a.Asset_Address__r.Country_ISO_Code__c;  
				address.StateCode    = a.Asset_Address__r.State_Province_ISO_Code__c;
				address.ZipCode      = a.Asset_Address__r.Postal_Code__c;
				address.SFDCId       = a.Asset_Address__r.Id;
				address.IEId         = a.Asset_Address__r.IE_ID__c;

				address.LastModifiedDate = Datetime.now(); // current date and time in the GMT time zone
				/*address.LastModifiedDate = DateTime.newInstance(a.Asset_Address__r.LastModifiedDate.dateGmt()
																,a.Asset_Address__r.LastModifiedDate.timeGmt());*/

				addressMap.put(a.Asset_Address__r.Id, a.Asset_Address__r);
             
            
				//create the Individual and add it to the list
				IE_IntegrationObjects.IE_Unit ieUnit = new IE_IntegrationObjects.IE_Unit();
				ieUnit.UnitAddress      =   address;
				ieUnit.SerialNumber     =   a.SerialNumber;
				ieUnit.UnitTag          =   a.Tag__c;
				ieUnit.SalesOrderNumber =   a.SO_Number__c;
				ieUnit.JobName          =   a.Job_Name__c;
				ieUnit.MACAddress       =   a.Device_ID__c;
				ieUnit.SIMCardICCID     =   a.SIM_Card_ICCID__c;
				ieUnit.CodeStringFormat =   a.Format_Number__c;
            
				//add the code string values
				string codeStringBreakDown = '';
            
				if(a.Current_Code_String_Breakdown__c != null) 
					codeStringBreakDown = a.Current_Code_String_Breakdown__c;
				else  
					codeStringBreakDown = a.Code_String_Breakdown__c;
            
				ieUnit.CodeValues = getCodeStringValues(codeStringBreakDown);
            
				ieUnit.Commissioned     =   a.Commissioned__c;  // Initialize this to the Commissioned field on the Unit Asset
				ieUnit.IEId             =   a.IE_ID__c;
				ieUnit.SFDCId           =   a.Id;  // Initialize this to the Unit Asset Id

				ieUnit.LastModifiedDate = Datetime.now(); // current date and time in the GMT time zone
				/*ieUnit.LastModifiedDate = DateTime.newInstance(a.LastModifiedDate.dateGmt()
															  ,a.LastModifiedDate.timeGmt());*/

				if (a.Assets__r != null && a.Assets__r.size() > 0)
				{
					for(Asset ax : a.Assets__r)
					{
						if(ax.Device_ID__c != null)
							ieUnit.MACAddress = ax.Device_ID__c;
						if(ax.SIM_Card_ICCID__c != null)
							ieUnit.SIMCardICCID = ax.SIM_Card_ICCID__c;

						if (ax.Name == 'Gateway On the Go' && ax.GWotGo__c == true)
						{
							ieUnit.SFDCId = ax.Id; // Here we change the SFDCId value to the Id of the GWotGo asset
							ieUnit.Commissioned = ax.Commissioned__c; // Here we change the Commissioned value to the Commissioned__c value of the GWotGo asset
							GWotGo_unitAssetMap.put(ax.Id, a.Id);
						}
					}
				}

				if(a.IE_ID__c == null)
					UnitsPost.Units.add(ieUnit);
				else
					UnitsPut.Units.add(ieUnit);

				//store the contact in the map to retrieve response status
				assetMap.put(a.Id, a);
			}
			else 
			{
				// Log that this asset is missing its address
				integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
                                         , Error_Description__c = 'Missing address information for asset ' + a.SerialNumber
                                         , Integration_Object__c = 'Asset'
                                         , Integration_Point__c = 'IE'
                                         , Request_Data__c = 'Cannot by synced with Coherent until address is provided' ));
			}
       }
       
       //
       // call the service - Determine PUT or POST
       //
       
       String jsonPostResponse = '';
       String jsonPutResponse = '';
       //Process the POST
       try{
           if(UnitsPost.Units != null && UnitsPost.Units.size() > 0)
           {
               IE_IntegrationObjects.IE_UnitList  Units = UnitsPost;
               System.debug('::::::> Post UNITS <::::::'+JSON.serialize(Units));
               HTTPResponse response = IE_IntegrationObjects.sendIeRequest(IE_Service_Configuration__c.getInstance().UnitService__c
                                                                         , 'POST'
                                                                         , JSON.serialize(Units));
				
			  if (crash_TestByResponseStatusCode) {
					// Crash Test is running so mock a bad response code
					response.setStatusCode(999);
              }

               if(response.getStatusCode() == 200)
                { 
                    //iterate over the response checking for errors maybe we just return the body
                    if(Test.isRunningTest())
                        jsonPostResponse = JSON.serialize(Units); //for testing purposes since we can't make a call-out
                    else
                        jsonPostResponse = response.getBody();
                    
                    System.debug('::::::> UNITS Post RESPONSE <::::::'+jsonPostResponse);
                    UnitsPostResponse = (IE_IntegrationObjects.IE_UnitListResponse )JSON.deserialize(jsonPostResponse, IE_IntegrationObjects.IE_UnitListResponse.class);
					System.Debug('::::Deserialized UnitsPostResponse::::'+UnitsPostResponse);
                }
                else{ 
                    //log the error
                    integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
                                                                , Error_Description__c = 'Transmission Error ['+response.getStatusCode()+']'
                                                                , Integration_Object__c = 'Asset'
                                                                , Integration_Point__c = 'IE'
                                                                , Request_Data__c = JSON.serialize(UnitsPost) ));
                    hasErrors = true;
                }
           }
       }
       catch(Exception e)
       {
            //log the error
            integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
                                                                , Error_Description__c = 'CALLOUT_EXCEPTION'
                                                                , Integration_Object__c = 'Asset'
                                                                , Integration_Point__c = 'IE'
                                                                , Request_Data__c = e.getMessage() ));
            hasErrors = true;
       }
       
       //Process the PUT
       try{
           if(UnitsPut.Units != null && UnitsPut.Units.size() > 0)
           {
               IE_IntegrationObjects.IE_UnitList  Units = UnitsPut;
               System.debug('::::::: Put UNITS::::: '+JSON.serialize(Units));
               HTTPResponse response = IE_IntegrationObjects.sendIeRequest(IE_Service_Configuration__c.getInstance().UnitService__c
                                                                         , 'PUT'
                                                                         , JSON.serialize(Units));
               System.debug('::::::: Put Response body>>>>::::: '+ response.getBody());

			   if (crash_TestByResponseStatusCode) {
					// Crash Test is running so mock a bad response code
					response.setStatusCode(999);
               }

               if(response.getStatusCode() == 200)
                { 
                    //iterate over the response checking for errors maybe we just return the body
                    if(Test.isRunningTest())
                        jsonPutResponse = JSON.serialize(Units); //for testing purposes since we can't make a call-out
                    else
                        jsonPutResponse = response.getBody();
                        
					System.debug('::::::> UNITS Put RESPONSE <::::::'+jsonPutResponse);
                    UnitsPutResponse = (IE_IntegrationObjects.IE_UnitListResponse )JSON.deserialize(jsonPutResponse, IE_IntegrationObjects.IE_UnitListResponse.class);
                    System.Debug('::::Deserialized UnitsPutResponse::::'+UnitsPutResponse);
                }
                else{ 
                    //log the error
                    integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
                                                                , Error_Description__c = 'Transmission Error ['+response.getStatusCode()+']'
                                                                , Integration_Object__c = 'Asset'
                                                                , Integration_Point__c = 'IE'
                                                                , Request_Data__c = JSON.serialize(UnitsPut) ));
                    hasErrors = true;
                }
           }
       }
       catch(Exception e)
       {
            //log the error
            System.debug(':::::::::>CALLOUT EXCEPTION:::::::'+ e);
            integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
                                                                , Error_Description__c = 'CALLOUT_EXCEPTION'
                                                                , Integration_Object__c = 'Asset'
                                                                , Integration_Point__c = 'IE'
                                                                , Request_Data__c = e.getMessage() ));
            hasErrors = true;
       }
       
       if(!hasErrors)
       {
           if(UnitsPostResponse.Units != null && UnitsPostResponse.Units.size() > 0)
                processResponse(UnitsPostResponse, hasErrors, assetMap, addressMap, GWotGo_unitAssetMap, integrationErrorList);
           if(UnitsPutResponse.Units != null && UnitsPutResponse.Units.size() > 0)
                processResponse(UnitsPutResponse, hasErrors, assetMap, addressMap, GWotGo_unitAssetMap, integrationErrorList);
           
           //update the records with the IE Keys
		   if (assetMap.size() > 0)
				update assetMap.values();

           if (addressMap.size() > 0)
                update addressMap.values();
       }
           
       if (integrationErrorList.size() > 0)
            insert integrationErrorList;
        
        
    }
    
    global void finish(Database.BatchableContext BC)
    {
        if(! this.hasErrors || Test.isRunningTest())
        {
            //call the next batch in the chain if there are no fatal errors
            Database.executeBatch(new Batch_Sync_IE_Organization('Pending'));
        }
    }
    
    global void processResponse(IE_IntegrationObjects.IE_UnitListResponse  Units, boolean hasErrors, 
		map<Id, Asset> assetMap, map<Id, Address__c> addressMap, map<Id, Id> GWotGo_unitAssetMap, list<Integration_Error__c> integrationErrorList)
    {
        
        //Parse the response for errors
        // retrieve the IE IDs and update the base as well as the child objects if they are null
        // update the status to Processed
       
        //log errors
        //update the status to Error
        for(IE_IntegrationObjects.IE_Unit unit : Units.Units)
        {
            if(unit.errors != null && unit.errors.size() > 0)
            {
                if (assetMap.containsKey(unit.SFDCId))
					// unit.SFDCId is a unit asset
					assetMap.get(unit.SFDCId).IE_Sync_Status__c = 'Error';
				else
					// unit.SFDCId is a GWotGo so get its unit asset from its map first
					assetMap.get(GWotGo_unitAssetMap.get(unit.SFDCId)).IE_Sync_Status__c = 'Error';

                integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
                                                                , Error_Description__c = String.ValueOf(unit.errors)
                                                                , Integration_Object__c = 'Asset'
                                                                , Integration_Object_Id__c = unit.SFDCId
                                                                , Integration_Point__c = 'IE'
                                                                , Request_Data__c = JSON.serialize(unit) ));
            }
            else
            {
                if (assetMap.containsKey(unit.SFDCId)) {
					// unit.SFDCId is a unit asset
					assetMap.get(unit.SFDCId).IE_Sync_Status__c = 'Processed';

					if (String.isNotEmpty(unit.IEId))
						assetMap.get(unit.SFDCId).IE_Id__c = unit.IEId;
				}
				else {
					// unit.SFDCId is a GWotGo so get its unit asset from its map first
					assetMap.get(GWotGo_unitAssetMap.get(unit.SFDCId)).IE_Sync_Status__c = 'Processed';

					if (String.isNotEmpty(unit.IEId))
						assetMap.get(GWotGo_unitAssetMap.get(unit.SFDCId)).IE_Id__c = unit.IEId;
				}
            }
            
            if(unit.UnitAddress != null && addressMap.containsKey(unit.UnitAddress.SFDCId))
            {
                
                if(unit.UnitAddress.errors != null && unit.UnitAddress.errors.size() > 0)
                {
                    if(addressMap.containsKey(unit.UnitAddress.SFDCId))
                      addressMap.get(unit.UnitAddress.SFDCId).IE_Sync_Status__c = 'Error';
                        
                    integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
                                                                    , Error_Description__c = String.ValueOf(unit.UnitAddress.errors)
                                                                    , Integration_Object__c = 'Address'
                                                                    , Integration_Object_Id__c = unit.UnitAddress.SFDCId
                                                                    , Integration_Point__c = 'IE'
                                                                    , Request_Data__c = JSON.serialize(unit) ));
                }
            
                else
                {
                    if(addressMap.containsKey(unit.UnitAddress.SFDCId))
                    {
                        addressMap.get(unit.UnitAddress.SFDCId).IE_Sync_Status__c = 'Processed';

						if (String.isNotEmpty(unit.UnitAddress.IEId))
							addressMap.get(unit.UnitAddress.SFDCId).IE_Id__c = unit.UnitAddress.IEId;

						addressMap.get(unit.UnitAddress.SFDCId).IE_Address__c = true;  // set this to true in case it wasn't set earlier
                    }
                }
            }
            
                
        }
    }
    
    public static list<String> getCodeStringValues(string codeString)
    {
        
        list<String> codeStringValues = new list<String>();
        try{
            JSONParser parser = JSON.createParser(codeString);
            string label = '';
            string value = '';
            while (parser.nextToken() != null) {
            // Start at the array of invoices.
                if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                    while (parser.nextToken() != null) {
                        // Advance to the start object marker to
                        //  find next invoice statement object.
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                            // Read entire invoice object, including its array of line items.
                             CodeStringViewerController.CodeStringRec codeRec 
                                = (CodeStringViewerController.CodeStringRec)parser.readValueAs(CodeStringViewerController.CodeStringRec.class);
                             System.Debug(':::>'+codeRec);
                             codeStringValues.add(codeRec.code_value);
                        }
                    }
                }
            }
        }
        catch(Exception e)
        {
            System.Debug('ERROR: '+e);
        }
        
        return codeStringValues;
    }
    

}