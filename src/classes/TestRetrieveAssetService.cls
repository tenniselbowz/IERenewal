@isTest
private class TestRetrieveAssetService {

    static testmethod void testUnitSN()
    {
        //!!!!!!!!!!! Need to add this code snippet for AvaTax- AccountAddressTrigger to run successfully on Before Insert into the Account table !!!!!!!!!!!!!!!!!
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;
        

		// Create a Product for the Parent Asset
		Product2 prodTemp2 = null;
        prodTemp2 = new Product2();
        prodTemp2.Name = 'Test Prod2';
        prodTemp2.Vendor_Supplier__c = 'Test Vendor2';
        prodTemp2.IsActive = true;
        prodTemp2.Description = 'Test Description2';
        prodTemp2.DW_PCL_Description__c = 'Test DW PCL Description2';
        prodTemp2.Apttus_Product__c = true;
        prodTemp2.Product_Category__c = 'Test Category2';
        prodTemp2.ProductCode = 'RPS015A';
        insert prodTemp2;


        // Create an account for the assets
        Account acct = new Account(Name = 'Test');
        insert acct;
        

        // Create Parent Asset
        Asset parentAsset = new Asset(Name = 'test',
                             AccountId = acct.Id,
                             SerialNumber='123Test',
							 Product2Id = prodTemp2.Id
                             );
		parentAsset.Code_String_Breakdown__c = '[{"code_sequence":"1","code_value":"MPS","code_description":"UNIT TYPE; Unit Type"},{"code_sequence":"2","code_value":"003B","code_description":"UNIT SIZE; 3 ton, R410A"},{"code_sequence":"3","code_value":"Y","code_description":"HEAT; None"},{"code_sequence":"4","code_value":"D","code_description":"VOLTAGE/POWER CONNECTION; 460 V power"},{"code_sequence":"5","code_value":"M","code_description":"DRIVE PACKAGE; Belt drive - high static"},{"code_sequence":"6","code_value":"00D","code_description":"HEATING CAPACITY/CONTROLS; DDC controls"},{"code_sequence":"7","code_value":"CZ","code_description":"OPTIONS; HP,LP,LowAmb/Comfort Aler,FldPower GFI, Hail Guard"},{"code_sequence":"8","code_value":"D","code_description":"ECONOMIZER; Field Mounted 0-30% Outside air hood"}]';
        insert parentAsset;
        

        // Create Product2, and Related Asset
        Product2 prodTemp1 = null;
        prodTemp1 = new Product2();
        prodTemp1.Name = 'Intelligent Equipment Gateway';
		prodTemp1.ProductCode = 'IEGATE1';
        prodTemp1.Vendor_Supplier__c = 'Test Vendor1';
        prodTemp1.IsActive = true;
        prodTemp1.Description = 'Test Description1';
        prodTemp1.DW_PCL_Description__c = 'Test DW PCL Description1';
        prodTemp1.Apttus_Product__c = true;
        prodTemp1.Product_Category__c = 'Test Category1';
        insert prodTemp1;

        Asset relatedAsset = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acct.Id, SerialNumber = 'PO112711-2-075', Parent_Asset__c = parentAsset.Id);
        relatedAsset.Product2Id = prodTemp1.Id;
        relatedAsset.SIM_Card_Active__c = true;
        insert relatedAsset;


        // Create Contact, Subscription and Contact_Subscription
        Datetime currDateTime = Datetime.now();
        Contact contactTemp1 = new Contact();
        RecordType recordTypeTemp = [SELECT Id FROM RecordType WHERE Name='Daikin Applied' AND SObjectType='Contact'];
        contactTemp1.Eprise_Login_ID__c = 'RoesslKS1';
        contactTemp1.RecordTypeId = recordTypeTemp.Id;
        contactTemp1.AccountId = acct.Id;
        contactTemp1.Status__c = 'Active';
        contactTemp1.Email = 'kent.roessler@daikinapplied.com';
        contactTemp1.FirstName = 'Kent1';
        contactTemp1.LastName = 'Roessler1';
		contactTemp1.IE_Sync_Status__c = 'Processed'; 
        contactTemp1.IE_Contact__c = true;
		TriggerUtility.limitIntegrationBatch = true; // set this to true so contact trigger handler doesn't set status to Pending
        insert contactTemp1;
		TriggerUtility.limitIntegrationBatch = false; // reset back to false

        Subscription__c subTemp1 = new Subscription__c();
        subTemp1.Start_Date__c = currDateTime;
        subTemp1.End_Date__c = currDateTime.addMonths(12);
        subTemp1.Type__c = 'TechReadWrite';
        subTemp1.Active__c = true;
        subTemp1.Asset__c = parentAsset.Id;
        subTemp1.Buyer_ID__c = acct.Id;
        subTemp1.Renewal_Counter__c = 0;
        subTemp1.Connectivity_Type__c = 'Cellular';
        subTemp1.Renewal_Notice_Current_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month__c = false;
        subTemp1.Renewal_Notice_Last_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp1.Renewal_Notice_Last_Month_Minus_1__c = false;
        insert subTemp1;
        
        Contact_Subscription__c contSubTemp1 = new Contact_Subscription__c();
        contSubTemp1.Role__c = 'RenewalAdministrator';
        contSubTemp1.Contact__c = contactTemp1.Id;
        contSubTemp1.Subscription__c = subTemp1.Id;
        contSubTemp1.Asset__c = parentAsset.Id;
        insert contSubTemp1;


        //call the service
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        req.requestURI = 'https://cs8.salesforce.com/services/apexrest/RetrieveAsset?SerialNumber=123Test';  
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        RestContext.request.params.put('SerialNumber','123Test');
        RetrieveAssetService.ServiceAsset results = RetrieveAssetService.getAsset();
        System.debug(':::::results:::::'+results);
        
        //assert the results
        System.assertEquals('123Test',results.SerialNumber);

    }


	static testmethod void testGatewaySN()
    {
        //!!!!!!!!!!! Need to add this code snippet for AvaTax- AccountAddressTrigger to run successfully on Before Insert into the Account table !!!!!!!!!!!!!!!!!
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;
        

		// Create a Product for the Parent Asset
		Product2 prodTemp2 = null;
        prodTemp2 = new Product2();
        prodTemp2.Name = 'Test Prod2';
        prodTemp2.Vendor_Supplier__c = 'Test Vendor2';
        prodTemp2.IsActive = true;
        prodTemp2.Description = 'Test Description2';
        prodTemp2.DW_PCL_Description__c = 'Test DW PCL Description2';
        prodTemp2.Apttus_Product__c = true;
        prodTemp2.Product_Category__c = 'Test Category2';
        prodTemp2.ProductCode = 'RPS015A';
        insert prodTemp2;


        // Create an account for the assets
        Account acct = new Account(Name = 'Test');
        insert acct;
        

        // Create Parent Asset
        Asset parentAsset = new Asset(Name = 'test',
                             AccountId = acct.Id,
                             SerialNumber='123Test',
							 Product2Id = prodTemp2.Id,
							 GWotGo__c = false
                             );
        insert parentAsset;
        

        // Create Product2, and Related Asset
        Product2 prodTemp1 = null;
        prodTemp1 = new Product2();
        prodTemp1.Name = 'Intelligent Equipment Gateway';
		prodTemp1.ProductCode = 'IEGATE1';
        prodTemp1.Vendor_Supplier__c = 'Test Vendor1';
        prodTemp1.IsActive = true;
        prodTemp1.Description = 'Test Description1';
        prodTemp1.DW_PCL_Description__c = 'Test DW PCL Description1';
        prodTemp1.Apttus_Product__c = true;
        prodTemp1.Product_Category__c = 'Test Category1';
        insert prodTemp1;

        Asset relatedAsset = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acct.Id, SerialNumber = 'PO112711-2-075', Parent_Asset__c = parentAsset.Id);
        relatedAsset.Product2Id = prodTemp1.Id;
		relatedAsset.GWotGo__c = true;
		relatedAsset.Commissioned__c = true;
        relatedAsset.SIM_Card_Active__c = true;
		relatedAsset.SIM_Card_ICCID__c = '89011704258018735310';
		relatedAsset.MAC_Address__c = '00600c82c7c8';
        insert relatedAsset;


        // Create Contact, Subscription and Contact_Subscription
        Datetime currDateTime = Datetime.now();
        Contact contactTemp1 = new Contact();
        RecordType recordTypeTemp = [SELECT Id FROM RecordType WHERE Name='Daikin Applied' AND SObjectType='Contact'];
        contactTemp1.Eprise_Login_ID__c = 'RoesslKS1';
        contactTemp1.RecordTypeId = recordTypeTemp.Id;
        contactTemp1.AccountId = acct.Id;
        contactTemp1.Status__c = 'Active';
        contactTemp1.Email = 'kent.roessler@daikinapplied.com';
        contactTemp1.FirstName = 'Kent1';
        contactTemp1.LastName = 'Roessler1';
        insert contactTemp1;

        Subscription__c subTemp1 = new Subscription__c();
		subTemp1.GWotGoAsset__c = relatedAsset.Id;
        subTemp1.Start_Date__c = currDateTime;
        subTemp1.End_Date__c = currDateTime.addMonths(12);
        subTemp1.Type__c = 'TechReadWrite';
        subTemp1.Active__c = true;
        subTemp1.Asset__c = parentAsset.Id;
        subTemp1.Buyer_ID__c = acct.Id;
        subTemp1.Renewal_Counter__c = 0;
        subTemp1.Connectivity_Type__c = 'Cellular';
        subTemp1.Renewal_Notice_Current_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month__c = false;
        subTemp1.Renewal_Notice_Last_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp1.Renewal_Notice_Last_Month_Minus_1__c = false;
        insert subTemp1;
        
        Contact_Subscription__c contSubTemp1 = new Contact_Subscription__c();
        contSubTemp1.Role__c = 'RenewalAdministrator';
        contSubTemp1.Contact__c = contactTemp1.Id;
        contSubTemp1.Subscription__c = subTemp1.Id;
        contSubTemp1.Asset__c = parentAsset.Id;
		contSubTemp1.GWotGoAsset__c = relatedAsset.Id;
		contSubTemp1.GWotGoPermAssoc__c = true;
        insert contSubTemp1;


        //call the service
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        req.requestURI = 'https://cs8.salesforce.com/services/apexrest/RetrieveAsset?SerialNumber=PO112711-2-075';  
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        RestContext.request.params.put('SerialNumber','PO112711-2-075');
        RetrieveAssetService.ServiceAsset results = RetrieveAssetService.getAsset();
        System.debug(':::::results:::::'+results);
        
        //assert the results
        System.assertEquals('PO112711-2-075',results.SerialNumber);

    }


	static testmethod void testSupportedModels()
    {
        //call the isIESupportedModel() method with different models

        boolean results = RetrieveAssetService.isIESupportedModel('AGZ055D');
        
        //assert the results
        System.assertEquals(true, results);


		results = RetrieveAssetService.isIESupportedModel('AGZ190E');
		System.assertEquals(true, results);

		results = RetrieveAssetService.isIESupportedModel('WMC048DD');
		System.assertEquals(true, results);

		results = RetrieveAssetService.isIESupportedModel('WME0700SS');
		System.assertEquals(true, results);

		results = RetrieveAssetService.isIESupportedModel('WME1000DB');
		System.assertEquals(true, results);

		results = RetrieveAssetService.isIESupportedModel('WME092ADC');
		System.assertEquals(false, results);
    }
}