@isTest
private class Batch_IE_ProcObsGWAssets_Test {
	
	static testMethod void testBatchExecution_ProcessObsoleteGWAssets() {
		//!!!!!!!!!!! Need to add this code snippet for AvaTax- AccountAddressTrigger to run successfully on Before Insert into the Account table !!!!!!!!!!!!!!!!!
    	AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c();
        ts1.AVA_SFCORE__Active_Setting__c = true;
        ts1.Name='Test Account';
        insert ts1;

        // ---------------------------------CREATE TEST DATA----------------------------
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
        Asset parentAsset1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test1', Tag__c='Order Tag 1');
        parentAsset1.Product2Id = prodTemp1.Id;
        parentAsset1.Order__c = orderTemp1.Id;
        parentAsset1.IE_Asset__c = true;
        insert parentAsset1;

        Asset parentAsset2 = new Asset(Name = 'Asset Test2', AccountId = acctTemp.Id, SerialNumber='SN123Test2', Tag__c='Order Tag 2');
        parentAsset2.Product2Id = prodTemp2.Id;
        parentAsset2.Order__c = orderTemp1.Id;
        parentAsset2.IE_Asset__c = true;
        parentAsset2.IE_ID__c = '999';  // forces a Put operation in the service call for subscriptions tied to this asset
        insert parentAsset2;

		Test.startTest();

        // Create Related Asset Records for each Parent Asset
        Asset relatedAsset1 = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-075', Parent_Asset__c = parentAsset1.Id);
        relatedAsset1.Product2Id = prodTemp3.Id;
        relatedAsset1.SIM_Card_Active__c = true;
        relatedAsset1.SIM_Card_ICCID__c = '89011704258018735310';
        relatedAsset1.Status = 'Obsolete';
        insert relatedAsset1;

        Asset relatedAsset2 = new Asset(Name = 'Intelligent Equipment Energy Management Module', AccountId = acctTemp.Id, SerialNumber = 'MESF04115', Parent_Asset__c = parentAsset1.Id);
        relatedAsset2.Product2Id = prodTemp4.Id;
        relatedAsset2.SIM_Card_Active__c = true;
        insert relatedAsset2;

        Asset relatedAsset3 = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-075', Parent_Asset__c = parentAsset2.Id);
        relatedAsset3.Product2Id = prodTemp3.Id;
        relatedAsset3.SIM_Card_Active__c = true;
        relatedAsset3.SIM_Card_ICCID__c = 'some text89011704258018735310some text';
        relatedAsset3.Status = 'Obsolete';
        insert relatedAsset3;

        Asset relatedAsset4 = new Asset(Name = 'Intelligent Equipment Energy Management Module', AccountId = acctTemp.Id, SerialNumber = 'MESF04115', Parent_Asset__c = parentAsset2.Id);
        relatedAsset4.Product2Id = prodTemp4.Id;
        relatedAsset4.SIM_Card_Active__c = true;
        insert relatedAsset4;


		//Test.startTest(); // moved this here to start another context since we were running into soql query limit exception

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


        Subscription__c subTemp1 = new Subscription__c();
        subTemp1.IE_Subscription__c = true;
        subTemp1.Start_Date__c = currDateTime;
        subTemp1.End_Date__c = currDateTime.addMonths(-1);  // Set End Date to Last Month
        subTemp1.Type__c = 'TechReadWrite';
        subTemp1.Active__c = false;
        subTemp1.Asset__c = parentAsset1.Id;
        subTemp1.Buyer_ID__c = acctTemp.Id;
        subTemp1.Renewal_Counter__c = 0;
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
        subTemp2.End_Date__c = currDateTime.addMonths(-1);
        subTemp2.Type__c = 'CustomRead';
        subTemp2.Active__c = false;
        subTemp2.Asset__c = parentAsset1.Id;
        subTemp2.Buyer_ID__c = acctTemp.Id;
        subTemp2.Renewal_Counter__c = 0;
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
        subTemp3.Start_Date__c = currDateTime.addMonths(-7);  // Set Start Date < 6 months ago
        subTemp3.End_Date__c = currDateTime.addMonths(12);
        subTemp3.Type__c = 'TechReadWrite';
        subTemp3.Active__c = false;
        subTemp3.Asset__c = parentAsset2.Id;
        subTemp3.Buyer_ID__c = acctTemp.Id;
        subTemp3.Renewal_Counter__c = 0;
        subTemp3.Last_Renewal_Date__c = null;
        subTemp3.Renewal_Date__c = null;
        subTemp3.Connectivity_Type__c = 'WiFi/LAN';
        subTemp3.Term_Years__c = 0.25;
        subTemp3.Renewal_Notice_Current_Month__c = false;
        subTemp3.Renewal_Notice_Next_Month__c = false;
        subTemp3.Renewal_Notice_Last_Month__c = false;
        subTemp3.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp3.Renewal_Notice_Last_Month_Minus_1__c = false;
        insert subTemp3;

        Subscription__c subTemp4 = new Subscription__c();
        subTemp4.IE_Subscription__c = true;
        subTemp4.Start_Date__c = currDateTime.addMonths(-7);
        subTemp4.End_Date__c = currDateTime.addMonths(12);
        subTemp4.Type__c = 'CustomRead';
        subTemp4.Active__c = false;
        subTemp4.Asset__c = parentAsset2.Id;
        subTemp4.Buyer_ID__c = acctTemp.Id;
        subTemp4.Renewal_Counter__c = 0;
        subTemp4.Last_Renewal_Date__c = null;
        subTemp4.Renewal_Date__c = null;
        subTemp4.Connectivity_Type__c = 'WiFi/LAN';
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


        //------------------------------Start Test----------------------------------
        //Test.startTest();
        
        	Batch_IE_ProcObsGWAssets iepogwa = new Batch_IE_ProcObsGWAssets();
	        ID batchProcessId = Database.executeBatch(iepogwa);
        
        Test.stopTest();
        //------------------------------End Test------------------------------------
 

 		//------------------------------Verify Test Results---------------------------
 		Asset gwAsset1 = [SELECT Id, SIM_Card_Active__c from Asset Where Id = :relatedAsset1.Id];
 		System.assertEquals(false, gwAsset1.SIM_Card_Active__c);

 		Asset gwAsset2 = [SELECT Id, SIM_Card_Active__c from Asset Where Id = :relatedAsset3.Id];
 		System.assertEquals(false, gwAsset2.SIM_Card_Active__c);

 		Asset pAsset1 = [SELECT Id, IE_Sync_Status__c from Asset Where Id = :parentAsset1.Id];
 		System.assertEquals('Processed', pAsset1.IE_Sync_Status__c);

 		Asset pAsset2 = [SELECT Id, IE_Sync_Status__c from Asset Where Id = :parentAsset2.Id];
 		System.assertEquals('Processed', pAsset2.IE_Sync_Status__c);

	}


	static testMethod void testBatchExecution_ExceptionThrown_syncIeCloudSIMCardActiveStatus() {
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
        insert acctTemp;
        
        acctAddrJunctionObj = new Account_Address__c();
        acctAddrJunctionObj.Account__c = acctTemp.Id;
        acctAddrJunctionObj.Address__c = addrTemp.Id;
        acctAddrJunctionObj.Active__c = true;
        acctAddrJunctionObj.Physical__c = true;
        insert acctAddrJunctionObj;
        

        // Create Product2, Order__c records
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
        Asset parentAsset1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test1', Tag__c='Order Tag 1');
        parentAsset1.Product2Id = prodTemp1.Id;
        parentAsset1.Order__c = orderTemp1.Id;
        parentAsset1.IE_Asset__c = true;
        insert parentAsset1;


        // Create Related Asset Records for each Parent Asset
        Asset relatedAsset1 = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-075', Parent_Asset__c = parentAsset1.Id);
        relatedAsset1.Product2Id = prodTemp3.Id;
        relatedAsset1.SIM_Card_Active__c = true;
        relatedAsset1.SIM_Card_ICCID__c = '89011704258018735310';
        relatedAsset1.Status = 'Obsolete';
        insert relatedAsset1;

        Asset relatedAsset2 = new Asset(Name = 'Intelligent Equipment Energy Management Module', AccountId = acctTemp.Id, SerialNumber = 'MESF04115', Parent_Asset__c = parentAsset1.Id);
        relatedAsset2.Product2Id = prodTemp4.Id;
        relatedAsset2.SIM_Card_Active__c = true;
        insert relatedAsset2;


        // Create Contact records
        Contact contactTemp1 = null;
        RecordType recordTypeTemp = null;
        
        recordTypeTemp = [SELECT Id FROM RecordType WHERE Name='Daikin Applied' AND SObjectType='Contact'];
        
        contactTemp1 = new Contact();
        contactTemp1.Eprise_Login_ID__c = 'RoesslKS1';
        contactTemp1.RecordTypeId = recordTypeTemp.Id;
        contactTemp1.AccountId = acctTemp.Id;
        contactTemp1.Status__c = 'Active';
        contactTemp1.Email = 'kent.roessler@daikinapplied.com';
        contactTemp1.FirstName = 'Kent1';
        contactTemp1.LastName = 'Roessler1';
        insert contactTemp1;


        //Subscription whose end date > current date, parent asset has no IE ID value (ie, not expired, uses Post operation)
        Datetime currDateTime = Datetime.now();
        Date currentDate = Date.today();
        Subscription__c subTemp1 = new Subscription__c();
        subTemp1.TriggerInvokedByAPI__c = true;
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
        
        Contact_Subscription__c contSubTemp1 = new Contact_Subscription__c();
        //Role__c needs to be set to 'TechnicianAdministrator' or 'CustomerAdministrator'
        contSubTemp1.Role__c = 'CustomerAdministrator';
        contSubTemp1.Contact__c = contactTemp1.Id;
        contSubTemp1.Subscription__c = subTemp1.Id;
        contSubTemp1.Asset__c = parentAsset1.Id;
        insert contSubTemp1;




        //------------------------------Start Test----------------------------------
        Test.startTest();

        	Batch_IE_ProcObsGWAssets iepogwa = new Batch_IE_ProcObsGWAssets();


	        // Force an exception to be thrown
	        Batch_IE_ProcObsGWAssets.crash_syncIeCloudSIMCardActiveStatus_TestByException = true;

	        ID batchProcessId = Database.executeBatch(iepogwa);

        	
        Test.stopTest();
        //------------------------------End Test------------------------------------
        
        
        //------------------------------Verify Test Results---------------------------
        Integration_Error__c[] errObj = [select Error_Description__c, Integration_Object__c, Integration_Point__c, Request_Data__c from Integration_Error__c where Integration_Object__c = 'Asset'];
        System.assert(errObj != null);
        System.assertEquals('CALLOUT_EXCEPTION', errObj[0].Error_Description__c);
        System.assertEquals('General Exception from Batch_IE_ProcObsGWAssets', errObj[1].Error_Description__c);

        Asset pa1 = [SELECT Id, IE_Id__c, IE_Sync_Status__c from Asset Where Id = :parentAsset1.Id];
 		System.assertEquals(null, pa1.IE_Id__c);
 		System.assertEquals('Processed', pa1.IE_Sync_Status__c);

	}


	static testMethod void testBatchExecution_ResponseStatusCodeError_syncIeCloudSIMCardActiveStatus() {
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
        insert acctTemp;
        
        acctAddrJunctionObj = new Account_Address__c();
        acctAddrJunctionObj.Account__c = acctTemp.Id;
        acctAddrJunctionObj.Address__c = addrTemp.Id;
        acctAddrJunctionObj.Active__c = true;
        acctAddrJunctionObj.Physical__c = true;
        insert acctAddrJunctionObj;
        

        // Create Product2, Order__c records
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
        Asset parentAsset1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test1', Tag__c='Order Tag 1');
        parentAsset1.Product2Id = prodTemp1.Id;
        parentAsset1.Order__c = orderTemp1.Id;
        parentAsset1.IE_Asset__c = true;
        insert parentAsset1;


        // Create Related Asset Records for each Parent Asset
        Asset relatedAsset1 = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-075', Parent_Asset__c = parentAsset1.Id);
        relatedAsset1.Product2Id = prodTemp3.Id;
        relatedAsset1.SIM_Card_Active__c = true;
        relatedAsset1.SIM_Card_ICCID__c = '89011704258018735310';
        relatedAsset1.Status = 'Obsolete';
        insert relatedAsset1;

        Asset relatedAsset2 = new Asset(Name = 'Intelligent Equipment Energy Management Module', AccountId = acctTemp.Id, SerialNumber = 'MESF04115', Parent_Asset__c = parentAsset1.Id);
        relatedAsset2.Product2Id = prodTemp4.Id;
        relatedAsset2.SIM_Card_Active__c = true;
        insert relatedAsset2;


        // Create Contact records
        Contact contactTemp1 = null;
        RecordType recordTypeTemp = null;
        
        recordTypeTemp = [SELECT Id FROM RecordType WHERE Name='Daikin Applied' AND SObjectType='Contact'];
        
        contactTemp1 = new Contact();
        contactTemp1.Eprise_Login_ID__c = 'RoesslKS1';
        contactTemp1.RecordTypeId = recordTypeTemp.Id;
        contactTemp1.AccountId = acctTemp.Id;
        contactTemp1.Status__c = 'Active';
        contactTemp1.Email = 'kent.roessler@daikinapplied.com';
        contactTemp1.FirstName = 'Kent1';
        contactTemp1.LastName = 'Roessler1';
        insert contactTemp1;


        //Subscription whose end date > current date, parent asset has no IE ID value (ie, not expired, uses Post operation)
        Datetime currDateTime = Datetime.now();
        Date currentDate = Date.today();
        Subscription__c subTemp1 = new Subscription__c();
        subTemp1.TriggerInvokedByAPI__c = true;
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
        
        Contact_Subscription__c contSubTemp1 = new Contact_Subscription__c();
        //Role__c needs to be set to 'TechnicianAdministrator' or 'CustomerAdministrator'
        contSubTemp1.Role__c = 'CustomerAdministrator';
        contSubTemp1.Contact__c = contactTemp1.Id;
        contSubTemp1.Subscription__c = subTemp1.Id;
        contSubTemp1.Asset__c = parentAsset1.Id;
        insert contSubTemp1;





        //------------------------------Start Test----------------------------------
        Test.startTest();

        	Batch_IE_ProcObsGWAssets iepogwa = new Batch_IE_ProcObsGWAssets();


	        // Force an unsuccessful http response status code
	        Batch_IE_ProcObsGWAssets.crash_syncIeCloudSIMCardActiveStatus_TestByResponseStatusCode = true;

	        ID batchProcessId = Database.executeBatch(iepogwa);

        Test.stopTest();
        //------------------------------End Test------------------------------------
        
        
        //------------------------------Verify Test Results---------------------------
        Integration_Error__c[] errObj = [select Error_Description__c, Integration_Object__c, Integration_Point__c, Request_Data__c from Integration_Error__c where Integration_Object__c = 'Asset'];
        System.assert(errObj != null);
        System.assertEquals('Transmission Error [0]', errObj[0].Error_Description__c);
        System.assertEquals('General Exception from Batch_IE_ProcObsGWAssets', errObj[1].Error_Description__c);

        Asset pa1 = [SELECT Id, IE_Id__c, IE_Sync_Status__c from Asset Where Id = :parentAsset1.Id];
 		System.assertEquals(null, pa1.IE_Id__c);
 		System.assertEquals('Processed', pa1.IE_Sync_Status__c);

	}



	static testmethod void testBatch_IE_ProcObsGWAssets_Sched() {
      Test.startTest();
      //define the CRON Expression, format: Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
      String CRON_EXP;
      CRON_EXP = '0 0 3 * * ?'; //class runs every day at 3am
      Batch_IE_ProcObsGWAssets_Sched s = new Batch_IE_ProcObsGWAssets_Sched();
      SchedulableContext sc;
      s.execute(sc);
      System.schedule('test-Batch_IE_ProcObsGWAssets_Sched', CRON_EXP, s);
      Test.stopTest();
   }
	
}