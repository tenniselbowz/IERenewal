@isTest 
private class IERenewal_ExtWebServiceCallouts_Test {

	@isTest static void test_syncIeCloudSubscriptions() {
		//!!!!!!!!!!! Need to add this code snippet for AvaTax- AccountAddressTrigger to run successfully on Before Insert into the Account table !!!!!!!!!!!!!!!!!
    	AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c();
        ts1.AVA_SFCORE__Active_Setting__c = true;
        ts1.Name='Test Account';
        insert ts1;

		
		Datetime currDateTime = Datetime.now();
		
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
        orderTemp1.Order_Type_ID__c = 'International'; //'Domestic'
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

        
        // Create Parent Asset records
        Asset parentAsset1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test1', Tag__c='Order Tag 1');
        parentAsset1.Product2Id = prodTemp1.Id;
        parentAsset1.Order__c = orderTemp1.Id;
		parentAsset1.Asset_Address__c = addrTemp.Id;
        parentAsset1.IE_Asset__c = true;
        parentAsset1.Code_String_Breakdown__c = '[{"code_sequence":"1","code_value":"MPS","code_description":"UNIT TYPE; Unit Type"},{"code_sequence":"2","code_value":"003B","code_description":"UNIT SIZE; 3 ton, R410A"},{"code_sequence":"3","code_value":"Y","code_description":"HEAT; None"},{"code_sequence":"4","code_value":"D","code_description":"VOLTAGE/POWER CONNECTION; 460 V power"},{"code_sequence":"5","code_value":"M","code_description":"DRIVE PACKAGE; Belt drive - high static"},{"code_sequence":"6","code_value":"00D","code_description":"HEATING CAPACITY/CONTROLS; DDC controls"},{"code_sequence":"7","code_value":"CZ","code_description":"OPTIONS; HP,LP,LowAmb/Comfort Aler,FldPower GFI, Hail Guard"},{"code_sequence":"8","code_value":"D","code_description":"ECONOMIZER; Field Mounted 0-30% Outside air hood"}]';
        insert parentAsset1;


		//Create Asset Address records
        Asset_Address__c aa = new Asset_Address__c(Asset__c = parentAsset1.Id
                                                  ,Address__c = addrTemp.Id
                                                  ,Building_Identifier__c = '123');
        insert aa;
        
		
		
		
		
		list<Integration_Error__c> integrationErrorList;
		list<Subscription__c> subscriptionList = new list<Subscription__c>();
		map<Id, Subscription__c> subscriptionMap = new map<Id, Subscription__c>();
		
		// Create a list of 11 subscriptions so we test the code where number of subscriptions > SUBSCRIPTION_BATCH_SIZE
		// Type, Asset and Buyer Id are required fields
		for (integer i=0; i < 11; i++)
		{
			Subscription__c s = new Subscription__c();
			s.Type__c = 'TechReadWrite';
			s.Asset__c = parentAsset1.Id;
			s.Buyer_ID__c = acctTemp.Id;
			s.IE_Subscription__c = true;
			s.Active__c = true;
			s.Connectivity_Type__c = 'Cellular';
			s.Term_Years__c = 1.0;
			s.Start_Date__c = currDateTime;
			s.End_Date__c = currDateTime.addMonths(12);
			
			subscriptionList.add(s);
		}
		insert subscriptionList;
		
		// Process the IE subscriptions
		IERenewal_ExtWebServiceCallouts.syncIeCloudSubscriptions(subscriptionList, subscriptionMap, integrationErrorList);
		
		
		// Assert results
		System.assertEquals(11, subscriptionMap.size());
	}


	@isTest static void test_syncIeCloudUnits() {
		//!!!!!!!!!!! Need to add this code snippet for AvaTax- AccountAddressTrigger to run successfully on Before Insert into the Account table !!!!!!!!!!!!!!!!!
    	AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c();
        ts1.AVA_SFCORE__Active_Setting__c = true;
        ts1.Name='Test Account';
        insert ts1;

		
		Datetime currDateTime = Datetime.now();
		
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
        orderTemp1.Order_Type_ID__c = 'International'; //'Domestic'
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

        
        // Create Parent Asset records
		// Create a list of 11 unit assets so we test the code where number of subscriptions whose type is TechReadWrite > UNIT_BATCH_SIZE
		list<Asset> assetList = new list<Asset>();
		for (integer i=0; i < 11; i++)
		{
			Asset a = new Asset(Name = 'Asset Test'+i, AccountId = acctTemp.Id, SerialNumber='SN123Test'+i, Tag__c='Order Tag '+i);
			a.Product2Id = prodTemp1.Id;
			a.Order__c = orderTemp1.Id;
			a.Asset_Address__c = addrTemp.Id;
			a.IE_Asset__c = true;
			a.Code_String_Breakdown__c = '[{"code_sequence":"1","code_value":"MPS","code_description":"UNIT TYPE; Unit Type"},{"code_sequence":"2","code_value":"003B","code_description":"UNIT SIZE; 3 ton, R410A"},{"code_sequence":"3","code_value":"Y","code_description":"HEAT; None"},{"code_sequence":"4","code_value":"D","code_description":"VOLTAGE/POWER CONNECTION; 460 V power"},{"code_sequence":"5","code_value":"M","code_description":"DRIVE PACKAGE; Belt drive - high static"},{"code_sequence":"6","code_value":"00D","code_description":"HEATING CAPACITY/CONTROLS; DDC controls"},{"code_sequence":"7","code_value":"CZ","code_description":"OPTIONS; HP,LP,LowAmb/Comfort Aler,FldPower GFI, Hail Guard"},{"code_sequence":"8","code_value":"D","code_description":"ECONOMIZER; Field Mounted 0-30% Outside air hood"}]';

			assetList.add(a);
		}
		insert assetList;
		System.debug(LoggingLevel.Error,assetList);


		list<Asset_Address__c> assetAddrList = new list<Asset_Address__c>();
		for (integer i=0; i < 11; i++)
		{
			Asset_Address__c aa = new Asset_Address__c(Asset__c = assetList[i].Id
                                                  ,Address__c = addrTemp.Id
                                                  ,Building_Identifier__c = '123');

			assetAddrList.add(aa);
		}
		insert assetAddrList;
		System.debug(LoggingLevel.Error,assetAddrList);
		
		
		
		list<Integration_Error__c> integrationErrorList;
		map<Id, Asset> assetMap = new map<Id, Asset>();
		map<Id, Asset> relatedAssetMap = new map<Id, Asset>();
		map<Id, Address__c> addressMap = new map<Id, Address__c>();
		
		// Create a list of 11 subscriptions so we test the code where number of subscriptions whose type is TechReadWrite > UNIT_BATCH_SIZE
		// Type, Asset and Buyer Id are required fields
		list<Subscription__c> subscriptionList = new list<Subscription__c>();
		for (integer i=0; i < 11; i++)
		{
			Subscription__c s = new Subscription__c();
			s.Type__c = 'TechReadWrite';
			s.TriggerInvokedByAPI__c = true;
			s.Asset__c = assetList[i].Id;
			s.Buyer_ID__c = acctTemp.Id;
			s.IE_Subscription__c = true;
			s.Active__c = true;
			s.Connectivity_Type__c = 'Cellular';
			s.Term_Years__c = 1.0;
			s.Start_Date__c = currDateTime;
			s.End_Date__c = currDateTime.addMonths(12);
			
			subscriptionList.add(s);
		}
		insert subscriptionList;
		System.debug(LoggingLevel.Error,subscriptionList);
		
		// Process the IE subscriptions/assets
		IERenewal_ExtWebServiceCallouts.syncIeCloudUnits(subscriptionList, assetMap, relatedAssetMap, addressMap, integrationErrorList);
		
		
		// Assert results
		System.assertEquals(11, assetMap.size());
	}


	@isTest static void test_syncIeCloudSIMCardActiveStatus() {
		//!!!!!!!!!!! Need to add this code snippet for AvaTax- AccountAddressTrigger to run successfully on Before Insert into the Account table !!!!!!!!!!!!!!!!!
    	AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c();
        ts1.AVA_SFCORE__Active_Setting__c = true;
        ts1.Name='Test Account';
        insert ts1;

		
		Datetime currDateTime = Datetime.now();
		
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
        orderTemp1.Order_Type_ID__c = 'International'; //'Domestic'
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

        
        // Create Parent Asset records
		// Create a list of 11 unit assets so we test the code where number of gateway assets > UNIT_BATCH_SIZE
		list<Asset> assetList = new list<Asset>();
		for (integer i=0; i < 11; i++)
		{
			Asset a = new Asset(Name = 'Asset Test'+i, AccountId = acctTemp.Id, SerialNumber='SN123Test'+i, Tag__c='Order Tag '+i);
			a.Product2Id = prodTemp1.Id;
			a.Order__c = orderTemp1.Id;
			a.Asset_Address__c = addrTemp.Id;
			a.IE_Asset__c = true;
			a.Code_String_Breakdown__c = '[{"code_sequence":"1","code_value":"MPS","code_description":"UNIT TYPE; Unit Type"},{"code_sequence":"2","code_value":"003B","code_description":"UNIT SIZE; 3 ton, R410A"},{"code_sequence":"3","code_value":"Y","code_description":"HEAT; None"},{"code_sequence":"4","code_value":"D","code_description":"VOLTAGE/POWER CONNECTION; 460 V power"},{"code_sequence":"5","code_value":"M","code_description":"DRIVE PACKAGE; Belt drive - high static"},{"code_sequence":"6","code_value":"00D","code_description":"HEATING CAPACITY/CONTROLS; DDC controls"},{"code_sequence":"7","code_value":"CZ","code_description":"OPTIONS; HP,LP,LowAmb/Comfort Aler,FldPower GFI, Hail Guard"},{"code_sequence":"8","code_value":"D","code_description":"ECONOMIZER; Field Mounted 0-30% Outside air hood"}]';

			assetList.add(a);
		}
		insert assetList;
		System.debug(LoggingLevel.Error,assetList);


		list<Asset_Address__c> assetAddrList = new list<Asset_Address__c>();
		for (integer i=0; i < 11; i++)
		{
			Asset_Address__c aa = new Asset_Address__c(Asset__c = assetList[i].Id
                                                  ,Address__c = addrTemp.Id
                                                  ,Building_Identifier__c = '123');

			assetAddrList.add(aa);
		}
		insert assetAddrList;
		System.debug(LoggingLevel.Error,assetAddrList);
		

		// Create a list of 11 GW assets one for each of the assets
		list<Asset> gwAssetList = new list<Asset>();
		for (integer i=0; i < 11; i++)
		{
			Asset a = new Asset(Name = 'Intelligent Equipment Gateway'+i, AccountId = acctTemp.Id, SerialNumber = 'GW_Test'+i, Parent_Asset__c = assetList[i].Id);
			a.Product2Id = prodTemp1.Id;
			a.SIM_Card_Active__c = true;
			a.SIM_Card_ICCID__c = 'SimCardICCID'+i;
			a.MAC_Address__c = 'MAC_Addr'+i;

			gwAssetList.add(a);
		}
		insert gwAssetList;
		System.debug(LoggingLevel.Error,gwAssetList);
		


		list<Integration_Error__c> integrationErrorList;
		map<Id, Asset> assetMap = new map<Id, Asset>();
		map<Id, Address__c> addressMap = new map<Id, Address__c>();
		
		// Create a list of 11 subscriptions one for each of the assets
		// Type, Asset and Buyer Id are required fields
		list<Subscription__c> subscriptionList = new list<Subscription__c>();
		for (integer i=0; i < 11; i++)
		{
			Subscription__c s = new Subscription__c();
			s.Type__c = 'TechReadWrite';
			s.TriggerInvokedByAPI__c = true;
			s.Asset__c = assetList[i].Id;
			s.Buyer_ID__c = acctTemp.Id;
			s.IE_Subscription__c = true;
			s.Active__c = true;
			s.Connectivity_Type__c = 'Cellular';
			s.Term_Years__c = 1.0;
			s.Start_Date__c = currDateTime;
			s.End_Date__c = currDateTime.addMonths(12);
			
			subscriptionList.add(s);
		}
		insert subscriptionList;
		System.debug(LoggingLevel.Error,subscriptionList);
		
		// Process the IE subscriptions/assets
		IERenewal_ExtWebServiceCallouts.syncIeCloudSIMCardActiveStatus(gwAssetList, assetMap, addressMap, integrationErrorList);
		
		
		// Assert results
		System.assertEquals(11, assetMap.size());
	}


	@isTest static void test_syncIeCloudIndividuals() {
		//!!!!!!!!!!! Need to add this code snippet for AvaTax- AccountAddressTrigger to run successfully on Before Insert into the Account table !!!!!!!!!!!!!!!!!
    	AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c();
        ts1.AVA_SFCORE__Active_Setting__c = true;
        ts1.Name='Test Account';
        insert ts1;

		
		Datetime currDateTime = Datetime.now();
		Date currentDate = Date.today();
		
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
        orderTemp1.Order_Type_ID__c = 'International'; //'Domestic'
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

        
        // Create Parent Asset records
        Asset parentAsset1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test1', Tag__c='Order Tag 1');
        parentAsset1.Product2Id = prodTemp1.Id;
        parentAsset1.Order__c = orderTemp1.Id;
		parentAsset1.Asset_Address__c = addrTemp.Id;
        parentAsset1.IE_Asset__c = true;
        parentAsset1.Code_String_Breakdown__c = '[{"code_sequence":"1","code_value":"MPS","code_description":"UNIT TYPE; Unit Type"},{"code_sequence":"2","code_value":"003B","code_description":"UNIT SIZE; 3 ton, R410A"},{"code_sequence":"3","code_value":"Y","code_description":"HEAT; None"},{"code_sequence":"4","code_value":"D","code_description":"VOLTAGE/POWER CONNECTION; 460 V power"},{"code_sequence":"5","code_value":"M","code_description":"DRIVE PACKAGE; Belt drive - high static"},{"code_sequence":"6","code_value":"00D","code_description":"HEATING CAPACITY/CONTROLS; DDC controls"},{"code_sequence":"7","code_value":"CZ","code_description":"OPTIONS; HP,LP,LowAmb/Comfort Aler,FldPower GFI, Hail Guard"},{"code_sequence":"8","code_value":"D","code_description":"ECONOMIZER; Field Mounted 0-30% Outside air hood"}]';
        insert parentAsset1;


		//Create Asset Address records
        Asset_Address__c aa = new Asset_Address__c(Asset__c = parentAsset1.Id
                                                  ,Address__c = addrTemp.Id
                                                  ,Building_Identifier__c = '123');
        insert aa;
        
		
		
		
		RecordType recordTypeTemp = [SELECT Id FROM RecordType WHERE Name='Daikin Applied' AND SObjectType='Contact'];
		list<Integration_Error__c> integrationErrorList;
		List<Contact> contactList = new List<Contact>();
		map<Id, Contact> contactMap = new map<Id, Contact>();
		map<Id, Address__c> addressMap = new map<Id, Address__c>();
		List<Contact> emptyContactList = new List<Contact>();
		list<Subscription__c> subscriptions = new list<Subscription__c>();

		// Create 11 contacts which will test the code where number of contacts > CONTACT_BATCH_SIZE
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
        contactList.add(contactTemp1);

        Contact contactTemp2 = new Contact();
        contactTemp2.Eprise_Login_ID__c = 'RoesslKS2';
        contactTemp2.RecordTypeId = recordTypeTemp.Id;
        contactTemp2.AccountId = acctTemp.Id;
        contactTemp2.Status__c = 'Active';
        contactTemp2.Email = 'kent.roessler@daikinapplied.com';
        contactTemp2.FirstName = 'Kent2';
        contactTemp2.LastName = 'Roessler2';
        contactTemp2.IE_Sync_Status__c = 'Pending';
        contactTemp2.IE_Contact__c = true;
        contactList.add(contactTemp2);

        Contact contactTemp3 = new Contact();
        contactTemp3.Eprise_Login_ID__c = 'RoesslKS3';
        contactTemp3.RecordTypeId = recordTypeTemp.Id;
        contactTemp3.AccountId = acctTemp.Id;
        contactTemp3.Status__c = 'Active';
        contactTemp3.Email = 'kent.roessler@daikinapplied.com';
        contactTemp3.FirstName = 'Kent3';
        contactTemp3.LastName = 'Roessler3';
        contactTemp3.IE_Sync_Status__c = 'Pending';
        contactTemp3.IE_Contact__c = true;
        contactList.add(contactTemp3);

        Contact contactTemp4 = new Contact();
        contactTemp4.IE_ID__c = '999';  // forces a Put operation in the service call
        contactTemp4.Eprise_Login_ID__c = 'RoesslKS4';
        contactTemp4.RecordTypeId = recordTypeTemp.Id;
        contactTemp4.AccountId = acctTemp.Id;
        contactTemp4.Status__c = 'Active';
        contactTemp4.Email = 'kent.roessler@daikinapplied.com';
        contactTemp4.FirstName = 'Kent4';
        contactTemp4.LastName = 'Roessler4';
        contactTemp4.IE_Sync_Status__c = 'Pending';
        contactTemp4.IE_Contact__c = true;
        contactList.add(contactTemp4);

        Contact contactTemp5 = new Contact();
        contactTemp5.Eprise_Login_ID__c = 'RoesslKS5';
        contactTemp5.RecordTypeId = recordTypeTemp.Id;
        contactTemp5.AccountId = acctTemp.Id;
        contactTemp5.Status__c = 'Active';
        contactTemp5.Email = 'kent.roessler@daikinapplied.com';
        contactTemp5.FirstName = 'Kent5';
        contactTemp5.LastName = 'Roessler5';
        contactTemp5.IE_Sync_Status__c = 'Pending';
        contactTemp5.IE_Contact__c = true;
        contactList.add(contactTemp5);

        Contact contactTemp6 = new Contact();
        contactTemp6.Eprise_Login_ID__c = 'RoesslKS6';
        contactTemp6.RecordTypeId = recordTypeTemp.Id;
        contactTemp6.AccountId = acctTemp.Id;
        contactTemp6.Status__c = 'Active';
        contactTemp6.Email = 'kent.roessler@daikinapplied.com';
        contactTemp6.FirstName = 'Kent6';
        contactTemp6.LastName = 'Roessler6';
        contactTemp6.IE_Sync_Status__c = 'Pending';
        contactTemp6.IE_Contact__c = true;
        contactList.add(contactTemp6);

        Contact contactTemp7 = new Contact();
        contactTemp7.Eprise_Login_ID__c = 'RoesslKS7';
        contactTemp7.RecordTypeId = recordTypeTemp.Id;
        contactTemp7.AccountId = acctTemp.Id;
        contactTemp7.Status__c = 'Active';
        contactTemp7.Email = 'kent.roessler@daikinapplied.com';
        contactTemp7.FirstName = 'Kent7';
        contactTemp7.LastName = 'Roessler7';
        contactTemp7.IE_Sync_Status__c = 'Pending';
        contactTemp7.IE_Contact__c = true;
        contactList.add(contactTemp7);

        Contact contactTemp8 = new Contact();
        contactTemp8.Eprise_Login_ID__c = 'RoesslKS8';
        contactTemp8.RecordTypeId = recordTypeTemp.Id;
        contactTemp8.AccountId = acctTemp.Id;
        contactTemp8.Status__c = 'Active';
        contactTemp8.Email = 'kent.roessler@daikinapplied.com';
        contactTemp8.FirstName = 'Kent8';
        contactTemp8.LastName = 'Roessler8';
        contactTemp8.IE_Sync_Status__c = 'Pending';
        contactTemp8.IE_Contact__c = true;
        contactList.add(contactTemp8);

        Contact contactTemp9 = new Contact();
        contactTemp9.Eprise_Login_ID__c = 'RoesslKS9';
        contactTemp9.RecordTypeId = recordTypeTemp.Id;
        contactTemp9.AccountId = acctTemp.Id;
        contactTemp9.Status__c = 'Active';
        contactTemp9.Email = 'kent.roessler@daikinapplied.com';
        contactTemp9.FirstName = 'Kent9';
        contactTemp9.LastName = 'Roessler9';
        contactTemp9.IE_Sync_Status__c = 'Pending';
        contactTemp9.IE_Contact__c = true;
        contactList.add(contactTemp9);

        Contact contactTemp10 = new Contact();
        contactTemp10.Eprise_Login_ID__c = 'RoesslKS10';
        contactTemp10.RecordTypeId = recordTypeTemp.Id;
        contactTemp10.AccountId = acctTemp.Id;
        contactTemp10.Status__c = 'Active';
        contactTemp10.Email = 'kent.roessler@daikinapplied.com';
        contactTemp10.FirstName = 'Kent10';
        contactTemp10.LastName = 'Roessler10';
        contactTemp10.IE_Sync_Status__c = 'Pending';
        contactTemp10.IE_Contact__c = true;
        contactList.add(contactTemp10);

        Contact contactTemp11 = new Contact();
        contactTemp11.Eprise_Login_ID__c = 'RoesslKS11';
        contactTemp11.RecordTypeId = recordTypeTemp.Id;
        contactTemp11.AccountId = acctTemp.Id;
        contactTemp11.Status__c = 'Active';
        contactTemp11.Email = 'kent.roessler@daikinapplied.com';
        contactTemp11.FirstName = 'Kent11';
        contactTemp11.LastName = 'Roessler11';
        contactTemp11.IE_Sync_Status__c = 'Pending';
        contactTemp11.IE_Contact__c = true;
        contactList.add(contactTemp11);

        insert contactList;

        Contact_Address__c contactAddrJunctionObj = new Contact_Address__c();
        contactAddrJunctionObj = new Contact_Address__c();
        contactAddrJunctionObj.Contact__c = contactTemp1.Id;
        contactAddrJunctionObj.Address__c = addrTemp2.Id;
        contactAddrJunctionObj.Active__c = true;
        contactAddrJunctionObj.Physical__c = true;
        insert contactAddrJunctionObj;


		//Create a subscription and associate the contacts to it
		Subscription__c subTemp1 = new Subscription__c();
        subTemp1.TriggerInvokedByAPI__c = true;
        subTemp1.IE_Subscription__c = true;
        subTemp1.Start_Date__c = currDateTime;
        subTemp1.End_Date__c = currDateTime.addMonths(12);
        subTemp1.Type__c = 'TechReadWrite';
        subTemp1.Active__c = true;
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

		subscriptions.add(subTemp1);


		Contact_Subscription__c contSubTemp1 = new Contact_Subscription__c();
        contSubTemp1.Role__c = 'Technician';
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

        Contact_Subscription__c contSubTemp4 = new Contact_Subscription__c();
        contSubTemp4.Role__c = 'Technician';
        contSubTemp4.Contact__c = contactTemp4.Id;
        contSubTemp4.Subscription__c = subTemp1.Id;
        contSubTemp4.Asset__c = parentAsset1.Id;
		contSubTemp4.Active_Subscription1__c = true;
        insert contSubTemp4;

        Contact_Subscription__c contSubTemp5 = new Contact_Subscription__c();
        contSubTemp5.Role__c = 'CustomerAdministrator;Customer';
        contSubTemp5.Contact__c = contactTemp5.Id;
        contSubTemp5.Subscription__c = subTemp1.Id;
        contSubTemp5.Asset__c = parentAsset1.Id;
		contSubTemp5.Active_Subscription1__c = true;
        insert contSubTemp5;

        Contact_Subscription__c contSubTemp6 = new Contact_Subscription__c();
        contSubTemp6.Role__c = 'TechnicianAdministrator;Technician';
        contSubTemp6.Contact__c = contactTemp6.Id;
        contSubTemp6.Subscription__c = subTemp1.Id;
        contSubTemp6.Asset__c = parentAsset1.Id;
		contSubTemp6.Active_Subscription1__c = true;
        insert contSubTemp6;

        Contact_Subscription__c contSubTemp7 = new Contact_Subscription__c();
        contSubTemp7.Role__c = 'Technician';
        contSubTemp7.Contact__c = contactTemp7.Id;
        contSubTemp7.Subscription__c = subTemp1.Id;
        contSubTemp7.Asset__c = parentAsset1.Id;
		contSubTemp7.Active_Subscription1__c = true;
        insert contSubTemp7;

        Contact_Subscription__c contSubTemp8 = new Contact_Subscription__c();
        contSubTemp8.Role__c = 'CustomerAdministrator;Customer';
        contSubTemp8.Contact__c = contactTemp8.Id;
        contSubTemp8.Subscription__c = subTemp1.Id;
        contSubTemp8.Asset__c = parentAsset1.Id;
		contSubTemp8.Active_Subscription1__c = true;
        insert contSubTemp8;

        Contact_Subscription__c contSubTemp9 = new Contact_Subscription__c();
        contSubTemp9.Role__c = 'TechnicianAdministrator;Technician';
        contSubTemp9.Contact__c = contactTemp9.Id;
        contSubTemp9.Subscription__c = subTemp1.Id;
        contSubTemp9.Asset__c = parentAsset1.Id;
		contSubTemp9.Active_Subscription1__c = true;
        insert contSubTemp9;

        Contact_Subscription__c contSubTemp10 = new Contact_Subscription__c();
        contSubTemp10.Role__c = 'Technician';
        contSubTemp10.Contact__c = contactTemp10.Id;
        contSubTemp10.Subscription__c = subTemp1.Id;
        contSubTemp10.Asset__c = parentAsset1.Id;
		contSubTemp10.Active_Subscription1__c = true;
        insert contSubTemp10;

        Contact_Subscription__c contSubTemp11 = new Contact_Subscription__c();
        contSubTemp11.Role__c = 'CustomerAdministrator;Customer';
        contSubTemp11.Contact__c = contactTemp11.Id;
        contSubTemp11.Subscription__c = subTemp1.Id;
        contSubTemp11.Asset__c = parentAsset1.Id;
		contSubTemp11.Active_Subscription1__c = true;
        insert contSubTemp11;


		// Process the IE contacts
		IERenewal_ExtWebServiceCallouts.syncIeCloudIndividuals(emptyContactList, contactMap, addressMap, integrationErrorList, subscriptions);
		
		
		// Assert results
		System.assertEquals(11, contactMap.size());

        for (Contact c : contactMap.values()) {
			//System.debug(LoggingLevel.ERROR, c.IE_Sync_Status__c);
        	System.assertEquals('Processed', c.IE_Sync_Status__c);
        }
	}


	@isTest static void test_syncIeCloudIndividuals2() {
		//!!!!!!!!!!! Need to add this code snippet for AvaTax- AccountAddressTrigger to run successfully on Before Insert into the Account table !!!!!!!!!!!!!!!!!
    	AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c();
        ts1.AVA_SFCORE__Active_Setting__c = true;
        ts1.Name='Test Account';
        insert ts1;

		
		Datetime currDateTime = Datetime.now();
		Date currentDate = Date.today();
		
		// Set these static control variables to True to avoid trigger code execution
		TriggerUtility.limitIntegrationBatch = true;
		TriggerUtility.limitContactExecution = true;


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
        orderTemp1.Order_Type_ID__c = 'International'; //'Domestic'
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

        
        // Create Parent Asset records
        Asset parentAsset1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test1', Tag__c='Order Tag 1');
        parentAsset1.Product2Id = prodTemp1.Id;
        parentAsset1.Order__c = orderTemp1.Id;
		parentAsset1.Asset_Address__c = addrTemp.Id;
        parentAsset1.IE_Asset__c = true;
        parentAsset1.Code_String_Breakdown__c = '[{"code_sequence":"1","code_value":"MPS","code_description":"UNIT TYPE; Unit Type"},{"code_sequence":"2","code_value":"003B","code_description":"UNIT SIZE; 3 ton, R410A"},{"code_sequence":"3","code_value":"Y","code_description":"HEAT; None"},{"code_sequence":"4","code_value":"D","code_description":"VOLTAGE/POWER CONNECTION; 460 V power"},{"code_sequence":"5","code_value":"M","code_description":"DRIVE PACKAGE; Belt drive - high static"},{"code_sequence":"6","code_value":"00D","code_description":"HEATING CAPACITY/CONTROLS; DDC controls"},{"code_sequence":"7","code_value":"CZ","code_description":"OPTIONS; HP,LP,LowAmb/Comfort Aler,FldPower GFI, Hail Guard"},{"code_sequence":"8","code_value":"D","code_description":"ECONOMIZER; Field Mounted 0-30% Outside air hood"}]';
        insert parentAsset1;


		//Create Asset Address records
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
		
		
		RecordType recordTypeTemp = [SELECT Id FROM RecordType WHERE Name='Daikin Applied' AND SObjectType='Contact'];
		list<Integration_Error__c> integrationErrorList;
		List<Contact> contactList = new List<Contact>();
		map<Id, Contact> contactMap = new map<Id, Contact>();
		map<Id, Address__c> addressMap = new map<Id, Address__c>();

		// Create 11 contacts which will test the code where number of contacts > CONTACT_BATCH_SIZE
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
        contactList.add(contactTemp1);

        Contact contactTemp2 = new Contact();
        contactTemp2.Eprise_Login_ID__c = 'RoesslKS2';
        contactTemp2.RecordTypeId = recordTypeTemp.Id;
        contactTemp2.AccountId = acctTemp.Id;
        contactTemp2.Status__c = 'Active';
        contactTemp2.Email = 'kent.roessler@daikinapplied.com';
        contactTemp2.FirstName = 'Kent2';
        contactTemp2.LastName = 'Roessler2';
        contactTemp2.IE_Sync_Status__c = 'Pending';
        contactTemp2.IE_Contact__c = true;
        contactList.add(contactTemp2);

        Contact contactTemp3 = new Contact();
        contactTemp3.Eprise_Login_ID__c = 'RoesslKS3';
        contactTemp3.RecordTypeId = recordTypeTemp.Id;
        contactTemp3.AccountId = acctTemp.Id;
        contactTemp3.Status__c = 'Active';
        contactTemp3.Email = 'kent.roessler@daikinapplied.com';
        contactTemp3.FirstName = 'Kent3';
        contactTemp3.LastName = 'Roessler3';
        contactTemp3.IE_Sync_Status__c = 'Pending';
        contactTemp3.IE_Contact__c = true;
        contactList.add(contactTemp3);

        Contact contactTemp4 = new Contact();
        contactTemp4.IE_ID__c = '999';  // forces a Put operation in the service call
        contactTemp4.Eprise_Login_ID__c = 'RoesslKS4';
        contactTemp4.RecordTypeId = recordTypeTemp.Id;
        contactTemp4.AccountId = acctTemp.Id;
        contactTemp4.Status__c = 'Active';
        contactTemp4.Email = 'kent.roessler@daikinapplied.com';
        contactTemp4.FirstName = 'Kent4';
        contactTemp4.LastName = 'Roessler4';
        contactTemp4.IE_Sync_Status__c = 'Pending';
        contactTemp4.IE_Contact__c = true;
        contactList.add(contactTemp4);

        Contact contactTemp5 = new Contact();
        contactTemp5.Eprise_Login_ID__c = 'RoesslKS5';
        contactTemp5.RecordTypeId = recordTypeTemp.Id;
        contactTemp5.AccountId = acctTemp.Id;
        contactTemp5.Status__c = 'Active';
        contactTemp5.Email = 'kent.roessler@daikinapplied.com';
        contactTemp5.FirstName = 'Kent5';
        contactTemp5.LastName = 'Roessler5';
        contactTemp5.IE_Sync_Status__c = 'Pending';
        contactTemp5.IE_Contact__c = true;
        contactList.add(contactTemp5);

        Contact contactTemp6 = new Contact();
        contactTemp6.Eprise_Login_ID__c = 'RoesslKS6';
        contactTemp6.RecordTypeId = recordTypeTemp.Id;
        contactTemp6.AccountId = acctTemp.Id;
        contactTemp6.Status__c = 'Active';
        contactTemp6.Email = 'kent.roessler@daikinapplied.com';
        contactTemp6.FirstName = 'Kent6';
        contactTemp6.LastName = 'Roessler6';
        contactTemp6.IE_Sync_Status__c = 'Pending';
        contactTemp6.IE_Contact__c = true;
        contactList.add(contactTemp6);

        Contact contactTemp7 = new Contact();
        contactTemp7.Eprise_Login_ID__c = 'RoesslKS7';
        contactTemp7.RecordTypeId = recordTypeTemp.Id;
        contactTemp7.AccountId = acctTemp.Id;
        contactTemp7.Status__c = 'Active';
        contactTemp7.Email = 'kent.roessler@daikinapplied.com';
        contactTemp7.FirstName = 'Kent7';
        contactTemp7.LastName = 'Roessler7';
        contactTemp7.IE_Sync_Status__c = 'Pending';
        contactTemp7.IE_Contact__c = true;
        contactList.add(contactTemp7);

        Contact contactTemp8 = new Contact();
        contactTemp8.Eprise_Login_ID__c = 'RoesslKS8';
        contactTemp8.RecordTypeId = recordTypeTemp.Id;
        contactTemp8.AccountId = acctTemp.Id;
        contactTemp8.Status__c = 'Active';
        contactTemp8.Email = 'kent.roessler@daikinapplied.com';
        contactTemp8.FirstName = 'Kent8';
        contactTemp8.LastName = 'Roessler8';
        contactTemp8.IE_Sync_Status__c = 'Pending';
        contactTemp8.IE_Contact__c = true;
        contactList.add(contactTemp8);

        Contact contactTemp9 = new Contact();
        contactTemp9.Eprise_Login_ID__c = 'RoesslKS9';
        contactTemp9.RecordTypeId = recordTypeTemp.Id;
        contactTemp9.AccountId = acctTemp.Id;
        contactTemp9.Status__c = 'Active';
        contactTemp9.Email = 'kent.roessler@daikinapplied.com';
        contactTemp9.FirstName = 'Kent9';
        contactTemp9.LastName = 'Roessler9';
        contactTemp9.IE_Sync_Status__c = 'Pending';
        contactTemp9.IE_Contact__c = true;
        contactList.add(contactTemp9);

        Contact contactTemp10 = new Contact();
        contactTemp10.Eprise_Login_ID__c = 'RoesslKS10';
        contactTemp10.RecordTypeId = recordTypeTemp.Id;
        contactTemp10.AccountId = acctTemp.Id;
        contactTemp10.Status__c = 'Active';
        contactTemp10.Email = 'kent.roessler@daikinapplied.com';
        contactTemp10.FirstName = 'Kent10';
        contactTemp10.LastName = 'Roessler10';
        contactTemp10.IE_Sync_Status__c = 'Pending';
        contactTemp10.IE_Contact__c = true;
        contactList.add(contactTemp10);

        Contact contactTemp11 = new Contact();
        contactTemp11.Eprise_Login_ID__c = 'RoesslKS11';
        contactTemp11.RecordTypeId = recordTypeTemp.Id;
        contactTemp11.AccountId = acctTemp.Id;
        contactTemp11.Status__c = 'Active';
        contactTemp11.Email = 'kent.roessler@daikinapplied.com';
        contactTemp11.FirstName = 'Kent11';
        contactTemp11.LastName = 'Roessler11';
        contactTemp11.IE_Sync_Status__c = 'Pending';
        contactTemp11.IE_Contact__c = true;
        contactList.add(contactTemp11);

        insert contactList;

        Contact_Address__c contactAddrJunctionObj = new Contact_Address__c();
        contactAddrJunctionObj = new Contact_Address__c();
        contactAddrJunctionObj.Contact__c = contactTemp1.Id;
        contactAddrJunctionObj.Address__c = addrTemp2.Id;
        contactAddrJunctionObj.Active__c = true;
        contactAddrJunctionObj.Physical__c = true;
        insert contactAddrJunctionObj;


		//Create a subscription and associate the contacts to it
		Subscription__c subTemp1 = new Subscription__c();
        subTemp1.TriggerInvokedByAPI__c = true;
        subTemp1.IE_Subscription__c = true;
        subTemp1.Start_Date__c = currDateTime;
        subTemp1.End_Date__c = currDateTime.addMonths(12);
        subTemp1.Type__c = 'TechReadWrite';
        subTemp1.Active__c = true;
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
		subTemp1.GWotGoAsset__c = relatedAsset1.Id;
        insert subTemp1;


		Contact_Subscription__c contSubTemp1 = new Contact_Subscription__c();
        contSubTemp1.Role__c = 'Technician';
        contSubTemp1.Contact__c = contactTemp1.Id;
        contSubTemp1.Subscription__c = subTemp1.Id;
        contSubTemp1.Asset__c = parentAsset1.Id;
		contSubTemp1.Active_Subscription1__c = true;
		contSubTemp1.GWotGoAsset__c = relatedAsset1.Id;
		contSubTemp1.GWotGoPermAssoc__c = true;
        insert contSubTemp1;

        Contact_Subscription__c contSubTemp2 = new Contact_Subscription__c();
        contSubTemp2.Role__c = 'CustomerAdministrator;Customer';
        contSubTemp2.Contact__c = contactTemp2.Id;
        contSubTemp2.Subscription__c = subTemp1.Id;
        contSubTemp2.Asset__c = parentAsset1.Id;
		contSubTemp2.Active_Subscription1__c = true;
		contSubTemp2.GWotGoAsset__c = relatedAsset1.Id;
		contSubTemp2.GWotGoPermAssoc__c = true;
        insert contSubTemp2;

        Contact_Subscription__c contSubTemp3 = new Contact_Subscription__c();
        contSubTemp3.Role__c = 'TechnicianAdministrator;Technician';
        contSubTemp3.Contact__c = contactTemp3.Id;
        contSubTemp3.Subscription__c = subTemp1.Id;
        contSubTemp3.Asset__c = parentAsset1.Id;
		contSubTemp3.Active_Subscription1__c = true;
		contSubTemp3.GWotGoAsset__c = relatedAsset1.Id;
		contSubTemp3.GWotGoPermAssoc__c = true;
        insert contSubTemp3;

        Contact_Subscription__c contSubTemp4 = new Contact_Subscription__c();
        contSubTemp4.Role__c = 'Technician';
        contSubTemp4.Contact__c = contactTemp4.Id;
        contSubTemp4.Subscription__c = subTemp1.Id;
        contSubTemp4.Asset__c = parentAsset1.Id;
		contSubTemp4.Active_Subscription1__c = true;
		contSubTemp4.GWotGoAsset__c = relatedAsset1.Id;
		contSubTemp4.GWotGoPermAssoc__c = true;
        insert contSubTemp4;

        Contact_Subscription__c contSubTemp5 = new Contact_Subscription__c();
        contSubTemp5.Role__c = 'CustomerAdministrator;Customer';
        contSubTemp5.Contact__c = contactTemp5.Id;
        contSubTemp5.Subscription__c = subTemp1.Id;
        contSubTemp5.Asset__c = parentAsset1.Id;
		contSubTemp5.Active_Subscription1__c = true;
		contSubTemp5.GWotGoAsset__c = relatedAsset1.Id;
		contSubTemp5.GWotGoPermAssoc__c = true;
        insert contSubTemp5;

        Contact_Subscription__c contSubTemp6 = new Contact_Subscription__c();
        contSubTemp6.Role__c = 'TechnicianAdministrator;Technician';
        contSubTemp6.Contact__c = contactTemp6.Id;
        contSubTemp6.Subscription__c = subTemp1.Id;
        contSubTemp6.Asset__c = parentAsset1.Id;
		contSubTemp6.Active_Subscription1__c = true;
		contSubTemp6.GWotGoAsset__c = relatedAsset1.Id;
		contSubTemp6.GWotGoPermAssoc__c = true;
        insert contSubTemp6;

        Contact_Subscription__c contSubTemp7 = new Contact_Subscription__c();
        contSubTemp7.Role__c = 'Technician';
        contSubTemp7.Contact__c = contactTemp7.Id;
        contSubTemp7.Subscription__c = subTemp1.Id;
        contSubTemp7.Asset__c = parentAsset1.Id;
		contSubTemp7.Active_Subscription1__c = true;
		contSubTemp7.GWotGoAsset__c = relatedAsset1.Id;
		contSubTemp7.GWotGoPermAssoc__c = true;
        insert contSubTemp7;

        Contact_Subscription__c contSubTemp8 = new Contact_Subscription__c();
        contSubTemp8.Role__c = 'CustomerAdministrator;Customer';
        contSubTemp8.Contact__c = contactTemp8.Id;
        contSubTemp8.Subscription__c = subTemp1.Id;
        contSubTemp8.Asset__c = parentAsset1.Id;
		contSubTemp8.Active_Subscription1__c = true;
		contSubTemp8.GWotGoAsset__c = relatedAsset1.Id;
		contSubTemp8.GWotGoPermAssoc__c = true;
        insert contSubTemp8;

        Contact_Subscription__c contSubTemp9 = new Contact_Subscription__c();
        contSubTemp9.Role__c = 'TechnicianAdministrator;Technician';
        contSubTemp9.Contact__c = contactTemp9.Id;
        contSubTemp9.Subscription__c = subTemp1.Id;
        contSubTemp9.Asset__c = parentAsset1.Id;
		contSubTemp9.Active_Subscription1__c = true;
		contSubTemp9.GWotGoAsset__c = relatedAsset1.Id;
		contSubTemp9.GWotGoPermAssoc__c = true;
        insert contSubTemp9;

        Contact_Subscription__c contSubTemp10 = new Contact_Subscription__c();
        contSubTemp10.Role__c = 'Technician';
        contSubTemp10.Contact__c = contactTemp10.Id;
        contSubTemp10.Subscription__c = subTemp1.Id;
        contSubTemp10.Asset__c = parentAsset1.Id;
		contSubTemp10.Active_Subscription1__c = true;
		contSubTemp10.GWotGoAsset__c = relatedAsset1.Id;
		contSubTemp10.GWotGoPermAssoc__c = true;
        insert contSubTemp10;

        Contact_Subscription__c contSubTemp11 = new Contact_Subscription__c();
        contSubTemp11.Role__c = 'CustomerAdministrator;Customer';
        contSubTemp11.Contact__c = contactTemp11.Id;
        contSubTemp11.Subscription__c = subTemp1.Id;
        contSubTemp11.Asset__c = parentAsset1.Id;
		contSubTemp11.Active_Subscription1__c = true;
		contSubTemp11.GWotGoAsset__c = relatedAsset1.Id;
		contSubTemp11.GWotGoPermAssoc__c = true;
        insert contSubTemp11;

		Test.startTest();

		// Process the IE contacts
		IERenewal_ExtWebServiceCallouts.syncIeCloudIndividuals2(contactList, contactMap, addressMap, integrationErrorList, relatedAsset1);
		
		
		// Assert results
		System.assertEquals(11, contactMap.size());

        for (Contact c : contactMap.values()) {
			//System.debug(LoggingLevel.ERROR, c.IE_Sync_Status__c);
        	System.assertEquals('Processed', c.IE_Sync_Status__c);
        }

		Test.stopTest();
	}

}