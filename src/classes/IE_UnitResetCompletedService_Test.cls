@isTest 
private class IE_UnitResetCompletedService_Test {

	@isTest static void testPutOperation_GWNotExist() {
		// ----------------Setup Test Data in Salesforce objects:
		// Assumption - The "Dummy GWotGo Unit Asset" and "Holding GWotGo Unit Asset" must exist in your testing environment.

		//!!!!!!!!!!! Need to add this code snippet for AvaTax- AccountAddressTrigger to run successfully on Before Insert into the Account table !!!!!!!!!!!!!!!!!
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;

		//setup request object
		list<IE_IntegrationObjects.IE_UnitResetCompleted> units = new list<IE_IntegrationObjects.IE_UnitResetCompleted>();
		IE_IntegrationObjects.IE_UnitResetCompleted unit = new IE_IntegrationObjects.IE_UnitResetCompleted();
		unit.SerialNumber = 'SN123Test1';
		unit.MACAddress = '00000000-00000000-000000FF-FF000000'; // The service queries via the Device_Id__c field which is the manipulated MAC Address
		unit.Errors = new list<IE_IntegrationObjects.IE_Error>();
		units.add(unit);

		//call the service
		IE_IntegrationObjects.IE_UnitResetCompletedResponse res = IE_UnitResetCompletedService.doPut(units);

		//assert the results
        System.assertEquals('SN123Test1', res.unit.SerialNumber);
		System.assertEquals('00000000-00000000-000000FF-FF000000', res.unit.MACAddress);

		for (IE_IntegrationObjects.IE_Error e : res.errors)
		{
			System.assertEquals('GWASSET_NOT_FOUND', e.ErrorCode);
			System.assertEquals('Gateway Asset with MAC Address ' + unit.MACAddress + ' not found in Salesforce or the status is Obsolete', e.ErrorMessage);
		}
	}


	@isTest static void testPutOperation_ExceptionThrown() {
		// ----------------Setup Test Data in Salesforce objects:
		// Assumption - The "Dummy GWotGo Unit Asset" and "Holding GWotGo Unit Asset" must exist in your testing environment.

		//!!!!!!!!!!! Need to add this code snippet for AvaTax- AccountAddressTrigger to run successfully on Before Insert into the Account table !!!!!!!!!!!!!!!!!
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;

		//setup request object
		list<IE_IntegrationObjects.IE_UnitResetCompleted> units = null; //new list<IE_IntegrationObjects.IE_UnitResetCompleted>();

		//call the service
		IE_IntegrationObjects.IE_UnitResetCompletedResponse res = IE_UnitResetCompletedService.doPut(units);

		//assert the results
		for (IE_IntegrationObjects.IE_Error e : res.errors)
		{
			System.assertEquals('UNIT_RESET_EXCEPTION', e.ErrorCode);
			System.assert(e.ErrorMessage.contains('IE_UnitResetCompletedService Exception:'));
		}
	}


	@isTest static void testPutOperation_UnitResetSuccess() {
		// ----------------Setup Test Data in Salesforce objects:
		// Assumption - The "Dummy GWotGo Unit Asset" and "Holding GWotGo Unit Asset" must exist in your testing environment.

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
        contactAddrJunctionObj = new Contact_Address__c();
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


		//setup request object
		list<IE_IntegrationObjects.IE_UnitResetCompleted> units = new list<IE_IntegrationObjects.IE_UnitResetCompleted>();
		IE_IntegrationObjects.IE_UnitResetCompleted unit = new IE_IntegrationObjects.IE_UnitResetCompleted();
		unit.SerialNumber = 'SN123Test1';
		unit.MACAddress = '00000000-00000000-000000FF-FF000000'; // The service queries via the Device_Id__c field which is the manipulated MAC Address
		unit.Errors = new list<IE_IntegrationObjects.IE_Error>();
		units.add(unit);


		//call the service
		IE_IntegrationObjects.IE_UnitResetCompletedResponse res = IE_UnitResetCompletedService.doPut(units);

		//assert the results
        System.assertEquals('SN123Test1', res.unit.SerialNumber);
		System.assertEquals('00000000-00000000-000000FF-FF000000', res.unit.MACAddress);

		Asset gwAsset1 = [SELECT Id, ResetSuccessful__c from Asset Where Id = :relatedAsset1.Id];
 		System.assertEquals('True', gwAsset1.ResetSuccessful__c);
	}


	@isTest static void testPutOperation_UnitResetFail() {
		// ----------------Setup Test Data in Salesforce objects:
		// Assumption - The "Dummy GWotGo Unit Asset" and "Holding GWotGo Unit Asset" must exist in your testing environment.

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


		//setup request object
		list<IE_IntegrationObjects.IE_UnitResetCompleted> units = new list<IE_IntegrationObjects.IE_UnitResetCompleted>();
		IE_IntegrationObjects.IE_UnitResetCompleted unit = new IE_IntegrationObjects.IE_UnitResetCompleted();
		unit.SerialNumber = 'SN123Test1';
		unit.MACAddress = '00000000-00000000-000000FF-FF000000'; // The service queries via the Device_Id__c field which is the manipulated MAC Address
		unit.Errors = new list<IE_IntegrationObjects.IE_Error>();
		IE_IntegrationObjects.IE_Error err = new IE_IntegrationObjects.IE_Error('Error_Code', 'Error Message');
		unit.Errors.add(err);
		units.add(unit);


		//call the service
		IE_IntegrationObjects.IE_UnitResetCompletedResponse res = IE_UnitResetCompletedService.doPut(units);

		//assert the results
        System.assertEquals('SN123Test1', res.unit.SerialNumber);
		System.assertEquals('00000000-00000000-000000FF-FF000000', res.unit.MACAddress);

		for (IE_IntegrationObjects.IE_Error e : res.errors)
		{
			System.assertEquals('UNIT_RESET_ERRORS', e.ErrorCode);
			System.assert(e.ErrorMessage.contains('Unit Reset failed on IE side with errors:'));
		}

		Asset gwAsset1 = [SELECT Id, ResetSuccessful__c from Asset Where Id = :relatedAsset1.Id];
 		System.assertEquals('False', gwAsset1.ResetSuccessful__c);
	}


}