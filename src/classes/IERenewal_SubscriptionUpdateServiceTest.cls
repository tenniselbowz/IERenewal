@isTest
private class IERenewal_SubscriptionUpdateServiceTest {
    
    @isTest static void testPut_SubscriptionNotFound() {
        IERenewal_SubscriptionUpdateService.RenewalOrderRequest testRequest = new IERenewal_SubscriptionUpdateService.RenewalOrderRequest();
        testRequest.orderTypeId = 'Domestic';
        testRequest.assetUnits = new List<IERenewal_SubscriptionUpdateService.Asset_Unit>();
        IERenewal_SubscriptionUpdateService.Asset_Unit assetUnit1 = new IERenewal_SubscriptionUpdateService.Asset_Unit();
        assetUnit1.serialNumber = 'testSN123';
        assetUnit1.subscriptionInfoList = null;
        testRequest.assetUnits.add(assetUnit1);


        RestContext.request = new System.RestRequest();
        RestContext.request.requestBody = Blob.valueOf( JSON.serialize(testRequest) );

        Test.startTest();

            RestContext.response = new System.RestResponse();
            IERenewal_SubscriptionUpdateService.doPut();

        Test.stopTest();

        IERenewal_SubscriptionUpdateService.RenewalOrderResponse theResponse = (IERenewal_SubscriptionUpdateService.RenewalOrderResponse)JSON.deserialize( RestContext.response.responseBody.toString(), IERenewal_SubscriptionUpdateService.RenewalOrderResponse.class );
        System.assertEquals( 1, theResponse.Statuses[0].Errors.size(), 'There should be an Error returned if an invalid Serial Number is given for the Subscription' );
    }


	@isTest static void testPut_GWotGo() {
        // ----------------Setup Test Data in Salesforce objects:

        //!!!!!!!!!!! Need to add this code snippet for AvaTax- AccountAddressTrigger to run successfully on Before Insert into the Account table !!!!!!!!!!!!!!!!!
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c();
        ts1.AVA_SFCORE__Active_Setting__c = true;
        ts1.Name='Test Account';
        insert ts1;

		// Set these static control variables to True to avoid trigger code execution
		TriggerUtility.limitIntegrationBatch = true;
		TriggerUtility.limitContactExecution = true;

        // Create Address__c, Account, Account_Address__c records
        Account acctTemp = null;
        Address__c addrTemp = null;
        Account_Address__c acctAddrJunctionObj = null;
        
        addrTemp = new Address__c();
        addrTemp.Address_Line_1__c = 'Test Address Line 1';
        addrTemp.City__c = 'Minneapolis';
        addrTemp.Postal_Code__c = '55421';
        addrTemp.Country__c = 'United States';
        addrTemp.State_Province__c = 'Minnesota';
        insert addrTemp;
        
        acctTemp = new Account();
        acctTemp.Name = 'Account Test1';
        acctTemp.Type = 'Developer';
        acctTemp.Physical_Address__c = addrTemp.Id;
        acctTemp.IE_Account__c = true;
        acctTemp.Record_Usage__c = 'IE';
        insert acctTemp;
        
        acctAddrJunctionObj = new Account_Address__c();
        acctAddrJunctionObj.Account__c = acctTemp.Id;
        acctAddrJunctionObj.Address__c = addrTemp.Id;
        acctAddrJunctionObj.Active__c = true;
        acctAddrJunctionObj.Physical__c = true;
        insert acctAddrJunctionObj;


        // Create Order__c and Product2 records
        Order__c orderTemp1 = null;
        orderTemp1 = new Order__c();
        orderTemp1.Job_Name__c = 'Test Order Job Name 1';
        orderTemp1.Order_Type_ID__c = 'Domestic';
        insert orderTemp1;

        Product2 prodTemp1 = null;
        prodTemp1 = new Product2();
        prodTemp1.Name = 'Test Prod1';
        prodTemp1.Vendor_Supplier__c = 'Test Vendor1';
        prodTemp1.IsActive = true;
        prodTemp1.Description = 'Test Description1';
        prodTemp1.DW_PCL_Description__c = 'Test DW PCL Description1';
        prodTemp1.Apttus_Product__c = true;
        prodTemp1.Product_Category__c = 'Test Category1';
        prodTemp1.ProductCode = 'DPS015A';
        insert prodTemp1;

        Product2 prodTemp3 = null;
        prodTemp3 = new Product2();
        prodTemp3.Name = 'Intelligent Equipment Gateway';
        prodTemp3.Vendor_Supplier__c = 'Test Vendor3';
        prodTemp3.IsActive = true;
        prodTemp3.Description = 'IE Gateway';
        prodTemp3.DW_PCL_Description__c = 'Test DW PCL Description3';
        prodTemp3.Apttus_Product__c = true;
        prodTemp3.Product_Category__c = 'Test Category3';
        insert prodTemp3;


		// Create Parent Asset record
        Asset parentAsset1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test_1', Tag__c='Order Tag 1');
        parentAsset1.Product2Id = prodTemp1.Id;
        parentAsset1.Order__c = orderTemp1.Id;
        parentAsset1.IE_Asset__c = true;
        insert parentAsset1;

		// Create Related Asset Records for Parent Asset
        Asset relatedAsset1 = new Asset(Name = 'Gateway On the Go', AccountId = acctTemp.Id, SerialNumber = 'PO112711-Z-XXX', Parent_Asset__c = parentAsset1.Id);
        relatedAsset1.Product2Id = prodTemp3.Id;
		relatedAsset1.GWotGo__c = true;
        relatedAsset1.SIM_Card_Active__c = true;
        relatedAsset1.SIM_Card_ICCID__c = '89011704258018735310';
        insert relatedAsset1;


		// Create Contacts, Subscription pair and Contact_Subscription records
        Datetime currDateTime = Datetime.now();
        Date currentDate = Date.today();
        RecordType recordTypeTemp = [SELECT Id FROM RecordType WHERE Name='Daikin Applied' AND SObjectType='Contact'];

		Contact contactTemp1 = new Contact();
        contactTemp1.Eprise_Login_ID__c = 'RoesslKS1';
        contactTemp1.RecordTypeId = recordTypeTemp.Id;
        contactTemp1.AccountId = acctTemp.Id;
        contactTemp1.Status__c = 'Active';
        contactTemp1.Email = 'kent.roessler@daikinapplied.com';
        contactTemp1.FirstName = 'Kent1';
        contactTemp1.LastName = 'Roessler1';
        contactTemp1.IE_Contact__c = true;
        contactTemp1.IE_Username__c = 'kent.roessler@daikinapplied.com';
        contactTemp1.Record_Usage__c = 'IE';
        insert contactTemp1;

		Subscription__c subTemp1 = new Subscription__c();
        subTemp1.IE_Subscription__c = true;
        subTemp1.Start_Date__c = currDateTime;
        subTemp1.End_Date__c = currDateTime.addMonths(12);
        subTemp1.Type__c = 'TechReadWrite';
        subTemp1.Active__c = true;
        subTemp1.Asset__c = parentAsset1.Id;
        subTemp1.Buyer_ID__c = acctTemp.Id;
        subTemp1.Renewal_Counter__c = 0;
        subTemp1.Last_Renewal_Date__c = null;
        subTemp1.Renewal_Date__c = null;
        subTemp1.Connectivity_Type__c = 'Cellular';
        subTemp1.Term_Years__c = 1.0;
        subTemp1.Renewal_Notice_Current_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month__c = false;
        subTemp1.Renewal_Notice_Last_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp1.Renewal_Notice_Last_Month_Minus_1__c = false;
		subTemp1.GWotGoAsset__c = relatedAsset1.Id;
        insert subTemp1;

        Subscription__c subTemp2 = new Subscription__c();
        subTemp2.IE_Subscription__c = true;
        subTemp2.Start_Date__c = currDateTime;
        subTemp2.End_Date__c = currDateTime.addMonths(12);
        subTemp2.Type__c = 'CustomRead';
        subTemp2.Active__c = true;
        subTemp2.Asset__c = parentAsset1.Id;
        subTemp2.Buyer_ID__c = acctTemp.Id;
        subTemp2.Renewal_Counter__c = 0;
        subTemp2.Last_Renewal_Date__c = null;
        subTemp2.Renewal_Date__c = null;
        subTemp2.Connectivity_Type__c = 'Cellular';
        subTemp2.Term_Years__c = 1.0;
        subTemp2.Renewal_Notice_Current_Month__c = false;
        subTemp2.Renewal_Notice_Next_Month__c = false;
        subTemp2.Renewal_Notice_Last_Month__c = false;
        subTemp2.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp2.Renewal_Notice_Last_Month_Minus_1__c = false;
		subTemp2.GWotGoAsset__c = relatedAsset1.Id;
        insert subTemp2;

		Contact_Subscription__c contSubTemp1 = new Contact_Subscription__c();
        contSubTemp1.Role__c = 'CustomerAdministrator';
        contSubTemp1.Contact__c = contactTemp1.Id;
        contSubTemp1.Subscription__c = subTemp2.Id;
        contSubTemp1.Asset__c = parentAsset1.Id;
		contSubTemp1.Active_Subscription1__c = true;
		contSubTemp1.GWotGoPermAssoc__c = true;
		contSubTemp1.GWotGoAsset__c = relatedAsset1.Id;
        insert contSubTemp1;

        Contact_Subscription__c contSubTemp2 = new Contact_Subscription__c();
        contSubTemp2.Role__c = 'TechnicianAdministrator';
        contSubTemp2.Contact__c = contactTemp1.Id;
        contSubTemp2.Subscription__c = subTemp1.Id;
        contSubTemp2.Asset__c = parentAsset1.Id;
		contSubTemp2.Active_Subscription1__c = true;
		contSubTemp2.GWotGoPermAssoc__c = true;
		contSubTemp2.GWotGoAsset__c = relatedAsset1.Id;
        insert contSubTemp2;


		// ----------------Setup Rest Request Object for the test:
        IERenewal_SubscriptionUpdateService.RenewalOrderRequest testRequest = new IERenewal_SubscriptionUpdateService.RenewalOrderRequest();
        testRequest.orderTypeId = 'Domestic';
        testRequest.assetUnits = new List<IERenewal_SubscriptionUpdateService.Asset_Unit>();

        // *** First asset
        IERenewal_SubscriptionUpdateService.Asset_Unit assetUnit1 = new IERenewal_SubscriptionUpdateService.Asset_Unit();
        assetUnit1.serialNumber = 'PO112711-Z-XXX';  // set it to the GWotGo SN
        assetUnit1.subscriptionInfoList = new List<IERenewal_SubscriptionUpdateService.Subscription_Info>();

        // First subscription for first asset
        IERenewal_SubscriptionUpdateService.Subscription_Info subInfo1 = new IERenewal_SubscriptionUpdateService.Subscription_Info();
        subInfo1.startDate = currDateTime;
        subInfo1.endDate = currDateTime.addMonths(12);
        subInfo1.connectivityType = 'Cellular';
        subInfo1.termYears = 1.0;
        subInfo1.subscriptionType = 'TechReadWrite';
        subInfo1.contactInfoList = new List<IERenewal_SubscriptionUpdateService.Contact_Info>();

        // First contact for first subscription
        IERenewal_SubscriptionUpdateService.Contact_Info contInfo1 = new IERenewal_SubscriptionUpdateService.Contact_Info();
        contInfo1.email = 'kent.roessler@daikinapplied.com';
        contInfo1.firstName = 'Kent1';
        contInfo1.middleName = '';
        contInfo1.lastName = 'Roessler1';
        contInfo1.customerAdmin = false;
        contInfo1.technicianAdmin = true;
        contInfo1.customer = false;
        contInfo1.technician = false;
        contInfo1.renewalAdmin = false;
        contInfo1.orgName = 'Account Test1';
        contInfo1.orgAddress = 'Test Address Line 1';
        contInfo1.orgCity = 'Minneapolis';
        contInfo1.orgState = 'Minnesota';
        contInfo1.orgCountry = 'United States';
        contInfo1.orgZip = '55421';
        subInfo1.contactInfoList.add(contInfo1);


        // Add first subscription to first asset
        assetUnit1.subscriptionInfoList.add(subInfo1);


        // Second subscription for first asset
        IERenewal_SubscriptionUpdateService.Subscription_Info subInfo2 = new IERenewal_SubscriptionUpdateService.Subscription_Info();
        subInfo2.startDate = currDateTime;
        subInfo2.endDate = currDateTime.addMonths(12);
        subInfo2.connectivityType = 'Cellular';
        subInfo2.termYears = 1.0;
        subInfo2.subscriptionType = 'CustomRead';
        subInfo2.contactInfoList = new List<IERenewal_SubscriptionUpdateService.Contact_Info>();

        // First contact for second subscription
        IERenewal_SubscriptionUpdateService.Contact_Info contInfo4 = new IERenewal_SubscriptionUpdateService.Contact_Info();
        contInfo4.email = 'kent.roessler@daikinapplied.com';
        contInfo4.firstName = 'Kent1';
        contInfo4.middleName = '';
        contInfo4.lastName = 'Roessler1';
        contInfo4.customerAdmin = true;
        contInfo4.technicianAdmin = false;
        contInfo4.customer = false;
        contInfo4.technician = false;
        contInfo4.renewalAdmin = false;
        contInfo4.orgName = 'Account Test1';
        contInfo4.orgAddress = 'Test Address Line 1';
        contInfo4.orgCity = 'Minneapolis';
        contInfo4.orgState = 'Minnesota';
        contInfo4.orgCountry = 'United States';
        contInfo4.orgZip = '55421';
        subInfo2.contactInfoList.add(contInfo4);


        // Add second subscription to first asset
        assetUnit1.subscriptionInfoList.add(subInfo2);


        // Add first asset to list of assets for the order
        testRequest.assetUnits.add(assetUnit1);


		RestContext.request = new System.RestRequest();
        RestContext.request.requestBody = Blob.valueOf( JSON.serialize(testRequest) );

        Test.startTest();

            RestContext.response = new System.RestResponse();
            IERenewal_SubscriptionUpdateService.doPut();

        Test.stopTest();

        IERenewal_SubscriptionUpdateService.RenewalOrderResponse theResponse = (IERenewal_SubscriptionUpdateService.RenewalOrderResponse)JSON.deserialize( RestContext.response.responseBody.toString(), IERenewal_SubscriptionUpdateService.RenewalOrderResponse.class );
        // Loop through the Response Statuses and make sure there are no errors
        for (IERenewal_SubscriptionUpdateService.Subscription_Update_Status subUpdateStatus : theResponse.Statuses) {
            if (!subUpdateStatus.Errors.isEmpty()) 
                System.debug(logginglevel.error, subUpdateStatus.Errors);

            System.assert(subUpdateStatus.Errors.isEmpty(), 'No errors should have been returned from the subscription update');
        }

	}

    

    @isTest static void testPut_AllDataExists() {
        // ----------------Setup Test Data in Salesforce objects:

        //!!!!!!!!!!! Need to add this code snippet for AvaTax- AccountAddressTrigger to run successfully on Before Insert into the Account table !!!!!!!!!!!!!!!!!
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c();
        ts1.AVA_SFCORE__Active_Setting__c = true;
        ts1.Name='Test Account';
        insert ts1;

		// Set these static control variables to True to avoid trigger code execution
		TriggerUtility.limitIntegrationBatch = true;
		TriggerUtility.limitContactExecution = true;

        // Create Address__c, Account, Account_Address__c records
        Account acctTemp = null;
        Address__c addrTemp = null;
        Account_Address__c acctAddrJunctionObj = null;
        
        addrTemp = new Address__c();
        addrTemp.Address_Line_1__c = 'Test Address Line 1';
        addrTemp.City__c = 'Minneapolis';
        addrTemp.Postal_Code__c = '55421';
        addrTemp.Country__c = 'United States';
        addrTemp.State_Province__c = 'Minnesota';
        insert addrTemp;
        
        acctTemp = new Account();
        acctTemp.Name = 'Account Test1';
        acctTemp.Type = 'Developer';
        acctTemp.Physical_Address__c = addrTemp.Id;
        acctTemp.IE_Account__c = true;
        acctTemp.Record_Usage__c = 'IE';
        insert acctTemp;
        
        acctAddrJunctionObj = new Account_Address__c();
        acctAddrJunctionObj.Account__c = acctTemp.Id;
        acctAddrJunctionObj.Address__c = addrTemp.Id;
        acctAddrJunctionObj.Active__c = true;
        acctAddrJunctionObj.Physical__c = true;
        insert acctAddrJunctionObj;


        // Create Order__c and Product2 records
        Order__c orderTemp1 = null;
        orderTemp1 = new Order__c();
        orderTemp1.Job_Name__c = 'Test Order Job Name 1';
        orderTemp1.Order_Type_ID__c = 'International'; //'Domestic'
        insert orderTemp1;

        Product2 prodTemp1 = null;
        prodTemp1 = new Product2();
        prodTemp1.Name = 'Test Prod1';
        prodTemp1.Vendor_Supplier__c = 'Test Vendor1';
        prodTemp1.IsActive = true;
        prodTemp1.Description = 'Test Description1';
        prodTemp1.DW_PCL_Description__c = 'Test DW PCL Description1';
        prodTemp1.Apttus_Product__c = true;
        prodTemp1.Product_Category__c = 'Test Category1';
        prodTemp1.ProductCode = 'DPS015A';
        insert prodTemp1;

        Product2 prodTemp2 = null;
        prodTemp2 = new Product2();
        prodTemp2.Name = 'Test Prod2';
        prodTemp2.Vendor_Supplier__c = 'Test Vendor2';
        prodTemp2.IsActive = true;
        prodTemp2.Description = 'Test Description2';
        prodTemp2.DW_PCL_Description__c = 'Test DW PCL Description2';
        prodTemp2.Apttus_Product__c = true;
        prodTemp2.Product_Category__c = 'Test Category2';
        prodTemp2.ProductCode = 'DPS015A';
        insert prodTemp2;

        Product2 prodTemp3 = null;
        prodTemp3 = new Product2();
        prodTemp3.Name = 'Intelligent Equipment Gateway';
        prodTemp3.Vendor_Supplier__c = 'Test Vendor3';
        prodTemp3.IsActive = true;
        prodTemp3.Description = 'Test Description3';
        prodTemp3.DW_PCL_Description__c = 'Test DW PCL Description3';
        prodTemp3.Apttus_Product__c = true;
        prodTemp3.Product_Category__c = 'Test Category3';
        insert prodTemp3;

        Product2 prodTemp4 = null;
        prodTemp4 = new Product2();
        prodTemp4.Name = 'Intelligent Equipment Energy Management Module';
        prodTemp4.Vendor_Supplier__c = 'Test Vendor4';
        prodTemp4.IsActive = true;
        prodTemp4.Description = 'Test Description4';
        prodTemp4.DW_PCL_Description__c = 'Test DW PCL Description4';
        prodTemp4.Apttus_Product__c = true;
        prodTemp4.Product_Category__c = 'Test Category4';
        insert prodTemp4;
        
        
        // Create Parent Asset records
        Asset parentAsset1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test_1', Tag__c='Order Tag 1');
        parentAsset1.Product2Id = prodTemp1.Id;
        parentAsset1.Order__c = orderTemp1.Id;
        parentAsset1.IE_Asset__c = true;
        insert parentAsset1;

        Asset parentAsset2 = new Asset(Name = 'Asset Test2', AccountId = acctTemp.Id, SerialNumber='SN123Test_2', Tag__c='Order Tag 2');
        parentAsset2.Product2Id = prodTemp2.Id;
        parentAsset2.Order__c = orderTemp1.Id;
        parentAsset2.IE_Asset__c = true;
        insert parentAsset2;


        // Create Related Asset Records for each Parent Asset
        Asset relatedAsset1 = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-075', Parent_Asset__c = parentAsset1.Id);
        relatedAsset1.Product2Id = prodTemp3.Id;
        relatedAsset1.SIM_Card_Active__c = true;
        relatedAsset1.SIM_Card_ICCID__c = '89011704258018735310';
        insert relatedAsset1;

        Asset relatedAsset2 = new Asset(Name = 'Intelligent Equipment Energy Management Module', AccountId = acctTemp.Id, SerialNumber = 'MESF04115', Parent_Asset__c = parentAsset1.Id);
        relatedAsset2.Product2Id = prodTemp4.Id;
        relatedAsset2.SIM_Card_Active__c = true;
        insert relatedAsset2;

        Asset relatedAsset3 = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-075', Parent_Asset__c = parentAsset2.Id);
        relatedAsset3.Product2Id = prodTemp3.Id;
        relatedAsset3.SIM_Card_Active__c = true;
        relatedAsset3.SIM_Card_ICCID__c = 'some text89011704258018735310some text';
        insert relatedAsset3;

        Asset relatedAsset4 = new Asset(Name = 'Intelligent Equipment Energy Management Module', AccountId = acctTemp.Id, SerialNumber = 'MESF04115', Parent_Asset__c = parentAsset2.Id);
        relatedAsset4.Product2Id = prodTemp4.Id;
        relatedAsset4.SIM_Card_Active__c = true;
        insert relatedAsset4;


        // Create Contact(3), Subscription(4) and Contact_Subscription(12) records
        Datetime currDateTime = Datetime.now();
        Date currentDate = Date.today();
        RecordType recordTypeTemp = [SELECT Id FROM RecordType WHERE Name='Daikin Applied' AND SObjectType='Contact'];

        Contact contactTemp1 = new Contact();
        contactTemp1.Eprise_Login_ID__c = 'RoesslKS1';
        contactTemp1.RecordTypeId = recordTypeTemp.Id;
        contactTemp1.AccountId = acctTemp.Id;
        contactTemp1.Status__c = 'Active';
        contactTemp1.Email = 'kent.roessler@daikinapplied.com';
        contactTemp1.FirstName = 'Kent1';
        contactTemp1.LastName = 'Roessler1';
        contactTemp1.IE_Contact__c = true;
        contactTemp1.IE_Username__c = 'kent.roessler@daikinapplied.com';
        contactTemp1.Record_Usage__c = 'IE';
        insert contactTemp1;

        Contact contactTemp2 = new Contact();
        contactTemp2.Eprise_Login_ID__c = 'RoesslKS2';
        contactTemp2.RecordTypeId = recordTypeTemp.Id;
        contactTemp2.AccountId = acctTemp.Id;
        contactTemp2.Status__c = 'Active';
        contactTemp2.Email = 'kent.roessler@daikinapplied.com';
        contactTemp2.FirstName = 'Kent2';
        contactTemp2.LastName = 'Roessler2';
        contactTemp2.IE_Contact__c = true;
        contactTemp2.IE_Username__c = 'kent.roessler@daikinapplied.com';
        contactTemp2.Record_Usage__c = 'IE';
        insert contactTemp2;

        Contact contactTemp3 = new Contact();
        contactTemp3.Eprise_Login_ID__c = 'RoesslKS3';
        contactTemp3.RecordTypeId = recordTypeTemp.Id;
        contactTemp3.AccountId = acctTemp.Id;
        contactTemp3.Status__c = 'Active';
        contactTemp3.Email = 'kent.roessler@daikinapplied.com';
        contactTemp3.FirstName = 'Kent3';
        contactTemp3.LastName = 'Roessler3';
        contactTemp3.IE_Contact__c = true;
        contactTemp3.IE_Username__c = 'kent.roessler@daikinapplied.com';
        contactTemp3.Record_Usage__c = 'IE';
        insert contactTemp3;


        Subscription__c subTemp1 = new Subscription__c();
        subTemp1.IE_Subscription__c = true;
        subTemp1.Start_Date__c = currDateTime;
        subTemp1.End_Date__c = currDateTime.addMonths(12);
        subTemp1.Type__c = 'TechReadWrite';
        subTemp1.Active__c = true;
        subTemp1.Asset__c = parentAsset1.Id;
        subTemp1.Buyer_ID__c = acctTemp.Id;
        subTemp1.Renewal_Counter__c = 1;  // Renewal Subscription has been renewed once
        subTemp1.Last_Renewal_Date__c = currentDate.addMonths(-12);
        subTemp1.Renewal_Date__c = currentDate;
        subTemp1.Connectivity_Type__c = 'Cellular';
        subTemp1.Term_Years__c = 1.0;
        subTemp1.Renewal_Notice_Current_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month__c = false;
        subTemp1.Renewal_Notice_Last_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp1.Renewal_Notice_Last_Month_Minus_1__c = false;
        insert subTemp1;

        Subscription__c subTemp2 = new Subscription__c();
        subTemp2.IE_Subscription__c = true;
        subTemp2.Start_Date__c = currDateTime;
        subTemp2.End_Date__c = currDateTime.addMonths(12);
        subTemp2.Type__c = 'CustomRead';
        subTemp2.Active__c = true;
        subTemp2.Asset__c = parentAsset1.Id;
        subTemp2.Buyer_ID__c = acctTemp.Id;
        subTemp2.Renewal_Counter__c = 2;  // Renewal Subscription has been renewed twice
        subTemp2.Last_Renewal_Date__c = currentDate.addMonths(-12);
        subTemp2.Renewal_Date__c = currentDate;
        subTemp2.Connectivity_Type__c = 'Cellular';
        subTemp2.Term_Years__c = 1.0;
        subTemp2.Renewal_Notice_Current_Month__c = false;
        subTemp2.Renewal_Notice_Next_Month__c = false;
        subTemp2.Renewal_Notice_Last_Month__c = false;
        subTemp2.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp2.Renewal_Notice_Last_Month_Minus_1__c = false;
        insert subTemp2;

        Subscription__c subTemp3 = new Subscription__c();
        subTemp3.IE_Subscription__c = true;
        subTemp3.Start_Date__c = currDateTime;
        subTemp3.End_Date__c = currDateTime.addMonths(12);
        subTemp3.Type__c = 'TechReadWrite';
        subTemp3.Active__c = true;
        subTemp3.Asset__c = parentAsset2.Id;
        subTemp3.Buyer_ID__c = acctTemp.Id;
        subTemp3.Renewal_Counter__c = 0; // Subscription-only order
        subTemp3.Last_Renewal_Date__c = null;
        subTemp3.Renewal_Date__c = null;
        subTemp3.Connectivity_Type__c = 'Cellular';
        subTemp3.Term_Years__c = 1.0;
        subTemp3.Renewal_Notice_Current_Month__c = false;
        subTemp3.Renewal_Notice_Next_Month__c = false;
        subTemp3.Renewal_Notice_Last_Month__c = false;
        subTemp3.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp3.Renewal_Notice_Last_Month_Minus_1__c = false;
        insert subTemp3;

        Subscription__c subTemp4 = new Subscription__c();
        subTemp4.IE_Subscription__c = true;
        subTemp4.Start_Date__c = currDateTime;
        subTemp4.End_Date__c = currDateTime.addMonths(12);
        subTemp4.Type__c = 'CustomRead';
        subTemp4.Active__c = true;
        subTemp4.Asset__c = parentAsset2.Id;
        subTemp4.Buyer_ID__c = acctTemp.Id;
        subTemp4.Renewal_Counter__c = 0;
        subTemp4.Last_Renewal_Date__c = null;
        subTemp4.Renewal_Date__c = null;
        subTemp4.Connectivity_Type__c = 'Cellular';
        subTemp4.Term_Years__c = 0.25; // Kit & Factory Order startup without a subscription
        subTemp4.Renewal_Notice_Current_Month__c = false;
        subTemp4.Renewal_Notice_Next_Month__c = false;
        subTemp4.Renewal_Notice_Last_Month__c = false;
        subTemp4.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp4.Renewal_Notice_Last_Month_Minus_1__c = false;
        insert subTemp4;


        // Associate the 3 contacts to the first subscription
        Contact_Subscription__c contSubTemp1 = new Contact_Subscription__c();
        contSubTemp1.Role__c = 'RenewalAdministrator';
        contSubTemp1.Contact__c = contactTemp1.Id;
        contSubTemp1.Subscription__c = subTemp1.Id;
        contSubTemp1.Asset__c = parentAsset1.Id;
		contSubTemp1.Active_Subscription1__c = true;
        insert contSubTemp1;

        Contact_Subscription__c contSubTemp2 = new Contact_Subscription__c();
        contSubTemp2.Role__c = 'CustomerAdministrator;Customer';
        contSubTemp2.Contact__c = contactTemp2.Id;
        contSubTemp2.Subscription__c = subTemp1.Id;
        contSubTemp2.Asset__c = parentAsset1.Id;
		contSubTemp2.Active_Subscription1__c = true;
        insert contSubTemp2;

        Contact_Subscription__c contSubTemp3 = new Contact_Subscription__c();
        contSubTemp3.Role__c = 'TechnicianAdministrator;Technician';
        contSubTemp3.Contact__c = contactTemp3.Id;
        contSubTemp3.Subscription__c = subTemp1.Id;
        contSubTemp3.Asset__c = parentAsset1.Id;
		contSubTemp3.Active_Subscription1__c = true;
        insert contSubTemp3;


        // Associate the 3 contacts to the second subscription
        Contact_Subscription__c contSubTemp4 = new Contact_Subscription__c();
        contSubTemp4.Role__c = 'RenewalAdministrator';
        contSubTemp4.Contact__c = contactTemp1.Id;
        contSubTemp4.Subscription__c = subTemp2.Id;
        contSubTemp4.Asset__c = parentAsset1.Id;
		contSubTemp4.Active_Subscription1__c = true;
        insert contSubTemp4;

        Contact_Subscription__c contSubTemp5 = new Contact_Subscription__c();
        contSubTemp5.Role__c = 'CustomerAdministrator;Customer';
        contSubTemp5.Contact__c = contactTemp2.Id;
        contSubTemp5.Subscription__c = subTemp2.Id;
        contSubTemp5.Asset__c = parentAsset1.Id;
		contSubTemp5.Active_Subscription1__c = true;
        insert contSubTemp5;

        Contact_Subscription__c contSubTemp6 = new Contact_Subscription__c();
        contSubTemp6.Role__c = 'TechnicianAdministrator;Technician';
        contSubTemp6.Contact__c = contactTemp3.Id;
        contSubTemp6.Subscription__c = subTemp2.Id;
        contSubTemp6.Asset__c = parentAsset1.Id;
		contSubTemp6.Active_Subscription1__c = true;
        insert contSubTemp6;


        // Associate the 3 contacts to the third subscription
        Contact_Subscription__c contSubTemp7 = new Contact_Subscription__c();
        contSubTemp7.Role__c = 'RenewalAdministrator';
        contSubTemp7.Contact__c = contactTemp1.Id;
        contSubTemp7.Subscription__c = subTemp3.Id;
        contSubTemp7.Asset__c = parentAsset2.Id;
		contSubTemp7.Active_Subscription1__c = true;
        insert contSubTemp7;

        Contact_Subscription__c contSubTemp8 = new Contact_Subscription__c();
        contSubTemp8.Role__c = 'CustomerAdministrator;Customer';
        contSubTemp8.Contact__c = contactTemp2.Id;
        contSubTemp8.Subscription__c = subTemp3.Id;
        contSubTemp8.Asset__c = parentAsset2.Id;
		contSubTemp8.Active_Subscription1__c = true;
        insert contSubTemp8;

        Contact_Subscription__c contSubTemp9 = new Contact_Subscription__c();
        contSubTemp9.Role__c = 'TechnicianAdministrator;Technician';
        contSubTemp9.Contact__c = contactTemp3.Id;
        contSubTemp9.Subscription__c = subTemp3.Id;
        contSubTemp9.Asset__c = parentAsset2.Id;
		contSubTemp9.Active_Subscription1__c = true;
        insert contSubTemp9;


        // Associate the 3 contacts to the fourth subscription
        Contact_Subscription__c contSubTemp10 = new Contact_Subscription__c();
        contSubTemp10.Role__c = 'RenewalAdministrator';
        contSubTemp10.Contact__c = contactTemp1.Id;
        contSubTemp10.Subscription__c = subTemp4.Id;
        contSubTemp10.Asset__c = parentAsset2.Id;
		contSubTemp10.Active_Subscription1__c = true;
        insert contSubTemp10;

        Contact_Subscription__c contSubTemp11 = new Contact_Subscription__c();
        contSubTemp11.Role__c = 'CustomerAdministrator;Customer';
        contSubTemp11.Contact__c = contactTemp2.Id;
        contSubTemp11.Subscription__c = subTemp4.Id;
        contSubTemp11.Asset__c = parentAsset2.Id;
		contSubTemp11.Active_Subscription1__c = true;
        insert contSubTemp11;

        Contact_Subscription__c contSubTemp12 = new Contact_Subscription__c();
        contSubTemp12.Role__c = 'TechnicianAdministrator;Technician';
        contSubTemp12.Contact__c = contactTemp3.Id;
        contSubTemp12.Subscription__c = subTemp4.Id;
        contSubTemp12.Asset__c = parentAsset2.Id;
		contSubTemp12.Active_Subscription1__c = true;
        insert contSubTemp12;


        // ----------------Setup Rest Request Object for the test:
        IERenewal_SubscriptionUpdateService.RenewalOrderRequest testRequest = new IERenewal_SubscriptionUpdateService.RenewalOrderRequest();
        testRequest.orderTypeId = 'International'; //'Domestic';
        testRequest.assetUnits = new List<IERenewal_SubscriptionUpdateService.Asset_Unit>();

        // *** First asset
        IERenewal_SubscriptionUpdateService.Asset_Unit assetUnit1 = new IERenewal_SubscriptionUpdateService.Asset_Unit();
        assetUnit1.serialNumber = 'SN123Test_1';
        assetUnit1.subscriptionInfoList = new List<IERenewal_SubscriptionUpdateService.Subscription_Info>();

        // First subscription for first asset
        IERenewal_SubscriptionUpdateService.Subscription_Info subInfo1 = new IERenewal_SubscriptionUpdateService.Subscription_Info();
        subInfo1.startDate = currDateTime;
        subInfo1.endDate = currDateTime.addMonths(12);
        subInfo1.connectivityType = 'Cellular';
        subInfo1.termYears = 1.0;
        subInfo1.subscriptionType = 'TechReadWrite';
        subInfo1.contactInfoList = new List<IERenewal_SubscriptionUpdateService.Contact_Info>();

        // First contact for first subscription
        IERenewal_SubscriptionUpdateService.Contact_Info contInfo1 = new IERenewal_SubscriptionUpdateService.Contact_Info();
        contInfo1.email = 'kent.roessler@daikinapplied.com';
        contInfo1.firstName = 'Kent1';
        contInfo1.middleName = '';
        contInfo1.lastName = 'Roessler1';
        contInfo1.customerAdmin = true; //change value here from false to true
        contInfo1.technicianAdmin = false;
        contInfo1.customer = true; //change value here from false to true
        contInfo1.technician = false;
        contInfo1.renewalAdmin = true;
        contInfo1.orgName = 'Account Test1';
        contInfo1.orgAddress = 'Test Address Line 1';
        contInfo1.orgCity = 'Minneapolis';
        contInfo1.orgState = 'Minnesota';
        contInfo1.orgCountry = 'United States';
        contInfo1.orgZip = '55421';
        subInfo1.contactInfoList.add(contInfo1);

        // Second contact for first subscription
        IERenewal_SubscriptionUpdateService.Contact_Info contInfo2 = new IERenewal_SubscriptionUpdateService.Contact_Info();
        contInfo2.email = 'kent.roessler@daikinapplied.com';
        contInfo2.firstName = 'Kent2';
        contInfo2.middleName = '';
        contInfo2.lastName = 'Roessler2';
        contInfo2.customerAdmin = true;
        contInfo2.technicianAdmin = true; //change value here from false to true
        contInfo2.customer = true;
        contInfo2.technician = true; //change value here from false to true
        contInfo2.renewalAdmin = false;
        contInfo2.orgName = 'Account Test1';
        contInfo2.orgAddress = 'Test Address Line 1';
        contInfo2.orgCity = 'Minneapolis';
        contInfo2.orgState = 'Minnesota';
        contInfo2.orgCountry = 'United States';
        contInfo2.orgZip = '55421';
        subInfo1.contactInfoList.add(contInfo2);

        // Third contact for first subscription
        IERenewal_SubscriptionUpdateService.Contact_Info contInfo3 = new IERenewal_SubscriptionUpdateService.Contact_Info();
        contInfo3.email = 'kent.roessler@daikinapplied.com';
        contInfo3.firstName = 'Kent3';
        contInfo3.middleName = '';
        contInfo3.lastName = 'Roessler3';
        contInfo3.customerAdmin = false;
        contInfo3.technicianAdmin = true;
        contInfo3.customer = false;
        contInfo3.technician = true;
        contInfo3.renewalAdmin = true; //change value here from false to true
        contInfo3.orgName = 'Account Test1';
        contInfo3.orgAddress = 'Test Address Line 1';
        contInfo3.orgCity = 'Minneapolis';
        contInfo3.orgState = 'Minnesota';
        contInfo3.orgCountry = 'United States';
        contInfo3.orgZip = '55421';
        subInfo1.contactInfoList.add(contInfo3);

        // Add first subscription to first asset
        assetUnit1.subscriptionInfoList.add(subInfo1);


        // Second subscription for first asset
        IERenewal_SubscriptionUpdateService.Subscription_Info subInfo2 = new IERenewal_SubscriptionUpdateService.Subscription_Info();
        subInfo2.startDate = currDateTime;
        subInfo2.endDate = currDateTime.addMonths(12);
        subInfo2.connectivityType = 'Cellular';
        subInfo2.termYears = 1.0;
        subInfo2.subscriptionType = 'CustomRead';
        subInfo2.contactInfoList = new List<IERenewal_SubscriptionUpdateService.Contact_Info>();

        // First contact for second subscription
        IERenewal_SubscriptionUpdateService.Contact_Info contInfo4 = new IERenewal_SubscriptionUpdateService.Contact_Info();
        contInfo4.email = 'kent.roessler@daikinapplied.com';
        contInfo4.firstName = 'Kent1';
        contInfo4.middleName = '';
        contInfo4.lastName = 'Roessler1';
        contInfo4.customerAdmin = false;
        contInfo4.technicianAdmin = false;
        contInfo4.customer = false;
        contInfo4.technician = false;
        contInfo4.renewalAdmin = true;
        contInfo4.orgName = 'Account Test1';
        contInfo4.orgAddress = 'Test Address Line 1';
        contInfo4.orgCity = 'Minneapolis';
        contInfo4.orgState = 'Minnesota';
        contInfo4.orgCountry = 'United States';
        contInfo4.orgZip = '55421';
        subInfo2.contactInfoList.add(contInfo4);

        // Second contact for second subscription
        IERenewal_SubscriptionUpdateService.Contact_Info contInfo5 = new IERenewal_SubscriptionUpdateService.Contact_Info();
        contInfo5.email = 'kent.roessler@daikinapplied.com';
        contInfo5.firstName = 'Kent2';
        contInfo5.middleName = '';
        contInfo5.lastName = 'Roessler2';
        contInfo5.customerAdmin = true;
        contInfo5.technicianAdmin = false;
        contInfo5.customer = true;
        contInfo5.technician = false;
        contInfo5.renewalAdmin = false;
        contInfo5.orgName = 'Account Test1';
        contInfo5.orgAddress = 'Test Address Line 1';
        contInfo5.orgCity = 'Minneapolis';
        contInfo5.orgState = 'Minnesota';
        contInfo5.orgCountry = 'United States';
        contInfo5.orgZip = '55421';
        subInfo2.contactInfoList.add(contInfo5);

        // Third contact for second subscription
        IERenewal_SubscriptionUpdateService.Contact_Info contInfo6 = new IERenewal_SubscriptionUpdateService.Contact_Info();
        contInfo6.email = 'kent.roessler@daikinapplied.com';
        contInfo6.firstName = 'Kent3';
        contInfo6.middleName = '';
        contInfo6.lastName = 'Roessler3';
        contInfo6.customerAdmin = false;
        contInfo6.technicianAdmin = true;
        contInfo6.customer = false;
        contInfo6.technician = true;
        contInfo6.renewalAdmin = false;
        contInfo6.orgName = 'Account Test1';
        contInfo6.orgAddress = 'Test Address Line 1';
        contInfo6.orgCity = 'Minneapolis';
        contInfo6.orgState = 'Minnesota';
        contInfo6.orgCountry = 'United States';
        contInfo6.orgZip = '55421';
        subInfo2.contactInfoList.add(contInfo6);

        // Add second subscription to first asset
        assetUnit1.subscriptionInfoList.add(subInfo2);


        // Add first asset to list of assets for the order
        testRequest.assetUnits.add(assetUnit1);


        // *** Second asset
        IERenewal_SubscriptionUpdateService.Asset_Unit assetUnit2 = new IERenewal_SubscriptionUpdateService.Asset_Unit();
        assetUnit2.serialNumber = 'SN123Test_2';
        assetUnit2.subscriptionInfoList = new List<IERenewal_SubscriptionUpdateService.Subscription_Info>();

        // First subscription for second asset
        IERenewal_SubscriptionUpdateService.Subscription_Info subInfo3 = new IERenewal_SubscriptionUpdateService.Subscription_Info();
        subInfo3.startDate = currDateTime;
        subInfo3.endDate = currDateTime.addMonths(12);
        subInfo3.connectivityType = 'Cellular';
        subInfo3.termYears = 1.0;
        subInfo3.subscriptionType = 'TechReadWrite';
        subInfo3.contactInfoList = new List<IERenewal_SubscriptionUpdateService.Contact_Info>();

        // First contact for first subscription
        IERenewal_SubscriptionUpdateService.Contact_Info contInfo7 = new IERenewal_SubscriptionUpdateService.Contact_Info();
        contInfo7.email = 'kent.roessler@daikinapplied.com';
        contInfo7.firstName = 'Kent1';
        contInfo7.middleName = '';
        contInfo7.lastName = 'Roessler1';
        contInfo7.customerAdmin = false;
        contInfo7.technicianAdmin = false;
        contInfo7.customer = false;
        contInfo7.technician = false;
        contInfo7.renewalAdmin = true;
        contInfo7.orgName = 'Account Test1';
        contInfo7.orgAddress = 'Test Address Line 1';
        contInfo7.orgCity = 'Minneapolis';
        contInfo7.orgState = 'Minnesota';
        contInfo7.orgCountry = 'United States';
        contInfo7.orgZip = '55421';
        subInfo3.contactInfoList.add(contInfo7);

        // Second contact for first subscription
        IERenewal_SubscriptionUpdateService.Contact_Info contInfo8 = new IERenewal_SubscriptionUpdateService.Contact_Info();
        contInfo8.email = 'kent.roessler@daikinapplied.com';
        contInfo8.firstName = 'Kent2';
        contInfo8.middleName = '';
        contInfo8.lastName = 'Roessler2';
        contInfo8.customerAdmin = true;
        contInfo8.technicianAdmin = false;
        contInfo8.customer = true;
        contInfo8.technician = false;
        contInfo8.renewalAdmin = false;
        contInfo8.orgName = 'Account Test1';
        contInfo8.orgAddress = 'Test Address Line 1';
        contInfo8.orgCity = 'Minneapolis';
        contInfo8.orgState = 'Minnesota';
        contInfo8.orgCountry = 'United States';
        contInfo8.orgZip = '55421';
        subInfo3.contactInfoList.add(contInfo8);

        // Third contact for first subscription
        IERenewal_SubscriptionUpdateService.Contact_Info contInfo9 = new IERenewal_SubscriptionUpdateService.Contact_Info();
        contInfo9.email = 'kent.roessler@daikinapplied.com';
        contInfo9.firstName = 'Kent3';
        contInfo9.middleName = '';
        contInfo9.lastName = 'Roessler3';
        contInfo9.customerAdmin = false;
        contInfo9.technicianAdmin = true;
        contInfo9.customer = false;
        contInfo9.technician = true;
        contInfo9.renewalAdmin = false;
        contInfo9.orgName = 'Account Test1';
        contInfo9.orgAddress = 'Test Address Line 1';
        contInfo9.orgCity = 'Minneapolis';
        contInfo9.orgState = 'Minnesota';
        contInfo9.orgCountry = 'United States';
        contInfo9.orgZip = '55421';
        subInfo3.contactInfoList.add(contInfo9);

        // Add first subscription to second asset
        assetUnit2.subscriptionInfoList.add(subInfo3);


        // Second subscription for second asset
        // ***************************************************************************************************************************
        // NOTE: This subscription is not a real scenario for the IE Renewal Service since it has a Term Years of 0.25 which is a
        // Kit & Factory order startup without a subscription. This scenario is really only valid from the ETL processing path.
        // We are adding this test here to test the part of the Subscription Trigger code that calls the AT&T CC Web Service API 
        // to update Kit & Factory information.
        // ***************************************************************************************************************************
        IERenewal_SubscriptionUpdateService.Subscription_Info subInfo4 = new IERenewal_SubscriptionUpdateService.Subscription_Info();
        subInfo4.startDate = currDateTime;
        subInfo4.endDate = currDateTime.addMonths(12);
        subInfo4.connectivityType = 'Cellular';
        subInfo4.termYears = 0.25;
        subInfo4.subscriptionType = 'CustomRead';
        subInfo4.contactInfoList = new List<IERenewal_SubscriptionUpdateService.Contact_Info>();

        // First contact for second subscription
        IERenewal_SubscriptionUpdateService.Contact_Info contInfo10 = new IERenewal_SubscriptionUpdateService.Contact_Info();
        contInfo10.email = 'kent.roessler@daikinapplied.com';
        contInfo10.firstName = 'Kent1';
        contInfo10.middleName = '';
        contInfo10.lastName = 'Roessler1';
        contInfo10.customerAdmin = false;
        contInfo10.technicianAdmin = false;
        contInfo10.customer = false;
        contInfo10.technician = false;
        contInfo10.renewalAdmin = true;
        contInfo10.orgName = 'Account Test1';
        contInfo10.orgAddress = 'Test Address Line 1';
        contInfo10.orgCity = 'Minneapolis';
        contInfo10.orgState = 'Minnesota';
        contInfo10.orgCountry = 'United States';
        contInfo10.orgZip = '55421';
        subInfo4.contactInfoList.add(contInfo10);

        // Second contact for second subscription
        IERenewal_SubscriptionUpdateService.Contact_Info contInfo11 = new IERenewal_SubscriptionUpdateService.Contact_Info();
        contInfo11.email = 'kent.roessler@daikinapplied.com';
        contInfo11.firstName = 'Kent2';
        contInfo11.middleName = '';
        contInfo11.lastName = 'Roessler2';
        contInfo11.customerAdmin = true;
        contInfo11.technicianAdmin = false;
        contInfo11.customer = true;
        contInfo11.technician = false;
        contInfo11.renewalAdmin = false;
        contInfo11.orgName = 'Account Test1';
        contInfo11.orgAddress = 'Test Address Line 1';
        contInfo11.orgCity = 'Minneapolis';
        contInfo11.orgState = 'Minnesota';
        contInfo11.orgCountry = 'United States';
        contInfo11.orgZip = '55421';
        subInfo4.contactInfoList.add(contInfo11);

        // Third contact for second subscription
        IERenewal_SubscriptionUpdateService.Contact_Info contInfo12 = new IERenewal_SubscriptionUpdateService.Contact_Info();
        contInfo12.email = 'kent.roessler@daikinapplied.com';
        contInfo12.firstName = 'Kent3';
        contInfo12.middleName = '';
        contInfo12.lastName = 'Roessler3';
        contInfo12.customerAdmin = false;
        contInfo12.technicianAdmin = true;
        contInfo12.customer = false;
        contInfo12.technician = true;
        contInfo12.renewalAdmin = false;
        contInfo12.orgName = 'Account Test1';
        contInfo12.orgAddress = 'Test Address Line 1';
        contInfo12.orgCity = 'Minneapolis';
        contInfo12.orgState = 'Minnesota';
        contInfo12.orgCountry = 'United States';
        contInfo12.orgZip = '55421';
        subInfo4.contactInfoList.add(contInfo12);

        // Add second subscription to second asset
        assetUnit2.subscriptionInfoList.add(subInfo4);


        // Add second asset to list of assets for the order
        testRequest.assetUnits.add(assetUnit2);


        RestContext.request = new System.RestRequest();
        RestContext.request.requestBody = Blob.valueOf( JSON.serialize(testRequest) );

        Test.startTest();

            RestContext.response = new System.RestResponse();
            IERenewal_SubscriptionUpdateService.doPut();

        Test.stopTest();

        IERenewal_SubscriptionUpdateService.RenewalOrderResponse theResponse = (IERenewal_SubscriptionUpdateService.RenewalOrderResponse)JSON.deserialize( RestContext.response.responseBody.toString(), IERenewal_SubscriptionUpdateService.RenewalOrderResponse.class );
        // Loop through the Response Statuses and make sure there are no errors
        for (IERenewal_SubscriptionUpdateService.Subscription_Update_Status subUpdateStatus : theResponse.Statuses) {
            if (!subUpdateStatus.Errors.isEmpty()) 
                System.debug(logginglevel.error, subUpdateStatus.Errors);

            System.assert(subUpdateStatus.Errors.isEmpty(), 'No errors should have been returned from the subscription update');
        }

        // Check that the renewal counter on each subscription is correct
        Subscription__c s1 = [Select Id, Renewal_Counter__c from Subscription__c where Id =: subTemp1.Id];
        System.assertEquals(2, s1.Renewal_Counter__c);

        Subscription__c s2 = [Select Id, Renewal_Counter__c from Subscription__c where Id =: subTemp2.Id];
        System.assertEquals(2, s2.Renewal_Counter__c);

        Subscription__c s3 = [Select Id, Renewal_Counter__c from Subscription__c where Id =: subTemp3.Id];
        System.assertEquals(1, s3.Renewal_Counter__c);

        Subscription__c s4 = [Select Id, Renewal_Counter__c from Subscription__c where Id =: subTemp4.Id];
        System.assertEquals(0, s4.Renewal_Counter__c);

    }


    @isTest static void testPut_SubscriptionTypeMatchError() {
        // -------------Setup Test Data in Salesforce objects:

        //!!!!!!!!!!! Need to add this code snippet for AvaTax- AccountAddressTrigger to run successfully on Before Insert into the Account table !!!!!!!!!!!!!!!!!
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c();
        ts1.AVA_SFCORE__Active_Setting__c = true;
        ts1.Name='Test Account';
        insert ts1;

		// Set these static control variables to True to avoid trigger code execution
		TriggerUtility.limitIntegrationBatch = true;
		TriggerUtility.limitContactExecution = true;

        // Create Address__c, Account, Account_Address__c records
        Account acctTemp = null;
        Address__c addrTemp = null;
        Account_Address__c acctAddrJunctionObj = null;
        
        addrTemp = new Address__c();
        addrTemp.Address_Line_1__c = 'Test Address Line 1';
        addrTemp.City__c = 'Minneapolis';
        addrTemp.Postal_Code__c = '55421';
        addrTemp.Country__c = 'United States';
        addrTemp.State_Province__c = 'Minnesota';
        insert addrTemp;
        
        acctTemp = new Account();
        acctTemp.Name = 'Account Test1';
        acctTemp.Type = 'Developer';
        acctTemp.Physical_Address__c = addrTemp.Id;
        acctTemp.IE_Account__c = true;
        acctTemp.Record_Usage__c = 'IE';
        insert acctTemp;
        
        acctAddrJunctionObj = new Account_Address__c();
        acctAddrJunctionObj.Account__c = acctTemp.Id;
        acctAddrJunctionObj.Address__c = addrTemp.Id;
        acctAddrJunctionObj.Active__c = true;
        acctAddrJunctionObj.Physical__c = true;
        insert acctAddrJunctionObj;


        // Create Order__c and Product2 records
        Order__c orderTemp1 = null;
        orderTemp1 = new Order__c();
        orderTemp1.Job_Name__c = 'Test Order Job Name 1';
        orderTemp1.Order_Type_ID__c = 'Domestic';
        insert orderTemp1;

        Product2 prodTemp1 = null;
        prodTemp1 = new Product2();
        prodTemp1.Name = 'Test Prod1';
        prodTemp1.Vendor_Supplier__c = 'Test Vendor1';
        prodTemp1.IsActive = true;
        prodTemp1.Description = 'Test Description1';
        prodTemp1.DW_PCL_Description__c = 'Test DW PCL Description1';
        prodTemp1.Apttus_Product__c = true;
        prodTemp1.Product_Category__c = 'Test Category1';
        insert prodTemp1;

        Product2 prodTemp2 = null;
        prodTemp2 = new Product2();
        prodTemp2.Name = 'Test Prod2';
        prodTemp2.Vendor_Supplier__c = 'Test Vendor2';
        prodTemp2.IsActive = true;
        prodTemp2.Description = 'Test Description2';
        prodTemp2.DW_PCL_Description__c = 'Test DW PCL Description2';
        prodTemp2.Apttus_Product__c = true;
        prodTemp2.Product_Category__c = 'Test Category2';
        insert prodTemp2;

        Product2 prodTemp3 = null;
        prodTemp3 = new Product2();
        prodTemp3.Name = 'Intelligent Equipment Gateway';
        prodTemp3.Vendor_Supplier__c = 'Test Vendor3';
        prodTemp3.IsActive = true;
        prodTemp3.Description = 'Test Description3';
        prodTemp3.DW_PCL_Description__c = 'Test DW PCL Description3';
        prodTemp3.Apttus_Product__c = true;
        prodTemp3.Product_Category__c = 'Test Category3';
        insert prodTemp3;

        Product2 prodTemp4 = null;
        prodTemp4 = new Product2();
        prodTemp4.Name = 'Intelligent Equipment Energy Management Module';
        prodTemp4.Vendor_Supplier__c = 'Test Vendor4';
        prodTemp4.IsActive = true;
        prodTemp4.Description = 'Test Description4';
        prodTemp4.DW_PCL_Description__c = 'Test DW PCL Description4';
        prodTemp4.Apttus_Product__c = true;
        prodTemp4.Product_Category__c = 'Test Category4';
        insert prodTemp4;
        
        
        // Create Parent Asset records
        Asset parentAsset1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test_1', Tag__c='Order Tag 1');
        parentAsset1.Product2Id = prodTemp1.Id;
        parentAsset1.Order__c = orderTemp1.Id;
        parentAsset1.IE_Asset__c = true;
        insert parentAsset1;

        Asset parentAsset2 = new Asset(Name = 'Asset Test2', AccountId = acctTemp.Id, SerialNumber='SN123Test_2', Tag__c='Order Tag 2');
        parentAsset2.Product2Id = prodTemp2.Id;
        parentAsset2.Order__c = orderTemp1.Id;
        parentAsset2.IE_Asset__c = true;
        insert parentAsset2;


        // Create Related Asset Records for each Parent Asset
        Asset relatedAsset1 = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-075', Parent_Asset__c = parentAsset1.Id);
        relatedAsset1.Product2Id = prodTemp3.Id;
        relatedAsset1.SIM_Card_Active__c = true;
        insert relatedAsset1;

        Asset relatedAsset2 = new Asset(Name = 'Intelligent Equipment Energy Management Module', AccountId = acctTemp.Id, SerialNumber = 'MESF04115', Parent_Asset__c = parentAsset1.Id);
        relatedAsset2.Product2Id = prodTemp4.Id;
        relatedAsset2.SIM_Card_Active__c = true;
        insert relatedAsset2;

        Asset relatedAsset3 = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-075', Parent_Asset__c = parentAsset2.Id);
        relatedAsset3.Product2Id = prodTemp3.Id;
        relatedAsset3.SIM_Card_Active__c = true;
        insert relatedAsset3;

        Asset relatedAsset4 = new Asset(Name = 'Intelligent Equipment Energy Management Module', AccountId = acctTemp.Id, SerialNumber = 'MESF04115', Parent_Asset__c = parentAsset2.Id);
        relatedAsset4.Product2Id = prodTemp4.Id;
        relatedAsset4.SIM_Card_Active__c = true;
        insert relatedAsset4;


        // Create Contact(3), Subscription(4) and Contact_Subscription(12) records
        Datetime currDateTime = Datetime.now();
        RecordType recordTypeTemp = [SELECT Id FROM RecordType WHERE Name='Daikin Applied' AND SObjectType='Contact'];

        Contact contactTemp1 = new Contact();
        contactTemp1.Eprise_Login_ID__c = 'RoesslKS1';
        contactTemp1.RecordTypeId = recordTypeTemp.Id;
        contactTemp1.AccountId = acctTemp.Id;
        contactTemp1.Status__c = 'Active';
        contactTemp1.Email = 'kent.roessler@daikinapplied.com';
        contactTemp1.FirstName = 'Kent1';
        contactTemp1.LastName = 'Roessler1';
        insert contactTemp1;

        Contact contactTemp2 = new Contact();
        contactTemp2.Eprise_Login_ID__c = 'RoesslKS2';
        contactTemp2.RecordTypeId = recordTypeTemp.Id;
        contactTemp2.AccountId = acctTemp.Id;
        contactTemp2.Status__c = 'Active';
        contactTemp2.Email = 'kent.roessler@daikinapplied.com';
        contactTemp2.FirstName = 'Kent2';
        contactTemp2.LastName = 'Roessler2';
        insert contactTemp2;

        Contact contactTemp3 = new Contact();
        contactTemp3.Eprise_Login_ID__c = 'RoesslKS3';
        contactTemp3.RecordTypeId = recordTypeTemp.Id;
        contactTemp3.AccountId = acctTemp.Id;
        contactTemp3.Status__c = 'Active';
        contactTemp3.Email = 'kent.roessler@daikinapplied.com';
        contactTemp3.FirstName = 'Kent3';
        contactTemp3.LastName = 'Roessler3';
        insert contactTemp3;


        Subscription__c subTemp1 = new Subscription__c();
        subTemp1.Start_Date__c = currDateTime;
        subTemp1.End_Date__c = currDateTime.addMonths(12);
        subTemp1.Type__c = 'TechReadWrite';
        subTemp1.Active__c = true;
        subTemp1.Asset__c = parentAsset1.Id;
        subTemp1.Buyer_ID__c = acctTemp.Id;
        subTemp1.Renewal_Counter__c = 0;
        subTemp1.Connectivity_Type__c = 'Cellular';
        subTemp1.Term_Years__c = 1.0;
        subTemp1.Renewal_Notice_Current_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month__c = false;
        subTemp1.Renewal_Notice_Last_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp1.Renewal_Notice_Last_Month_Minus_1__c = false;
        insert subTemp1;

        Subscription__c subTemp2 = new Subscription__c();
        subTemp2.Start_Date__c = currDateTime;
        subTemp2.End_Date__c = currDateTime.addMonths(12);
        subTemp2.Type__c = 'CustomRead';
        subTemp2.Active__c = true;
        subTemp2.Asset__c = parentAsset1.Id;
        subTemp2.Buyer_ID__c = acctTemp.Id;
        subTemp2.Renewal_Counter__c = 0;
        subTemp2.Connectivity_Type__c = 'Cellular';
        subTemp2.Term_Years__c = 1.0;
        subTemp2.Renewal_Notice_Current_Month__c = false;
        subTemp2.Renewal_Notice_Next_Month__c = false;
        subTemp2.Renewal_Notice_Last_Month__c = false;
        subTemp2.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp2.Renewal_Notice_Last_Month_Minus_1__c = false;
        insert subTemp2;

        Subscription__c subTemp3 = new Subscription__c();
        subTemp3.Start_Date__c = currDateTime;
        subTemp3.End_Date__c = currDateTime.addMonths(12);
        subTemp3.Type__c = 'TechReadWrite';
        subTemp3.Active__c = true;
        subTemp3.Asset__c = parentAsset2.Id;
        subTemp3.Buyer_ID__c = acctTemp.Id;
        subTemp3.Renewal_Counter__c = 0;
        subTemp3.Connectivity_Type__c = 'Cellular';
        subTemp3.Term_Years__c = 1.0;
        subTemp3.Renewal_Notice_Current_Month__c = false;
        subTemp3.Renewal_Notice_Next_Month__c = false;
        subTemp3.Renewal_Notice_Last_Month__c = false;
        subTemp3.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp3.Renewal_Notice_Last_Month_Minus_1__c = false;
        insert subTemp3;

        Subscription__c subTemp4 = new Subscription__c();
        subTemp4.Start_Date__c = currDateTime;
        subTemp4.End_Date__c = currDateTime.addMonths(12);
        subTemp4.Type__c = 'CustomRead';
        subTemp4.Active__c = true;
        subTemp4.Asset__c = parentAsset2.Id;
        subTemp4.Buyer_ID__c = acctTemp.Id;
        subTemp4.Renewal_Counter__c = 0;
        subTemp4.Connectivity_Type__c = 'Cellular';
        subTemp4.Term_Years__c = 1.0;
        subTemp4.Renewal_Notice_Current_Month__c = false;
        subTemp4.Renewal_Notice_Next_Month__c = false;
        subTemp4.Renewal_Notice_Last_Month__c = false;
        subTemp4.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp4.Renewal_Notice_Last_Month_Minus_1__c = false;
        insert subTemp4;


        // Associate the 3 contacts to the first subscription
        Contact_Subscription__c contSubTemp1 = new Contact_Subscription__c();
        contSubTemp1.Role__c = 'RenewalAdministrator';
        contSubTemp1.Contact__c = contactTemp1.Id;
        contSubTemp1.Subscription__c = subTemp1.Id;
        contSubTemp1.Asset__c = parentAsset1.Id;
		contSubTemp1.Active_Subscription1__c = true;
        insert contSubTemp1;

        Contact_Subscription__c contSubTemp2 = new Contact_Subscription__c();
        contSubTemp2.Role__c = 'CustomerAdministrator;Customer';
        contSubTemp2.Contact__c = contactTemp2.Id;
        contSubTemp2.Subscription__c = subTemp1.Id;
        contSubTemp2.Asset__c = parentAsset1.Id;
		contSubTemp2.Active_Subscription1__c = true;
        insert contSubTemp2;

        Contact_Subscription__c contSubTemp3 = new Contact_Subscription__c();
        contSubTemp3.Role__c = 'TechnicianAdministrator;Technician';
        contSubTemp3.Contact__c = contactTemp3.Id;
        contSubTemp3.Subscription__c = subTemp1.Id;
        contSubTemp3.Asset__c = parentAsset1.Id;
		contSubTemp3.Active_Subscription1__c = true;
        insert contSubTemp3;


        // Associate the 3 contacts to the second subscription
        Contact_Subscription__c contSubTemp4 = new Contact_Subscription__c();
        contSubTemp4.Role__c = 'RenewalAdministrator';
        contSubTemp4.Contact__c = contactTemp1.Id;
        contSubTemp4.Subscription__c = subTemp2.Id;
        contSubTemp4.Asset__c = parentAsset1.Id;
		contSubTemp4.Active_Subscription1__c = true;
        insert contSubTemp4;

        Contact_Subscription__c contSubTemp5 = new Contact_Subscription__c();
        contSubTemp5.Role__c = 'CustomerAdministrator;Customer';
        contSubTemp5.Contact__c = contactTemp2.Id;
        contSubTemp5.Subscription__c = subTemp2.Id;
        contSubTemp5.Asset__c = parentAsset1.Id;
		contSubTemp5.Active_Subscription1__c = true;
        insert contSubTemp5;

        Contact_Subscription__c contSubTemp6 = new Contact_Subscription__c();
        contSubTemp6.Role__c = 'TechnicianAdministrator;Technician';
        contSubTemp6.Contact__c = contactTemp3.Id;
        contSubTemp6.Subscription__c = subTemp2.Id;
        contSubTemp6.Asset__c = parentAsset1.Id;
		contSubTemp6.Active_Subscription1__c = true;
        insert contSubTemp6;


        // Associate the 3 contacts to the third subscription
        Contact_Subscription__c contSubTemp7 = new Contact_Subscription__c();
        contSubTemp7.Role__c = 'RenewalAdministrator';
        contSubTemp7.Contact__c = contactTemp1.Id;
        contSubTemp7.Subscription__c = subTemp3.Id;
        contSubTemp7.Asset__c = parentAsset2.Id;
		contSubTemp7.Active_Subscription1__c = true;
        insert contSubTemp7;

        Contact_Subscription__c contSubTemp8 = new Contact_Subscription__c();
        contSubTemp8.Role__c = 'CustomerAdministrator;Customer';
        contSubTemp8.Contact__c = contactTemp2.Id;
        contSubTemp8.Subscription__c = subTemp3.Id;
        contSubTemp8.Asset__c = parentAsset2.Id;
		contSubTemp8.Active_Subscription1__c = true;
        insert contSubTemp8;

        Contact_Subscription__c contSubTemp9 = new Contact_Subscription__c();
        contSubTemp9.Role__c = 'TechnicianAdministrator;Technician';
        contSubTemp9.Contact__c = contactTemp3.Id;
        contSubTemp9.Subscription__c = subTemp3.Id;
        contSubTemp9.Asset__c = parentAsset2.Id;
		contSubTemp9.Active_Subscription1__c = true;
        insert contSubTemp9;


        // Associate the 3 contacts to the fourth subscription
        Contact_Subscription__c contSubTemp10 = new Contact_Subscription__c();
        contSubTemp10.Role__c = 'RenewalAdministrator';
        contSubTemp10.Contact__c = contactTemp1.Id;
        contSubTemp10.Subscription__c = subTemp4.Id;
        contSubTemp10.Asset__c = parentAsset2.Id;
		contSubTemp10.Active_Subscription1__c = true;
        insert contSubTemp10;

        Contact_Subscription__c contSubTemp11 = new Contact_Subscription__c();
        contSubTemp11.Role__c = 'CustomerAdministrator;Customer';
        contSubTemp11.Contact__c = contactTemp2.Id;
        contSubTemp11.Subscription__c = subTemp4.Id;
        contSubTemp11.Asset__c = parentAsset2.Id;
		contSubTemp11.Active_Subscription1__c = true;
        insert contSubTemp11;

        Contact_Subscription__c contSubTemp12 = new Contact_Subscription__c();
        contSubTemp12.Role__c = 'TechnicianAdministrator;Technician';
        contSubTemp12.Contact__c = contactTemp3.Id;
        contSubTemp12.Subscription__c = subTemp4.Id;
        contSubTemp12.Asset__c = parentAsset2.Id;
		contSubTemp12.Active_Subscription1__c = true;
        insert contSubTemp12;


        // ---------------Setup Rest Request Object for the test:
        IERenewal_SubscriptionUpdateService.RenewalOrderRequest testRequest = new IERenewal_SubscriptionUpdateService.RenewalOrderRequest();
        testRequest.orderTypeId = 'Domestic';
        testRequest.assetUnits = new List<IERenewal_SubscriptionUpdateService.Asset_Unit>();

        // *** First asset
        IERenewal_SubscriptionUpdateService.Asset_Unit assetUnit1 = new IERenewal_SubscriptionUpdateService.Asset_Unit();
        assetUnit1.serialNumber = 'SN123Test_1';
        assetUnit1.subscriptionInfoList = new List<IERenewal_SubscriptionUpdateService.Subscription_Info>();

        // First subscription for first asset
        IERenewal_SubscriptionUpdateService.Subscription_Info subInfo1 = new IERenewal_SubscriptionUpdateService.Subscription_Info();
        subInfo1.startDate = currDateTime;
        subInfo1.endDate = currDateTime.addMonths(12);
        subInfo1.connectivityType = 'Cellular';
        subInfo1.termYears = 1.25;
        subInfo1.subscriptionType = 'CustomRead'; // set to a type that is not in SF so we get a mismatch
        subInfo1.contactInfoList = new List<IERenewal_SubscriptionUpdateService.Contact_Info>();

        // First contact for first subscription
        IERenewal_SubscriptionUpdateService.Contact_Info contInfo1 = new IERenewal_SubscriptionUpdateService.Contact_Info();
        contInfo1.email = 'kent.roessler@daikinapplied.com';
        contInfo1.firstName = 'Kent1';
        contInfo1.middleName = '';
        contInfo1.lastName = 'Roessler1';
        contInfo1.customerAdmin = false;
        contInfo1.technicianAdmin = false;
        contInfo1.customer = false;
        contInfo1.technician = false;
        contInfo1.renewalAdmin = true;
        contInfo1.orgName = 'Account Test1';
        contInfo1.orgAddress = 'Test Address Line 1';
        contInfo1.orgCity = 'Minneapolis';
        contInfo1.orgState = 'Minnesota';
        contInfo1.orgCountry = 'United States';
        contInfo1.orgZip = '55421';
        subInfo1.contactInfoList.add(contInfo1);

        // Second contact for first subscription
        IERenewal_SubscriptionUpdateService.Contact_Info contInfo2 = new IERenewal_SubscriptionUpdateService.Contact_Info();
        contInfo2.email = 'kent.roessler@daikinapplied.com';
        contInfo2.firstName = 'Kent2';
        contInfo2.middleName = '';
        contInfo2.lastName = 'Roessler2';
        contInfo2.customerAdmin = true;
        contInfo2.technicianAdmin = false;
        contInfo2.customer = true;
        contInfo2.technician = false;
        contInfo2.renewalAdmin = false;
        contInfo2.orgName = 'Account Test1';
        contInfo2.orgAddress = 'Test Address Line 1';
        contInfo2.orgCity = 'Minneapolis';
        contInfo2.orgState = 'Minnesota';
        contInfo2.orgCountry = 'United States';
        contInfo2.orgZip = '55421';
        subInfo1.contactInfoList.add(contInfo2);

        // Third contact for first subscription
        IERenewal_SubscriptionUpdateService.Contact_Info contInfo3 = new IERenewal_SubscriptionUpdateService.Contact_Info();
        contInfo3.email = 'kent.roessler@daikinapplied.com';
        contInfo3.firstName = 'Kent3';
        contInfo3.middleName = '';
        contInfo3.lastName = 'Roessler3';
        contInfo3.customerAdmin = false;
        contInfo3.technicianAdmin = true;
        contInfo3.customer = false;
        contInfo3.technician = true;
        contInfo3.renewalAdmin = false;
        contInfo3.orgName = 'Account Test1';
        contInfo3.orgAddress = 'Test Address Line 1';
        contInfo3.orgCity = 'Minneapolis';
        contInfo3.orgState = 'Minnesota';
        contInfo3.orgCountry = 'United States';
        contInfo3.orgZip = '55421';
        subInfo1.contactInfoList.add(contInfo3);

        // Add first subscription to first asset
        assetUnit1.subscriptionInfoList.add(subInfo1);


        // Add first asset to list of assets for the order
        testRequest.assetUnits.add(assetUnit1);


        RestContext.request = new System.RestRequest();
        RestContext.request.requestBody = Blob.valueOf( JSON.serialize(testRequest) );

        Test.startTest();

            RestContext.response = new System.RestResponse();
            IERenewal_SubscriptionUpdateService.doPut();

        Test.stopTest();

        IERenewal_SubscriptionUpdateService.RenewalOrderResponse theResponse = (IERenewal_SubscriptionUpdateService.RenewalOrderResponse)JSON.deserialize( RestContext.response.responseBody.toString(), IERenewal_SubscriptionUpdateService.RenewalOrderResponse.class );
        // Loop through the Response Statuses and make sure there are no errors
        for (IERenewal_SubscriptionUpdateService.Subscription_Update_Status subUpdateStatus : theResponse.Statuses) {
            if (!subUpdateStatus.Errors.isEmpty()) {
                System.debug(logginglevel.error, subUpdateStatus.Errors);
                for (IERenewal_SubscriptionUpdateService.Response_Error err : subUpdateStatus.Errors) {
                    System.assertEquals('No Subscription Type Match', err.ErrorCode);
                    System.assertEquals('For asset serial number SN123Test_1, no matches were found in the RenewalOrderRequest object for subscription type TechReadWrite', err.ErrorMessage);
                }
            }
        }
    }


    @isTest static void testPut_AccountAndContactDoNotExist() {
        // -------------Setup Test Data in Salesforce objects:

        //!!!!!!!!!!! Need to add this code snippet for AvaTax- AccountAddressTrigger to run successfully on Before Insert into the Account table !!!!!!!!!!!!!!!!!
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c();
        ts1.AVA_SFCORE__Active_Setting__c = true;
        ts1.Name='Test Account';
        insert ts1;

		// Set these static control variables to True to avoid trigger code execution
		TriggerUtility.limitIntegrationBatch = true;
		TriggerUtility.limitContactExecution = true;

        // Create Address__c, Account, Account_Address__c records
        Account acctTemp = null;
        Address__c addrTemp = null;
        Account_Address__c acctAddrJunctionObj = null;
        
        addrTemp = new Address__c();
        addrTemp.Address_Line_1__c = 'Test Address Line 1';
        addrTemp.City__c = 'Minneapolis';
        addrTemp.Postal_Code__c = '55421';
        addrTemp.Country__c = 'United States';
        addrTemp.State_Province__c = 'Minnesota';
        insert addrTemp;
        
        acctTemp = new Account();
        acctTemp.Name = 'Account Test1';
        acctTemp.Type = 'Developer';
        acctTemp.Physical_Address__c = addrTemp.Id;
        acctTemp.IE_Account__c = true;
        acctTemp.Record_Usage__c = 'IE';
        insert acctTemp;
        
        acctAddrJunctionObj = new Account_Address__c();
        acctAddrJunctionObj.Account__c = acctTemp.Id;
        acctAddrJunctionObj.Address__c = addrTemp.Id;
        acctAddrJunctionObj.Active__c = true;
        acctAddrJunctionObj.Physical__c = true;
        insert acctAddrJunctionObj;


        // Create Order__c and Product2 records
        Order__c orderTemp1 = null;
        orderTemp1 = new Order__c();
        orderTemp1.Job_Name__c = 'Test Order Job Name 1';
        orderTemp1.Order_Type_ID__c = 'Domestic';
        insert orderTemp1;

        Product2 prodTemp1 = null;
        prodTemp1 = new Product2();
        prodTemp1.Name = 'Test Prod1';
        prodTemp1.Vendor_Supplier__c = 'Test Vendor1';
        prodTemp1.IsActive = true;
        prodTemp1.Description = 'Test Description1';
        prodTemp1.DW_PCL_Description__c = 'Test DW PCL Description1';
        prodTemp1.Apttus_Product__c = true;
        prodTemp1.Product_Category__c = 'Test Category1';
        insert prodTemp1;

        Product2 prodTemp2 = null;
        prodTemp2 = new Product2();
        prodTemp2.Name = 'Test Prod2';
        prodTemp2.Vendor_Supplier__c = 'Test Vendor2';
        prodTemp2.IsActive = true;
        prodTemp2.Description = 'Test Description2';
        prodTemp2.DW_PCL_Description__c = 'Test DW PCL Description2';
        prodTemp2.Apttus_Product__c = true;
        prodTemp2.Product_Category__c = 'Test Category2';
        insert prodTemp2;

        Product2 prodTemp3 = null;
        prodTemp3 = new Product2();
        prodTemp3.Name = 'Intelligent Equipment Gateway';
        prodTemp3.Vendor_Supplier__c = 'Test Vendor3';
        prodTemp3.IsActive = true;
        prodTemp3.Description = 'Test Description3';
        prodTemp3.DW_PCL_Description__c = 'Test DW PCL Description3';
        prodTemp3.Apttus_Product__c = true;
        prodTemp3.Product_Category__c = 'Test Category3';
        insert prodTemp3;

        Product2 prodTemp4 = null;
        prodTemp4 = new Product2();
        prodTemp4.Name = 'Intelligent Equipment Energy Management Module';
        prodTemp4.Vendor_Supplier__c = 'Test Vendor4';
        prodTemp4.IsActive = true;
        prodTemp4.Description = 'Test Description4';
        prodTemp4.DW_PCL_Description__c = 'Test DW PCL Description4';
        prodTemp4.Apttus_Product__c = true;
        prodTemp4.Product_Category__c = 'Test Category4';
        insert prodTemp4;
        
        
        // Create Parent Asset records
        Asset parentAsset1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test_1', Tag__c='Order Tag 1');
        parentAsset1.Product2Id = prodTemp1.Id;
        parentAsset1.Order__c = orderTemp1.Id;
        parentAsset1.IE_Asset__c = true;
        insert parentAsset1;

        Asset parentAsset2 = new Asset(Name = 'Asset Test2', AccountId = acctTemp.Id, SerialNumber='SN123Test_2', Tag__c='Order Tag 2');
        parentAsset2.Product2Id = prodTemp2.Id;
        parentAsset2.Order__c = orderTemp1.Id;
        parentAsset2.IE_Asset__c = true;
        insert parentAsset2;


        // Create Related Asset Records for each Parent Asset
        Asset relatedAsset1 = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-075', Parent_Asset__c = parentAsset1.Id);
        relatedAsset1.Product2Id = prodTemp3.Id;
        relatedAsset1.SIM_Card_Active__c = true;
        insert relatedAsset1;

        Asset relatedAsset2 = new Asset(Name = 'Intelligent Equipment Energy Management Module', AccountId = acctTemp.Id, SerialNumber = 'MESF04115', Parent_Asset__c = parentAsset1.Id);
        relatedAsset2.Product2Id = prodTemp4.Id;
        relatedAsset2.SIM_Card_Active__c = true;
        insert relatedAsset2;

        Asset relatedAsset3 = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-075', Parent_Asset__c = parentAsset2.Id);
        relatedAsset3.Product2Id = prodTemp3.Id;
        relatedAsset3.SIM_Card_Active__c = true;
        insert relatedAsset3;

        Asset relatedAsset4 = new Asset(Name = 'Intelligent Equipment Energy Management Module', AccountId = acctTemp.Id, SerialNumber = 'MESF04115', Parent_Asset__c = parentAsset2.Id);
        relatedAsset4.Product2Id = prodTemp4.Id;
        relatedAsset4.SIM_Card_Active__c = true;
        insert relatedAsset4;


        // Create Contact(3), Subscription(4) and Contact_Subscription(12) records
        Datetime currDateTime = Datetime.now();
        RecordType recordTypeTemp = [SELECT Id FROM RecordType WHERE Name='Daikin Applied' AND SObjectType='Contact'];

        Contact contactTemp1 = new Contact();
        contactTemp1.Eprise_Login_ID__c = 'RoesslKS1';
        contactTemp1.RecordTypeId = recordTypeTemp.Id;
        contactTemp1.AccountId = acctTemp.Id;
        contactTemp1.Status__c = 'Active';
        contactTemp1.Email = 'kent.roessler@daikinapplied.com';
        contactTemp1.FirstName = 'Kent1';
        contactTemp1.LastName = 'Roessler1';
        insert contactTemp1;

        Contact contactTemp2 = new Contact();
        contactTemp2.Eprise_Login_ID__c = 'RoesslKS2';
        contactTemp2.RecordTypeId = recordTypeTemp.Id;
        contactTemp2.AccountId = acctTemp.Id;
        contactTemp2.Status__c = 'Active';
        contactTemp2.Email = 'kent.roessler@daikinapplied.com';
        contactTemp2.FirstName = 'Kent2';
        contactTemp2.LastName = 'Roessler2';
        insert contactTemp2;

        Contact contactTemp3 = new Contact();
        contactTemp3.Eprise_Login_ID__c = 'RoesslKS3';
        contactTemp3.RecordTypeId = recordTypeTemp.Id;
        contactTemp3.AccountId = acctTemp.Id;
        contactTemp3.Status__c = 'Active';
        contactTemp3.Email = 'kent.roessler@daikinapplied.com';
        contactTemp3.FirstName = 'Kent3';
        contactTemp3.LastName = 'Roessler3';
        insert contactTemp3;


        Subscription__c subTemp1 = new Subscription__c();
        subTemp1.Start_Date__c = currDateTime;
        subTemp1.End_Date__c = currDateTime.addMonths(12);
        subTemp1.Type__c = 'TechReadWrite';
        subTemp1.Active__c = true;
        subTemp1.Asset__c = parentAsset1.Id;
        subTemp1.Buyer_ID__c = acctTemp.Id;
        subTemp1.Renewal_Counter__c = 0;
        subTemp1.Connectivity_Type__c = 'Cellular';
        subTemp1.Term_Years__c = 1.0;
        subTemp1.Renewal_Notice_Current_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month__c = false;
        subTemp1.Renewal_Notice_Last_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp1.Renewal_Notice_Last_Month_Minus_1__c = false;
        insert subTemp1;

        Subscription__c subTemp2 = new Subscription__c();
        subTemp2.Start_Date__c = currDateTime;
        subTemp2.End_Date__c = currDateTime.addMonths(12);
        subTemp2.Type__c = 'CustomRead';
        subTemp2.Active__c = true;
        subTemp2.Asset__c = parentAsset1.Id;
        subTemp2.Buyer_ID__c = acctTemp.Id;
        subTemp2.Renewal_Counter__c = 0;
        subTemp2.Connectivity_Type__c = 'Cellular';
        subTemp2.Term_Years__c = 1.0;
        subTemp2.Renewal_Notice_Current_Month__c = false;
        subTemp2.Renewal_Notice_Next_Month__c = false;
        subTemp2.Renewal_Notice_Last_Month__c = false;
        subTemp2.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp2.Renewal_Notice_Last_Month_Minus_1__c = false;
        insert subTemp2;

        Subscription__c subTemp3 = new Subscription__c();
        subTemp3.Start_Date__c = currDateTime;
        subTemp3.End_Date__c = currDateTime.addMonths(12);
        subTemp3.Type__c = 'TechReadWrite';
        subTemp3.Active__c = true;
        subTemp3.Asset__c = parentAsset2.Id;
        subTemp3.Buyer_ID__c = acctTemp.Id;
        subTemp3.Renewal_Counter__c = 0;
        subTemp3.Connectivity_Type__c = 'Cellular';
        subTemp3.Term_Years__c = 1.0;
        subTemp3.Renewal_Notice_Current_Month__c = false;
        subTemp3.Renewal_Notice_Next_Month__c = false;
        subTemp3.Renewal_Notice_Last_Month__c = false;
        subTemp3.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp3.Renewal_Notice_Last_Month_Minus_1__c = false;
        insert subTemp3;

        Subscription__c subTemp4 = new Subscription__c();
        subTemp4.Start_Date__c = currDateTime;
        subTemp4.End_Date__c = currDateTime.addMonths(12);
        subTemp4.Type__c = 'CustomRead';
        subTemp4.Active__c = true;
        subTemp4.Asset__c = parentAsset2.Id;
        subTemp4.Buyer_ID__c = acctTemp.Id;
        subTemp4.Renewal_Counter__c = 0;
        subTemp4.Connectivity_Type__c = 'Cellular';
        subTemp4.Term_Years__c = 1.0;
        subTemp4.Renewal_Notice_Current_Month__c = false;
        subTemp4.Renewal_Notice_Next_Month__c = false;
        subTemp4.Renewal_Notice_Last_Month__c = false;
        subTemp4.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp4.Renewal_Notice_Last_Month_Minus_1__c = false;
        insert subTemp4;


        // Associate the 3 contacts to the first subscription
        Contact_Subscription__c contSubTemp1 = new Contact_Subscription__c();
        contSubTemp1.Role__c = 'RenewalAdministrator';
        contSubTemp1.Contact__c = contactTemp1.Id;
        contSubTemp1.Subscription__c = subTemp1.Id;
        contSubTemp1.Asset__c = parentAsset1.Id;
		contSubTemp1.Active_Subscription1__c = true;
        insert contSubTemp1;

        Contact_Subscription__c contSubTemp2 = new Contact_Subscription__c();
        contSubTemp2.Role__c = 'CustomerAdministrator;Customer';
        contSubTemp2.Contact__c = contactTemp2.Id;
        contSubTemp2.Subscription__c = subTemp1.Id;
        contSubTemp2.Asset__c = parentAsset1.Id;
		contSubTemp2.Active_Subscription1__c = true;
        insert contSubTemp2;

        Contact_Subscription__c contSubTemp3 = new Contact_Subscription__c();
        contSubTemp3.Role__c = 'TechnicianAdministrator;Technician';
        contSubTemp3.Contact__c = contactTemp3.Id;
        contSubTemp3.Subscription__c = subTemp1.Id;
        contSubTemp3.Asset__c = parentAsset1.Id;
		contSubTemp3.Active_Subscription1__c = true;
        insert contSubTemp3;


        // Associate the 3 contacts to the second subscription
        Contact_Subscription__c contSubTemp4 = new Contact_Subscription__c();
        contSubTemp4.Role__c = 'RenewalAdministrator';
        contSubTemp4.Contact__c = contactTemp1.Id;
        contSubTemp4.Subscription__c = subTemp2.Id;
        contSubTemp4.Asset__c = parentAsset1.Id;
		contSubTemp4.Active_Subscription1__c = true;
        insert contSubTemp4;

        Contact_Subscription__c contSubTemp5 = new Contact_Subscription__c();
        contSubTemp5.Role__c = 'CustomerAdministrator;Customer';
        contSubTemp5.Contact__c = contactTemp2.Id;
        contSubTemp5.Subscription__c = subTemp2.Id;
        contSubTemp5.Asset__c = parentAsset1.Id;
		contSubTemp5.Active_Subscription1__c = true;
        insert contSubTemp5;

        Contact_Subscription__c contSubTemp6 = new Contact_Subscription__c();
        contSubTemp6.Role__c = 'TechnicianAdministrator;Technician';
        contSubTemp6.Contact__c = contactTemp3.Id;
        contSubTemp6.Subscription__c = subTemp2.Id;
        contSubTemp6.Asset__c = parentAsset1.Id;
		contSubTemp6.Active_Subscription1__c = true;
        insert contSubTemp6;


        // Associate the 3 contacts to the third subscription
        Contact_Subscription__c contSubTemp7 = new Contact_Subscription__c();
        contSubTemp7.Role__c = 'RenewalAdministrator';
        contSubTemp7.Contact__c = contactTemp1.Id;
        contSubTemp7.Subscription__c = subTemp3.Id;
        contSubTemp7.Asset__c = parentAsset2.Id;
		contSubTemp7.Active_Subscription1__c = true;
        insert contSubTemp7;

        Contact_Subscription__c contSubTemp8 = new Contact_Subscription__c();
        contSubTemp8.Role__c = 'CustomerAdministrator;Customer';
        contSubTemp8.Contact__c = contactTemp2.Id;
        contSubTemp8.Subscription__c = subTemp3.Id;
        contSubTemp8.Asset__c = parentAsset2.Id;
		contSubTemp8.Active_Subscription1__c = true;
        insert contSubTemp8;

        Contact_Subscription__c contSubTemp9 = new Contact_Subscription__c();
        contSubTemp9.Role__c = 'TechnicianAdministrator;Technician';
        contSubTemp9.Contact__c = contactTemp3.Id;
        contSubTemp9.Subscription__c = subTemp3.Id;
        contSubTemp9.Asset__c = parentAsset2.Id;
		contSubTemp9.Active_Subscription1__c = true;
        insert contSubTemp9;


        // Associate the 3 contacts to the fourth subscription
        Contact_Subscription__c contSubTemp10 = new Contact_Subscription__c();
        contSubTemp10.Role__c = 'RenewalAdministrator';
        contSubTemp10.Contact__c = contactTemp1.Id;
        contSubTemp10.Subscription__c = subTemp4.Id;
        contSubTemp10.Asset__c = parentAsset2.Id;
		contSubTemp10.Active_Subscription1__c = true;
        insert contSubTemp10;

        Contact_Subscription__c contSubTemp11 = new Contact_Subscription__c();
        contSubTemp11.Role__c = 'CustomerAdministrator;Customer';
        contSubTemp11.Contact__c = contactTemp2.Id;
        contSubTemp11.Subscription__c = subTemp4.Id;
        contSubTemp11.Asset__c = parentAsset2.Id;
		contSubTemp11.Active_Subscription1__c = true;
        insert contSubTemp11;

        Contact_Subscription__c contSubTemp12 = new Contact_Subscription__c();
        contSubTemp12.Role__c = 'TechnicianAdministrator;Technician';
        contSubTemp12.Contact__c = contactTemp3.Id;
        contSubTemp12.Subscription__c = subTemp4.Id;
        contSubTemp12.Asset__c = parentAsset2.Id;
		contSubTemp12.Active_Subscription1__c = true;
        insert contSubTemp12;


        // ----------------Setup Rest Request Object with a new Contact and Account for the test:
        IERenewal_SubscriptionUpdateService.RenewalOrderRequest testRequest = new IERenewal_SubscriptionUpdateService.RenewalOrderRequest();
        testRequest.orderTypeId = 'Domestic';
        testRequest.assetUnits = new List<IERenewal_SubscriptionUpdateService.Asset_Unit>();

        // *** First asset
        IERenewal_SubscriptionUpdateService.Asset_Unit assetUnit1 = new IERenewal_SubscriptionUpdateService.Asset_Unit();
        assetUnit1.serialNumber = 'SN123Test_1';
        assetUnit1.subscriptionInfoList = new List<IERenewal_SubscriptionUpdateService.Subscription_Info>();

        // First subscription for first asset
        IERenewal_SubscriptionUpdateService.Subscription_Info subInfo1 = new IERenewal_SubscriptionUpdateService.Subscription_Info();
        subInfo1.startDate = currDateTime;
        subInfo1.endDate = currDateTime.addMonths(12);
        subInfo1.connectivityType = 'Cellular';
        subInfo1.termYears = 1.25;
        subInfo1.subscriptionType = 'TechReadWrite';
        subInfo1.contactInfoList = new List<IERenewal_SubscriptionUpdateService.Contact_Info>();

        // New contact and new account for first subscription
        IERenewal_SubscriptionUpdateService.Contact_Info contInfo1 = new IERenewal_SubscriptionUpdateService.Contact_Info();
        contInfo1.email = 'Mike.lyga@daikinapplied.com';
        contInfo1.firstName = 'Mike';
        contInfo1.middleName = '';
        contInfo1.lastName = 'Lyga';
        contInfo1.customerAdmin = false;
        contInfo1.technicianAdmin = false;
        contInfo1.customer = false;
        contInfo1.technician = false;
        contInfo1.renewalAdmin = true;
        contInfo1.orgName = 'New Account Test';
        contInfo1.orgAddress = 'New Account Test Address Line 1';
        contInfo1.orgCity = 'Minneapolis';
        contInfo1.orgState = 'Minnesota';
        contInfo1.orgCountry = 'United States';
        contInfo1.orgZip = '55421';
        subInfo1.contactInfoList.add(contInfo1);


        // Add first subscription to first asset
        assetUnit1.subscriptionInfoList.add(subInfo1);


        // Second subscription for first asset
        IERenewal_SubscriptionUpdateService.Subscription_Info subInfo2 = new IERenewal_SubscriptionUpdateService.Subscription_Info();
        subInfo2.startDate = currDateTime;
        subInfo2.endDate = currDateTime.addMonths(12);
        subInfo2.connectivityType = 'Cellular';
        subInfo2.termYears = 1.25;
        subInfo2.subscriptionType = 'CustomRead';
        subInfo2.contactInfoList = new List<IERenewal_SubscriptionUpdateService.Contact_Info>();

        // Existing contact and new account for second subscription
        IERenewal_SubscriptionUpdateService.Contact_Info contInfo4 = new IERenewal_SubscriptionUpdateService.Contact_Info();
        contInfo4.email = 'Mike.lyga@daikinapplied.com';
        contInfo4.firstName = 'Mike';
        contInfo4.middleName = '';
        contInfo4.lastName = 'Lyga';
        contInfo4.customerAdmin = false;
        contInfo4.technicianAdmin = false;
        contInfo4.customer = false;
        contInfo4.technician = false;
        contInfo4.renewalAdmin = true;
        contInfo4.orgName = 'New Account Test2';
        contInfo4.orgAddress = 'New Account Test2 Address Line 1';
        contInfo4.orgCity = 'Minneapolis';
        contInfo4.orgState = 'Minnesota';
        contInfo4.orgCountry = 'United States';
        contInfo4.orgZip = '55421';
        subInfo2.contactInfoList.add(contInfo4);


        // Add second subscription to first asset
        assetUnit1.subscriptionInfoList.add(subInfo2);


        // Add first asset to list of assets for the order
        testRequest.assetUnits.add(assetUnit1);


        RestContext.request = new System.RestRequest();
        RestContext.request.requestBody = Blob.valueOf( JSON.serialize(testRequest) );

        Test.startTest();

            RestContext.response = new System.RestResponse();
            IERenewal_SubscriptionUpdateService.doPut();

        Test.stopTest();

        IERenewal_SubscriptionUpdateService.RenewalOrderResponse theResponse = (IERenewal_SubscriptionUpdateService.RenewalOrderResponse)JSON.deserialize( RestContext.response.responseBody.toString(), IERenewal_SubscriptionUpdateService.RenewalOrderResponse.class );
        // Loop through the Response Statuses and make sure there are no errors
        for (IERenewal_SubscriptionUpdateService.Subscription_Update_Status subUpdateStatus : theResponse.Statuses) {
            if (!subUpdateStatus.Errors.isEmpty()) 
                System.debug(logginglevel.error, subUpdateStatus.Errors);

            System.assert(subUpdateStatus.Errors.isEmpty(), 'No errors should have been returned from the subscription update');
        }

        // Check that the new Contact, Accounts, and Contact Subscription records were created
        Contact[] cl = [SELECT Id, Email, LastName, FirstName, RecordTypeId, AccountId, Status__c, Middle_Name__c, IE_Contact__c, IE_Username__c, Record_Usage__c FROM Contact WHERE Email = :contInfo1.email AND LastName = :contInfo1.lastName AND FirstName = :contInfo1.firstName limit 1];
        System.assert(cl.size()>0, 'Test failed as the first contact was not found!');

        List<Account> acctList = [SELECT Id, Name, Physical_Address__c, (Select Id, Physical__c, Active__c, Account__c, Address__c from Account_Addresses__r)
                            FROM Account 
                            WHERE Name = :contInfo1.orgName];
        System.assert(!acctList.isEmpty(), 'Test failed as the first account was not found!');

        List<Account> acctList2 = [SELECT Id, Name, Physical_Address__c, (Select Id, Physical__c, Active__c, Account__c, Address__c from Account_Addresses__r)
                            FROM Account 
                            WHERE Name = :contInfo4.orgName];
        System.assert(acctList2.isEmpty(), 'Test failed as the second account with a CustomRead subscription was found and this should be ignored by the service!');

        Contact_Subscription__c[] csl = [Select Id, Role__c, Contact__c, Subscription__c, Serial_Number__c From Contact_Subscription__c Where Contact__c = :cl[0].Id AND Subscription__c = :subTemp1.Id AND Serial_Number__c = :assetUnit1.serialNumber];
        System.assert(csl.size()>0, 'Test failed as the first contact subscription association was not found!');

        Contact_Subscription__c[] csl2 = [Select Id, Role__c, Contact__c, Subscription__c, Serial_Number__c From Contact_Subscription__c Where Contact__c = :cl[0].Id AND Subscription__c = :subTemp2.Id AND Serial_Number__c = :assetUnit1.serialNumber];
        System.assert(csl2.size()==0, 'Test failed as the second contact subscription association with a CustomRead subscription was found and this should not have been created by the service!');

    }


/*
    @isTest static void testPut_syncIeCloudUnits_InSubscriptionTrigger() {
        // ----------------Setup Test Data in Salesforce objects:

        //!!!!!!!!!!! Need to add this code snippet for AvaTax- AccountAddressTrigger to run successfully on Before Insert into the Account table !!!!!!!!!!!!!!!!!
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c();
        ts1.AVA_SFCORE__Active_Setting__c = true;
        ts1.Name='Test Account';
        insert ts1;
        
        // Create Address__c, Account, Account_Address__c records
        Account acctTemp = null;
        Address__c addrTemp = null;
        Account_Address__c acctAddrJunctionObj = null;
        
        addrTemp = new Address__c();
        addrTemp.Address_Line_1__c = 'Test Address Line 1';
        addrTemp.Address_Line_2__c = 'Test Address Line 2';
        addrTemp.Address_Line_3__c = 'Test Address Line 3';
        addrTemp.Address_Line_4__c = 'Test Address Line 4';
        addrTemp.City__c = 'Minneapolis';
        addrTemp.Postal_Code__c = '55421';
        addrTemp.Country__c = 'United States';
        addrTemp.State_Province__c = 'Minnesota';
        insert addrTemp;
        
        acctTemp = new Account();
        acctTemp.Name = 'Account Test1';
        acctTemp.Type = 'Developer';
        acctTemp.Physical_Address__c = addrTemp.Id;
        acctTemp.IE_Account__c = true;
        acctTemp.Record_Usage__c = 'IE';
        insert acctTemp;
        
        acctAddrJunctionObj = new Account_Address__c();
        acctAddrJunctionObj.Account__c = acctTemp.Id;
        acctAddrJunctionObj.Address__c = addrTemp.Id;
        acctAddrJunctionObj.Active__c = true;
        acctAddrJunctionObj.Physical__c = true;
        insert acctAddrJunctionObj;
        

        // Create Product2 and Order__c records
        Product2 prodTemp1 = null;
        prodTemp1 = new Product2();
        prodTemp1.Name = 'Test Prod1';
        prodTemp1.Vendor_Supplier__c = 'Test Vendor1';
        prodTemp1.IsActive = true;
        prodTemp1.Description = 'Test Description1';
        prodTemp1.DW_PCL_Description__c = 'Test DW PCL Description1';
        prodTemp1.Apttus_Product__c = true;
        prodTemp1.Product_Category__c = 'Test Category1';
        prodTemp1.ProductCode = 'DPS015A';
        insert prodTemp1;

        Product2 prodTemp2 = null;
        prodTemp2 = new Product2();
        prodTemp2.Name = 'Test Prod2';
        prodTemp2.Vendor_Supplier__c = 'Test Vendor2';
        prodTemp2.IsActive = true;
        prodTemp2.Description = 'Test Description2';
        prodTemp2.DW_PCL_Description__c = 'Test DW PCL Description2';
        prodTemp2.Apttus_Product__c = true;
        prodTemp2.Product_Category__c = 'Test Category2';
        prodTemp2.ProductCode = 'DPS015A';
        insert prodTemp2;

        Product2 prodTemp3 = null;
        prodTemp3 = new Product2();
        prodTemp3.Name = 'Intelligent Equipment Gateway';
        prodTemp3.Vendor_Supplier__c = 'Test Vendor3';
        prodTemp3.IsActive = true;
        prodTemp3.Description = 'Test Description3';
        prodTemp3.DW_PCL_Description__c = 'Test DW PCL Description3';
        prodTemp3.Apttus_Product__c = true;
        prodTemp3.Product_Category__c = 'Test Category3';
        insert prodTemp3;

        Product2 prodTemp4 = null;
        prodTemp4 = new Product2();
        prodTemp4.Name = 'Intelligent Equipment Energy Management Module';
        prodTemp4.Vendor_Supplier__c = 'Test Vendor4';
        prodTemp4.IsActive = true;
        prodTemp4.Description = 'Test Description4';
        prodTemp4.DW_PCL_Description__c = 'Test DW PCL Description4';
        prodTemp4.Apttus_Product__c = true;
        prodTemp4.Product_Category__c = 'Test Category4';
        insert prodTemp4;

        Order__c orderTemp1 = null;
        orderTemp1 = new Order__c();
        orderTemp1.Job_Name__c = 'Test Order Job Name 1';
        orderTemp1.Order_Type_ID__c = 'Domestic'; //'International'
        insert orderTemp1;
        

        // Create Parent Asset records
        Asset parentAsset1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test_1', Tag__c='Order Tag 1');
        parentAsset1.Product2Id = prodTemp1.Id;
        parentAsset1.Order__c = orderTemp1.Id;
        parentAsset1.IE_Asset__c = true;
        insert parentAsset1;

        Asset parentAsset2 = new Asset(Name = 'Asset Test2', AccountId = acctTemp.Id, SerialNumber='SN123Test_2', Tag__c='Order Tag 2');
        parentAsset2.Product2Id = prodTemp2.Id;
        parentAsset2.Order__c = orderTemp1.Id;
        parentAsset2.IE_ID__c = '999';  // forces a Put operation in the trigger for subscriptions tied to this asset
        parentAsset2.IE_Asset__c = true;
        insert parentAsset2;


        // Create Related Asset Records for each Parent Asset
        Asset relatedAsset1 = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-075', Parent_Asset__c = parentAsset1.Id);
        relatedAsset1.Product2Id = prodTemp3.Id;
        relatedAsset1.SIM_Card_Active__c = true;
        relatedAsset1.SIM_Card_ICCID__c = '89011704258018735310';
        insert relatedAsset1;

        Asset relatedAsset2 = new Asset(Name = 'Intelligent Equipment Energy Management Module', AccountId = acctTemp.Id, SerialNumber = 'MESF04115', Parent_Asset__c = parentAsset1.Id);
        relatedAsset2.Product2Id = prodTemp4.Id;
        relatedAsset2.SIM_Card_Active__c = true;
        insert relatedAsset2;

        Asset relatedAsset3 = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-075', Parent_Asset__c = parentAsset2.Id);
        relatedAsset3.Product2Id = prodTemp3.Id;
        relatedAsset3.SIM_Card_Active__c = true;
        relatedAsset3.SIM_Card_ICCID__c = 'some text89011704258018735310some text';
        insert relatedAsset3;

        Asset relatedAsset4 = new Asset(Name = 'Intelligent Equipment Energy Management Module', AccountId = acctTemp.Id, SerialNumber = 'MESF04115', Parent_Asset__c = parentAsset2.Id);
        relatedAsset4.Product2Id = prodTemp4.Id;
        relatedAsset4.SIM_Card_Active__c = true;
        insert relatedAsset4;



        // Create Contact(3), Subscription(4) and Contact_Subscription(12) records
        Datetime currDateTime = Datetime.now();
        Date currentDate = Date.today();
        RecordType recordTypeTemp = [SELECT Id FROM RecordType WHERE Name='Daikin Applied' AND SObjectType='Contact'];

        Contact contactTemp1 = new Contact();
        contactTemp1.Eprise_Login_ID__c = 'RoesslKS1';
        contactTemp1.RecordTypeId = recordTypeTemp.Id;
        contactTemp1.AccountId = acctTemp.Id;
        contactTemp1.Status__c = 'Active';
        contactTemp1.Email = 'kent.roessler@daikinapplied.com';
        contactTemp1.FirstName = 'Kent1';
        contactTemp1.LastName = 'Roessler1';
        insert contactTemp1;

        Contact contactTemp2 = new Contact();
        contactTemp2.Eprise_Login_ID__c = 'RoesslKS2';
        contactTemp2.RecordTypeId = recordTypeTemp.Id;
        contactTemp2.AccountId = acctTemp.Id;
        contactTemp2.Status__c = 'Active';
        contactTemp2.Email = 'kent.roessler@daikinapplied.com';
        contactTemp2.FirstName = 'Kent2';
        contactTemp2.LastName = 'Roessler2';
        insert contactTemp2;

        Contact contactTemp3 = new Contact();
        contactTemp3.Eprise_Login_ID__c = 'RoesslKS3';
        contactTemp3.RecordTypeId = recordTypeTemp.Id;
        contactTemp3.AccountId = acctTemp.Id;
        contactTemp3.Status__c = 'Active';
        contactTemp3.Email = 'kent.roessler@daikinapplied.com';
        contactTemp3.FirstName = 'Kent3';
        contactTemp3.LastName = 'Roessler3';
        insert contactTemp3;


        
        // TechReadWrite Subscription whose end date > current date (ie, not expired, uses Post operation in trigger)
        Subscription__c subTemp1 = new Subscription__c();
        subTemp1.Start_Date__c = currDateTime;
        subTemp1.End_Date__c = currDateTime.addMonths(12);
        subTemp1.Type__c = 'TechReadWrite';
        subTemp1.Active__c = true;
        subTemp1.IE_Subscription__c = true;
        subTemp1.Asset__c = parentAsset1.Id;
        subTemp1.Buyer_ID__c = acctTemp.Id;
        subTemp1.Renewal_Counter__c = 1;  // Renewal Subscription has been renewed once
        subTemp1.Last_Renewal_Date__c = currentDate.addMonths(-12);
        subTemp1.Renewal_Date__c = currentDate;
        subTemp1.Connectivity_Type__c = 'Cellular';
        subTemp1.Term_Years__c = 1.0;
        subTemp1.Renewal_Notice_Current_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month__c = false;
        subTemp1.Renewal_Notice_Last_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp1.Renewal_Notice_Last_Month_Minus_1__c = false;
        insert subTemp1;
        
        
        // CustomRead Subscription whose end date > current date (ie, not expired, uses Post operation in trigger)
        Subscription__c subTemp2 = new Subscription__c();
        subTemp2.Start_Date__c = currDateTime;
        subTemp2.End_Date__c = currDateTime.addMonths(12);
        subTemp2.Type__c = 'CustomRead';
        subTemp2.Active__c = true;
        subTemp2.IE_Subscription__c = true;
        subTemp2.Asset__c = parentAsset1.Id;
        subTemp2.Buyer_ID__c = acctTemp.Id;
        subTemp2.Renewal_Counter__c = 1;  // Renewal Subscription has been renewed once
        subTemp2.Last_Renewal_Date__c = currentDate.addMonths(-12);
        subTemp2.Renewal_Date__c = currentDate;
        subTemp2.Connectivity_Type__c = 'Cellular';
        subTemp2.Term_Years__c = 1.0;
        subTemp2.Renewal_Notice_Current_Month__c = false;
        subTemp2.Renewal_Notice_Next_Month__c = false;
        subTemp2.Renewal_Notice_Last_Month__c = false;
        subTemp2.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp2.Renewal_Notice_Last_Month_Minus_1__c = false;
        insert subTemp2;
        

        // TechReadWrite Subscription whose end date >= current date and it already has an IE ID (ie, not expired, uses Put operation in trigger)
        Subscription__c subTemp3 = new Subscription__c();
        subTemp3.Start_Date__c = currDateTime;
        subTemp3.End_Date__c = currDateTime.addMonths(12);
        subTemp3.Type__c = 'TechReadWrite';
        subTemp3.Active__c = true;
        subTemp3.IE_Subscription__c = true;
        subTemp3.Asset__c = parentAsset2.Id;
        subTemp3.Buyer_ID__c = acctTemp.Id;
        subTemp3.Renewal_Counter__c = 0;
        subTemp3.Last_Renewal_Date__c = null;
        subTemp3.Renewal_Date__c = null;
        subTemp3.Connectivity_Type__c = 'Cellular';
        subTemp3.Term_Years__c = 1.0;
        subTemp3.Renewal_Notice_Current_Month__c = false;
        subTemp3.Renewal_Notice_Next_Month__c = false;
        subTemp3.Renewal_Notice_Last_Month__c = false;
        subTemp3.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp3.Renewal_Notice_Last_Month_Minus_1__c = false;
        insert subTemp3;
        

        // CustomRead Subscription whose end date >= current date and it already has an IE ID (ie, not expired, uses Put operation in trigger)
        Subscription__c subTemp4 = new Subscription__c();
        subTemp4.Start_Date__c = currDateTime;
        subTemp4.End_Date__c = currDateTime.addMonths(12);
        subTemp4.Type__c = 'CustomRead';
        subTemp4.Active__c = true;
        subTemp4.IE_Subscription__c = true;
        subTemp4.Asset__c = parentAsset2.Id;
        subTemp4.Buyer_ID__c = acctTemp.Id;
        subTemp4.Renewal_Counter__c = 0;
        subTemp4.Last_Renewal_Date__c = null;
        subTemp4.Renewal_Date__c = null;
        subTemp4.Connectivity_Type__c = 'Cellular';
        subTemp4.Term_Years__c = 1.0;
        subTemp4.Renewal_Notice_Current_Month__c = false;
        subTemp4.Renewal_Notice_Next_Month__c = false;
        subTemp4.Renewal_Notice_Last_Month__c = false;
        subTemp4.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp4.Renewal_Notice_Last_Month_Minus_1__c = false;
        insert subTemp4;
        

        // Associate the 3 contacts to the first subscription
        Contact_Subscription__c contSubTemp1 = new Contact_Subscription__c();
        contSubTemp1.Role__c = 'RenewalAdministrator';
        contSubTemp1.Contact__c = contactTemp1.Id;
        contSubTemp1.Subscription__c = subTemp1.Id;
        contSubTemp1.Asset__c = parentAsset1.Id;
        insert contSubTemp1;

        Contact_Subscription__c contSubTemp2 = new Contact_Subscription__c();
        contSubTemp2.Role__c = 'CustomerAdministrator;Customer';
        contSubTemp2.Contact__c = contactTemp2.Id;
        contSubTemp2.Subscription__c = subTemp1.Id;
        contSubTemp2.Asset__c = parentAsset1.Id;
        insert contSubTemp2;

        Contact_Subscription__c contSubTemp3 = new Contact_Subscription__c();
        contSubTemp3.Role__c = 'TechnicianAdministrator;Technician';
        contSubTemp3.Contact__c = contactTemp3.Id;
        contSubTemp3.Subscription__c = subTemp1.Id;
        contSubTemp3.Asset__c = parentAsset1.Id;
        insert contSubTemp3;


        // Associate the 3 contacts to the second subscription
        Contact_Subscription__c contSubTemp4 = new Contact_Subscription__c();
        contSubTemp4.Role__c = 'RenewalAdministrator';
        contSubTemp4.Contact__c = contactTemp1.Id;
        contSubTemp4.Subscription__c = subTemp2.Id;
        contSubTemp4.Asset__c = parentAsset1.Id;
        insert contSubTemp4;

        Contact_Subscription__c contSubTemp5 = new Contact_Subscription__c();
        contSubTemp5.Role__c = 'CustomerAdministrator;Customer';
        contSubTemp5.Contact__c = contactTemp2.Id;
        contSubTemp5.Subscription__c = subTemp2.Id;
        contSubTemp5.Asset__c = parentAsset1.Id;
        insert contSubTemp5;

        Contact_Subscription__c contSubTemp6 = new Contact_Subscription__c();
        contSubTemp6.Role__c = 'TechnicianAdministrator;Technician';
        contSubTemp6.Contact__c = contactTemp3.Id;
        contSubTemp6.Subscription__c = subTemp2.Id;
        contSubTemp6.Asset__c = parentAsset1.Id;
        insert contSubTemp6;


        // Associate the 3 contacts to the third subscription
        Contact_Subscription__c contSubTemp7 = new Contact_Subscription__c();
        contSubTemp7.Role__c = 'RenewalAdministrator';
        contSubTemp7.Contact__c = contactTemp1.Id;
        contSubTemp7.Subscription__c = subTemp3.Id;
        contSubTemp7.Asset__c = parentAsset2.Id;
        insert contSubTemp7;

        Contact_Subscription__c contSubTemp8 = new Contact_Subscription__c();
        contSubTemp8.Role__c = 'CustomerAdministrator;Customer';
        contSubTemp8.Contact__c = contactTemp2.Id;
        contSubTemp8.Subscription__c = subTemp3.Id;
        contSubTemp8.Asset__c = parentAsset2.Id;
        insert contSubTemp8;

        Contact_Subscription__c contSubTemp9 = new Contact_Subscription__c();
        contSubTemp9.Role__c = 'TechnicianAdministrator;Technician';
        contSubTemp9.Contact__c = contactTemp3.Id;
        contSubTemp9.Subscription__c = subTemp3.Id;
        contSubTemp9.Asset__c = parentAsset2.Id;
        insert contSubTemp9;


        // Associate the 3 contacts to the fourth subscription
        Contact_Subscription__c contSubTemp10 = new Contact_Subscription__c();
        contSubTemp10.Role__c = 'RenewalAdministrator';
        contSubTemp10.Contact__c = contactTemp1.Id;
        contSubTemp10.Subscription__c = subTemp4.Id;
        contSubTemp10.Asset__c = parentAsset2.Id;
        insert contSubTemp10;

        Contact_Subscription__c contSubTemp11 = new Contact_Subscription__c();
        contSubTemp11.Role__c = 'CustomerAdministrator;Customer';
        contSubTemp11.Contact__c = contactTemp2.Id;
        contSubTemp11.Subscription__c = subTemp4.Id;
        contSubTemp11.Asset__c = parentAsset2.Id;
        insert contSubTemp11;

        Contact_Subscription__c contSubTemp12 = new Contact_Subscription__c();
        contSubTemp12.Role__c = 'TechnicianAdministrator;Technician';
        contSubTemp12.Contact__c = contactTemp3.Id;
        contSubTemp12.Subscription__c = subTemp4.Id;
        contSubTemp12.Asset__c = parentAsset2.Id;
        insert contSubTemp12;



        // ----------------Setup Rest Request Object for the test:
        IERenewal_SubscriptionUpdateService.RenewalOrderRequest testRequest = new IERenewal_SubscriptionUpdateService.RenewalOrderRequest();
        testRequest.orderTypeId = 'Domestic';
        testRequest.assetUnits = new List<IERenewal_SubscriptionUpdateService.Asset_Unit>();

        // *** First asset
        IERenewal_SubscriptionUpdateService.Asset_Unit assetUnit1 = new IERenewal_SubscriptionUpdateService.Asset_Unit();
        assetUnit1.serialNumber = 'SN123Test_1';
        assetUnit1.subscriptionInfoList = new List<IERenewal_SubscriptionUpdateService.Subscription_Info>();

        // First subscription for first asset
        IERenewal_SubscriptionUpdateService.Subscription_Info subInfo1 = new IERenewal_SubscriptionUpdateService.Subscription_Info();
        subInfo1.startDate = currDateTime;
        subInfo1.endDate = currDateTime.addMonths(12);
        subInfo1.connectivityType = 'Cellular';
        subInfo1.termYears = 1.0;
        subInfo1.subscriptionType = 'TechReadWrite';
        subInfo1.contactInfoList = new List<IERenewal_SubscriptionUpdateService.Contact_Info>();

        // First contact for first subscription
        IERenewal_SubscriptionUpdateService.Contact_Info contInfo1 = new IERenewal_SubscriptionUpdateService.Contact_Info();
        contInfo1.email = 'kent.roessler@daikinapplied.com';
        contInfo1.firstName = 'Kent1';
        contInfo1.middleName = '';
        contInfo1.lastName = 'Roessler1';
        contInfo1.customerAdmin = false;
        contInfo1.technicianAdmin = false;
        contInfo1.customer = false;
        contInfo1.technician = false;
        contInfo1.renewalAdmin = true;
        contInfo1.orgName = 'Account Test1';
        contInfo1.orgAddress = 'Test Address Line 1';
        contInfo1.orgCity = 'Minneapolis';
        contInfo1.orgState = 'Minnesota';
        contInfo1.orgCountry = 'United States';
        contInfo1.orgZip = '55421';
        subInfo1.contactInfoList.add(contInfo1);

        // Second contact for first subscription
        IERenewal_SubscriptionUpdateService.Contact_Info contInfo2 = new IERenewal_SubscriptionUpdateService.Contact_Info();
        contInfo2.email = 'kent.roessler@daikinapplied.com';
        contInfo2.firstName = 'Kent2';
        contInfo2.middleName = '';
        contInfo2.lastName = 'Roessler2';
        contInfo2.customerAdmin = true;
        contInfo2.technicianAdmin = false;
        contInfo2.customer = true;
        contInfo2.technician = false;
        contInfo2.renewalAdmin = false;
        contInfo2.orgName = 'Account Test1';
        contInfo2.orgAddress = 'Test Address Line 1';
        contInfo2.orgCity = 'Minneapolis';
        contInfo2.orgState = 'Minnesota';
        contInfo2.orgCountry = 'United States';
        contInfo2.orgZip = '55421';
        subInfo1.contactInfoList.add(contInfo2);

        // Third contact for first subscription
        IERenewal_SubscriptionUpdateService.Contact_Info contInfo3 = new IERenewal_SubscriptionUpdateService.Contact_Info();
        contInfo3.email = 'kent.roessler@daikinapplied.com';
        contInfo3.firstName = 'Kent3';
        contInfo3.middleName = '';
        contInfo3.lastName = 'Roessler3';
        contInfo3.customerAdmin = false;
        contInfo3.technicianAdmin = true;
        contInfo3.customer = false;
        contInfo3.technician = true;
        contInfo3.renewalAdmin = false;
        contInfo3.orgName = 'Account Test1';
        contInfo3.orgAddress = 'Test Address Line 1';
        contInfo3.orgCity = 'Minneapolis';
        contInfo3.orgState = 'Minnesota';
        contInfo3.orgCountry = 'United States';
        contInfo3.orgZip = '55421';
        subInfo1.contactInfoList.add(contInfo3);

        // Add first subscription to first asset
        assetUnit1.subscriptionInfoList.add(subInfo1);


        // Second subscription for first asset
        IERenewal_SubscriptionUpdateService.Subscription_Info subInfo2 = new IERenewal_SubscriptionUpdateService.Subscription_Info();
        subInfo2.startDate = currDateTime;
        subInfo2.endDate = currDateTime.addMonths(12);
        subInfo2.connectivityType = 'Cellular';
        subInfo2.termYears = 1.0;
        subInfo2.subscriptionType = 'CustomRead';
        subInfo2.contactInfoList = new List<IERenewal_SubscriptionUpdateService.Contact_Info>();

        // First contact for second subscription
        IERenewal_SubscriptionUpdateService.Contact_Info contInfo4 = new IERenewal_SubscriptionUpdateService.Contact_Info();
        contInfo4.email = 'kent.roessler@daikinapplied.com';
        contInfo4.firstName = 'Kent1';
        contInfo4.middleName = '';
        contInfo4.lastName = 'Roessler1';
        contInfo4.customerAdmin = false;
        contInfo4.technicianAdmin = false;
        contInfo4.customer = false;
        contInfo4.technician = false;
        contInfo4.renewalAdmin = true;
        contInfo4.orgName = 'Account Test1';
        contInfo4.orgAddress = 'Test Address Line 1';
        contInfo4.orgCity = 'Minneapolis';
        contInfo4.orgState = 'Minnesota';
        contInfo4.orgCountry = 'United States';
        contInfo4.orgZip = '55421';
        subInfo2.contactInfoList.add(contInfo4);

        // Second contact for second subscription
        IERenewal_SubscriptionUpdateService.Contact_Info contInfo5 = new IERenewal_SubscriptionUpdateService.Contact_Info();
        contInfo5.email = 'kent.roessler@daikinapplied.com';
        contInfo5.firstName = 'Kent2';
        contInfo5.middleName = '';
        contInfo5.lastName = 'Roessler2';
        contInfo5.customerAdmin = true;
        contInfo5.technicianAdmin = false;
        contInfo5.customer = true;
        contInfo5.technician = false;
        contInfo5.renewalAdmin = false;
        contInfo5.orgName = 'Account Test1';
        contInfo5.orgAddress = 'Test Address Line 1';
        contInfo5.orgCity = 'Minneapolis';
        contInfo5.orgState = 'Minnesota';
        contInfo5.orgCountry = 'United States';
        contInfo5.orgZip = '55421';
        subInfo2.contactInfoList.add(contInfo5);

        // Third contact for second subscription
        IERenewal_SubscriptionUpdateService.Contact_Info contInfo6 = new IERenewal_SubscriptionUpdateService.Contact_Info();
        contInfo6.email = 'kent.roessler@daikinapplied.com';
        contInfo6.firstName = 'Kent3';
        contInfo6.middleName = '';
        contInfo6.lastName = 'Roessler3';
        contInfo6.customerAdmin = false;
        contInfo6.technicianAdmin = true;
        contInfo6.customer = false;
        contInfo6.technician = true;
        contInfo6.renewalAdmin = false;
        contInfo6.orgName = 'Account Test1';
        contInfo6.orgAddress = 'Test Address Line 1';
        contInfo6.orgCity = 'Minneapolis';
        contInfo6.orgState = 'Minnesota';
        contInfo6.orgCountry = 'United States';
        contInfo6.orgZip = '55421';
        subInfo2.contactInfoList.add(contInfo6);

        // Add second subscription to first asset
        assetUnit1.subscriptionInfoList.add(subInfo2);


        // Add first asset to list of assets for the order
        testRequest.assetUnits.add(assetUnit1);


        // *** Second asset
        IERenewal_SubscriptionUpdateService.Asset_Unit assetUnit2 = new IERenewal_SubscriptionUpdateService.Asset_Unit();
        assetUnit2.serialNumber = 'SN123Test_2';
        assetUnit2.subscriptionInfoList = new List<IERenewal_SubscriptionUpdateService.Subscription_Info>();

        // First subscription for second asset
        IERenewal_SubscriptionUpdateService.Subscription_Info subInfo3 = new IERenewal_SubscriptionUpdateService.Subscription_Info();
        subInfo3.startDate = currDateTime;
        subInfo3.endDate = currDateTime.addMonths(12);
        subInfo3.connectivityType = 'Cellular';
        subInfo3.termYears = 1.0;
        subInfo3.subscriptionType = 'TechReadWrite';
        subInfo3.contactInfoList = new List<IERenewal_SubscriptionUpdateService.Contact_Info>();

        // First contact for first subscription
        IERenewal_SubscriptionUpdateService.Contact_Info contInfo7 = new IERenewal_SubscriptionUpdateService.Contact_Info();
        contInfo7.email = 'kent.roessler@daikinapplied.com';
        contInfo7.firstName = 'Kent1';
        contInfo7.middleName = '';
        contInfo7.lastName = 'Roessler1';
        contInfo7.customerAdmin = false;
        contInfo7.technicianAdmin = false;
        contInfo7.customer = false;
        contInfo7.technician = false;
        contInfo7.renewalAdmin = true;
        contInfo7.orgName = 'Account Test1';
        contInfo7.orgAddress = 'Test Address Line 1';
        contInfo7.orgCity = 'Minneapolis';
        contInfo7.orgState = 'Minnesota';
        contInfo7.orgCountry = 'United States';
        contInfo7.orgZip = '55421';
        subInfo3.contactInfoList.add(contInfo7);

        // Second contact for first subscription
        IERenewal_SubscriptionUpdateService.Contact_Info contInfo8 = new IERenewal_SubscriptionUpdateService.Contact_Info();
        contInfo8.email = 'kent.roessler@daikinapplied.com';
        contInfo8.firstName = 'Kent2';
        contInfo8.middleName = '';
        contInfo8.lastName = 'Roessler2';
        contInfo8.customerAdmin = true;
        contInfo8.technicianAdmin = false;
        contInfo8.customer = true;
        contInfo8.technician = false;
        contInfo8.renewalAdmin = false;
        contInfo8.orgName = 'Account Test1';
        contInfo8.orgAddress = 'Test Address Line 1';
        contInfo8.orgCity = 'Minneapolis';
        contInfo8.orgState = 'Minnesota';
        contInfo8.orgCountry = 'United States';
        contInfo8.orgZip = '55421';
        subInfo3.contactInfoList.add(contInfo8);

        // Third contact for first subscription
        IERenewal_SubscriptionUpdateService.Contact_Info contInfo9 = new IERenewal_SubscriptionUpdateService.Contact_Info();
        contInfo9.email = 'kent.roessler@daikinapplied.com';
        contInfo9.firstName = 'Kent3';
        contInfo9.middleName = '';
        contInfo9.lastName = 'Roessler3';
        contInfo9.customerAdmin = false;
        contInfo9.technicianAdmin = true;
        contInfo9.customer = false;
        contInfo9.technician = true;
        contInfo9.renewalAdmin = false;
        contInfo9.orgName = 'Account Test1';
        contInfo9.orgAddress = 'Test Address Line 1';
        contInfo9.orgCity = 'Minneapolis';
        contInfo9.orgState = 'Minnesota';
        contInfo9.orgCountry = 'United States';
        contInfo9.orgZip = '55421';
        subInfo3.contactInfoList.add(contInfo9);

        // Add first subscription to second asset
        assetUnit2.subscriptionInfoList.add(subInfo3);


        // Second subscription for second asset
        IERenewal_SubscriptionUpdateService.Subscription_Info subInfo4 = new IERenewal_SubscriptionUpdateService.Subscription_Info();
        subInfo4.startDate = currDateTime;
        subInfo4.endDate = currDateTime.addMonths(12);
        subInfo4.connectivityType = 'Cellular';
        subInfo4.termYears = 1.0;
        subInfo4.subscriptionType = 'CustomRead';
        subInfo4.contactInfoList = new List<IERenewal_SubscriptionUpdateService.Contact_Info>();

        // First contact for second subscription
        IERenewal_SubscriptionUpdateService.Contact_Info contInfo10 = new IERenewal_SubscriptionUpdateService.Contact_Info();
        contInfo10.email = 'kent.roessler@daikinapplied.com';
        contInfo10.firstName = 'Kent1';
        contInfo10.middleName = '';
        contInfo10.lastName = 'Roessler1';
        contInfo10.customerAdmin = false;
        contInfo10.technicianAdmin = false;
        contInfo10.customer = false;
        contInfo10.technician = false;
        contInfo10.renewalAdmin = true;
        contInfo10.orgName = 'Account Test1';
        contInfo10.orgAddress = 'Test Address Line 1';
        contInfo10.orgCity = 'Minneapolis';
        contInfo10.orgState = 'Minnesota';
        contInfo10.orgCountry = 'United States';
        contInfo10.orgZip = '55421';
        subInfo4.contactInfoList.add(contInfo10);

        // Second contact for second subscription
        IERenewal_SubscriptionUpdateService.Contact_Info contInfo11 = new IERenewal_SubscriptionUpdateService.Contact_Info();
        contInfo11.email = 'kent.roessler@daikinapplied.com';
        contInfo11.firstName = 'Kent2';
        contInfo11.middleName = '';
        contInfo11.lastName = 'Roessler2';
        contInfo11.customerAdmin = true;
        contInfo11.technicianAdmin = false;
        contInfo11.customer = true;
        contInfo11.technician = false;
        contInfo11.renewalAdmin = false;
        contInfo11.orgName = 'Account Test1';
        contInfo11.orgAddress = 'Test Address Line 1';
        contInfo11.orgCity = 'Minneapolis';
        contInfo11.orgState = 'Minnesota';
        contInfo11.orgCountry = 'United States';
        contInfo11.orgZip = '55421';
        subInfo4.contactInfoList.add(contInfo11);

        // Third contact for second subscription
        IERenewal_SubscriptionUpdateService.Contact_Info contInfo12 = new IERenewal_SubscriptionUpdateService.Contact_Info();
        contInfo12.email = 'kent.roessler@daikinapplied.com';
        contInfo12.firstName = 'Kent3';
        contInfo12.middleName = '';
        contInfo12.lastName = 'Roessler3';
        contInfo12.customerAdmin = false;
        contInfo12.technicianAdmin = true;
        contInfo12.customer = false;
        contInfo12.technician = true;
        contInfo12.renewalAdmin = false;
        contInfo12.orgName = 'Account Test1';
        contInfo12.orgAddress = 'Test Address Line 1';
        contInfo12.orgCity = 'Minneapolis';
        contInfo12.orgState = 'Minnesota';
        contInfo12.orgCountry = 'United States';
        contInfo12.orgZip = '55421';
        subInfo4.contactInfoList.add(contInfo12);

        // Add second subscription to second asset
        assetUnit2.subscriptionInfoList.add(subInfo4);


        // Add second asset to list of assets for the order
        testRequest.assetUnits.add(assetUnit2);


        RestContext.request = new System.RestRequest();
        RestContext.request.requestBody = Blob.valueOf( JSON.serialize(testRequest) );



        //------------------------------Start Test----------------------------------
        Test.startTest();
        
            RestContext.response = new System.RestResponse();
            IERenewal_SubscriptionUpdateService.doPut();
        
        Test.stopTest();
        //------------------------------End Test------------------------------------
        
        
        //------------------------------Verify Test Results---------------------------
        IERenewal_SubscriptionUpdateService.RenewalOrderResponse theResponse = (IERenewal_SubscriptionUpdateService.RenewalOrderResponse)JSON.deserialize( RestContext.response.responseBody.toString(), IERenewal_SubscriptionUpdateService.RenewalOrderResponse.class );
        // Loop through the Response Statuses and make sure there are no errors
        for (IERenewal_SubscriptionUpdateService.Subscription_Update_Status subUpdateStatus : theResponse.Statuses) {
            if (!subUpdateStatus.Errors.isEmpty()) 
                System.debug(logginglevel.error, subUpdateStatus.Errors);

            System.assert(subUpdateStatus.Errors.isEmpty(), 'No errors should have been returned from the subscription update');
        }

        Asset pa1 = [SELECT Id, IE_Id__c, IE_Sync_Status__c from Asset Where Id = :parentAsset1.Id];
        System.assertEquals(null, pa1.IE_Id__c);
        System.assertEquals('Processed', pa1.IE_Sync_Status__c);

        Asset pa2 = [SELECT Id, IE_Id__c, IE_Sync_Status__c from Asset Where Id = :parentAsset2.Id];
        System.assertEquals('999', pa2.IE_Id__c);
        System.assertEquals('Processed', pa2.IE_Sync_Status__c);

    }


*/
}