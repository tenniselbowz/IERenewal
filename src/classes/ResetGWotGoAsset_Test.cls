@isTest 
private class ResetGWotGoAsset_Test {
// Assumption - The "Dummy GWotGo Unit Asset" and "Holding GWotGo Unit Asset" must exist in your testing environment.
// NOTE: Need to use the @isTest(SeeAllData=true) annotation because some of the test methods need to access
// the Dummy and Holding Unit Asset records

// ************
// By using the Test.startTest() & Test.stopTest() you get 2X governer limits.
// In nutshell you have 2 context:
//  1. Outside of Test.startTest() & Test.stopTest() and
//  2. Inside of Test.startTest() & Test.stopTest().
// In both context you get separate limits.
// ************


	@isTest(SeeAllData=true) static void testPut_processRequest_MoveGWotGoFromDummyToRealUnit1() {
		// ----------------Setup Test Data in Salesforce objects:

		//!!!!!!!!!!! Need to add this code snippet for AvaTax- AccountAddressTrigger to run successfully on Before Insert into the Account table !!!!!!!!!!!!!!!!!
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;

		Datetime currDateTime = Datetime.now();
        Date currentDate = Date.today();
        RecordType recordTypeTemp = [SELECT Id FROM RecordType WHERE Name='Daikin Applied' AND SObjectType='Contact'];

		// Get Dummy Unit Asset for GWotGo
		Asset dummyUnitAsset = [SELECT Id, Name from Asset Where Name = 'Dummy GWotGo Unit Asset'];

		// Get Holding Unit Asset for GWotGo
		Asset holdingUnitAsset = [SELECT Id, Name from Asset Where Name = 'Holding GWotGo Unit Asset'];


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
        acctTemp.IE_Sync_Status__c = 'Pending';
		acctTemp.IE_ID__c = null;  // Forces a POST operation in the IE Organizations Service call
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
        orderTemp1.Order_Entry_Date__c = Date.today();
        orderTemp1.SO_Number__c = 'SO #999';
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
        
        
        // Create Parent Asset record with a GWotGo
        Asset parentAsset1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test1', Tag__c='Order Tag 1');
        parentAsset1.Product2Id = prodTemp1.Id;
        parentAsset1.Order__c = orderTemp1.Id;
		parentAsset1.Asset_Address__c = addrTemp.Id;
        parentAsset1.IE_Asset__c = true;
        parentAsset1.Code_String_Breakdown__c = '[{"code_sequence":"1","code_value":"MPS","code_description":"UNIT TYPE; Unit Type"},{"code_sequence":"2","code_value":"003B","code_description":"UNIT SIZE; 3 ton, R410A"},{"code_sequence":"3","code_value":"Y","code_description":"HEAT; None"},{"code_sequence":"4","code_value":"D","code_description":"VOLTAGE/POWER CONNECTION; 460 V power"},{"code_sequence":"5","code_value":"M","code_description":"DRIVE PACKAGE; Belt drive - high static"},{"code_sequence":"6","code_value":"00D","code_description":"HEATING CAPACITY/CONTROLS; DDC controls"},{"code_sequence":"7","code_value":"CZ","code_description":"OPTIONS; HP,LP,LowAmb/Comfort Aler,FldPower GFI, Hail Guard"},{"code_sequence":"8","code_value":"D","code_description":"ECONOMIZER; Field Mounted 0-30% Outside air hood"}]';
        insert parentAsset1;

		//Create Asset Address record
        Asset_Address__c aa = new Asset_Address__c(Asset__c = parentAsset1.Id
                                                  ,Address__c = addrTemp.Id
                                                  ,Building_Identifier__c = '123');
        insert aa;
        
		
        // Create GWotGo Asset Record for the Parent Asset
        Asset relatedAsset1 = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-075', Parent_Asset__c = parentAsset1.Id);
        relatedAsset1.Product2Id = prodTemp3.Id;
        relatedAsset1.SIM_Card_Active__c = true;
        relatedAsset1.SIM_Card_ICCID__c = '89011704258018735310';
		relatedAsset1.GWotGo__c = true;
		relatedAsset1.Commissioned__c = true;
		relatedAsset1.ResetSuccessful__c = 'None';
		relatedAsset1.MAC_Address__c = '000000000001';
        insert relatedAsset1;

		// Create Subscription Pair and a Permanent Contact
		Contact contactTemp1 = new Contact();
        contactTemp1.Eprise_Login_ID__c = 'RoesslKS1';
        contactTemp1.RecordTypeId = recordTypeTemp.Id;
        contactTemp1.AccountId = acctTemp.Id;
        contactTemp1.Status__c = 'Active';
        contactTemp1.Email = 'kent.roessler@daikinapplied.com';
        contactTemp1.FirstName = 'Kent1';
        contactTemp1.LastName = 'Roessler1';
        contactTemp1.IE_Sync_Status__c = 'Processed'; // Don't set to Pending so it executes the contact_subscription_trigger
        contactTemp1.IE_Contact__c = true;
        // Create an address for this contact
        Address__c addrTemp2 = new Address__c();
        addrTemp2.Address_Line_1__c = 'Test Address Line 1';
        addrTemp2.City__c = 'Minneapolis';
        addrTemp2.Postal_Code__c = '55421';
        addrTemp2.Country__c = 'United States';
        addrTemp2.State_Province__c = 'Minnesota';
        insert addrTemp2;
        contactTemp1.Physical_Address__c = addrTemp2.Id;
        insert contactTemp1;

		Contact_Address__c contactAddrJunctionObj = new Contact_Address__c();
        contactAddrJunctionObj.Contact__c = contactTemp1.Id;
        contactAddrJunctionObj.Address__c = addrTemp2.Id;
        contactAddrJunctionObj.Active__c = true;
        contactAddrJunctionObj.Physical__c = true;
        insert contactAddrJunctionObj;

		Subscription__c subTemp1 = new Subscription__c();
        subTemp1.TriggerInvokedByAPI__c = false;
        subTemp1.IE_Subscription__c = true;
        subTemp1.Start_Date__c = currDateTime;
        subTemp1.End_Date__c = currDateTime.addMonths(6);
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
        subTemp2.TriggerInvokedByAPI__c = false;
        subTemp2.IE_Subscription__c = true;
        subTemp2.Start_Date__c = currDateTime;
        subTemp2.End_Date__c = currDateTime.addMonths(6);
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

		// Associate the contact to the subscription
        Contact_Subscription__c contSubTemp1 = new Contact_Subscription__c();
        contSubTemp1.Role__c = 'TechnicianAdministrator';
        contSubTemp1.Contact__c = contactTemp1.Id;
        contSubTemp1.Subscription__c = subTemp1.Id;
        contSubTemp1.Asset__c = parentAsset1.Id;
		contSubTemp1.GWotGoAsset__c = relatedAsset1.Id;
		contSubTemp1.GWotGoPermAssoc__c = true;
        insert contSubTemp1;

		Test.startTest();
		// Create GWotGo Asset Record for the Dummy Asset
        Asset GWotGo = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-076', Parent_Asset__c = dummyUnitAsset.Id);
        GWotGo.Product2Id = prodTemp3.Id;
        GWotGo.SIM_Card_Active__c = true;
        GWotGo.SIM_Card_ICCID__c = 'some text 89011704258018735311';
		GWotGo.GWotGo__c = true;
		GWotGo.Commissioned__c = true;
		GWotGo.ResetSuccessful__c = 'None';
		GWotGo.MAC_Address__c = '000000000000';
        insert GWotGo;

		// Create Subscription Pair and a Permanent Contact
		Contact contactTemp2 = new Contact();
        contactTemp2.Eprise_Login_ID__c = 'RoesslKS2';
        contactTemp2.RecordTypeId = recordTypeTemp.Id;
        contactTemp2.AccountId = acctTemp.Id;
        contactTemp2.Status__c = 'Active';
        contactTemp2.Email = 'kent2.roessler@daikinapplied.com';
        contactTemp2.FirstName = 'Kent2';
        contactTemp2.LastName = 'Roessler2';
        contactTemp2.IE_Sync_Status__c = 'Pending';
        contactTemp2.IE_Contact__c = true;
        // Create an address for this contact
        Address__c addrTemp3 = new Address__c();
        addrTemp3.Address_Line_1__c = 'Test Address Line 2';
        addrTemp3.City__c = 'Minneapolis';
        addrTemp3.Postal_Code__c = '55421';
        addrTemp3.Country__c = 'United States';
        addrTemp3.State_Province__c = 'Minnesota';
        insert addrTemp3;
        contactTemp2.Physical_Address__c = addrTemp3.Id;
        insert contactTemp2;

		Contact_Address__c contactAddrJunctionObj2 = new Contact_Address__c();
        contactAddrJunctionObj2.Contact__c = contactTemp2.Id;
        contactAddrJunctionObj2.Address__c = addrTemp3.Id;
        contactAddrJunctionObj2.Active__c = true;
        contactAddrJunctionObj2.Physical__c = true;
        insert contactAddrJunctionObj2;

		Subscription__c subTemp3 = new Subscription__c();
        subTemp3.TriggerInvokedByAPI__c = false;
        subTemp3.IE_Subscription__c = true;
        subTemp3.Start_Date__c = currDateTime;
        subTemp3.End_Date__c = currDateTime.addMonths(6);
        subTemp3.Type__c = 'TechReadWrite';
        subTemp3.Active__c = true;
        subTemp3.Asset__c = dummyUnitAsset.Id;
        subTemp3.Buyer_ID__c = acctTemp.Id;
        subTemp3.Renewal_Counter__c = 0;
        subTemp3.Last_Renewal_Date__c = null;
        subTemp3.Renewal_Date__c = null;
        subTemp3.Connectivity_Type__c = 'Cellular';
        subTemp3.Term_Years__c = 1.25;
        subTemp3.Renewal_Notice_Current_Month__c = false;
        subTemp3.Renewal_Notice_Next_Month__c = false;
        subTemp3.Renewal_Notice_Last_Month__c = false;
        subTemp3.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp3.Renewal_Notice_Last_Month_Minus_1__c = false;
		subTemp3.GWotGoAsset__c = GWotGo.Id;
        insert subTemp3;

		Subscription__c subTemp4 = new Subscription__c();
        subTemp4.TriggerInvokedByAPI__c = false;
        subTemp4.IE_Subscription__c = true;
        subTemp4.Start_Date__c = currDateTime;
        subTemp4.End_Date__c = currDateTime.addMonths(6);
        subTemp4.Type__c = 'CustomRead';
        subTemp4.Active__c = true;
        subTemp4.Asset__c = dummyUnitAsset.Id;
        subTemp4.Buyer_ID__c = acctTemp.Id;
        subTemp4.Renewal_Counter__c = 0;
        subTemp4.Last_Renewal_Date__c = null;
        subTemp4.Renewal_Date__c = null;
        subTemp4.Connectivity_Type__c = 'Cellular';
        subTemp4.Term_Years__c = 1.25;
        subTemp4.Renewal_Notice_Current_Month__c = false;
        subTemp4.Renewal_Notice_Next_Month__c = false;
        subTemp4.Renewal_Notice_Last_Month__c = false;
        subTemp4.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp4.Renewal_Notice_Last_Month_Minus_1__c = false;
		subTemp4.GWotGoAsset__c = GWotGo.Id;
        insert subTemp4;

		// Associate the contact to the subscription
        Contact_Subscription__c contSubTemp2 = new Contact_Subscription__c();
        contSubTemp2.Role__c = 'TechnicianAdministrator';
        contSubTemp2.Contact__c = contactTemp2.Id;
        contSubTemp2.Subscription__c = subTemp3.Id;
        contSubTemp2.Asset__c = dummyUnitAsset.Id;
		contSubTemp2.GWotGoAsset__c = GWotGo.Id;
		contSubTemp2.GWotGoPermAssoc__c = true;
        insert contSubTemp2;



		//call the service
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        req.requestURI = 'https://cs8.salesforce.com/services/apexrest/ResetGWotGoAsset?UnitSerialNumber=SN123Test1&GatewayMACAddr=000000000000&UserEmail=kent.roessler@daikinapplied.com';  
        req.httpMethod = 'PUT';
        RestContext.request = req;
        RestContext.response = res;
        RestContext.request.params.put('UnitSerialNumber','SN123Test1');
		RestContext.request.params.put('GatewayMACAddr','000000000000');
		RestContext.request.params.put('UserEmail','kent.roessler@daikinapplied.com');

		//Test.startTest();
			ResetGWotGoAsset.ResetResponse results = ResetGWotGoAsset.doPut();
		Test.stopTest();

		//assert the results
        System.assertEquals('SN123Test1', results.UnitSerialNumber);
		System.assertEquals('000000000000', results.GatewayMACAddress);
		System.assertEquals('kent.roessler@daikinapplied.com', results.UserEmail);
		System.assertEquals(0, results.Errors.size());

		// verify that the GW on the parent asset went to Holding
		Asset gw1 = [SELECT Id, Parent_Asset__c from Asset Where Id = :relatedAsset1.Id];
 		System.assertEquals(holdingUnitAsset.Id, gw1.Parent_Asset__c);
		
		// verify that the GW on the Dummy went to the parent asset
		Asset gw2 = [SELECT Id, Parent_Asset__c from Asset Where Id = :GWotGo.Id];
 		System.assertEquals(parentAsset1.Id, gw2.Parent_Asset__c);
	}


	@isTest(SeeAllData=true) static void testPut_processRequest_MoveGWotGoFromDummyToRealUnit2() {
		// ----------------Setup Test Data in Salesforce objects:

		//!!!!!!!!!!! Need to add this code snippet for AvaTax- AccountAddressTrigger to run successfully on Before Insert into the Account table !!!!!!!!!!!!!!!!!
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;

		Datetime currDateTime = Datetime.now();
        Date currentDate = Date.today();
        RecordType recordTypeTemp = [SELECT Id FROM RecordType WHERE Name='Daikin Applied' AND SObjectType='Contact'];

		// Get Dummy Unit Asset for GWotGo
		Asset dummyUnitAsset = [SELECT Id, Name from Asset Where Name = 'Dummy GWotGo Unit Asset'];

		// Get Holding Unit Asset for GWotGo
		Asset holdingUnitAsset = [SELECT Id, Name from Asset Where Name = 'Holding GWotGo Unit Asset'];


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
        acctTemp.IE_Sync_Status__c = 'Pending';
		acctTemp.IE_ID__c = '999';  // Forces a PUT operation in the IE Organizations Service call
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
        orderTemp1.Order_Type_ID__c = 'International';
        orderTemp1.Order_Entry_Date__c = Date.today();
        orderTemp1.SO_Number__c = 'SO #999';
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
        
        
        // Create Parent Asset record with a GWotGo
        Asset parentAsset1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test1', Tag__c='Order Tag 1');
        parentAsset1.Product2Id = prodTemp1.Id;
        parentAsset1.Order__c = orderTemp1.Id;
		parentAsset1.Asset_Address__c = addrTemp.Id;
        parentAsset1.IE_Asset__c = true;
        parentAsset1.Code_String_Breakdown__c = '[{"code_sequence":"1","code_value":"MPS","code_description":"UNIT TYPE; Unit Type"},{"code_sequence":"2","code_value":"003B","code_description":"UNIT SIZE; 3 ton, R410A"},{"code_sequence":"3","code_value":"Y","code_description":"HEAT; None"},{"code_sequence":"4","code_value":"D","code_description":"VOLTAGE/POWER CONNECTION; 460 V power"},{"code_sequence":"5","code_value":"M","code_description":"DRIVE PACKAGE; Belt drive - high static"},{"code_sequence":"6","code_value":"00D","code_description":"HEATING CAPACITY/CONTROLS; DDC controls"},{"code_sequence":"7","code_value":"CZ","code_description":"OPTIONS; HP,LP,LowAmb/Comfort Aler,FldPower GFI, Hail Guard"},{"code_sequence":"8","code_value":"D","code_description":"ECONOMIZER; Field Mounted 0-30% Outside air hood"}]';
        insert parentAsset1;

		//Create Asset Address record
        Asset_Address__c aa = new Asset_Address__c(Asset__c = parentAsset1.Id
                                                  ,Address__c = addrTemp.Id
                                                  ,Building_Identifier__c = '123');
        insert aa;
        
		
        // Create GWotGo Asset Record for the Parent Asset
        Asset relatedAsset1 = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-075', Parent_Asset__c = parentAsset1.Id);
        relatedAsset1.Product2Id = prodTemp3.Id;
        relatedAsset1.SIM_Card_Active__c = true;
        relatedAsset1.SIM_Card_ICCID__c = '89011704258018735310';
		relatedAsset1.GWotGo__c = true;
		relatedAsset1.Commissioned__c = true;
		relatedAsset1.ResetSuccessful__c = 'None';
		relatedAsset1.MAC_Address__c = '000000000001';
        insert relatedAsset1;

		// Create Subscription Pair and a Permanent Contact
		Contact contactTemp1 = new Contact();
        contactTemp1.Eprise_Login_ID__c = 'RoesslKS1';
        contactTemp1.RecordTypeId = recordTypeTemp.Id;
        contactTemp1.AccountId = acctTemp.Id;
        contactTemp1.Status__c = 'Active';
        contactTemp1.Email = 'kent.roessler@daikinapplied.com';
        contactTemp1.FirstName = 'Kent1';
        contactTemp1.LastName = 'Roessler1';
        contactTemp1.IE_Sync_Status__c = 'Pending';
        contactTemp1.IE_Contact__c = true;
        // Create an address for this contact
        Address__c addrTemp2 = new Address__c();
        addrTemp2.Address_Line_1__c = 'Test Address Line 1';
        addrTemp2.City__c = 'Minneapolis';
        addrTemp2.Postal_Code__c = '55421';
        addrTemp2.Country__c = 'United States';
        addrTemp2.State_Province__c = 'Minnesota';
        insert addrTemp2;
        contactTemp1.Physical_Address__c = addrTemp2.Id;
        insert contactTemp1;

		Contact_Address__c contactAddrJunctionObj = new Contact_Address__c();
        contactAddrJunctionObj.Contact__c = contactTemp1.Id;
        contactAddrJunctionObj.Address__c = addrTemp2.Id;
        contactAddrJunctionObj.Active__c = true;
        contactAddrJunctionObj.Physical__c = true;
        insert contactAddrJunctionObj;

		Subscription__c subTemp1 = new Subscription__c();
        subTemp1.TriggerInvokedByAPI__c = false;
        subTemp1.IE_Subscription__c = true;
        subTemp1.Start_Date__c = currDateTime;
        subTemp1.End_Date__c = currDateTime.addMonths(6);
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
        subTemp2.TriggerInvokedByAPI__c = false;
        subTemp2.IE_Subscription__c = true;
        subTemp2.Start_Date__c = currDateTime;
        subTemp2.End_Date__c = currDateTime.addMonths(6);
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

		// Associate the contact to the subscription
        Contact_Subscription__c contSubTemp1 = new Contact_Subscription__c();
        contSubTemp1.Role__c = 'TechnicianAdministrator';
        contSubTemp1.Contact__c = contactTemp1.Id;
        contSubTemp1.Subscription__c = subTemp1.Id;
        contSubTemp1.Asset__c = parentAsset1.Id;
		contSubTemp1.GWotGoAsset__c = relatedAsset1.Id;
		contSubTemp1.GWotGoPermAssoc__c = true;
        insert contSubTemp1;

		Test.startTest();
		// Create GWotGo Asset Record for the Dummy Asset
        Asset GWotGo = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-076', Parent_Asset__c = dummyUnitAsset.Id);
        GWotGo.Product2Id = prodTemp3.Id;
        GWotGo.SIM_Card_Active__c = true;
        GWotGo.SIM_Card_ICCID__c = 'some text 89011704258018735311';
		GWotGo.GWotGo__c = true;
		GWotGo.Commissioned__c = true;
		GWotGo.ResetSuccessful__c = 'None';
		GWotGo.MAC_Address__c = '000000000000';
        insert GWotGo;

		// Create Subscription Pair and a Permanent Contact
		Contact contactTemp2 = new Contact();
        contactTemp2.Eprise_Login_ID__c = 'RoesslKS2';
        contactTemp2.RecordTypeId = recordTypeTemp.Id;
        contactTemp2.AccountId = acctTemp.Id;
        contactTemp2.Status__c = 'Active';
        contactTemp2.Email = 'kent2.roessler@daikinapplied.com';
        contactTemp2.FirstName = 'Kent2';
        contactTemp2.LastName = 'Roessler2';
        contactTemp2.IE_Sync_Status__c = 'Pending';
        contactTemp2.IE_Contact__c = true;
        // Create an address for this contact
        Address__c addrTemp3 = new Address__c();
        addrTemp3.Address_Line_1__c = 'Test Address Line 2';
        addrTemp3.City__c = 'Minneapolis';
        addrTemp3.Postal_Code__c = '55421';
        addrTemp3.Country__c = 'United States';
        addrTemp3.State_Province__c = 'Minnesota';
        insert addrTemp3;
        contactTemp2.Physical_Address__c = addrTemp3.Id;
        insert contactTemp2;

		Contact_Address__c contactAddrJunctionObj2 = new Contact_Address__c();
        contactAddrJunctionObj2.Contact__c = contactTemp2.Id;
        contactAddrJunctionObj2.Address__c = addrTemp3.Id;
        contactAddrJunctionObj2.Active__c = true;
        contactAddrJunctionObj2.Physical__c = true;
        insert contactAddrJunctionObj2;

		Subscription__c subTemp3 = new Subscription__c();
        subTemp3.TriggerInvokedByAPI__c = false;
        subTemp3.IE_Subscription__c = true;
        subTemp3.Start_Date__c = currDateTime;
        subTemp3.End_Date__c = currDateTime.addMonths(6);
        subTemp3.Type__c = 'TechReadWrite';
        subTemp3.Active__c = true;
        subTemp3.Asset__c = dummyUnitAsset.Id;
        subTemp3.Buyer_ID__c = acctTemp.Id;
        subTemp3.Renewal_Counter__c = 0;
        subTemp3.Last_Renewal_Date__c = null;
        subTemp3.Renewal_Date__c = null;
        subTemp3.Connectivity_Type__c = 'Cellular';
        subTemp3.Term_Years__c = 1.25;
        subTemp3.Renewal_Notice_Current_Month__c = false;
        subTemp3.Renewal_Notice_Next_Month__c = false;
        subTemp3.Renewal_Notice_Last_Month__c = false;
        subTemp3.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp3.Renewal_Notice_Last_Month_Minus_1__c = false;
		subTemp3.GWotGoAsset__c = GWotGo.Id;
        insert subTemp3;

		Subscription__c subTemp4 = new Subscription__c();
        subTemp4.TriggerInvokedByAPI__c = false;
        subTemp4.IE_Subscription__c = true;
        subTemp4.Start_Date__c = currDateTime;
        subTemp4.End_Date__c = currDateTime.addMonths(6);
        subTemp4.Type__c = 'CustomRead';
        subTemp4.Active__c = true;
        subTemp4.Asset__c = dummyUnitAsset.Id;
        subTemp4.Buyer_ID__c = acctTemp.Id;
        subTemp4.Renewal_Counter__c = 0;
        subTemp4.Last_Renewal_Date__c = null;
        subTemp4.Renewal_Date__c = null;
        subTemp4.Connectivity_Type__c = 'Cellular';
        subTemp4.Term_Years__c = 1.25;
        subTemp4.Renewal_Notice_Current_Month__c = false;
        subTemp4.Renewal_Notice_Next_Month__c = false;
        subTemp4.Renewal_Notice_Last_Month__c = false;
        subTemp4.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp4.Renewal_Notice_Last_Month_Minus_1__c = false;
		subTemp4.GWotGoAsset__c = GWotGo.Id;
        insert subTemp4;

		// Associate the contact to the subscription
        Contact_Subscription__c contSubTemp2 = new Contact_Subscription__c();
        contSubTemp2.Role__c = 'TechnicianAdministrator';
        contSubTemp2.Contact__c = contactTemp2.Id;
        contSubTemp2.Subscription__c = subTemp3.Id;
        contSubTemp2.Asset__c = dummyUnitAsset.Id;
		contSubTemp2.GWotGoAsset__c = GWotGo.Id;
		contSubTemp2.GWotGoPermAssoc__c = true;
        insert contSubTemp2;



		//call the service
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        req.requestURI = 'https://cs8.salesforce.com/services/apexrest/ResetGWotGoAsset?UnitSerialNumber=SN123Test1&GatewayMACAddr=000000000000&UserEmail=kent.roessler@daikinapplied.com';  
        req.httpMethod = 'PUT';
        RestContext.request = req;
        RestContext.response = res;
        RestContext.request.params.put('UnitSerialNumber','SN123Test1');
		RestContext.request.params.put('GatewayMACAddr','000000000000');
		RestContext.request.params.put('UserEmail','kent.roessler@daikinapplied.com');

		//Test.startTest();
			ResetGWotGoAsset.ResetResponse results = ResetGWotGoAsset.doPut();
		Test.stopTest();

		//assert the results
        System.assertEquals('SN123Test1', results.UnitSerialNumber);
		System.assertEquals('000000000000', results.GatewayMACAddress);
		System.assertEquals('kent.roessler@daikinapplied.com', results.UserEmail);
		System.assertEquals(0, results.Errors.size());

		// verify that the GW on the parent asset went to Holding
		Asset gw1 = [SELECT Id, Parent_Asset__c from Asset Where Id = :relatedAsset1.Id];
 		System.assertEquals(holdingUnitAsset.Id, gw1.Parent_Asset__c);
		
		// verify that the GW on the Dummy went to the parent asset
		Asset gw2 = [SELECT Id, Parent_Asset__c from Asset Where Id = :GWotGo.Id];
 		System.assertEquals(parentAsset1.Id, gw2.Parent_Asset__c);
	}


	@isTest(SeeAllData=true) static void testPut_processRequest_MoveGWotGoFromRealUnitToAnotherRealUnit() {
		// ----------------Setup Test Data in Salesforce objects:

		//!!!!!!!!!!! Need to add this code snippet for AvaTax- AccountAddressTrigger to run successfully on Before Insert into the Account table !!!!!!!!!!!!!!!!!
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;

		Datetime currDateTime = Datetime.now();
        Date currentDate = Date.today();
        RecordType recordTypeTemp = [SELECT Id FROM RecordType WHERE Name='Daikin Applied' AND SObjectType='Contact'];

		// Get Dummy Unit Asset for GWotGo
		Asset dummyUnitAsset = [SELECT Id, Name from Asset Where Name = 'Dummy GWotGo Unit Asset'];

		// Get Holding Unit Asset for GWotGo
		Asset holdingUnitAsset = [SELECT Id, Name from Asset Where Name = 'Holding GWotGo Unit Asset'];


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
        acctTemp.IE_Sync_Status__c = 'Pending';
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
        orderTemp1.Order_Entry_Date__c = Date.today();
        orderTemp1.SO_Number__c = 'SO #999';
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
        
        
        // Create Parent Asset record with a GWotGo
        Asset parentAsset1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test1', Tag__c='Order Tag 1');
        parentAsset1.Product2Id = prodTemp1.Id;
        parentAsset1.Order__c = orderTemp1.Id;
		parentAsset1.Asset_Address__c = addrTemp.Id;
        parentAsset1.IE_Asset__c = true;
        parentAsset1.Code_String_Breakdown__c = '[{"code_sequence":"1","code_value":"MPS","code_description":"UNIT TYPE; Unit Type"},{"code_sequence":"2","code_value":"003B","code_description":"UNIT SIZE; 3 ton, R410A"},{"code_sequence":"3","code_value":"Y","code_description":"HEAT; None"},{"code_sequence":"4","code_value":"D","code_description":"VOLTAGE/POWER CONNECTION; 460 V power"},{"code_sequence":"5","code_value":"M","code_description":"DRIVE PACKAGE; Belt drive - high static"},{"code_sequence":"6","code_value":"00D","code_description":"HEATING CAPACITY/CONTROLS; DDC controls"},{"code_sequence":"7","code_value":"CZ","code_description":"OPTIONS; HP,LP,LowAmb/Comfort Aler,FldPower GFI, Hail Guard"},{"code_sequence":"8","code_value":"D","code_description":"ECONOMIZER; Field Mounted 0-30% Outside air hood"}]';
        insert parentAsset1;

		//Create Asset Address record
        Asset_Address__c aa = new Asset_Address__c(Asset__c = parentAsset1.Id
                                                  ,Address__c = addrTemp.Id
                                                  ,Building_Identifier__c = '123');
        insert aa;
        
		
        // Create GWotGo Asset Record for the Parent Asset
        Asset relatedAsset1 = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-075', Parent_Asset__c = parentAsset1.Id);
        relatedAsset1.Product2Id = prodTemp3.Id;
        relatedAsset1.SIM_Card_Active__c = true;
        relatedAsset1.SIM_Card_ICCID__c = '89011704258018735310';
		relatedAsset1.GWotGo__c = true;
		relatedAsset1.Commissioned__c = true;
		relatedAsset1.ResetSuccessful__c = 'None';
		relatedAsset1.MAC_Address__c = '000000000001';
        insert relatedAsset1;

		// Create Subscription Pair and a Permanent Contact
		Contact contactTemp1 = new Contact();
        contactTemp1.Eprise_Login_ID__c = 'RoesslKS1';
        contactTemp1.RecordTypeId = recordTypeTemp.Id;
        contactTemp1.AccountId = acctTemp.Id;
        contactTemp1.Status__c = 'Active';
        contactTemp1.Email = 'kent.roessler@daikinapplied.com';
        contactTemp1.FirstName = 'Kent1';
        contactTemp1.LastName = 'Roessler1';
        contactTemp1.IE_Sync_Status__c = 'Pending';
        contactTemp1.IE_Contact__c = true;
        // Create an address for this contact
        Address__c addrTemp2 = new Address__c();
        addrTemp2.Address_Line_1__c = 'Test Address Line 1';
        addrTemp2.City__c = 'Minneapolis';
        addrTemp2.Postal_Code__c = '55421';
        addrTemp2.Country__c = 'United States';
        addrTemp2.State_Province__c = 'Minnesota';
        insert addrTemp2;
        contactTemp1.Physical_Address__c = addrTemp2.Id;
        insert contactTemp1;

		Contact_Address__c contactAddrJunctionObj = new Contact_Address__c();
        contactAddrJunctionObj.Contact__c = contactTemp1.Id;
        contactAddrJunctionObj.Address__c = addrTemp2.Id;
        contactAddrJunctionObj.Active__c = true;
        contactAddrJunctionObj.Physical__c = true;
        insert contactAddrJunctionObj;

		Subscription__c subTemp1 = new Subscription__c();
        subTemp1.TriggerInvokedByAPI__c = false;
        subTemp1.IE_Subscription__c = true;
        subTemp1.Start_Date__c = currDateTime;
        subTemp1.End_Date__c = currDateTime.addMonths(6);
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
        subTemp2.TriggerInvokedByAPI__c = false;
        subTemp2.IE_Subscription__c = true;
        subTemp2.Start_Date__c = currDateTime;
        subTemp2.End_Date__c = currDateTime.addMonths(6);
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

		// Associate the contact to the subscription
        Contact_Subscription__c contSubTemp1 = new Contact_Subscription__c();
        contSubTemp1.Role__c = 'TechnicianAdministrator';
        contSubTemp1.Contact__c = contactTemp1.Id;
        contSubTemp1.Subscription__c = subTemp1.Id;
        contSubTemp1.Asset__c = parentAsset1.Id;
		contSubTemp1.GWotGoAsset__c = relatedAsset1.Id;
		contSubTemp1.GWotGoPermAssoc__c = true;
        insert contSubTemp1;


		// Create a Unit Asset that the GWotGo will move to
		Asset unitAsset = new Asset(Name = 'Asset Test2', AccountId = acctTemp.Id, SerialNumber='SN123Test2', Tag__c='Order Tag 1');
        unitAsset.Product2Id = prodTemp1.Id;
        unitAsset.Order__c = orderTemp1.Id;
		unitAsset.Asset_Address__c = addrTemp.Id;
        unitAsset.IE_Asset__c = false;
        unitAsset.Code_String_Breakdown__c = '[{"code_sequence":"1","code_value":"MPS","code_description":"UNIT TYPE; Unit Type"},{"code_sequence":"2","code_value":"003B","code_description":"UNIT SIZE; 3 ton, R410A"},{"code_sequence":"3","code_value":"Y","code_description":"HEAT; None"},{"code_sequence":"4","code_value":"D","code_description":"VOLTAGE/POWER CONNECTION; 460 V power"},{"code_sequence":"5","code_value":"M","code_description":"DRIVE PACKAGE; Belt drive - high static"},{"code_sequence":"6","code_value":"00D","code_description":"HEATING CAPACITY/CONTROLS; DDC controls"},{"code_sequence":"7","code_value":"CZ","code_description":"OPTIONS; HP,LP,LowAmb/Comfort Aler,FldPower GFI, Hail Guard"},{"code_sequence":"8","code_value":"D","code_description":"ECONOMIZER; Field Mounted 0-30% Outside air hood"}]';
        insert unitAsset;

		//Create Asset Address record
        Asset_Address__c aa2 = new Asset_Address__c(Asset__c = unitAsset.Id
                                                  ,Address__c = addrTemp.Id
                                                  ,Building_Identifier__c = '456');
        insert aa2;

		//call the service
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        req.requestURI = 'https://cs8.salesforce.com/services/apexrest/ResetGWotGoAsset?UnitSerialNumber=SN123Test2&GatewayMACAddr=000000000001&UserEmail=kent.roessler@daikinapplied.com';  
        req.httpMethod = 'PUT';
        RestContext.request = req;
        RestContext.response = res;
        RestContext.request.params.put('UnitSerialNumber','SN123Test2');
		RestContext.request.params.put('GatewayMACAddr','000000000001');
		RestContext.request.params.put('UserEmail','kent.roessler@daikinapplied.com');

		Test.startTest();
			ResetGWotGoAsset.ResetResponse results = ResetGWotGoAsset.doPut();
		Test.stopTest();

		//assert the results
        System.assertEquals('SN123Test2', results.UnitSerialNumber);
		System.assertEquals('000000000001', results.GatewayMACAddress);
		System.assertEquals('kent.roessler@daikinapplied.com', results.UserEmail);
		System.assertEquals(0, results.Errors.size());

		// verify that the GW moved to the new Unit Asset
		Asset gw1 = [SELECT Id, Parent_Asset__c from Asset Where Id = :relatedAsset1.Id];
 		System.assertEquals(unitAsset.Id, gw1.Parent_Asset__c);

		// verify that the new unit asset is now an IE Asset
		Asset newUnit = [SELECT Id, IE_Asset__c from Asset Where Id = :unitAsset.Id];
 		System.assertEquals(true, newUnit.IE_Asset__c);
		
		// verify that the old unit asset is not an IE Asset anymore
		Asset oldUnit = [SELECT Id, IE_Asset__c from Asset Where Id = :parentAsset1.Id];
 		System.assertEquals(false, oldUnit.IE_Asset__c);

	}


	@isTest(SeeAllData=true) static void testPut_processRequest_UnitResetException() {
		// ----------------Setup Test Data in Salesforce objects:

		//!!!!!!!!!!! Need to add this code snippet for AvaTax- AccountAddressTrigger to run successfully on Before Insert into the Account table !!!!!!!!!!!!!!!!!
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;

		Datetime currDateTime = Datetime.now();
        Date currentDate = Date.today();
        RecordType recordTypeTemp = [SELECT Id FROM RecordType WHERE Name='Daikin Applied' AND SObjectType='Contact'];

		// Get Dummy Unit Asset for GWotGo
		Asset dummyUnitAsset = [SELECT Id, Name from Asset Where Name = 'Dummy GWotGo Unit Asset'];

		// Get Holding Unit Asset for GWotGo
		Asset holdingUnitAsset = [SELECT Id, Name from Asset Where Name = 'Holding GWotGo Unit Asset'];


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
        acctTemp.IE_Sync_Status__c = 'Pending';
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
        orderTemp1.Order_Entry_Date__c = Date.today();
        orderTemp1.SO_Number__c = 'SO #999';
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
        
        
        // Create Parent Asset record with a GWotGo
        Asset parentAsset1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test1', Tag__c='Order Tag 1');
        parentAsset1.Product2Id = prodTemp1.Id;
        parentAsset1.Order__c = orderTemp1.Id;
		parentAsset1.Asset_Address__c = addrTemp.Id;
        parentAsset1.IE_Asset__c = true;
        parentAsset1.Code_String_Breakdown__c = '[{"code_sequence":"1","code_value":"MPS","code_description":"UNIT TYPE; Unit Type"},{"code_sequence":"2","code_value":"003B","code_description":"UNIT SIZE; 3 ton, R410A"},{"code_sequence":"3","code_value":"Y","code_description":"HEAT; None"},{"code_sequence":"4","code_value":"D","code_description":"VOLTAGE/POWER CONNECTION; 460 V power"},{"code_sequence":"5","code_value":"M","code_description":"DRIVE PACKAGE; Belt drive - high static"},{"code_sequence":"6","code_value":"00D","code_description":"HEATING CAPACITY/CONTROLS; DDC controls"},{"code_sequence":"7","code_value":"CZ","code_description":"OPTIONS; HP,LP,LowAmb/Comfort Aler,FldPower GFI, Hail Guard"},{"code_sequence":"8","code_value":"D","code_description":"ECONOMIZER; Field Mounted 0-30% Outside air hood"}]';
        insert parentAsset1;

		//Create Asset Address record
        Asset_Address__c aa = new Asset_Address__c(Asset__c = parentAsset1.Id
                                                  ,Address__c = addrTemp.Id
                                                  ,Building_Identifier__c = '123');
        insert aa;
        
		
        // Create GWotGo Asset Record for the Parent Asset
        Asset relatedAsset1 = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-075', Parent_Asset__c = parentAsset1.Id);
        relatedAsset1.Product2Id = prodTemp3.Id;
        relatedAsset1.SIM_Card_Active__c = true;
        relatedAsset1.SIM_Card_ICCID__c = '89011704258018735310';
		relatedAsset1.GWotGo__c = true;
		relatedAsset1.Commissioned__c = true;
		relatedAsset1.ResetSuccessful__c = 'None';
		relatedAsset1.MAC_Address__c = '000000000001';
        insert relatedAsset1;

		// Create Subscription Pair and a Permanent Contact
		Contact contactTemp1 = new Contact();
        contactTemp1.Eprise_Login_ID__c = 'RoesslKS1';
        contactTemp1.RecordTypeId = recordTypeTemp.Id;
        contactTemp1.AccountId = acctTemp.Id;
        contactTemp1.Status__c = 'Active';
        contactTemp1.Email = 'kent.roessler@daikinapplied.com';
        contactTemp1.FirstName = 'Kent1';
        contactTemp1.LastName = 'Roessler1';
        contactTemp1.IE_Sync_Status__c = 'Pending';
        contactTemp1.IE_Contact__c = true;
        // Create an address for this contact
        Address__c addrTemp2 = new Address__c();
        addrTemp2.Address_Line_1__c = 'Test Address Line 1';
        addrTemp2.City__c = 'Minneapolis';
        addrTemp2.Postal_Code__c = '55421';
        addrTemp2.Country__c = 'United States';
        addrTemp2.State_Province__c = 'Minnesota';
        insert addrTemp2;
        contactTemp1.Physical_Address__c = addrTemp2.Id;
        insert contactTemp1;

		Contact_Address__c contactAddrJunctionObj = new Contact_Address__c();
        contactAddrJunctionObj.Contact__c = contactTemp1.Id;
        contactAddrJunctionObj.Address__c = addrTemp2.Id;
        contactAddrJunctionObj.Active__c = true;
        contactAddrJunctionObj.Physical__c = true;
        insert contactAddrJunctionObj;

		Subscription__c subTemp1 = new Subscription__c();
        subTemp1.TriggerInvokedByAPI__c = false;
        subTemp1.IE_Subscription__c = true;
        subTemp1.Start_Date__c = currDateTime;
        subTemp1.End_Date__c = currDateTime.addMonths(6);
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
        subTemp2.TriggerInvokedByAPI__c = false;
        subTemp2.IE_Subscription__c = true;
        subTemp2.Start_Date__c = currDateTime;
        subTemp2.End_Date__c = currDateTime.addMonths(6);
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

		// Associate the contact to the subscription
        Contact_Subscription__c contSubTemp1 = new Contact_Subscription__c();
        contSubTemp1.Role__c = 'TechnicianAdministrator';
        contSubTemp1.Contact__c = contactTemp1.Id;
        contSubTemp1.Subscription__c = subTemp1.Id;
        contSubTemp1.Asset__c = parentAsset1.Id;
		contSubTemp1.GWotGoAsset__c = relatedAsset1.Id;
		contSubTemp1.GWotGoPermAssoc__c = true;
        insert contSubTemp1;


		// Create a Unit Asset that the GWotGo will move to
		Asset unitAsset = new Asset(Name = 'Asset Test2', AccountId = acctTemp.Id, SerialNumber='SN123Test2', Tag__c='Order Tag 1');
        unitAsset.Product2Id = prodTemp1.Id;
        unitAsset.Order__c = orderTemp1.Id;
		unitAsset.Asset_Address__c = addrTemp.Id;
        unitAsset.IE_Asset__c = false;
        unitAsset.Code_String_Breakdown__c = '[{"code_sequence":"1","code_value":"MPS","code_description":"UNIT TYPE; Unit Type"},{"code_sequence":"2","code_value":"003B","code_description":"UNIT SIZE; 3 ton, R410A"},{"code_sequence":"3","code_value":"Y","code_description":"HEAT; None"},{"code_sequence":"4","code_value":"D","code_description":"VOLTAGE/POWER CONNECTION; 460 V power"},{"code_sequence":"5","code_value":"M","code_description":"DRIVE PACKAGE; Belt drive - high static"},{"code_sequence":"6","code_value":"00D","code_description":"HEATING CAPACITY/CONTROLS; DDC controls"},{"code_sequence":"7","code_value":"CZ","code_description":"OPTIONS; HP,LP,LowAmb/Comfort Aler,FldPower GFI, Hail Guard"},{"code_sequence":"8","code_value":"D","code_description":"ECONOMIZER; Field Mounted 0-30% Outside air hood"}]';
        insert unitAsset;

		//Create Asset Address record
        Asset_Address__c aa2 = new Asset_Address__c(Asset__c = unitAsset.Id
                                                  ,Address__c = addrTemp.Id
                                                  ,Building_Identifier__c = '456');
        insert aa2;

		//call the service
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        req.requestURI = 'https://cs8.salesforce.com/services/apexrest/ResetGWotGoAsset?UnitSerialNumber=SN123Test2&GatewayMACAddr=000000000001&UserEmail=kent.roessler@daikinapplied.com';  
        req.httpMethod = 'PUT';
        RestContext.request = req;
        RestContext.response = res;
        RestContext.request.params.put('UnitSerialNumber','SN123Test2');
		RestContext.request.params.put('GatewayMACAddr','000000000001');
		RestContext.request.params.put('UserEmail','kent.roessler@daikinapplied.com');

		Test.startTest();
			// Force an exception to be thrown
			Batch_IE_CallExtWebServices.crash_syncIeCloudUnits_TestByException = true;

			ResetGWotGoAsset.ResetResponse results = ResetGWotGoAsset.doPut();
		Test.stopTest();


		//assert the results
        System.assertEquals('SN123Test2', results.UnitSerialNumber);
		System.assertEquals('000000000001', results.GatewayMACAddress);
		System.assertEquals('kent.roessler@daikinapplied.com', results.UserEmail);

		for (ResetGWotGoAsset.Response_Error e : results.Errors)
		{
			System.assertEquals('UNIT_RESET_EXCEPTION', e.ErrorCode);
			System.assert(e.ErrorMessage.contains('ResetGWotGoAsset Exception:'));
		}

	}


	@isTest(SeeAllData=true) static void testPut_processRequest_UnitResetResponseStatusCodeError() {
		// ----------------Setup Test Data in Salesforce objects:

		//!!!!!!!!!!! Need to add this code snippet for AvaTax- AccountAddressTrigger to run successfully on Before Insert into the Account table !!!!!!!!!!!!!!!!!
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;

		Datetime currDateTime = Datetime.now();
        Date currentDate = Date.today();
        RecordType recordTypeTemp = [SELECT Id FROM RecordType WHERE Name='Daikin Applied' AND SObjectType='Contact'];

		// Get Dummy Unit Asset for GWotGo
		Asset dummyUnitAsset = [SELECT Id, Name from Asset Where Name = 'Dummy GWotGo Unit Asset'];

		// Get Holding Unit Asset for GWotGo
		Asset holdingUnitAsset = [SELECT Id, Name from Asset Where Name = 'Holding GWotGo Unit Asset'];


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
        acctTemp.IE_Sync_Status__c = 'Pending';
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
        orderTemp1.Order_Entry_Date__c = Date.today();
        orderTemp1.SO_Number__c = 'SO #999';
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
        
        
        // Create Parent Asset record with a GWotGo
        Asset parentAsset1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test1', Tag__c='Order Tag 1');
        parentAsset1.Product2Id = prodTemp1.Id;
        parentAsset1.Order__c = orderTemp1.Id;
		parentAsset1.Asset_Address__c = addrTemp.Id;
        parentAsset1.IE_Asset__c = true;
        parentAsset1.Code_String_Breakdown__c = '[{"code_sequence":"1","code_value":"MPS","code_description":"UNIT TYPE; Unit Type"},{"code_sequence":"2","code_value":"003B","code_description":"UNIT SIZE; 3 ton, R410A"},{"code_sequence":"3","code_value":"Y","code_description":"HEAT; None"},{"code_sequence":"4","code_value":"D","code_description":"VOLTAGE/POWER CONNECTION; 460 V power"},{"code_sequence":"5","code_value":"M","code_description":"DRIVE PACKAGE; Belt drive - high static"},{"code_sequence":"6","code_value":"00D","code_description":"HEATING CAPACITY/CONTROLS; DDC controls"},{"code_sequence":"7","code_value":"CZ","code_description":"OPTIONS; HP,LP,LowAmb/Comfort Aler,FldPower GFI, Hail Guard"},{"code_sequence":"8","code_value":"D","code_description":"ECONOMIZER; Field Mounted 0-30% Outside air hood"}]';
        insert parentAsset1;

		//Create Asset Address record
        Asset_Address__c aa = new Asset_Address__c(Asset__c = parentAsset1.Id
                                                  ,Address__c = addrTemp.Id
                                                  ,Building_Identifier__c = '123');
        insert aa;
        
		
        // Create GWotGo Asset Record for the Parent Asset
        Asset relatedAsset1 = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-075', Parent_Asset__c = parentAsset1.Id);
        relatedAsset1.Product2Id = prodTemp3.Id;
        relatedAsset1.SIM_Card_Active__c = true;
        relatedAsset1.SIM_Card_ICCID__c = '89011704258018735310';
		relatedAsset1.GWotGo__c = true;
		relatedAsset1.Commissioned__c = true;
		relatedAsset1.ResetSuccessful__c = 'None';
		relatedAsset1.MAC_Address__c = '000000000001';
        insert relatedAsset1;

		// Create Subscription Pair and a Permanent Contact
		Contact contactTemp1 = new Contact();
        contactTemp1.Eprise_Login_ID__c = 'RoesslKS1';
        contactTemp1.RecordTypeId = recordTypeTemp.Id;
        contactTemp1.AccountId = acctTemp.Id;
        contactTemp1.Status__c = 'Active';
        contactTemp1.Email = 'kent.roessler@daikinapplied.com';
        contactTemp1.FirstName = 'Kent1';
        contactTemp1.LastName = 'Roessler1';
        contactTemp1.IE_Sync_Status__c = 'Pending';
        contactTemp1.IE_Contact__c = true;
        // Create an address for this contact
        Address__c addrTemp2 = new Address__c();
        addrTemp2.Address_Line_1__c = 'Test Address Line 1';
        addrTemp2.City__c = 'Minneapolis';
        addrTemp2.Postal_Code__c = '55421';
        addrTemp2.Country__c = 'United States';
        addrTemp2.State_Province__c = 'Minnesota';
        insert addrTemp2;
        contactTemp1.Physical_Address__c = addrTemp2.Id;
        insert contactTemp1;

		Contact_Address__c contactAddrJunctionObj = new Contact_Address__c();
        contactAddrJunctionObj.Contact__c = contactTemp1.Id;
        contactAddrJunctionObj.Address__c = addrTemp2.Id;
        contactAddrJunctionObj.Active__c = true;
        contactAddrJunctionObj.Physical__c = true;
        insert contactAddrJunctionObj;

		Subscription__c subTemp1 = new Subscription__c();
        subTemp1.TriggerInvokedByAPI__c = false;
        subTemp1.IE_Subscription__c = true;
        subTemp1.Start_Date__c = currDateTime;
        subTemp1.End_Date__c = currDateTime.addMonths(6);
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
        subTemp2.TriggerInvokedByAPI__c = false;
        subTemp2.IE_Subscription__c = true;
        subTemp2.Start_Date__c = currDateTime;
        subTemp2.End_Date__c = currDateTime.addMonths(6);
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

		// Associate the contact to the subscription
        Contact_Subscription__c contSubTemp1 = new Contact_Subscription__c();
        contSubTemp1.Role__c = 'TechnicianAdministrator';
        contSubTemp1.Contact__c = contactTemp1.Id;
        contSubTemp1.Subscription__c = subTemp1.Id;
        contSubTemp1.Asset__c = parentAsset1.Id;
		contSubTemp1.GWotGoAsset__c = relatedAsset1.Id;
		contSubTemp1.GWotGoPermAssoc__c = true;
        insert contSubTemp1;


		// Create a Unit Asset that the GWotGo will move to
		Asset unitAsset = new Asset(Name = 'Asset Test2', AccountId = acctTemp.Id, SerialNumber='SN123Test2', Tag__c='Order Tag 1');
        unitAsset.Product2Id = prodTemp1.Id;
        unitAsset.Order__c = orderTemp1.Id;
		unitAsset.Asset_Address__c = addrTemp.Id;
        unitAsset.IE_Asset__c = false;
        unitAsset.Code_String_Breakdown__c = '[{"code_sequence":"1","code_value":"MPS","code_description":"UNIT TYPE; Unit Type"},{"code_sequence":"2","code_value":"003B","code_description":"UNIT SIZE; 3 ton, R410A"},{"code_sequence":"3","code_value":"Y","code_description":"HEAT; None"},{"code_sequence":"4","code_value":"D","code_description":"VOLTAGE/POWER CONNECTION; 460 V power"},{"code_sequence":"5","code_value":"M","code_description":"DRIVE PACKAGE; Belt drive - high static"},{"code_sequence":"6","code_value":"00D","code_description":"HEATING CAPACITY/CONTROLS; DDC controls"},{"code_sequence":"7","code_value":"CZ","code_description":"OPTIONS; HP,LP,LowAmb/Comfort Aler,FldPower GFI, Hail Guard"},{"code_sequence":"8","code_value":"D","code_description":"ECONOMIZER; Field Mounted 0-30% Outside air hood"}]';
        insert unitAsset;

		//Create Asset Address record
        Asset_Address__c aa2 = new Asset_Address__c(Asset__c = unitAsset.Id
                                                  ,Address__c = addrTemp.Id
                                                  ,Building_Identifier__c = '456');
        insert aa2;

		//call the service
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        req.requestURI = 'https://cs8.salesforce.com/services/apexrest/ResetGWotGoAsset?UnitSerialNumber=SN123Test2&GatewayMACAddr=000000000001&UserEmail=kent.roessler@daikinapplied.com';  
        req.httpMethod = 'PUT';
        RestContext.request = req;
        RestContext.response = res;
        RestContext.request.params.put('UnitSerialNumber','SN123Test2');
		RestContext.request.params.put('GatewayMACAddr','000000000001');
		RestContext.request.params.put('UserEmail','kent.roessler@daikinapplied.com');

		Test.startTest();
			// Force an exception to be thrown
			Batch_IE_CallExtWebServices.crash_syncIeCloudUnits_TestByResponseStatusCode = true;

			ResetGWotGoAsset.ResetResponse results = ResetGWotGoAsset.doPut();
		Test.stopTest();


		//assert the results
        System.assertEquals('SN123Test2', results.UnitSerialNumber);
		System.assertEquals('000000000001', results.GatewayMACAddress);
		System.assertEquals('kent.roessler@daikinapplied.com', results.UserEmail);

		for (ResetGWotGoAsset.Response_Error e : results.Errors)
		{
			System.assertEquals('UNIT_RESET_EXCEPTION', e.ErrorCode);
			System.assert(e.ErrorMessage.contains('ResetGWotGoAsset Exception:'));
		}

	}


	@isTest(SeeAllData=true) static void testPut_processRequest_UnitCreateException1() {
		// ----------------Setup Test Data in Salesforce objects:

		//!!!!!!!!!!! Need to add this code snippet for AvaTax- AccountAddressTrigger to run successfully on Before Insert into the Account table !!!!!!!!!!!!!!!!!
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;

		Datetime currDateTime = Datetime.now();
        Date currentDate = Date.today();
        RecordType recordTypeTemp = [SELECT Id FROM RecordType WHERE Name='Daikin Applied' AND SObjectType='Contact'];

		// Get Dummy Unit Asset for GWotGo
		Asset dummyUnitAsset = [SELECT Id, Name from Asset Where Name = 'Dummy GWotGo Unit Asset'];


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
        acctTemp.IE_Sync_Status__c = 'Pending';
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
        orderTemp1.Order_Entry_Date__c = Date.today();
        orderTemp1.SO_Number__c = 'SO #999';
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
        
        
        // Create Parent Asset record with a GWotGo
        Asset parentAsset1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test1', Tag__c='Order Tag 1');
        parentAsset1.Product2Id = prodTemp1.Id;
        parentAsset1.Order__c = orderTemp1.Id;
		parentAsset1.Asset_Address__c = addrTemp.Id;
        parentAsset1.IE_Asset__c = true;
        parentAsset1.Code_String_Breakdown__c = '[{"code_sequence":"1","code_value":"MPS","code_description":"UNIT TYPE; Unit Type"},{"code_sequence":"2","code_value":"003B","code_description":"UNIT SIZE; 3 ton, R410A"},{"code_sequence":"3","code_value":"Y","code_description":"HEAT; None"},{"code_sequence":"4","code_value":"D","code_description":"VOLTAGE/POWER CONNECTION; 460 V power"},{"code_sequence":"5","code_value":"M","code_description":"DRIVE PACKAGE; Belt drive - high static"},{"code_sequence":"6","code_value":"00D","code_description":"HEATING CAPACITY/CONTROLS; DDC controls"},{"code_sequence":"7","code_value":"CZ","code_description":"OPTIONS; HP,LP,LowAmb/Comfort Aler,FldPower GFI, Hail Guard"},{"code_sequence":"8","code_value":"D","code_description":"ECONOMIZER; Field Mounted 0-30% Outside air hood"}]';
        insert parentAsset1;

		//Create Asset Address record
        Asset_Address__c aa = new Asset_Address__c(Asset__c = parentAsset1.Id
                                                  ,Address__c = addrTemp.Id
                                                  ,Building_Identifier__c = '123');
        insert aa;
        
		
        // Create GWotGo Asset Record for the Parent Asset
        Asset relatedAsset1 = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-075', Parent_Asset__c = parentAsset1.Id);
        relatedAsset1.Product2Id = prodTemp3.Id;
        relatedAsset1.SIM_Card_Active__c = true;
        relatedAsset1.SIM_Card_ICCID__c = '89011704258018735310';
		relatedAsset1.GWotGo__c = true;
		relatedAsset1.Commissioned__c = true;
		relatedAsset1.ResetSuccessful__c = 'None';
		relatedAsset1.MAC_Address__c = '000000000001';
        insert relatedAsset1;

		// Create Subscription Pair and a Permanent Contact
		Contact contactTemp1 = new Contact();
        contactTemp1.Eprise_Login_ID__c = 'RoesslKS1';
        contactTemp1.RecordTypeId = recordTypeTemp.Id;
        contactTemp1.AccountId = acctTemp.Id;
        contactTemp1.Status__c = 'Active';
        contactTemp1.Email = 'kent.roessler@daikinapplied.com';
        contactTemp1.FirstName = 'Kent1';
        contactTemp1.LastName = 'Roessler1';
        contactTemp1.IE_Sync_Status__c = 'Pending';
        contactTemp1.IE_Contact__c = true;
        // Create an address for this contact
        Address__c addrTemp2 = new Address__c();
        addrTemp2.Address_Line_1__c = 'Test Address Line 1';
        addrTemp2.City__c = 'Minneapolis';
        addrTemp2.Postal_Code__c = '55421';
        addrTemp2.Country__c = 'United States';
        addrTemp2.State_Province__c = 'Minnesota';
        insert addrTemp2;
        contactTemp1.Physical_Address__c = addrTemp2.Id;
        insert contactTemp1;

		Contact_Address__c contactAddrJunctionObj = new Contact_Address__c();
        contactAddrJunctionObj.Contact__c = contactTemp1.Id;
        contactAddrJunctionObj.Address__c = addrTemp2.Id;
        contactAddrJunctionObj.Active__c = true;
        contactAddrJunctionObj.Physical__c = true;
        insert contactAddrJunctionObj;

		Subscription__c subTemp1 = new Subscription__c();
        subTemp1.TriggerInvokedByAPI__c = false;
        subTemp1.IE_Subscription__c = true;
        subTemp1.Start_Date__c = currDateTime;
        subTemp1.End_Date__c = currDateTime.addMonths(6);
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
        subTemp2.TriggerInvokedByAPI__c = false;
        subTemp2.IE_Subscription__c = true;
        subTemp2.Start_Date__c = currDateTime;
        subTemp2.End_Date__c = currDateTime.addMonths(6);
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

		// Associate the contact to the subscription
        Contact_Subscription__c contSubTemp1 = new Contact_Subscription__c();
        contSubTemp1.Role__c = 'TechnicianAdministrator';
        contSubTemp1.Contact__c = contactTemp1.Id;
        contSubTemp1.Subscription__c = subTemp1.Id;
        contSubTemp1.Asset__c = parentAsset1.Id;
		contSubTemp1.GWotGoAsset__c = relatedAsset1.Id;
		contSubTemp1.GWotGoPermAssoc__c = true;
        insert contSubTemp1;

		Test.startTest();
		// Create GWotGo Asset Record for the Dummy Asset
        Asset GWotGo = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-076', Parent_Asset__c = dummyUnitAsset.Id);
        GWotGo.Product2Id = prodTemp3.Id;
        GWotGo.SIM_Card_Active__c = true;
        GWotGo.SIM_Card_ICCID__c = '89011704258018735311';
		GWotGo.GWotGo__c = true;
		GWotGo.Commissioned__c = true;
		GWotGo.ResetSuccessful__c = 'None';
		GWotGo.MAC_Address__c = '000000000000';
        insert GWotGo;

		// Create Subscription Pair and a Permanent Contact
		Contact contactTemp2 = new Contact();
        contactTemp2.Eprise_Login_ID__c = 'RoesslKS2';
        contactTemp2.RecordTypeId = recordTypeTemp.Id;
        contactTemp2.AccountId = acctTemp.Id;
        contactTemp2.Status__c = 'Active';
        contactTemp2.Email = 'kent2.roessler@daikinapplied.com';
        contactTemp2.FirstName = 'Kent2';
        contactTemp2.LastName = 'Roessler2';
        contactTemp2.IE_Sync_Status__c = 'Pending';
        contactTemp2.IE_Contact__c = true;
        // Create an address for this contact
        Address__c addrTemp3 = new Address__c();
        addrTemp3.Address_Line_1__c = 'Test Address Line 2';
        addrTemp3.City__c = 'Minneapolis';
        addrTemp3.Postal_Code__c = '55421';
        addrTemp3.Country__c = 'United States';
        addrTemp3.State_Province__c = 'Minnesota';
        insert addrTemp3;
        contactTemp2.Physical_Address__c = addrTemp3.Id;
        insert contactTemp2;

		Contact_Address__c contactAddrJunctionObj2 = new Contact_Address__c();
        contactAddrJunctionObj2.Contact__c = contactTemp2.Id;
        contactAddrJunctionObj2.Address__c = addrTemp3.Id;
        contactAddrJunctionObj2.Active__c = true;
        contactAddrJunctionObj2.Physical__c = true;
        insert contactAddrJunctionObj2;

		Subscription__c subTemp3 = new Subscription__c();
        subTemp3.TriggerInvokedByAPI__c = false;
        subTemp3.IE_Subscription__c = true;
        subTemp3.Start_Date__c = currDateTime;
        subTemp3.End_Date__c = currDateTime.addMonths(6);
        subTemp3.Type__c = 'TechReadWrite';
        subTemp3.Active__c = true;
        subTemp3.Asset__c = dummyUnitAsset.Id;
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
		subTemp3.GWotGoAsset__c = GWotGo.Id;
        insert subTemp3;

		Subscription__c subTemp4 = new Subscription__c();
        subTemp4.TriggerInvokedByAPI__c = false;
        subTemp4.IE_Subscription__c = true;
        subTemp4.Start_Date__c = currDateTime;
        subTemp4.End_Date__c = currDateTime.addMonths(6);
        subTemp4.Type__c = 'CustomRead';
        subTemp4.Active__c = true;
        subTemp4.Asset__c = dummyUnitAsset.Id;
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
		subTemp4.GWotGoAsset__c = GWotGo.Id;
        insert subTemp4;

		// Associate the contact to the subscription
        Contact_Subscription__c contSubTemp2 = new Contact_Subscription__c();
        contSubTemp2.Role__c = 'TechnicianAdministrator';
        contSubTemp2.Contact__c = contactTemp2.Id;
        contSubTemp2.Subscription__c = subTemp3.Id;
        contSubTemp2.Asset__c = dummyUnitAsset.Id;
		contSubTemp2.GWotGoAsset__c = GWotGo.Id;
		contSubTemp2.GWotGoPermAssoc__c = true;
        insert contSubTemp2;



		//call the service
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        req.requestURI = 'https://cs8.salesforce.com/services/apexrest/ResetGWotGoAsset?UnitSerialNumber=SN123Test1&GatewayMACAddr=000000000000&UserEmail=kent.roessler@daikinapplied.com';  
        req.httpMethod = 'PUT';
        RestContext.request = req;
        RestContext.response = res;
        RestContext.request.params.put('UnitSerialNumber','SN123Test1');
		RestContext.request.params.put('GatewayMACAddr','000000000000');
		RestContext.request.params.put('UserEmail','kent.roessler@daikinapplied.com');

		//Test.startTest();
		// Force an exception to be thrown
	    Batch_IE_CallExtWebServices.crash_syncIeCloudUnits_TestByException = true;

        ResetGWotGoAsset.ResetResponse results = ResetGWotGoAsset.doPut();
		Test.stopTest();

		//assert the results
        System.assertEquals('SN123Test1', results.UnitSerialNumber);
		System.assertEquals('000000000000', results.GatewayMACAddress);
		System.assertEquals('kent.roessler@daikinapplied.com', results.UserEmail);

		for (ResetGWotGoAsset.Response_Error e : results.Errors)
		{
			System.assertEquals('UNIT_RESET_EXCEPTION', e.ErrorCode);
			System.assert(e.ErrorMessage.contains('ResetGWotGoAsset Exception:'));
		}

	}


	@isTest(SeeAllData=true) static void testPut_processRequest_UnitCreateResponseStatusCodeError1() {
		// ----------------Setup Test Data in Salesforce objects:

		//!!!!!!!!!!! Need to add this code snippet for AvaTax- AccountAddressTrigger to run successfully on Before Insert into the Account table !!!!!!!!!!!!!!!!!
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;

		Datetime currDateTime = Datetime.now();
        Date currentDate = Date.today();
        RecordType recordTypeTemp = [SELECT Id FROM RecordType WHERE Name='Daikin Applied' AND SObjectType='Contact'];

		// Get Dummy Unit Asset for GWotGo
		Asset dummyUnitAsset = [SELECT Id, Name from Asset Where Name = 'Dummy GWotGo Unit Asset'];


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
        acctTemp.IE_Sync_Status__c = 'Pending';
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
        orderTemp1.Order_Entry_Date__c = Date.today();
        orderTemp1.SO_Number__c = 'SO #999';
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
        
        
        // Create Parent Asset record with a GWotGo
        Asset parentAsset1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test1', Tag__c='Order Tag 1');
        parentAsset1.Product2Id = prodTemp1.Id;
        parentAsset1.Order__c = orderTemp1.Id;
		parentAsset1.Asset_Address__c = addrTemp.Id;
        parentAsset1.IE_Asset__c = true;
        parentAsset1.Code_String_Breakdown__c = '[{"code_sequence":"1","code_value":"MPS","code_description":"UNIT TYPE; Unit Type"},{"code_sequence":"2","code_value":"003B","code_description":"UNIT SIZE; 3 ton, R410A"},{"code_sequence":"3","code_value":"Y","code_description":"HEAT; None"},{"code_sequence":"4","code_value":"D","code_description":"VOLTAGE/POWER CONNECTION; 460 V power"},{"code_sequence":"5","code_value":"M","code_description":"DRIVE PACKAGE; Belt drive - high static"},{"code_sequence":"6","code_value":"00D","code_description":"HEATING CAPACITY/CONTROLS; DDC controls"},{"code_sequence":"7","code_value":"CZ","code_description":"OPTIONS; HP,LP,LowAmb/Comfort Aler,FldPower GFI, Hail Guard"},{"code_sequence":"8","code_value":"D","code_description":"ECONOMIZER; Field Mounted 0-30% Outside air hood"}]';
        insert parentAsset1;

		//Create Asset Address record
        Asset_Address__c aa = new Asset_Address__c(Asset__c = parentAsset1.Id
                                                  ,Address__c = addrTemp.Id
                                                  ,Building_Identifier__c = '123');
        insert aa;
        
		
        // Create GWotGo Asset Record for the Parent Asset
        Asset relatedAsset1 = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-075', Parent_Asset__c = parentAsset1.Id);
        relatedAsset1.Product2Id = prodTemp3.Id;
        relatedAsset1.SIM_Card_Active__c = true;
        relatedAsset1.SIM_Card_ICCID__c = '89011704258018735310';
		relatedAsset1.GWotGo__c = true;
		relatedAsset1.Commissioned__c = true;
		relatedAsset1.ResetSuccessful__c = 'None';
		relatedAsset1.MAC_Address__c = '000000000001';
        insert relatedAsset1;

		// Create Subscription Pair and a Permanent Contact
		Contact contactTemp1 = new Contact();
        contactTemp1.Eprise_Login_ID__c = 'RoesslKS1';
        contactTemp1.RecordTypeId = recordTypeTemp.Id;
        contactTemp1.AccountId = acctTemp.Id;
        contactTemp1.Status__c = 'Active';
        contactTemp1.Email = 'kent.roessler@daikinapplied.com';
        contactTemp1.FirstName = 'Kent1';
        contactTemp1.LastName = 'Roessler1';
        contactTemp1.IE_Sync_Status__c = 'Pending';
        contactTemp1.IE_Contact__c = true;
        // Create an address for this contact
        Address__c addrTemp2 = new Address__c();
        addrTemp2.Address_Line_1__c = 'Test Address Line 1';
        addrTemp2.City__c = 'Minneapolis';
        addrTemp2.Postal_Code__c = '55421';
        addrTemp2.Country__c = 'United States';
        addrTemp2.State_Province__c = 'Minnesota';
        insert addrTemp2;
        contactTemp1.Physical_Address__c = addrTemp2.Id;
        insert contactTemp1;

		Contact_Address__c contactAddrJunctionObj = new Contact_Address__c();
        contactAddrJunctionObj.Contact__c = contactTemp1.Id;
        contactAddrJunctionObj.Address__c = addrTemp2.Id;
        contactAddrJunctionObj.Active__c = true;
        contactAddrJunctionObj.Physical__c = true;
        insert contactAddrJunctionObj;

		Subscription__c subTemp1 = new Subscription__c();
        subTemp1.TriggerInvokedByAPI__c = false;
        subTemp1.IE_Subscription__c = true;
        subTemp1.Start_Date__c = currDateTime;
        subTemp1.End_Date__c = currDateTime.addMonths(6);
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
        subTemp2.TriggerInvokedByAPI__c = false;
        subTemp2.IE_Subscription__c = true;
        subTemp2.Start_Date__c = currDateTime;
        subTemp2.End_Date__c = currDateTime.addMonths(6);
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

		// Associate the contact to the subscription
        Contact_Subscription__c contSubTemp1 = new Contact_Subscription__c();
        contSubTemp1.Role__c = 'TechnicianAdministrator';
        contSubTemp1.Contact__c = contactTemp1.Id;
        contSubTemp1.Subscription__c = subTemp1.Id;
        contSubTemp1.Asset__c = parentAsset1.Id;
		contSubTemp1.GWotGoAsset__c = relatedAsset1.Id;
		contSubTemp1.GWotGoPermAssoc__c = true;
        insert contSubTemp1;

		Test.startTest();
		// Create GWotGo Asset Record for the Dummy Asset
        Asset GWotGo = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-076', Parent_Asset__c = dummyUnitAsset.Id);
        GWotGo.Product2Id = prodTemp3.Id;
        GWotGo.SIM_Card_Active__c = true;
        GWotGo.SIM_Card_ICCID__c = '89011704258018735311';
		GWotGo.GWotGo__c = true;
		GWotGo.Commissioned__c = true;
		GWotGo.ResetSuccessful__c = 'None';
		GWotGo.MAC_Address__c = '000000000000';
        insert GWotGo;

		// Create Subscription Pair and a Permanent Contact
		Contact contactTemp2 = new Contact();
        contactTemp2.Eprise_Login_ID__c = 'RoesslKS2';
        contactTemp2.RecordTypeId = recordTypeTemp.Id;
        contactTemp2.AccountId = acctTemp.Id;
        contactTemp2.Status__c = 'Active';
        contactTemp2.Email = 'kent2.roessler@daikinapplied.com';
        contactTemp2.FirstName = 'Kent2';
        contactTemp2.LastName = 'Roessler2';
        contactTemp2.IE_Sync_Status__c = 'Pending';
        contactTemp2.IE_Contact__c = true;
        // Create an address for this contact
        Address__c addrTemp3 = new Address__c();
        addrTemp3.Address_Line_1__c = 'Test Address Line 2';
        addrTemp3.City__c = 'Minneapolis';
        addrTemp3.Postal_Code__c = '55421';
        addrTemp3.Country__c = 'United States';
        addrTemp3.State_Province__c = 'Minnesota';
        insert addrTemp3;
        contactTemp2.Physical_Address__c = addrTemp3.Id;
        insert contactTemp2;

		Contact_Address__c contactAddrJunctionObj2 = new Contact_Address__c();
        contactAddrJunctionObj2.Contact__c = contactTemp2.Id;
        contactAddrJunctionObj2.Address__c = addrTemp3.Id;
        contactAddrJunctionObj2.Active__c = true;
        contactAddrJunctionObj2.Physical__c = true;
        insert contactAddrJunctionObj2;

		Subscription__c subTemp3 = new Subscription__c();
        subTemp3.TriggerInvokedByAPI__c = false;
        subTemp3.IE_Subscription__c = true;
        subTemp3.Start_Date__c = currDateTime;
        subTemp3.End_Date__c = currDateTime.addMonths(6);
        subTemp3.Type__c = 'TechReadWrite';
        subTemp3.Active__c = true;
        subTemp3.Asset__c = dummyUnitAsset.Id;
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
		subTemp3.GWotGoAsset__c = GWotGo.Id;
        insert subTemp3;

		Subscription__c subTemp4 = new Subscription__c();
        subTemp4.TriggerInvokedByAPI__c = false;
        subTemp4.IE_Subscription__c = true;
        subTemp4.Start_Date__c = currDateTime;
        subTemp4.End_Date__c = currDateTime.addMonths(6);
        subTemp4.Type__c = 'CustomRead';
        subTemp4.Active__c = true;
        subTemp4.Asset__c = dummyUnitAsset.Id;
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
		subTemp4.GWotGoAsset__c = GWotGo.Id;
        insert subTemp4;

		// Associate the contact to the subscription
        Contact_Subscription__c contSubTemp2 = new Contact_Subscription__c();
        contSubTemp2.Role__c = 'TechnicianAdministrator';
        contSubTemp2.Contact__c = contactTemp2.Id;
        contSubTemp2.Subscription__c = subTemp3.Id;
        contSubTemp2.Asset__c = dummyUnitAsset.Id;
		contSubTemp2.GWotGoAsset__c = GWotGo.Id;
		contSubTemp2.GWotGoPermAssoc__c = true;
        insert contSubTemp2;



		//call the service
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        req.requestURI = 'https://cs8.salesforce.com/services/apexrest/ResetGWotGoAsset?UnitSerialNumber=SN123Test1&GatewayMACAddr=000000000000&UserEmail=kent.roessler@daikinapplied.com';  
        req.httpMethod = 'PUT';
        RestContext.request = req;
        RestContext.response = res;
        RestContext.request.params.put('UnitSerialNumber','SN123Test1');
		RestContext.request.params.put('GatewayMACAddr','000000000000');
		RestContext.request.params.put('UserEmail','kent.roessler@daikinapplied.com');

		//Test.startTest();
		// Force an exception to be thrown
	    Batch_IE_CallExtWebServices.crash_syncIeCloudUnits_TestByResponseStatusCode = true;

        ResetGWotGoAsset.ResetResponse results = ResetGWotGoAsset.doPut();
		Test.stopTest();

		//assert the results
        System.assertEquals('SN123Test1', results.UnitSerialNumber);
		System.assertEquals('000000000000', results.GatewayMACAddress);
		System.assertEquals('kent.roessler@daikinapplied.com', results.UserEmail);

		for (ResetGWotGoAsset.Response_Error e : results.Errors)
		{
			System.assertEquals('UNIT_RESET_EXCEPTION', e.ErrorCode);
			System.assert(e.ErrorMessage.contains('ResetGWotGoAsset Exception:'));
		}

	}


	@isTest(SeeAllData=true) static void testPut_processRequest_UnitCreateException2() {
		// ----------------Setup Test Data in Salesforce objects:

		//!!!!!!!!!!! Need to add this code snippet for AvaTax- AccountAddressTrigger to run successfully on Before Insert into the Account table !!!!!!!!!!!!!!!!!
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;

		Datetime currDateTime = Datetime.now();
        Date currentDate = Date.today();
        RecordType recordTypeTemp = [SELECT Id FROM RecordType WHERE Name='Daikin Applied' AND SObjectType='Contact'];

		// Get Dummy Unit Asset for GWotGo
		Asset dummyUnitAsset = [SELECT Id, Name from Asset Where Name = 'Dummy GWotGo Unit Asset'];


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
        acctTemp.IE_Sync_Status__c = 'Pending';
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
        orderTemp1.Order_Entry_Date__c = Date.today();
        orderTemp1.SO_Number__c = 'SO #999';
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
        
        
        // Create Parent Asset record with a GWotGo
        Asset parentAsset1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test1', Tag__c='Order Tag 1');
        parentAsset1.Product2Id = prodTemp1.Id;
        parentAsset1.Order__c = orderTemp1.Id;
		parentAsset1.Asset_Address__c = addrTemp.Id;
        parentAsset1.IE_Asset__c = true;
        parentAsset1.Code_String_Breakdown__c = '[{"code_sequence":"1","code_value":"MPS","code_description":"UNIT TYPE; Unit Type"},{"code_sequence":"2","code_value":"003B","code_description":"UNIT SIZE; 3 ton, R410A"},{"code_sequence":"3","code_value":"Y","code_description":"HEAT; None"},{"code_sequence":"4","code_value":"D","code_description":"VOLTAGE/POWER CONNECTION; 460 V power"},{"code_sequence":"5","code_value":"M","code_description":"DRIVE PACKAGE; Belt drive - high static"},{"code_sequence":"6","code_value":"00D","code_description":"HEATING CAPACITY/CONTROLS; DDC controls"},{"code_sequence":"7","code_value":"CZ","code_description":"OPTIONS; HP,LP,LowAmb/Comfort Aler,FldPower GFI, Hail Guard"},{"code_sequence":"8","code_value":"D","code_description":"ECONOMIZER; Field Mounted 0-30% Outside air hood"}]';
        insert parentAsset1;

		//Create Asset Address record
        Asset_Address__c aa = new Asset_Address__c(Asset__c = parentAsset1.Id
                                                  ,Address__c = addrTemp.Id
                                                  ,Building_Identifier__c = '123');
        insert aa;
        
		
        // Create GWotGo Asset Record for the Parent Asset
        Asset relatedAsset1 = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-075', Parent_Asset__c = parentAsset1.Id);
        relatedAsset1.Product2Id = prodTemp3.Id;
        relatedAsset1.SIM_Card_Active__c = true;
        relatedAsset1.SIM_Card_ICCID__c = '89011704258018735310';
		relatedAsset1.GWotGo__c = true;
		relatedAsset1.Commissioned__c = true;
		relatedAsset1.ResetSuccessful__c = 'None';
		relatedAsset1.MAC_Address__c = '000000000001';
        insert relatedAsset1;

		// Create Subscription Pair and a Permanent Contact
		Contact contactTemp1 = new Contact();
        contactTemp1.Eprise_Login_ID__c = 'RoesslKS1';
        contactTemp1.RecordTypeId = recordTypeTemp.Id;
        contactTemp1.AccountId = acctTemp.Id;
        contactTemp1.Status__c = 'Active';
        contactTemp1.Email = 'kent.roessler@daikinapplied.com';
        contactTemp1.FirstName = 'Kent1';
        contactTemp1.LastName = 'Roessler1';
        contactTemp1.IE_Sync_Status__c = 'Pending';
        contactTemp1.IE_Contact__c = true;
        // Create an address for this contact
        Address__c addrTemp2 = new Address__c();
        addrTemp2.Address_Line_1__c = 'Test Address Line 1';
        addrTemp2.City__c = 'Minneapolis';
        addrTemp2.Postal_Code__c = '55421';
        addrTemp2.Country__c = 'United States';
        addrTemp2.State_Province__c = 'Minnesota';
        insert addrTemp2;
        contactTemp1.Physical_Address__c = addrTemp2.Id;
        insert contactTemp1;

		Contact_Address__c contactAddrJunctionObj = new Contact_Address__c();
        contactAddrJunctionObj.Contact__c = contactTemp1.Id;
        contactAddrJunctionObj.Address__c = addrTemp2.Id;
        contactAddrJunctionObj.Active__c = true;
        contactAddrJunctionObj.Physical__c = true;
        insert contactAddrJunctionObj;

		Subscription__c subTemp1 = new Subscription__c();
        subTemp1.TriggerInvokedByAPI__c = false;
        subTemp1.IE_Subscription__c = true;
        subTemp1.Start_Date__c = currDateTime;
        subTemp1.End_Date__c = currDateTime.addMonths(6);
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
        subTemp2.TriggerInvokedByAPI__c = false;
        subTemp2.IE_Subscription__c = true;
        subTemp2.Start_Date__c = currDateTime;
        subTemp2.End_Date__c = currDateTime.addMonths(6);
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

		// Associate the contact to the subscription
        Contact_Subscription__c contSubTemp1 = new Contact_Subscription__c();
        contSubTemp1.Role__c = 'TechnicianAdministrator';
        contSubTemp1.Contact__c = contactTemp1.Id;
        contSubTemp1.Subscription__c = subTemp1.Id;
        contSubTemp1.Asset__c = parentAsset1.Id;
		contSubTemp1.GWotGoAsset__c = relatedAsset1.Id;
		contSubTemp1.GWotGoPermAssoc__c = true;
        insert contSubTemp1;

		Test.startTest();
		// Create GWotGo Asset Record for the Dummy Asset
        Asset GWotGo = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-076', Parent_Asset__c = dummyUnitAsset.Id);
        GWotGo.Product2Id = prodTemp3.Id;
        GWotGo.SIM_Card_Active__c = true;
        GWotGo.SIM_Card_ICCID__c = '89011704258018735311';
		GWotGo.GWotGo__c = true;
		GWotGo.Commissioned__c = true;
		GWotGo.ResetSuccessful__c = 'None';
		GWotGo.MAC_Address__c = '000000000000';
        insert GWotGo;

		// Create Subscription Pair and a Permanent Contact
		Contact contactTemp2 = new Contact();
        contactTemp2.Eprise_Login_ID__c = 'RoesslKS2';
        contactTemp2.RecordTypeId = recordTypeTemp.Id;
        contactTemp2.AccountId = acctTemp.Id;
        contactTemp2.Status__c = 'Active';
        contactTemp2.Email = 'kent2.roessler@daikinapplied.com';
        contactTemp2.FirstName = 'Kent2';
        contactTemp2.LastName = 'Roessler2';
        contactTemp2.IE_Sync_Status__c = 'Pending';
        contactTemp2.IE_Contact__c = true;
        // Create an address for this contact
        Address__c addrTemp3 = new Address__c();
        addrTemp3.Address_Line_1__c = 'Test Address Line 2';
        addrTemp3.City__c = 'Minneapolis';
        addrTemp3.Postal_Code__c = '55421';
        addrTemp3.Country__c = 'United States';
        addrTemp3.State_Province__c = 'Minnesota';
        insert addrTemp3;
        contactTemp2.Physical_Address__c = addrTemp3.Id;
        insert contactTemp2;

		Contact_Address__c contactAddrJunctionObj2 = new Contact_Address__c();
        contactAddrJunctionObj2.Contact__c = contactTemp2.Id;
        contactAddrJunctionObj2.Address__c = addrTemp3.Id;
        contactAddrJunctionObj2.Active__c = true;
        contactAddrJunctionObj2.Physical__c = true;
        insert contactAddrJunctionObj2;

		Subscription__c subTemp3 = new Subscription__c();
        subTemp3.TriggerInvokedByAPI__c = false;
        subTemp3.IE_Subscription__c = true;
        subTemp3.Start_Date__c = currDateTime;
        subTemp3.End_Date__c = currDateTime.addMonths(6);
        subTemp3.Type__c = 'TechReadWrite';
        subTemp3.Active__c = true;
        subTemp3.Asset__c = dummyUnitAsset.Id;
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
		subTemp3.GWotGoAsset__c = GWotGo.Id;
        insert subTemp3;

		Subscription__c subTemp4 = new Subscription__c();
        subTemp4.TriggerInvokedByAPI__c = false;
        subTemp4.IE_Subscription__c = true;
        subTemp4.Start_Date__c = currDateTime;
        subTemp4.End_Date__c = currDateTime.addMonths(6);
        subTemp4.Type__c = 'CustomRead';
        subTemp4.Active__c = true;
        subTemp4.Asset__c = dummyUnitAsset.Id;
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
		subTemp4.GWotGoAsset__c = GWotGo.Id;
        insert subTemp4;

		// Associate the contact to the subscription
        Contact_Subscription__c contSubTemp2 = new Contact_Subscription__c();
        contSubTemp2.Role__c = 'TechnicianAdministrator';
        contSubTemp2.Contact__c = contactTemp2.Id;
        contSubTemp2.Subscription__c = subTemp3.Id;
        contSubTemp2.Asset__c = dummyUnitAsset.Id;
		contSubTemp2.GWotGoAsset__c = GWotGo.Id;
		contSubTemp2.GWotGoPermAssoc__c = true;
        insert contSubTemp2;



		//call the service
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        req.requestURI = 'https://cs8.salesforce.com/services/apexrest/ResetGWotGoAsset?UnitSerialNumber=SN123Test1&GatewayMACAddr=000000000000&UserEmail=kent.roessler@daikinapplied.com';  
        req.httpMethod = 'PUT';
        RestContext.request = req;
        RestContext.response = res;
        RestContext.request.params.put('UnitSerialNumber','SN123Test1');
		RestContext.request.params.put('GatewayMACAddr','000000000000');
		RestContext.request.params.put('UserEmail','kent.roessler@daikinapplied.com');

		//Test.startTest();
		// Force an exception to be thrown
	    Batch_IE_CallExtWebServices.crash_syncIeCloudOrganizations_TestByException = true;

        ResetGWotGoAsset.ResetResponse results = ResetGWotGoAsset.doPut();
		Test.stopTest();

		//assert the results
        System.assertEquals('SN123Test1', results.UnitSerialNumber);
		System.assertEquals('000000000000', results.GatewayMACAddress);
		System.assertEquals('kent.roessler@daikinapplied.com', results.UserEmail);

		for (ResetGWotGoAsset.Response_Error e : results.Errors)
		{
			System.assertEquals('UNIT_RESET_EXCEPTION', e.ErrorCode);
			System.assert(e.ErrorMessage.contains('ResetGWotGoAsset Exception:'));
		}

	}


	@isTest(SeeAllData=true) static void testPut_processRequest_UnitCreateResponseStatusCodeError2() {
		// ----------------Setup Test Data in Salesforce objects:

		//!!!!!!!!!!! Need to add this code snippet for AvaTax- AccountAddressTrigger to run successfully on Before Insert into the Account table !!!!!!!!!!!!!!!!!
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;

		Datetime currDateTime = Datetime.now();
        Date currentDate = Date.today();
        RecordType recordTypeTemp = [SELECT Id FROM RecordType WHERE Name='Daikin Applied' AND SObjectType='Contact'];

		// Get Dummy Unit Asset for GWotGo
		Asset dummyUnitAsset = [SELECT Id, Name from Asset Where Name = 'Dummy GWotGo Unit Asset'];


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
        acctTemp.IE_Sync_Status__c = 'Pending';
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
        orderTemp1.Order_Entry_Date__c = Date.today();
        orderTemp1.SO_Number__c = 'SO #999';
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
        
        
        // Create Parent Asset record with a GWotGo
        Asset parentAsset1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test1', Tag__c='Order Tag 1');
        parentAsset1.Product2Id = prodTemp1.Id;
        parentAsset1.Order__c = orderTemp1.Id;
		parentAsset1.Asset_Address__c = addrTemp.Id;
        parentAsset1.IE_Asset__c = true;
        parentAsset1.Code_String_Breakdown__c = '[{"code_sequence":"1","code_value":"MPS","code_description":"UNIT TYPE; Unit Type"},{"code_sequence":"2","code_value":"003B","code_description":"UNIT SIZE; 3 ton, R410A"},{"code_sequence":"3","code_value":"Y","code_description":"HEAT; None"},{"code_sequence":"4","code_value":"D","code_description":"VOLTAGE/POWER CONNECTION; 460 V power"},{"code_sequence":"5","code_value":"M","code_description":"DRIVE PACKAGE; Belt drive - high static"},{"code_sequence":"6","code_value":"00D","code_description":"HEATING CAPACITY/CONTROLS; DDC controls"},{"code_sequence":"7","code_value":"CZ","code_description":"OPTIONS; HP,LP,LowAmb/Comfort Aler,FldPower GFI, Hail Guard"},{"code_sequence":"8","code_value":"D","code_description":"ECONOMIZER; Field Mounted 0-30% Outside air hood"}]';
        insert parentAsset1;

		//Create Asset Address record
        Asset_Address__c aa = new Asset_Address__c(Asset__c = parentAsset1.Id
                                                  ,Address__c = addrTemp.Id
                                                  ,Building_Identifier__c = '123');
        insert aa;
        
		
        // Create GWotGo Asset Record for the Parent Asset
        Asset relatedAsset1 = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-075', Parent_Asset__c = parentAsset1.Id);
        relatedAsset1.Product2Id = prodTemp3.Id;
        relatedAsset1.SIM_Card_Active__c = true;
        relatedAsset1.SIM_Card_ICCID__c = '89011704258018735310';
		relatedAsset1.GWotGo__c = true;
		relatedAsset1.Commissioned__c = true;
		relatedAsset1.ResetSuccessful__c = 'None';
		relatedAsset1.MAC_Address__c = '000000000001';
        insert relatedAsset1;

		// Create Subscription Pair and a Permanent Contact
		Contact contactTemp1 = new Contact();
        contactTemp1.Eprise_Login_ID__c = 'RoesslKS1';
        contactTemp1.RecordTypeId = recordTypeTemp.Id;
        contactTemp1.AccountId = acctTemp.Id;
        contactTemp1.Status__c = 'Active';
        contactTemp1.Email = 'kent.roessler@daikinapplied.com';
        contactTemp1.FirstName = 'Kent1';
        contactTemp1.LastName = 'Roessler1';
        contactTemp1.IE_Sync_Status__c = 'Pending';
        contactTemp1.IE_Contact__c = true;
        // Create an address for this contact
        Address__c addrTemp2 = new Address__c();
        addrTemp2.Address_Line_1__c = 'Test Address Line 1';
        addrTemp2.City__c = 'Minneapolis';
        addrTemp2.Postal_Code__c = '55421';
        addrTemp2.Country__c = 'United States';
        addrTemp2.State_Province__c = 'Minnesota';
        insert addrTemp2;
        contactTemp1.Physical_Address__c = addrTemp2.Id;
        insert contactTemp1;

		Contact_Address__c contactAddrJunctionObj = new Contact_Address__c();
        contactAddrJunctionObj.Contact__c = contactTemp1.Id;
        contactAddrJunctionObj.Address__c = addrTemp2.Id;
        contactAddrJunctionObj.Active__c = true;
        contactAddrJunctionObj.Physical__c = true;
        insert contactAddrJunctionObj;

		Subscription__c subTemp1 = new Subscription__c();
        subTemp1.TriggerInvokedByAPI__c = false;
        subTemp1.IE_Subscription__c = true;
        subTemp1.Start_Date__c = currDateTime;
        subTemp1.End_Date__c = currDateTime.addMonths(6);
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
        subTemp2.TriggerInvokedByAPI__c = false;
        subTemp2.IE_Subscription__c = true;
        subTemp2.Start_Date__c = currDateTime;
        subTemp2.End_Date__c = currDateTime.addMonths(6);
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

		// Associate the contact to the subscription
        Contact_Subscription__c contSubTemp1 = new Contact_Subscription__c();
        contSubTemp1.Role__c = 'TechnicianAdministrator';
        contSubTemp1.Contact__c = contactTemp1.Id;
        contSubTemp1.Subscription__c = subTemp1.Id;
        contSubTemp1.Asset__c = parentAsset1.Id;
		contSubTemp1.GWotGoAsset__c = relatedAsset1.Id;
		contSubTemp1.GWotGoPermAssoc__c = true;
        insert contSubTemp1;

		Test.startTest();
		// Create GWotGo Asset Record for the Dummy Asset
        Asset GWotGo = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-076', Parent_Asset__c = dummyUnitAsset.Id);
        GWotGo.Product2Id = prodTemp3.Id;
        GWotGo.SIM_Card_Active__c = true;
        GWotGo.SIM_Card_ICCID__c = '89011704258018735311';
		GWotGo.GWotGo__c = true;
		GWotGo.Commissioned__c = true;
		GWotGo.ResetSuccessful__c = 'None';
		GWotGo.MAC_Address__c = '000000000000';
        insert GWotGo;

		// Create Subscription Pair and a Permanent Contact
		Contact contactTemp2 = new Contact();
        contactTemp2.Eprise_Login_ID__c = 'RoesslKS2';
        contactTemp2.RecordTypeId = recordTypeTemp.Id;
        contactTemp2.AccountId = acctTemp.Id;
        contactTemp2.Status__c = 'Active';
        contactTemp2.Email = 'kent2.roessler@daikinapplied.com';
        contactTemp2.FirstName = 'Kent2';
        contactTemp2.LastName = 'Roessler2';
        contactTemp2.IE_Sync_Status__c = 'Pending';
        contactTemp2.IE_Contact__c = true;
        // Create an address for this contact
        Address__c addrTemp3 = new Address__c();
        addrTemp3.Address_Line_1__c = 'Test Address Line 2';
        addrTemp3.City__c = 'Minneapolis';
        addrTemp3.Postal_Code__c = '55421';
        addrTemp3.Country__c = 'United States';
        addrTemp3.State_Province__c = 'Minnesota';
        insert addrTemp3;
        contactTemp2.Physical_Address__c = addrTemp3.Id;
        insert contactTemp2;

		Contact_Address__c contactAddrJunctionObj2 = new Contact_Address__c();
        contactAddrJunctionObj2.Contact__c = contactTemp2.Id;
        contactAddrJunctionObj2.Address__c = addrTemp3.Id;
        contactAddrJunctionObj2.Active__c = true;
        contactAddrJunctionObj2.Physical__c = true;
        insert contactAddrJunctionObj2;

		Subscription__c subTemp3 = new Subscription__c();
        subTemp3.TriggerInvokedByAPI__c = false;
        subTemp3.IE_Subscription__c = true;
        subTemp3.Start_Date__c = currDateTime;
        subTemp3.End_Date__c = currDateTime.addMonths(6);
        subTemp3.Type__c = 'TechReadWrite';
        subTemp3.Active__c = true;
        subTemp3.Asset__c = dummyUnitAsset.Id;
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
		subTemp3.GWotGoAsset__c = GWotGo.Id;
        insert subTemp3;

		Subscription__c subTemp4 = new Subscription__c();
        subTemp4.TriggerInvokedByAPI__c = false;
        subTemp4.IE_Subscription__c = true;
        subTemp4.Start_Date__c = currDateTime;
        subTemp4.End_Date__c = currDateTime.addMonths(6);
        subTemp4.Type__c = 'CustomRead';
        subTemp4.Active__c = true;
        subTemp4.Asset__c = dummyUnitAsset.Id;
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
		subTemp4.GWotGoAsset__c = GWotGo.Id;
        insert subTemp4;

		// Associate the contact to the subscription
        Contact_Subscription__c contSubTemp2 = new Contact_Subscription__c();
        contSubTemp2.Role__c = 'TechnicianAdministrator';
        contSubTemp2.Contact__c = contactTemp2.Id;
        contSubTemp2.Subscription__c = subTemp3.Id;
        contSubTemp2.Asset__c = dummyUnitAsset.Id;
		contSubTemp2.GWotGoAsset__c = GWotGo.Id;
		contSubTemp2.GWotGoPermAssoc__c = true;
        insert contSubTemp2;



		//call the service
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        req.requestURI = 'https://cs8.salesforce.com/services/apexrest/ResetGWotGoAsset?UnitSerialNumber=SN123Test1&GatewayMACAddr=000000000000&UserEmail=kent.roessler@daikinapplied.com';  
        req.httpMethod = 'PUT';
        RestContext.request = req;
        RestContext.response = res;
        RestContext.request.params.put('UnitSerialNumber','SN123Test1');
		RestContext.request.params.put('GatewayMACAddr','000000000000');
		RestContext.request.params.put('UserEmail','kent.roessler@daikinapplied.com');

		//Test.startTest();
		// Force an exception to be thrown
	    Batch_IE_CallExtWebServices.crash_syncIeCloudOrganizations_TestByResponseStatusCode = true;

        ResetGWotGoAsset.ResetResponse results = ResetGWotGoAsset.doPut();
		Test.stopTest();

		//assert the results
        System.assertEquals('SN123Test1', results.UnitSerialNumber);
		System.assertEquals('000000000000', results.GatewayMACAddress);
		System.assertEquals('kent.roessler@daikinapplied.com', results.UserEmail);

		for (ResetGWotGoAsset.Response_Error e : results.Errors)
		{
			System.assertEquals('UNIT_RESET_EXCEPTION', e.ErrorCode);
			System.assert(e.ErrorMessage.contains('ResetGWotGoAsset Exception:'));
		}

	}


	@isTest static void testPut_processRequest_ErrorCondition_UnitAssetIsIEAsset() {
		// ----------------Setup Test Data in Salesforce objects:

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
        acctTemp.IE_Sync_Status__c = 'Pending';
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
        orderTemp1.Order_Entry_Date__c = Date.today();
        orderTemp1.SO_Number__c = 'SO #999';
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
        
        
        // Create Parent Asset record
        Asset parentAsset1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test1', Tag__c='Order Tag 1');
        parentAsset1.Product2Id = prodTemp1.Id;
        parentAsset1.Order__c = orderTemp1.Id;
		parentAsset1.Asset_Address__c = addrTemp.Id;
        parentAsset1.IE_Asset__c = true;
        parentAsset1.Code_String_Breakdown__c = '[{"code_sequence":"1","code_value":"MPS","code_description":"UNIT TYPE; Unit Type"},{"code_sequence":"2","code_value":"003B","code_description":"UNIT SIZE; 3 ton, R410A"},{"code_sequence":"3","code_value":"Y","code_description":"HEAT; None"},{"code_sequence":"4","code_value":"D","code_description":"VOLTAGE/POWER CONNECTION; 460 V power"},{"code_sequence":"5","code_value":"M","code_description":"DRIVE PACKAGE; Belt drive - high static"},{"code_sequence":"6","code_value":"00D","code_description":"HEATING CAPACITY/CONTROLS; DDC controls"},{"code_sequence":"7","code_value":"CZ","code_description":"OPTIONS; HP,LP,LowAmb/Comfort Aler,FldPower GFI, Hail Guard"},{"code_sequence":"8","code_value":"D","code_description":"ECONOMIZER; Field Mounted 0-30% Outside air hood"}]';
        insert parentAsset1;

		//Create Asset Address record
        Asset_Address__c aa = new Asset_Address__c(Asset__c = parentAsset1.Id
                                                  ,Address__c = addrTemp.Id
                                                  ,Building_Identifier__c = '123');
        insert aa;
        
		// Create Related Asset Records for the Parent Asset
        Asset relatedAsset1 = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-075', Parent_Asset__c = parentAsset1.Id);
        relatedAsset1.Product2Id = prodTemp3.Id;
        relatedAsset1.SIM_Card_Active__c = true;
        relatedAsset1.SIM_Card_ICCID__c = '89011704258018735310';
        insert relatedAsset1;

        Asset relatedAsset2 = new Asset(Name = 'Intelligent Equipment Energy Management Module', AccountId = acctTemp.Id, SerialNumber = 'MESF04115', Parent_Asset__c = parentAsset1.Id);
        relatedAsset2.Product2Id = prodTemp4.Id;
        relatedAsset2.SIM_Card_Active__c = true;
        insert relatedAsset2;


		//call the service
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        req.requestURI = 'https://cs8.salesforce.com/services/apexrest/ResetGWotGoAsset?UnitSerialNumber=SN123Test1&GatewayMACAddr=000000000000&UserEmail=kent.roessler@daikinapplied.com';  
        req.httpMethod = 'PUT';
        RestContext.request = req;
        RestContext.response = res;
        RestContext.request.params.put('UnitSerialNumber','SN123Test1');
		RestContext.request.params.put('GatewayMACAddr','000000000000');
		RestContext.request.params.put('UserEmail','kent.roessler@daikinapplied.com');
        ResetGWotGoAsset.ResetResponse results = ResetGWotGoAsset.doPut();

		//assert the results
        System.assertEquals('SN123Test1', results.UnitSerialNumber);
		System.assertEquals('000000000000', results.GatewayMACAddress);
		System.assertEquals('kent.roessler@daikinapplied.com', results.UserEmail);

		for (ResetGWotGoAsset.Response_Error e : results.Errors)
		{
			System.assertEquals('ILLEGAL_CONDITION', e.ErrorCode);
			System.assert(e.ErrorMessage.contains('ResetGWotGoAsset Illegal Condition: The new unit asset is an IE asset and has a permanent gateway associated with it.  Cannot assign a GWotGo asset to this unit!'));
		}
	}


	@isTest static void testPut_processRequest_NewUnitNotFound() {
		// ----------------Setup Test Data in Salesforce objects:

		//!!!!!!!!!!! Need to add this code snippet for AvaTax- AccountAddressTrigger to run successfully on Before Insert into the Account table !!!!!!!!!!!!!!!!!
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;


		//call the service
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        req.requestURI = 'https://cs8.salesforce.com/services/apexrest/ResetGWotGoAsset?UnitSerialNumber=SN123Test1&GatewayMACAddr=000000000000&UserEmail=kent.roessler@daikinapplied.com';  
        req.httpMethod = 'PUT';
        RestContext.request = req;
        RestContext.response = res;
        //RestContext.request.params.put('UnitSerialNumber','SN123Test1');
		//RestContext.request.params.put('GatewayMACAddr','000000000000');
		//RestContext.request.params.put('UserEmail','kent.roessler@daikinapplied.com');
        ResetGWotGoAsset.ResetResponse results = ResetGWotGoAsset.doPut();

		//assert the results
        System.assertEquals(null, results.UnitSerialNumber);
		System.assertEquals(null, results.GatewayMACAddress);
		System.assertEquals(null, results.UserEmail);

		for (ResetGWotGoAsset.Response_Error e : results.Errors)
		{
			System.assertEquals('NEWUNIT_NOT_FOUND', e.ErrorCode);
			System.assert(e.ErrorMessage.contains('New Unit not found for Serial Number'));
		}

	}


	@isTest static void testPut_processRequest_GWAssetNotFound() {
		// ----------------Setup Test Data in Salesforce objects:

		//!!!!!!!!!!! Need to add this code snippet for AvaTax- AccountAddressTrigger to run successfully on Before Insert into the Account table !!!!!!!!!!!!!!!!!
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;

		Datetime currDateTime = Datetime.now();
        Date currentDate = Date.today();
        RecordType recordTypeTemp = [SELECT Id FROM RecordType WHERE Name='Daikin Applied' AND SObjectType='Contact'];


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
        acctTemp.IE_Sync_Status__c = 'Pending';
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
        orderTemp1.Order_Entry_Date__c = Date.today();
        orderTemp1.SO_Number__c = 'SO #999';
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
        
        
        // Create Parent Asset record
        Asset parentAsset1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test1', Tag__c='Order Tag 1');
        parentAsset1.Product2Id = prodTemp1.Id;
        parentAsset1.Order__c = orderTemp1.Id;
		parentAsset1.Asset_Address__c = addrTemp.Id;
        parentAsset1.IE_Asset__c = true;
        parentAsset1.Code_String_Breakdown__c = '[{"code_sequence":"1","code_value":"MPS","code_description":"UNIT TYPE; Unit Type"},{"code_sequence":"2","code_value":"003B","code_description":"UNIT SIZE; 3 ton, R410A"},{"code_sequence":"3","code_value":"Y","code_description":"HEAT; None"},{"code_sequence":"4","code_value":"D","code_description":"VOLTAGE/POWER CONNECTION; 460 V power"},{"code_sequence":"5","code_value":"M","code_description":"DRIVE PACKAGE; Belt drive - high static"},{"code_sequence":"6","code_value":"00D","code_description":"HEATING CAPACITY/CONTROLS; DDC controls"},{"code_sequence":"7","code_value":"CZ","code_description":"OPTIONS; HP,LP,LowAmb/Comfort Aler,FldPower GFI, Hail Guard"},{"code_sequence":"8","code_value":"D","code_description":"ECONOMIZER; Field Mounted 0-30% Outside air hood"}]';
        insert parentAsset1;

		//Create Asset Address record
        Asset_Address__c aa = new Asset_Address__c(Asset__c = parentAsset1.Id
                                                  ,Address__c = addrTemp.Id
                                                  ,Building_Identifier__c = '123');
        insert aa;
        
		
        // Create GWotGo Asset Record for the Parent Asset
        Asset relatedAsset1 = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-075', Parent_Asset__c = parentAsset1.Id);
        relatedAsset1.Product2Id = prodTemp3.Id;
        relatedAsset1.SIM_Card_Active__c = true;
        relatedAsset1.SIM_Card_ICCID__c = '89011704258018735310';
		relatedAsset1.GWotGo__c = true;
		relatedAsset1.Commissioned__c = true;
		relatedAsset1.ResetSuccessful__c = 'None';
		relatedAsset1.MAC_Address__c = '000000000000';
        insert relatedAsset1;

		// Create Subscription Pair and a Permanent Contact
		Contact contactTemp1 = new Contact();
        contactTemp1.Eprise_Login_ID__c = 'RoesslKS1';
        contactTemp1.RecordTypeId = recordTypeTemp.Id;
        contactTemp1.AccountId = acctTemp.Id;
        contactTemp1.Status__c = 'Active';
        contactTemp1.Email = 'kent.roessler@daikinapplied.com';
        contactTemp1.FirstName = 'Kent1';
        contactTemp1.LastName = 'Roessler1';
        contactTemp1.IE_Sync_Status__c = 'Pending';
        contactTemp1.IE_Contact__c = true;
        // Create an address for this contact
        Address__c addrTemp2 = new Address__c();
        addrTemp2.Address_Line_1__c = 'Test Address Line 1';
        addrTemp2.City__c = 'Minneapolis';
        addrTemp2.Postal_Code__c = '55421';
        addrTemp2.Country__c = 'United States';
        addrTemp2.State_Province__c = 'Minnesota';
        insert addrTemp2;
        contactTemp1.Physical_Address__c = addrTemp2.Id;
        insert contactTemp1;

		Contact_Address__c contactAddrJunctionObj = new Contact_Address__c();
        contactAddrJunctionObj.Contact__c = contactTemp1.Id;
        contactAddrJunctionObj.Address__c = addrTemp2.Id;
        contactAddrJunctionObj.Active__c = true;
        contactAddrJunctionObj.Physical__c = true;
        insert contactAddrJunctionObj;

		Subscription__c subTemp1 = new Subscription__c();
        subTemp1.TriggerInvokedByAPI__c = false;
        subTemp1.IE_Subscription__c = true;
        subTemp1.Start_Date__c = currDateTime;
        subTemp1.End_Date__c = currDateTime.addMonths(6);
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
        subTemp2.TriggerInvokedByAPI__c = false;
        subTemp2.IE_Subscription__c = true;
        subTemp2.Start_Date__c = currDateTime;
        subTemp2.End_Date__c = currDateTime.addMonths(6);
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

		// Associate the contact to the subscription
        Contact_Subscription__c contSubTemp1 = new Contact_Subscription__c();
        contSubTemp1.Role__c = 'TechnicianAdministrator';
        contSubTemp1.Contact__c = contactTemp1.Id;
        contSubTemp1.Subscription__c = subTemp1.Id;
        contSubTemp1.Asset__c = parentAsset1.Id;
		contSubTemp1.GWotGoAsset__c = relatedAsset1.Id;
		contSubTemp1.GWotGoPermAssoc__c = true;
        insert contSubTemp1;


		//call the service
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        req.requestURI = 'https://cs8.salesforce.com/services/apexrest/ResetGWotGoAsset?UnitSerialNumber=SN123Test1&GatewayMACAddr=000000000001&UserEmail=kent.roessler@daikinapplied.com';  
        req.httpMethod = 'PUT';
        RestContext.request = req;
        RestContext.response = res;
        RestContext.request.params.put('UnitSerialNumber','SN123Test1');
		RestContext.request.params.put('GatewayMACAddr','000000000001'); // use a value that doesn't exist
		RestContext.request.params.put('UserEmail','kent.roessler@daikinapplied.com');
        ResetGWotGoAsset.ResetResponse results = ResetGWotGoAsset.doPut();

		//assert the results
        System.assertEquals('SN123Test1', results.UnitSerialNumber);
		System.assertEquals('000000000001', results.GatewayMACAddress);
		System.assertEquals('kent.roessler@daikinapplied.com', results.UserEmail);

		for (ResetGWotGoAsset.Response_Error e : results.Errors)
		{
			System.assertEquals('GWASSET_NOT_FOUND', e.ErrorCode);
			System.assert(e.ErrorMessage.contains('Gateway Asset with MAC Address'));
		}
	}


	@isTest static void testPut_processRequest_ParentUnitForGWAssetNotFound() {
		// ----------------Setup Test Data in Salesforce objects:

		//!!!!!!!!!!! Need to add this code snippet for AvaTax- AccountAddressTrigger to run successfully on Before Insert into the Account table !!!!!!!!!!!!!!!!!
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;

		Datetime currDateTime = Datetime.now();
        Date currentDate = Date.today();
        RecordType recordTypeTemp = [SELECT Id FROM RecordType WHERE Name='Daikin Applied' AND SObjectType='Contact'];


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
        acctTemp.IE_Sync_Status__c = 'Pending';
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
        orderTemp1.Order_Entry_Date__c = Date.today();
        orderTemp1.SO_Number__c = 'SO #999';
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
        
        
        // Create a Unit Asset record
        Asset parentAsset1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test1', Tag__c='Order Tag 1');
        parentAsset1.Product2Id = prodTemp1.Id;
        parentAsset1.Order__c = orderTemp1.Id;
		parentAsset1.Asset_Address__c = addrTemp.Id;
        parentAsset1.IE_Asset__c = false;
        parentAsset1.Code_String_Breakdown__c = '[{"code_sequence":"1","code_value":"MPS","code_description":"UNIT TYPE; Unit Type"},{"code_sequence":"2","code_value":"003B","code_description":"UNIT SIZE; 3 ton, R410A"},{"code_sequence":"3","code_value":"Y","code_description":"HEAT; None"},{"code_sequence":"4","code_value":"D","code_description":"VOLTAGE/POWER CONNECTION; 460 V power"},{"code_sequence":"5","code_value":"M","code_description":"DRIVE PACKAGE; Belt drive - high static"},{"code_sequence":"6","code_value":"00D","code_description":"HEATING CAPACITY/CONTROLS; DDC controls"},{"code_sequence":"7","code_value":"CZ","code_description":"OPTIONS; HP,LP,LowAmb/Comfort Aler,FldPower GFI, Hail Guard"},{"code_sequence":"8","code_value":"D","code_description":"ECONOMIZER; Field Mounted 0-30% Outside air hood"}]';
        insert parentAsset1;

		//Create Asset Address record
        Asset_Address__c aa = new Asset_Address__c(Asset__c = parentAsset1.Id
                                                  ,Address__c = addrTemp.Id
                                                  ,Building_Identifier__c = '123');
        insert aa;
        
		
        // Create GWotGo Asset Record with NO Parent Asset
        Asset relatedAsset1 = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-075', Parent_Asset__c = null);
        relatedAsset1.Product2Id = prodTemp3.Id;
        relatedAsset1.SIM_Card_Active__c = true;
        relatedAsset1.SIM_Card_ICCID__c = '89011704258018735310';
		relatedAsset1.GWotGo__c = true;
		relatedAsset1.Commissioned__c = true;
		relatedAsset1.ResetSuccessful__c = 'None';
		relatedAsset1.MAC_Address__c = '000000000000';
        insert relatedAsset1;

		// Create Subscription Pair and a Permanent Contact
		Contact contactTemp1 = new Contact();
        contactTemp1.Eprise_Login_ID__c = 'RoesslKS1';
        contactTemp1.RecordTypeId = recordTypeTemp.Id;
        contactTemp1.AccountId = acctTemp.Id;
        contactTemp1.Status__c = 'Active';
        contactTemp1.Email = 'kent.roessler@daikinapplied.com';
        contactTemp1.FirstName = 'Kent1';
        contactTemp1.LastName = 'Roessler1';
        contactTemp1.IE_Sync_Status__c = 'Pending';
        contactTemp1.IE_Contact__c = true;
        // Create an address for this contact
        Address__c addrTemp2 = new Address__c();
        addrTemp2.Address_Line_1__c = 'Test Address Line 1';
        addrTemp2.City__c = 'Minneapolis';
        addrTemp2.Postal_Code__c = '55421';
        addrTemp2.Country__c = 'United States';
        addrTemp2.State_Province__c = 'Minnesota';
        insert addrTemp2;
        contactTemp1.Physical_Address__c = addrTemp2.Id;
        insert contactTemp1;

		Contact_Address__c contactAddrJunctionObj = new Contact_Address__c();
        contactAddrJunctionObj.Contact__c = contactTemp1.Id;
        contactAddrJunctionObj.Address__c = addrTemp2.Id;
        contactAddrJunctionObj.Active__c = true;
        contactAddrJunctionObj.Physical__c = true;
        insert contactAddrJunctionObj;

		Subscription__c subTemp1 = new Subscription__c();
        subTemp1.TriggerInvokedByAPI__c = false;
        subTemp1.IE_Subscription__c = true;
        subTemp1.Start_Date__c = currDateTime;
        subTemp1.End_Date__c = currDateTime.addMonths(6);
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
        subTemp2.TriggerInvokedByAPI__c = false;
        subTemp2.IE_Subscription__c = true;
        subTemp2.Start_Date__c = currDateTime;
        subTemp2.End_Date__c = currDateTime.addMonths(6);
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

		// Associate the contact to the subscription
        Contact_Subscription__c contSubTemp1 = new Contact_Subscription__c();
        contSubTemp1.Role__c = 'TechnicianAdministrator';
        contSubTemp1.Contact__c = contactTemp1.Id;
        contSubTemp1.Subscription__c = subTemp1.Id;
        contSubTemp1.Asset__c = parentAsset1.Id;
		contSubTemp1.GWotGoAsset__c = relatedAsset1.Id;
		contSubTemp1.GWotGoPermAssoc__c = true;
        insert contSubTemp1;


		//call the service
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        req.requestURI = 'https://cs8.salesforce.com/services/apexrest/ResetGWotGoAsset?UnitSerialNumber=SN123Test1&GatewayMACAddr=000000000000&UserEmail=kent.roessler@daikinapplied.com';  
        req.httpMethod = 'PUT';
        RestContext.request = req;
        RestContext.response = res;
        RestContext.request.params.put('UnitSerialNumber','SN123Test1');
		RestContext.request.params.put('GatewayMACAddr','000000000000');
		RestContext.request.params.put('UserEmail','kent.roessler@daikinapplied.com');
        ResetGWotGoAsset.ResetResponse results = ResetGWotGoAsset.doPut();

		//assert the results
        System.assertEquals('SN123Test1', results.UnitSerialNumber);
		System.assertEquals('000000000000', results.GatewayMACAddress);
		System.assertEquals('kent.roessler@daikinapplied.com', results.UserEmail);

		for (ResetGWotGoAsset.Response_Error e : results.Errors)
		{
			System.assertEquals('PARENTUNIT_NOT_FOUND', e.ErrorCode);
			System.assert(e.ErrorMessage.contains('Parent Unit not found for GWotGo asset with Serial Number'));
		}

	}


	@isTest(SeeAllData=true) static void testPut_processRequest_SubscriptionPairForGWAssetNotFound() {
		// ----------------Setup Test Data in Salesforce objects:

		//!!!!!!!!!!! Need to add this code snippet for AvaTax- AccountAddressTrigger to run successfully on Before Insert into the Account table !!!!!!!!!!!!!!!!!
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;

		Datetime currDateTime = Datetime.now();
        Date currentDate = Date.today();
        RecordType recordTypeTemp = [SELECT Id FROM RecordType WHERE Name='Daikin Applied' AND SObjectType='Contact'];

		// Get Dummy Unit Asset for GWotGo
		Asset dummyUnitAsset = [SELECT Id, Name from Asset Where Name = 'Dummy GWotGo Unit Asset'];



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
        acctTemp.IE_Sync_Status__c = 'Pending';
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
        orderTemp1.Order_Entry_Date__c = Date.today();
        orderTemp1.SO_Number__c = 'SO #999';
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
        
        
        // Create a Unit Asset record
        Asset parentAsset1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test1', Tag__c='Order Tag 1');
        parentAsset1.Product2Id = prodTemp1.Id;
        parentAsset1.Order__c = orderTemp1.Id;
		parentAsset1.Asset_Address__c = addrTemp.Id;
        parentAsset1.IE_Asset__c = false;
        parentAsset1.Code_String_Breakdown__c = '[{"code_sequence":"1","code_value":"MPS","code_description":"UNIT TYPE; Unit Type"},{"code_sequence":"2","code_value":"003B","code_description":"UNIT SIZE; 3 ton, R410A"},{"code_sequence":"3","code_value":"Y","code_description":"HEAT; None"},{"code_sequence":"4","code_value":"D","code_description":"VOLTAGE/POWER CONNECTION; 460 V power"},{"code_sequence":"5","code_value":"M","code_description":"DRIVE PACKAGE; Belt drive - high static"},{"code_sequence":"6","code_value":"00D","code_description":"HEATING CAPACITY/CONTROLS; DDC controls"},{"code_sequence":"7","code_value":"CZ","code_description":"OPTIONS; HP,LP,LowAmb/Comfort Aler,FldPower GFI, Hail Guard"},{"code_sequence":"8","code_value":"D","code_description":"ECONOMIZER; Field Mounted 0-30% Outside air hood"}]';
        insert parentAsset1;

		//Create Asset Address record
        Asset_Address__c aa = new Asset_Address__c(Asset__c = parentAsset1.Id
                                                  ,Address__c = addrTemp.Id
                                                  ,Building_Identifier__c = '123');
        insert aa;
        
		
        // Create GWotGo Asset Record with Dummy Parent Asset
        Asset relatedAsset1 = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-075', Parent_Asset__c = dummyUnitAsset.Id);
        relatedAsset1.Product2Id = prodTemp3.Id;
        relatedAsset1.SIM_Card_Active__c = true;
        relatedAsset1.SIM_Card_ICCID__c = '89011704258018735310';
		relatedAsset1.GWotGo__c = true;
		relatedAsset1.Commissioned__c = true;
		relatedAsset1.ResetSuccessful__c = 'None';
		relatedAsset1.MAC_Address__c = '000000000000';
        insert relatedAsset1;


		//call the service
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        req.requestURI = 'https://cs8.salesforce.com/services/apexrest/ResetGWotGoAsset?UnitSerialNumber=SN123Test1&GatewayMACAddr=000000000000&UserEmail=kent.roessler@daikinapplied.com';  
        req.httpMethod = 'PUT';
        RestContext.request = req;
        RestContext.response = res;
        RestContext.request.params.put('UnitSerialNumber','SN123Test1');
		RestContext.request.params.put('GatewayMACAddr','000000000000');
		RestContext.request.params.put('UserEmail','kent.roessler@daikinapplied.com');
        ResetGWotGoAsset.ResetResponse results = ResetGWotGoAsset.doPut();

		//assert the results
        System.assertEquals('SN123Test1', results.UnitSerialNumber);
		System.assertEquals('000000000000', results.GatewayMACAddress);
		System.assertEquals('kent.roessler@daikinapplied.com', results.UserEmail);

		for (ResetGWotGoAsset.Response_Error e : results.Errors)
		{
			System.assertEquals('SUBSCRIPTIONPAIR_NOT_FOUND', e.ErrorCode);
			System.assert(e.ErrorMessage.contains('No subscription pair found for Gateway Asset with MAC Address'));
		}

	}


	@isTest(SeeAllData=true) static void testPut_processRequest_UnitAssetWithNoOrderException() {
		// ----------------Setup Test Data in Salesforce objects:

		//!!!!!!!!!!! Need to add this code snippet for AvaTax- AccountAddressTrigger to run successfully on Before Insert into the Account table !!!!!!!!!!!!!!!!!
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;

		Datetime currDateTime = Datetime.now();
        Date currentDate = Date.today();
        RecordType recordTypeTemp = [SELECT Id FROM RecordType WHERE Name='Daikin Applied' AND SObjectType='Contact'];

		// Get Dummy Unit Asset for GWotGo
		Asset dummyUnitAsset = [SELECT Id, Name from Asset Where Name = 'Dummy GWotGo Unit Asset'];

		// Get Holding Unit Asset for GWotGo
		Asset holdingUnitAsset = [SELECT Id, Name from Asset Where Name = 'Holding GWotGo Unit Asset'];


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
        acctTemp.IE_Sync_Status__c = 'Pending';
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
        orderTemp1.Order_Entry_Date__c = Date.today();
        orderTemp1.SO_Number__c = 'SO #999';
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
        
        
        // Create Parent Asset record with a GWotGo
        Asset parentAsset1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test1', Tag__c='Order Tag 1');
        parentAsset1.Product2Id = prodTemp1.Id;
        parentAsset1.Order__c = null;  // set to null so an exception will be thrown
		parentAsset1.Asset_Address__c = addrTemp.Id;
        parentAsset1.IE_Asset__c = true;
        parentAsset1.Code_String_Breakdown__c = '[{"code_sequence":"1","code_value":"MPS","code_description":"UNIT TYPE; Unit Type"},{"code_sequence":"2","code_value":"003B","code_description":"UNIT SIZE; 3 ton, R410A"},{"code_sequence":"3","code_value":"Y","code_description":"HEAT; None"},{"code_sequence":"4","code_value":"D","code_description":"VOLTAGE/POWER CONNECTION; 460 V power"},{"code_sequence":"5","code_value":"M","code_description":"DRIVE PACKAGE; Belt drive - high static"},{"code_sequence":"6","code_value":"00D","code_description":"HEATING CAPACITY/CONTROLS; DDC controls"},{"code_sequence":"7","code_value":"CZ","code_description":"OPTIONS; HP,LP,LowAmb/Comfort Aler,FldPower GFI, Hail Guard"},{"code_sequence":"8","code_value":"D","code_description":"ECONOMIZER; Field Mounted 0-30% Outside air hood"}]';
        insert parentAsset1;

		//Create Asset Address record
        Asset_Address__c aa = new Asset_Address__c(Asset__c = parentAsset1.Id
                                                  ,Address__c = addrTemp.Id
                                                  ,Building_Identifier__c = '123');
        insert aa;
        
		
        // Create GWotGo Asset Record for the Parent Asset
        Asset relatedAsset1 = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-075', Parent_Asset__c = parentAsset1.Id);
        relatedAsset1.Product2Id = prodTemp3.Id;
        relatedAsset1.SIM_Card_Active__c = true;
        relatedAsset1.SIM_Card_ICCID__c = '89011704258018735310';
		relatedAsset1.GWotGo__c = true;
		relatedAsset1.Commissioned__c = true;
		relatedAsset1.ResetSuccessful__c = 'None';
		relatedAsset1.MAC_Address__c = '000000000001';
        insert relatedAsset1;

		// Create Subscription Pair and a Permanent Contact
		Contact contactTemp1 = new Contact();
        contactTemp1.Eprise_Login_ID__c = 'RoesslKS1';
        contactTemp1.RecordTypeId = recordTypeTemp.Id;
        contactTemp1.AccountId = acctTemp.Id;
        contactTemp1.Status__c = 'Active';
        contactTemp1.Email = 'kent.roessler@daikinapplied.com';
        contactTemp1.FirstName = 'Kent1';
        contactTemp1.LastName = 'Roessler1';
        contactTemp1.IE_Sync_Status__c = 'Pending';
        contactTemp1.IE_Contact__c = true;
        // Create an address for this contact
        Address__c addrTemp2 = new Address__c();
        addrTemp2.Address_Line_1__c = 'Test Address Line 1';
        addrTemp2.City__c = 'Minneapolis';
        addrTemp2.Postal_Code__c = '55421';
        addrTemp2.Country__c = 'United States';
        addrTemp2.State_Province__c = 'Minnesota';
        insert addrTemp2;
        contactTemp1.Physical_Address__c = addrTemp2.Id;
        insert contactTemp1;

		Contact_Address__c contactAddrJunctionObj = new Contact_Address__c();
        contactAddrJunctionObj.Contact__c = contactTemp1.Id;
        contactAddrJunctionObj.Address__c = addrTemp2.Id;
        contactAddrJunctionObj.Active__c = true;
        contactAddrJunctionObj.Physical__c = true;
        insert contactAddrJunctionObj;

		Subscription__c subTemp1 = new Subscription__c();
        subTemp1.TriggerInvokedByAPI__c = false;
        subTemp1.IE_Subscription__c = true;
        subTemp1.Start_Date__c = currDateTime;
        subTemp1.End_Date__c = currDateTime.addMonths(6);
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
        subTemp2.TriggerInvokedByAPI__c = false;
        subTemp2.IE_Subscription__c = true;
        subTemp2.Start_Date__c = currDateTime;
        subTemp2.End_Date__c = currDateTime.addMonths(6);
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

		// Associate the contact to the subscription
        Contact_Subscription__c contSubTemp1 = new Contact_Subscription__c();
        contSubTemp1.Role__c = 'TechnicianAdministrator';
        contSubTemp1.Contact__c = contactTemp1.Id;
        contSubTemp1.Subscription__c = subTemp1.Id;
        contSubTemp1.Asset__c = parentAsset1.Id;
		contSubTemp1.GWotGoAsset__c = relatedAsset1.Id;
		contSubTemp1.GWotGoPermAssoc__c = true;
        insert contSubTemp1;

		Test.startTest();
		// Create GWotGo Asset Record for the Dummy Asset
        Asset GWotGo = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-076', Parent_Asset__c = dummyUnitAsset.Id);
        GWotGo.Product2Id = prodTemp3.Id;
        GWotGo.SIM_Card_Active__c = true;
        GWotGo.SIM_Card_ICCID__c = 'some text 89011704258018735311';
		GWotGo.GWotGo__c = true;
		GWotGo.Commissioned__c = true;
		GWotGo.ResetSuccessful__c = 'None';
		GWotGo.MAC_Address__c = '000000000000';
        insert GWotGo;

		// Create Subscription Pair and a Permanent Contact
		Contact contactTemp2 = new Contact();
        contactTemp2.Eprise_Login_ID__c = 'RoesslKS2';
        contactTemp2.RecordTypeId = recordTypeTemp.Id;
        contactTemp2.AccountId = acctTemp.Id;
        contactTemp2.Status__c = 'Active';
        contactTemp2.Email = 'kent2.roessler@daikinapplied.com';
        contactTemp2.FirstName = 'Kent2';
        contactTemp2.LastName = 'Roessler2';
        contactTemp2.IE_Sync_Status__c = 'Pending';
        contactTemp2.IE_Contact__c = true;
        // Create an address for this contact
        Address__c addrTemp3 = new Address__c();
        addrTemp3.Address_Line_1__c = 'Test Address Line 2';
        addrTemp3.City__c = 'Minneapolis';
        addrTemp3.Postal_Code__c = '55421';
        addrTemp3.Country__c = 'United States';
        addrTemp3.State_Province__c = 'Minnesota';
        insert addrTemp3;
        contactTemp2.Physical_Address__c = addrTemp3.Id;
        insert contactTemp2;

		Contact_Address__c contactAddrJunctionObj2 = new Contact_Address__c();
        contactAddrJunctionObj2.Contact__c = contactTemp2.Id;
        contactAddrJunctionObj2.Address__c = addrTemp3.Id;
        contactAddrJunctionObj2.Active__c = true;
        contactAddrJunctionObj2.Physical__c = true;
        insert contactAddrJunctionObj2;

		Subscription__c subTemp3 = new Subscription__c();
        subTemp3.TriggerInvokedByAPI__c = false;
        subTemp3.IE_Subscription__c = true;
        subTemp3.Start_Date__c = currDateTime;
        subTemp3.End_Date__c = currDateTime.addMonths(6);
        subTemp3.Type__c = 'TechReadWrite';
        subTemp3.Active__c = true;
        subTemp3.Asset__c = dummyUnitAsset.Id;
        subTemp3.Buyer_ID__c = acctTemp.Id;
        subTemp3.Renewal_Counter__c = 0;
        subTemp3.Last_Renewal_Date__c = null;
        subTemp3.Renewal_Date__c = null;
        subTemp3.Connectivity_Type__c = 'Cellular';
        subTemp3.Term_Years__c = 1.25;
        subTemp3.Renewal_Notice_Current_Month__c = false;
        subTemp3.Renewal_Notice_Next_Month__c = false;
        subTemp3.Renewal_Notice_Last_Month__c = false;
        subTemp3.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp3.Renewal_Notice_Last_Month_Minus_1__c = false;
		subTemp3.GWotGoAsset__c = GWotGo.Id;
        insert subTemp3;

		Subscription__c subTemp4 = new Subscription__c();
        subTemp4.TriggerInvokedByAPI__c = false;
        subTemp4.IE_Subscription__c = true;
        subTemp4.Start_Date__c = currDateTime;
        subTemp4.End_Date__c = currDateTime.addMonths(6);
        subTemp4.Type__c = 'CustomRead';
        subTemp4.Active__c = true;
        subTemp4.Asset__c = dummyUnitAsset.Id;
        subTemp4.Buyer_ID__c = acctTemp.Id;
        subTemp4.Renewal_Counter__c = 0;
        subTemp4.Last_Renewal_Date__c = null;
        subTemp4.Renewal_Date__c = null;
        subTemp4.Connectivity_Type__c = 'Cellular';
        subTemp4.Term_Years__c = 1.25;
        subTemp4.Renewal_Notice_Current_Month__c = false;
        subTemp4.Renewal_Notice_Next_Month__c = false;
        subTemp4.Renewal_Notice_Last_Month__c = false;
        subTemp4.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp4.Renewal_Notice_Last_Month_Minus_1__c = false;
		subTemp4.GWotGoAsset__c = GWotGo.Id;
        insert subTemp4;

		// Associate the contact to the subscription
        Contact_Subscription__c contSubTemp2 = new Contact_Subscription__c();
        contSubTemp2.Role__c = 'TechnicianAdministrator';
        contSubTemp2.Contact__c = contactTemp2.Id;
        contSubTemp2.Subscription__c = subTemp3.Id;
        contSubTemp2.Asset__c = dummyUnitAsset.Id;
		contSubTemp2.GWotGoAsset__c = GWotGo.Id;
		contSubTemp2.GWotGoPermAssoc__c = true;
        insert contSubTemp2;



		//call the service
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        req.requestURI = 'https://cs8.salesforce.com/services/apexrest/ResetGWotGoAsset?UnitSerialNumber=SN123Test1&GatewayMACAddr=000000000000&UserEmail=kent.roessler@daikinapplied.com';  
        req.httpMethod = 'PUT';
        RestContext.request = req;
        RestContext.response = res;
        RestContext.request.params.put('UnitSerialNumber','SN123Test1');
		RestContext.request.params.put('GatewayMACAddr','000000000000');
		RestContext.request.params.put('UserEmail','kent.roessler@daikinapplied.com');

		//Test.startTest();
			ResetGWotGoAsset.ResetResponse results = ResetGWotGoAsset.doPut();
		Test.stopTest();

		//assert the results
        System.assertEquals('SN123Test1', results.UnitSerialNumber);
		System.assertEquals('000000000000', results.GatewayMACAddress);
		System.assertEquals('kent.roessler@daikinapplied.com', results.UserEmail);

		for (ResetGWotGoAsset.Response_Error e : results.Errors)
		{
			System.assertEquals('UNIT_RESET_EXCEPTION', e.ErrorCode);
			System.assert(e.ErrorMessage.contains('ResetGWotGoAsset Exception:'));
		}
	}


	@isTest(SeeAllData=true) static void testPut_processRequest_UnitAddressMissing() {
		// ----------------Setup Test Data in Salesforce objects:

		//!!!!!!!!!!! Need to add this code snippet for AvaTax- AccountAddressTrigger to run successfully on Before Insert into the Account table !!!!!!!!!!!!!!!!!
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;

		Datetime currDateTime = Datetime.now();
        Date currentDate = Date.today();
        RecordType recordTypeTemp = [SELECT Id FROM RecordType WHERE Name='Daikin Applied' AND SObjectType='Contact'];

		// Get Dummy Unit Asset for GWotGo
		Asset dummyUnitAsset = [SELECT Id, Name from Asset Where Name = 'Dummy GWotGo Unit Asset'];

		// Get Holding Unit Asset for GWotGo
		Asset holdingUnitAsset = [SELECT Id, Name from Asset Where Name = 'Holding GWotGo Unit Asset'];


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
        acctTemp.IE_Sync_Status__c = 'Pending';
		acctTemp.IE_ID__c = null;  // Forces a POST operation in the IE Organizations Service call
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
        orderTemp1.Order_Entry_Date__c = Date.today();
        orderTemp1.SO_Number__c = 'SO #999';
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
        
        
        // Create Parent Asset record with a GWotGo
        Asset parentAsset1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test1', Tag__c='Order Tag 1');
        parentAsset1.Product2Id = prodTemp1.Id;
        parentAsset1.Order__c = orderTemp1.Id;
		parentAsset1.Asset_Address__c = null;  // set to null for a missing address
        parentAsset1.IE_Asset__c = true;
        parentAsset1.Code_String_Breakdown__c = '[{"code_sequence":"1","code_value":"MPS","code_description":"UNIT TYPE; Unit Type"},{"code_sequence":"2","code_value":"003B","code_description":"UNIT SIZE; 3 ton, R410A"},{"code_sequence":"3","code_value":"Y","code_description":"HEAT; None"},{"code_sequence":"4","code_value":"D","code_description":"VOLTAGE/POWER CONNECTION; 460 V power"},{"code_sequence":"5","code_value":"M","code_description":"DRIVE PACKAGE; Belt drive - high static"},{"code_sequence":"6","code_value":"00D","code_description":"HEATING CAPACITY/CONTROLS; DDC controls"},{"code_sequence":"7","code_value":"CZ","code_description":"OPTIONS; HP,LP,LowAmb/Comfort Aler,FldPower GFI, Hail Guard"},{"code_sequence":"8","code_value":"D","code_description":"ECONOMIZER; Field Mounted 0-30% Outside air hood"}]';
        insert parentAsset1;

		//Create Asset Address record
        /*Asset_Address__c aa = new Asset_Address__c(Asset__c = parentAsset1.Id
                                                  ,Address__c = addrTemp.Id
                                                  ,Building_Identifier__c = '123');
        insert aa;*/
        
		
        // Create GWotGo Asset Record for the Parent Asset
        Asset relatedAsset1 = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-075', Parent_Asset__c = parentAsset1.Id);
        relatedAsset1.Product2Id = prodTemp3.Id;
        relatedAsset1.SIM_Card_Active__c = true;
        relatedAsset1.SIM_Card_ICCID__c = '89011704258018735310';
		relatedAsset1.GWotGo__c = true;
		relatedAsset1.Commissioned__c = true;
		relatedAsset1.ResetSuccessful__c = 'None';
		relatedAsset1.MAC_Address__c = '000000000001';
        insert relatedAsset1;

		// Create Subscription Pair and a Permanent Contact
		Contact contactTemp1 = new Contact();
        contactTemp1.Eprise_Login_ID__c = 'RoesslKS1';
        contactTemp1.RecordTypeId = recordTypeTemp.Id;
        contactTemp1.AccountId = acctTemp.Id;
        contactTemp1.Status__c = 'Active';
        contactTemp1.Email = 'kent.roessler@daikinapplied.com';
        contactTemp1.FirstName = 'Kent1';
        contactTemp1.LastName = 'Roessler1';
        contactTemp1.IE_Sync_Status__c = 'Pending';
        contactTemp1.IE_Contact__c = true;
        // Create an address for this contact
        Address__c addrTemp2 = new Address__c();
        addrTemp2.Address_Line_1__c = 'Test Address Line 1';
        addrTemp2.City__c = 'Minneapolis';
        addrTemp2.Postal_Code__c = '55421';
        addrTemp2.Country__c = 'United States';
        addrTemp2.State_Province__c = 'Minnesota';
        insert addrTemp2;
        contactTemp1.Physical_Address__c = addrTemp2.Id;
        insert contactTemp1;

		Contact_Address__c contactAddrJunctionObj = new Contact_Address__c();
        contactAddrJunctionObj.Contact__c = contactTemp1.Id;
        contactAddrJunctionObj.Address__c = addrTemp2.Id;
        contactAddrJunctionObj.Active__c = true;
        contactAddrJunctionObj.Physical__c = true;
        insert contactAddrJunctionObj;

		Subscription__c subTemp1 = new Subscription__c();
        subTemp1.TriggerInvokedByAPI__c = false;
        subTemp1.IE_Subscription__c = true;
        subTemp1.Start_Date__c = currDateTime;
        subTemp1.End_Date__c = currDateTime.addMonths(6);
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
        subTemp2.TriggerInvokedByAPI__c = false;
        subTemp2.IE_Subscription__c = true;
        subTemp2.Start_Date__c = currDateTime;
        subTemp2.End_Date__c = currDateTime.addMonths(6);
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

		// Associate the contact to the subscription
        Contact_Subscription__c contSubTemp1 = new Contact_Subscription__c();
        contSubTemp1.Role__c = 'TechnicianAdministrator';
        contSubTemp1.Contact__c = contactTemp1.Id;
        contSubTemp1.Subscription__c = subTemp1.Id;
        contSubTemp1.Asset__c = parentAsset1.Id;
		contSubTemp1.GWotGoAsset__c = relatedAsset1.Id;
		contSubTemp1.GWotGoPermAssoc__c = true;
        insert contSubTemp1;

		Test.startTest();
		// Create GWotGo Asset Record for the Dummy Asset
        Asset GWotGo = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-076', Parent_Asset__c = dummyUnitAsset.Id);
        GWotGo.Product2Id = prodTemp3.Id;
        GWotGo.SIM_Card_Active__c = true;
        GWotGo.SIM_Card_ICCID__c = 'some text 89011704258018735311';
		GWotGo.GWotGo__c = true;
		GWotGo.Commissioned__c = true;
		GWotGo.ResetSuccessful__c = 'None';
		GWotGo.MAC_Address__c = '000000000000';
        insert GWotGo;

		// Create Subscription Pair and a Permanent Contact
		Contact contactTemp2 = new Contact();
        contactTemp2.Eprise_Login_ID__c = 'RoesslKS2';
        contactTemp2.RecordTypeId = recordTypeTemp.Id;
        contactTemp2.AccountId = acctTemp.Id;
        contactTemp2.Status__c = 'Active';
        contactTemp2.Email = 'kent2.roessler@daikinapplied.com';
        contactTemp2.FirstName = 'Kent2';
        contactTemp2.LastName = 'Roessler2';
        contactTemp2.IE_Sync_Status__c = 'Pending';
        contactTemp2.IE_Contact__c = true;
        // Create an address for this contact
        Address__c addrTemp3 = new Address__c();
        addrTemp3.Address_Line_1__c = 'Test Address Line 2';
        addrTemp3.City__c = 'Minneapolis';
        addrTemp3.Postal_Code__c = '55421';
        addrTemp3.Country__c = 'United States';
        addrTemp3.State_Province__c = 'Minnesota';
        insert addrTemp3;
        contactTemp2.Physical_Address__c = addrTemp3.Id;
        insert contactTemp2;

		Contact_Address__c contactAddrJunctionObj2 = new Contact_Address__c();
        contactAddrJunctionObj2.Contact__c = contactTemp2.Id;
        contactAddrJunctionObj2.Address__c = addrTemp3.Id;
        contactAddrJunctionObj2.Active__c = true;
        contactAddrJunctionObj2.Physical__c = true;
        insert contactAddrJunctionObj2;

		Subscription__c subTemp3 = new Subscription__c();
        subTemp3.TriggerInvokedByAPI__c = false;
        subTemp3.IE_Subscription__c = true;
        subTemp3.Start_Date__c = currDateTime;
        subTemp3.End_Date__c = currDateTime.addMonths(6);
        subTemp3.Type__c = 'TechReadWrite';
        subTemp3.Active__c = true;
        subTemp3.Asset__c = dummyUnitAsset.Id;
        subTemp3.Buyer_ID__c = acctTemp.Id;
        subTemp3.Renewal_Counter__c = 0;
        subTemp3.Last_Renewal_Date__c = null;
        subTemp3.Renewal_Date__c = null;
        subTemp3.Connectivity_Type__c = 'Cellular';
        subTemp3.Term_Years__c = 1.25;
        subTemp3.Renewal_Notice_Current_Month__c = false;
        subTemp3.Renewal_Notice_Next_Month__c = false;
        subTemp3.Renewal_Notice_Last_Month__c = false;
        subTemp3.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp3.Renewal_Notice_Last_Month_Minus_1__c = false;
		subTemp3.GWotGoAsset__c = GWotGo.Id;
        insert subTemp3;

		Subscription__c subTemp4 = new Subscription__c();
        subTemp4.TriggerInvokedByAPI__c = false;
        subTemp4.IE_Subscription__c = true;
        subTemp4.Start_Date__c = currDateTime;
        subTemp4.End_Date__c = currDateTime.addMonths(6);
        subTemp4.Type__c = 'CustomRead';
        subTemp4.Active__c = true;
        subTemp4.Asset__c = dummyUnitAsset.Id;
        subTemp4.Buyer_ID__c = acctTemp.Id;
        subTemp4.Renewal_Counter__c = 0;
        subTemp4.Last_Renewal_Date__c = null;
        subTemp4.Renewal_Date__c = null;
        subTemp4.Connectivity_Type__c = 'Cellular';
        subTemp4.Term_Years__c = 1.25;
        subTemp4.Renewal_Notice_Current_Month__c = false;
        subTemp4.Renewal_Notice_Next_Month__c = false;
        subTemp4.Renewal_Notice_Last_Month__c = false;
        subTemp4.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp4.Renewal_Notice_Last_Month_Minus_1__c = false;
		subTemp4.GWotGoAsset__c = GWotGo.Id;
        insert subTemp4;

		// Associate the contact to the subscription
        Contact_Subscription__c contSubTemp2 = new Contact_Subscription__c();
        contSubTemp2.Role__c = 'TechnicianAdministrator';
        contSubTemp2.Contact__c = contactTemp2.Id;
        contSubTemp2.Subscription__c = subTemp3.Id;
        contSubTemp2.Asset__c = dummyUnitAsset.Id;
		contSubTemp2.GWotGoAsset__c = GWotGo.Id;
		contSubTemp2.GWotGoPermAssoc__c = true;
        insert contSubTemp2;



		//call the service
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        req.requestURI = 'https://cs8.salesforce.com/services/apexrest/ResetGWotGoAsset?UnitSerialNumber=SN123Test1&GatewayMACAddr=000000000000&UserEmail=kent.roessler@daikinapplied.com';  
        req.httpMethod = 'PUT';
        RestContext.request = req;
        RestContext.response = res;
        RestContext.request.params.put('UnitSerialNumber','SN123Test1');
		RestContext.request.params.put('GatewayMACAddr','000000000000');
		RestContext.request.params.put('UserEmail','kent.roessler@daikinapplied.com');

		//Test.startTest();
			ResetGWotGoAsset.ResetResponse results = ResetGWotGoAsset.doPut();
		Test.stopTest();

		//assert the results
        System.assertEquals('SN123Test1', results.UnitSerialNumber);
		System.assertEquals('000000000000', results.GatewayMACAddress);
		System.assertEquals('kent.roessler@daikinapplied.com', results.UserEmail);

		for (ResetGWotGoAsset.Response_Warning w : results.Warnings)
		{
			System.assert(w.WarningMessage.contains('Direction:'));
		}
	}

}