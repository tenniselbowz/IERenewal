@isTest
private class Batch_IE_CallExtWebServices_Test {
	
	static testMethod void testBatchExecution_CallExternalWebServices_InternationalOrder() {
		//!!!!!!!!!!! Need to add this code snippet for AvaTax- AccountAddressTrigger to run successfully on Before Insert into the Account table !!!!!!!!!!!!!!!!!
    	AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c();
        ts1.AVA_SFCORE__Active_Setting__c = true;
        ts1.Name='Test Account';
        insert ts1;

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
		parentAsset1.Asset_Address__c = addrTemp.Id;
        parentAsset1.IE_Asset__c = true;
        parentAsset1.Code_String_Breakdown__c = '[{"code_sequence":"1","code_value":"MPS","code_description":"UNIT TYPE; Unit Type"},{"code_sequence":"2","code_value":"003B","code_description":"UNIT SIZE; 3 ton, R410A"},{"code_sequence":"3","code_value":"Y","code_description":"HEAT; None"},{"code_sequence":"4","code_value":"D","code_description":"VOLTAGE/POWER CONNECTION; 460 V power"},{"code_sequence":"5","code_value":"M","code_description":"DRIVE PACKAGE; Belt drive - high static"},{"code_sequence":"6","code_value":"00D","code_description":"HEATING CAPACITY/CONTROLS; DDC controls"},{"code_sequence":"7","code_value":"CZ","code_description":"OPTIONS; HP,LP,LowAmb/Comfort Aler,FldPower GFI, Hail Guard"},{"code_sequence":"8","code_value":"D","code_description":"ECONOMIZER; Field Mounted 0-30% Outside air hood"}]';
        insert parentAsset1;

        Asset parentAsset2 = new Asset(Name = 'Asset Test2', AccountId = acctTemp.Id, SerialNumber='SN123Test2', Tag__c='Order Tag 2');
        parentAsset2.Product2Id = prodTemp2.Id;
        parentAsset2.Order__c = orderTemp1.Id;
		parentAsset2.Asset_Address__c = addrTemp.Id;
        parentAsset2.IE_Asset__c = true;
        parentAsset2.IE_ID__c = '999';  // forces a Put operation in the service call for subscriptions tied to this asset
        insert parentAsset2;

		//Create Asset Address records
        Asset_Address__c aa = new Asset_Address__c(Asset__c = parentAsset1.Id
                                                  ,Address__c = addrTemp.Id
                                                  ,Building_Identifier__c = '123');
        insert aa;
        
        Asset_Address__c aa2 = new Asset_Address__c(Asset__c = parentAsset2.Id
                                                  ,Address__c = addrTemp.Id
                                                  ,Building_Identifier__c = '123');
        insert aa2;



        // Create Related Asset Records for each Parent Asset
        Asset relatedAsset1 = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-075', Parent_Asset__c = parentAsset1.Id);
        relatedAsset1.Product2Id = prodTemp3.Id;
        relatedAsset1.SIM_Card_Active__c = true;
        relatedAsset1.SIM_Card_ICCID__c = '89011704258018735310';
		relatedAsset1.MAC_Address__c = '0123456789ab';
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
        // Create 5th Subscription with 1 contact and with a role that isn't RenewalAdministrator or SalesRep
        Datetime currDateTime = Datetime.now();
        Date currentDate = Date.today();
        RecordType recordTypeTemp = [SELECT Id FROM RecordType WHERE Name='Daikin Applied' AND SObjectType='Contact'];

        List<Contact> contactList = new List<Contact>();

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
        //insert contactTemp1;

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
        //insert contactTemp2;

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
        //insert contactTemp3;

        // Create 8 additional contacts so we have a total of 11 which will test the code where number of contacts > CONTACT_BATCH_SIZE
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
        //insert contactTemp4;

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
        //insert contactTemp5;

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
        //insert contactTemp6;

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
        //insert contactTemp7;

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
        //insert contactTemp8;

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
        //insert contactTemp9;

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
        //insert contactTemp10;

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
        //insert contactTemp11;

        insert contactList;

        Contact_Address__c contactAddrJunctionObj = new Contact_Address__c();
        contactAddrJunctionObj = new Contact_Address__c();
        contactAddrJunctionObj.Contact__c = contactTemp1.Id;
        contactAddrJunctionObj.Address__c = addrTemp2.Id;
        contactAddrJunctionObj.Active__c = true;
        contactAddrJunctionObj.Physical__c = true;
        insert contactAddrJunctionObj;



        Subscription__c subTemp1 = new Subscription__c();
        subTemp1.TriggerInvokedByAPI__c = true;
        subTemp1.IE_Subscription__c = true;
        subTemp1.Start_Date__c = currDateTime;
        subTemp1.End_Date__c = currDateTime.addMonths(-1);  // Set End Date to Last Month - Expired Subscription
        subTemp1.Type__c = 'TechReadWrite';
        subTemp1.Active__c = false;  // Set to false to simulate a run of "Batch_IE_DeactivateExpiredSubscriptions"
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


        Subscription__c subTemp2_1 = new Subscription__c();
        subTemp2_1.TriggerInvokedByAPI__c = true;
        subTemp2_1.IE_Subscription__c = true;
        subTemp2_1.Start_Date__c = currDateTime;
        subTemp2_1.End_Date__c = currDateTime.addMonths(12);  // Subscription not expired
        subTemp2_1.Type__c = 'TechReadWrite';
        subTemp2_1.Active__c = true;
        subTemp2_1.Asset__c = parentAsset1.Id;
        subTemp2_1.Buyer_ID__c = acctTemp.Id;
        subTemp2_1.Renewal_Counter__c = 0;
        subTemp2_1.Last_Renewal_Date__c = currentDate.addMonths(-12);
        subTemp2_1.Renewal_Date__c = currentDate;
        subTemp2_1.Connectivity_Type__c = 'Cellular';
        subTemp2_1.Term_Years__c = 1.0;
        subTemp2_1.Renewal_Notice_Current_Month__c = false;
        subTemp2_1.Renewal_Notice_Next_Month__c = false;
        subTemp2_1.Renewal_Notice_Last_Month__c = false;
        subTemp2_1.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp2_1.Renewal_Notice_Last_Month_Minus_1__c = false;
        insert subTemp2_1;

        Subscription__c subTemp2 = new Subscription__c();
        subTemp2.TriggerInvokedByAPI__c = true;
        subTemp2.IE_Subscription__c = true;
        subTemp2.Start_Date__c = currDateTime;
        subTemp2.End_Date__c = currDateTime.addMonths(12);  // Subscription not expired
        subTemp2.Type__c = 'CustomRead';
        subTemp2.Active__c = true;
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
        subTemp3.TriggerInvokedByAPI__c = true;
        subTemp3.IE_Subscription__c = true;
        subTemp3.Start_Date__c = currDateTime.addMonths(-7);  // Set Start Date < 6 months ago
        subTemp3.End_Date__c = currDateTime.addMonths(12);  // Subscription not expired
        subTemp3.Type__c = 'TechReadWrite';
        subTemp3.Active__c = true;
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
        subTemp4.TriggerInvokedByAPI__c = true;
        subTemp4.IE_ID__c = '999';  // forces a Put operation in the service call
        subTemp4.IE_Subscription__c = true;
        subTemp4.Start_Date__c = currDateTime;
        subTemp4.End_Date__c = currDateTime.addMonths(12);  // Subscription not expired
        subTemp4.Type__c = 'CustomRead';
        subTemp4.Active__c = true;
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


        Subscription__c subTemp5 = new Subscription__c();
        subTemp5.TriggerInvokedByAPI__c = true;
        subTemp5.IE_Subscription__c = true;
        subTemp5.Start_Date__c = currDateTime;
        subTemp5.End_Date__c = currDateTime.addMonths(12);  // Subscription not expired
        subTemp5.Type__c = 'CustomRead';
        subTemp5.Active__c = true;
        subTemp5.Asset__c = parentAsset1.Id;
        subTemp5.Buyer_ID__c = acctTemp.Id;
        subTemp5.Renewal_Counter__c = 0;
        subTemp5.Last_Renewal_Date__c = currentDate.addMonths(-12);
        subTemp5.Renewal_Date__c = currentDate;
        subTemp5.Connectivity_Type__c = 'Cellular';
        subTemp5.Term_Years__c = 1.0;
        subTemp5.Renewal_Notice_Current_Month__c = false;
        subTemp5.Renewal_Notice_Next_Month__c = false;
        subTemp5.Renewal_Notice_Last_Month__c = false;
        subTemp5.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp5.Renewal_Notice_Last_Month_Minus_1__c = false;
        insert subTemp5;


        // Associate the 3 contacts to the first subscription
        Contact_Subscription__c contSubTemp1 = new Contact_Subscription__c();
        contSubTemp1.Role__c = 'Technician';
        contSubTemp1.Contact__c = contactTemp1.Id;
        contSubTemp1.Subscription__c = subTemp1.Id;
        contSubTemp1.Asset__c = parentAsset1.Id;
		contSubTemp1.Active_Subscription1__c = false;
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
        contSubTemp4.Role__c = 'Technician';
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
        contSubTemp7.Role__c = 'Technician';
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
        contSubTemp10.Role__c = 'Technician';
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


        // Associate the 1 contact to the fifth subscription
        Contact_Subscription__c contSubTemp13 = new Contact_Subscription__c();
        contSubTemp13.Role__c = 'TechnicianAdministrator;Technician';
        contSubTemp13.Contact__c = contactTemp3.Id;
        contSubTemp13.Subscription__c = subTemp5.Id;
        contSubTemp13.Asset__c = parentAsset1.Id;
		contSubTemp13.Active_Subscription1__c = true;
        insert contSubTemp13;


        // Associate the 1 contact to the subscription 2_1
        Contact_Subscription__c contSubTemp14 = new Contact_Subscription__c();
        contSubTemp14.Role__c = 'TechnicianAdministrator;RenewalAdministrator';
        contSubTemp14.Contact__c = contactTemp3.Id;
        contSubTemp14.Subscription__c = subTemp2_1.Id;
        contSubTemp14.Asset__c = parentAsset1.Id;
		contSubTemp14.Active_Subscription1__c = true;
        insert contSubTemp14;



        // Create an additional account
        Account acctTemp2 = new Account();
        acctTemp2.IE_ID__c = '999';  // forces a Put operation in the service call
        acctTemp2.Name = 'Account Test2';
        acctTemp2.Type = 'Developer';
        acctTemp2.Physical_Address__c = addrTemp.Id;
        acctTemp2.IE_Sync_Status__c = 'Pending';
        insert acctTemp2;



        //------------------------------Start Test----------------------------------
        Test.startTest();
        
        Batch_IE_CallExtWebServices iecews = new Batch_IE_CallExtWebServices();
        ID batchProcessId = Database.executeBatch(iecews);
        
        Test.stopTest();
        //------------------------------End Test------------------------------------
 

 		//------------------------------Verify Test Results---------------------------
		/* Comment all these verification queries out since the Process Builder Flow, "Contact IE Subscription Active" triggers and causes SOQL query limit exception 4/9/18*/
 		Subscription__c subObj1 = [select Id, Name, Serial_Number__c, Start_Date__c, End_Date__c, Active__c, TriggerInvokedByAPI__c, IE_Sync_Status__c from Subscription__c where Id =: subTemp1.Id];
		System.assertEquals(false, subObj1.Active__c);
        System.assertEquals(false, subObj1.TriggerInvokedByAPI__c);
        System.assertEquals('Processed', subObj1.IE_Sync_Status__c);

        Subscription__c subObj2_1 = [select Id, Name, Serial_Number__c, Start_Date__c, End_Date__c, Active__c, TriggerInvokedByAPI__c, IE_Sync_Status__c from Subscription__c where Id =: subTemp2_1.Id];
		System.assertEquals(true, subObj2_1.Active__c);
        System.assertEquals(false, subObj2_1.TriggerInvokedByAPI__c);
        System.assertEquals('Processed', subObj2_1.IE_Sync_Status__c);

        Subscription__c subObj2 = [select Id, Name, Serial_Number__c, Start_Date__c, End_Date__c, Active__c, TriggerInvokedByAPI__c, IE_Sync_Status__c from Subscription__c where Id =: subTemp2.Id];
		System.assertEquals(true, subObj2.Active__c);
        System.assertEquals(false, subObj2.TriggerInvokedByAPI__c);
        System.assertEquals('Processed', subObj2.IE_Sync_Status__c);

		Subscription__c subObj3 = [select Id, Name, Serial_Number__c, Start_Date__c, End_Date__c, Active__c, TriggerInvokedByAPI__c, IE_Sync_Status__c from Subscription__c where Id =: subTemp3.Id];
		System.assertEquals(true, subObj3.Active__c);
        System.assertEquals(false, subObj3.TriggerInvokedByAPI__c);
        System.assertEquals('Processed', subObj3.IE_Sync_Status__c);

        Subscription__c subObj4 = [select Id, Name, Serial_Number__c, Start_Date__c, End_Date__c, Active__c, TriggerInvokedByAPI__c, IE_Sync_Status__c from Subscription__c where Id =: subTemp4.Id];
		System.assertEquals(true, subObj4.Active__c);
        System.assertEquals(false, subObj4.TriggerInvokedByAPI__c);
        System.assertEquals('Processed', subObj4.IE_Sync_Status__c);

        Subscription__c subObj5 = [select Id, Name, Serial_Number__c, Start_Date__c, End_Date__c, Active__c, TriggerInvokedByAPI__c, IE_Sync_Status__c from Subscription__c where Id =: subTemp5.Id];
		System.assertEquals(true, subObj5.Active__c);
        System.assertEquals(false, subObj5.TriggerInvokedByAPI__c);
        System.assertEquals('Processed', subObj5.IE_Sync_Status__c);



 		Asset gwAsset1 = [SELECT Id, SIM_Card_Active__c from Asset Where Id = :relatedAsset1.Id];
 		System.assertEquals(true, gwAsset1.SIM_Card_Active__c); // Connectivity type is Cellular

 		Asset gwAsset2 = [SELECT Id, SIM_Card_Active__c from Asset Where Id = :relatedAsset3.Id];
 		System.assertEquals(false, gwAsset2.SIM_Card_Active__c); // Connectivity type is WiFi/LAN

 		Asset pAsset1 = [SELECT Id, IE_Sync_Status__c from Asset Where Id = :parentAsset1.Id];
 		System.assertEquals('Processed', pAsset1.IE_Sync_Status__c);

		// Had to comment out these since it was giving me a "Too many SOQL queries limit" exception
 		Asset pAsset2 = [SELECT Id, IE_Sync_Status__c from Asset Where Id = :parentAsset2.Id];
 		System.assertEquals('Processed', pAsset2.IE_Sync_Status__c);



 		Account[] acctObjs = [select IE_Sync_Status__c from Account];
        System.assert(acctObjs != null);
        System.assertEquals('Processed', acctObjs[0].IE_Sync_Status__c);
        System.assertEquals('Pending', acctObjs[1].IE_Sync_Status__c);

        Contact[] contactObjs = [select IE_Sync_Status__c from Contact];
        System.assert(contactObjs != null);
		// The first 3 contacts will be at Processed and the rest at Pending
		integer cnt=0;
        for (Contact c : contactObjs) {
			//System.debug(LoggingLevel.ERROR, c.IE_Sync_Status__c);
			if (cnt < 3)
        		System.assertEquals('Processed', c.IE_Sync_Status__c);
			else 
				System.assertEquals('Pending', c.IE_Sync_Status__c);

			cnt++;
        }

	}


	static testMethod void testBatchExecution_CallExternalWebServices_DomesticOrder() {
		//!!!!!!!!!!! Need to add this code snippet for AvaTax- AccountAddressTrigger to run successfully on Before Insert into the Account table !!!!!!!!!!!!!!!!!
    	AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c();
        ts1.AVA_SFCORE__Active_Setting__c = true;
        ts1.Name='Test Account';
        insert ts1;

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
		parentAsset1.Asset_Address__c = addrTemp.Id;
        parentAsset1.IE_Asset__c = true;
        parentAsset1.Code_String_Breakdown__c = '[{"code_sequence":"1","code_value":"MPS","code_description":"UNIT TYPE; Unit Type"},{"code_sequence":"2","code_value":"003B","code_description":"UNIT SIZE; 3 ton, R410A"},{"code_sequence":"3","code_value":"Y","code_description":"HEAT; None"},{"code_sequence":"4","code_value":"D","code_description":"VOLTAGE/POWER CONNECTION; 460 V power"},{"code_sequence":"5","code_value":"M","code_description":"DRIVE PACKAGE; Belt drive - high static"},{"code_sequence":"6","code_value":"00D","code_description":"HEATING CAPACITY/CONTROLS; DDC controls"},{"code_sequence":"7","code_value":"CZ","code_description":"OPTIONS; HP,LP,LowAmb/Comfort Aler,FldPower GFI, Hail Guard"},{"code_sequence":"8","code_value":"D","code_description":"ECONOMIZER; Field Mounted 0-30% Outside air hood"}]';
        insert parentAsset1;

        Asset parentAsset2 = new Asset(Name = 'Asset Test2', AccountId = acctTemp.Id, SerialNumber='SN123Test2', Tag__c='Order Tag 2');
        parentAsset2.Product2Id = prodTemp2.Id;
        parentAsset2.Order__c = orderTemp1.Id;
		parentAsset2.Asset_Address__c = addrTemp.Id;
        parentAsset2.IE_Asset__c = true;
        parentAsset2.IE_ID__c = '999';  // forces a Put operation in the service call for subscriptions tied to this asset
        insert parentAsset2;

		//Create Asset Address records
        Asset_Address__c aa = new Asset_Address__c(Asset__c = parentAsset1.Id
                                                  ,Address__c = addrTemp.Id
                                                  ,Building_Identifier__c = '123');
        insert aa;
        
        Asset_Address__c aa2 = new Asset_Address__c(Asset__c = parentAsset2.Id
                                                  ,Address__c = addrTemp.Id
                                                  ,Building_Identifier__c = '123');
        insert aa2;


        // Create Related Asset Records for each Parent Asset
        Asset relatedAsset1 = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-075', Parent_Asset__c = parentAsset1.Id);
        relatedAsset1.Product2Id = prodTemp3.Id;
        relatedAsset1.SIM_Card_Active__c = true;
        relatedAsset1.SIM_Card_ICCID__c = '89011704258018735310';
		relatedAsset1.MAC_Address__c = '0123456789ab';
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
        // Create 5th Subscription with 1 contact and with a role that isn't RenewalAdministrator or SalesRep
        Datetime currDateTime = Datetime.now();
        Date currentDate = Date.today();
        RecordType recordTypeTemp = [SELECT Id FROM RecordType WHERE Name='Daikin Applied' AND SObjectType='Contact'];

        List<Contact> contactList = new List<Contact>();

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
        //insert contactTemp1;

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
        //insert contactTemp2;

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
        //insert contactTemp3;

        // Create 8 additional contacts so we have a total of 11 which will test the code where number of contacts > CONTACT_BATCH_SIZE
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
        //insert contactTemp4;

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
        //insert contactTemp5;

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
        //insert contactTemp6;

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
        //insert contactTemp7;

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
        //insert contactTemp8;

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
        //insert contactTemp9;

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
        //insert contactTemp10;

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
        //insert contactTemp11;

        insert contactList;

        Contact_Address__c contactAddrJunctionObj = new Contact_Address__c();
        contactAddrJunctionObj = new Contact_Address__c();
        contactAddrJunctionObj.Contact__c = contactTemp1.Id;
        contactAddrJunctionObj.Address__c = addrTemp2.Id;
        contactAddrJunctionObj.Active__c = true;
        contactAddrJunctionObj.Physical__c = true;
        insert contactAddrJunctionObj;



        Subscription__c subTemp1 = new Subscription__c();
        subTemp1.TriggerInvokedByAPI__c = true;
        subTemp1.IE_Subscription__c = true;
        subTemp1.Start_Date__c = currDateTime;
        subTemp1.End_Date__c = currDateTime.addMonths(-1);  // Set End Date to Last Month - Expired Subscription
        subTemp1.Type__c = 'TechReadWrite';
        subTemp1.Active__c = false;  // Set to false to simulate a run of "Batch_IE_DeactivateExpiredSubscriptions"
        subTemp1.Asset__c = parentAsset1.Id;
        subTemp1.Buyer_ID__c = acctTemp.Id;
        subTemp1.Renewal_Counter__c = 0;
        subTemp1.Last_Renewal_Date__c = currentDate.addMonths(-12);
        subTemp1.Renewal_Date__c = currentDate;
        subTemp1.Connectivity_Type__c = 'Cellular';
        subTemp1.Term_Years__c = 1.25;
        subTemp1.Renewal_Notice_Current_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month__c = false;
        subTemp1.Renewal_Notice_Last_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp1.Renewal_Notice_Last_Month_Minus_1__c = false;
        insert subTemp1;


        Subscription__c subTemp2_1 = new Subscription__c();
        subTemp2_1.TriggerInvokedByAPI__c = true;
        subTemp2_1.IE_Subscription__c = true;
        subTemp2_1.Start_Date__c = currDateTime;
        subTemp2_1.End_Date__c = currDateTime.addMonths(12);  // Subscription not expired
        subTemp2_1.Type__c = 'TechReadWrite';
        subTemp2_1.Active__c = true;
        subTemp2_1.Asset__c = parentAsset1.Id;
        subTemp2_1.Buyer_ID__c = acctTemp.Id;
        subTemp2_1.Renewal_Counter__c = 0;
        subTemp2_1.Last_Renewal_Date__c = currentDate.addMonths(-12);
        subTemp2_1.Renewal_Date__c = currentDate;
        subTemp2_1.Connectivity_Type__c = 'Cellular';
        subTemp2_1.Term_Years__c = 1.25;
        subTemp2_1.Renewal_Notice_Current_Month__c = false;
        subTemp2_1.Renewal_Notice_Next_Month__c = false;
        subTemp2_1.Renewal_Notice_Last_Month__c = false;
        subTemp2_1.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp2_1.Renewal_Notice_Last_Month_Minus_1__c = false;
        insert subTemp2_1;

        Subscription__c subTemp2 = new Subscription__c();
        subTemp2.TriggerInvokedByAPI__c = true;
        subTemp2.IE_Subscription__c = true;
        subTemp2.Start_Date__c = currDateTime;
        subTemp2.End_Date__c = currDateTime.addMonths(12);  // Subscription not expired
        subTemp2.Type__c = 'CustomRead';
        subTemp2.Active__c = true;
        subTemp2.Asset__c = parentAsset1.Id;
        subTemp2.Buyer_ID__c = acctTemp.Id;
        subTemp2.Renewal_Counter__c = 0;
        subTemp2.Last_Renewal_Date__c = currentDate.addMonths(-12);
        subTemp2.Renewal_Date__c = currentDate;
        subTemp2.Connectivity_Type__c = 'Cellular';
        subTemp2.Term_Years__c = 1.25;
        subTemp2.Renewal_Notice_Current_Month__c = false;
        subTemp2.Renewal_Notice_Next_Month__c = false;
        subTemp2.Renewal_Notice_Last_Month__c = false;
        subTemp2.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp2.Renewal_Notice_Last_Month_Minus_1__c = false;
        insert subTemp2;


        Subscription__c subTemp3 = new Subscription__c();
        subTemp3.TriggerInvokedByAPI__c = true;
        subTemp3.IE_Subscription__c = true;
        subTemp3.Start_Date__c = currDateTime.addMonths(-7);  // Set Start Date < 6 months ago
        subTemp3.End_Date__c = currDateTime.addMonths(12);  // Subscription not expired
        subTemp3.Type__c = 'TechReadWrite';
        subTemp3.Active__c = true;
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
        subTemp4.TriggerInvokedByAPI__c = true;
        subTemp4.IE_ID__c = '999';  // forces a Put operation in the service call
        subTemp4.IE_Subscription__c = true;
        subTemp4.Start_Date__c = currDateTime;
        subTemp4.End_Date__c = currDateTime.addMonths(12);  // Subscription not expired
        subTemp4.Type__c = 'CustomRead';
        subTemp4.Active__c = true;
        subTemp4.Asset__c = parentAsset2.Id;
        subTemp4.Buyer_ID__c = acctTemp.Id;
        subTemp4.Renewal_Counter__c = 0;
        subTemp4.Last_Renewal_Date__c = null;
        subTemp4.Renewal_Date__c = null;
        subTemp4.Connectivity_Type__c = 'WiFi/LAN';
        subTemp4.Term_Years__c = 1.25;
        subTemp4.Renewal_Notice_Current_Month__c = false;
        subTemp4.Renewal_Notice_Next_Month__c = false;
        subTemp4.Renewal_Notice_Last_Month__c = false;
        subTemp4.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp4.Renewal_Notice_Last_Month_Minus_1__c = false;
        insert subTemp4;


        Subscription__c subTemp5 = new Subscription__c();
        subTemp5.TriggerInvokedByAPI__c = true;
        subTemp5.IE_Subscription__c = true;
        subTemp5.Start_Date__c = currDateTime;
        subTemp5.End_Date__c = currDateTime.addMonths(12);  // Subscription not expired
        subTemp5.Type__c = 'CustomRead';
        subTemp5.Active__c = true;
        subTemp5.Asset__c = parentAsset1.Id;
        subTemp5.Buyer_ID__c = acctTemp.Id;
        subTemp5.Renewal_Counter__c = 0;
        subTemp5.Last_Renewal_Date__c = currentDate.addMonths(-12);
        subTemp5.Renewal_Date__c = currentDate;
        subTemp5.Connectivity_Type__c = 'Cellular';
        subTemp5.Term_Years__c = 1.25;
        subTemp5.Renewal_Notice_Current_Month__c = false;
        subTemp5.Renewal_Notice_Next_Month__c = false;
        subTemp5.Renewal_Notice_Last_Month__c = false;
        subTemp5.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp5.Renewal_Notice_Last_Month_Minus_1__c = false;
        insert subTemp5;


        // Associate the 3 contacts to the first subscription
        Contact_Subscription__c contSubTemp1 = new Contact_Subscription__c();
        contSubTemp1.Role__c = 'Technician';
        contSubTemp1.Contact__c = contactTemp1.Id;
        contSubTemp1.Subscription__c = subTemp1.Id;
        contSubTemp1.Asset__c = parentAsset1.Id;
		contSubTemp1.Active_Subscription1__c = false;
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
        contSubTemp4.Role__c = 'Technician';
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
        contSubTemp7.Role__c = 'Technician';
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
        contSubTemp10.Role__c = 'Technician';
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


        // Associate the 1 contact to the fifth subscription
        Contact_Subscription__c contSubTemp13 = new Contact_Subscription__c();
        contSubTemp13.Role__c = 'TechnicianAdministrator;Technician';
        contSubTemp13.Contact__c = contactTemp3.Id;
        contSubTemp13.Subscription__c = subTemp5.Id;
        contSubTemp13.Asset__c = parentAsset1.Id;
		contSubTemp13.Active_Subscription1__c = true;
        insert contSubTemp13;


        // Associate the 1 contact to the subscription 2_1
        Contact_Subscription__c contSubTemp14 = new Contact_Subscription__c();
        contSubTemp14.Role__c = 'TechnicianAdministrator;RenewalAdministrator';
        contSubTemp14.Contact__c = contactTemp3.Id;
        contSubTemp14.Subscription__c = subTemp2_1.Id;
        contSubTemp14.Asset__c = parentAsset1.Id;
		contSubTemp14.Active_Subscription1__c = true;
        insert contSubTemp14;



        // Create an additional account
        Account acctTemp2 = new Account();
        acctTemp2.IE_ID__c = '999';  // forces a Put operation in the service call
        acctTemp2.Name = 'Account Test2';
        acctTemp2.Type = 'Developer';
        acctTemp2.Physical_Address__c = addrTemp.Id;
        acctTemp2.IE_Sync_Status__c = 'Pending';
        insert acctTemp2;



        //------------------------------Start Test----------------------------------
        Test.startTest();
        
        Batch_IE_CallExtWebServices iecews = new Batch_IE_CallExtWebServices();
        ID batchProcessId = Database.executeBatch(iecews);
        
        Test.stopTest();
        //------------------------------End Test------------------------------------
 

 		//------------------------------Verify Test Results---------------------------
		/* Comment all these verification queries out since the Process Builder Flow, "Contact IE Subscription Active" triggers and causes SOQL query limit exception 4/9/18*/
 		Subscription__c subObj1 = [select Id, Name, Serial_Number__c, Start_Date__c, End_Date__c, Active__c, TriggerInvokedByAPI__c, IE_Sync_Status__c from Subscription__c where Id =: subTemp1.Id];
		System.assertEquals(false, subObj1.Active__c);
        System.assertEquals(false, subObj1.TriggerInvokedByAPI__c);
        System.assertEquals('Processed', subObj1.IE_Sync_Status__c);

        Subscription__c subObj2_1 = [select Id, Name, Serial_Number__c, Start_Date__c, End_Date__c, Active__c, TriggerInvokedByAPI__c, IE_Sync_Status__c from Subscription__c where Id =: subTemp2_1.Id];
		System.assertEquals(true, subObj2_1.Active__c);
        System.assertEquals(false, subObj2_1.TriggerInvokedByAPI__c);
        System.assertEquals('Processed', subObj2_1.IE_Sync_Status__c);

        Subscription__c subObj2 = [select Id, Name, Serial_Number__c, Start_Date__c, End_Date__c, Active__c, TriggerInvokedByAPI__c, IE_Sync_Status__c from Subscription__c where Id =: subTemp2.Id];
		System.assertEquals(true, subObj2.Active__c);
        System.assertEquals(false, subObj2.TriggerInvokedByAPI__c);
        System.assertEquals('Processed', subObj2.IE_Sync_Status__c);

		Subscription__c subObj3 = [select Id, Name, Serial_Number__c, Start_Date__c, End_Date__c, Active__c, TriggerInvokedByAPI__c, IE_Sync_Status__c from Subscription__c where Id =: subTemp3.Id];
		System.assertEquals(true, subObj3.Active__c);
        System.assertEquals(false, subObj3.TriggerInvokedByAPI__c);
        System.assertEquals('Processed', subObj3.IE_Sync_Status__c);

        Subscription__c subObj4 = [select Id, Name, Serial_Number__c, Start_Date__c, End_Date__c, Active__c, TriggerInvokedByAPI__c, IE_Sync_Status__c from Subscription__c where Id =: subTemp4.Id];
		System.assertEquals(true, subObj4.Active__c);
        System.assertEquals(false, subObj4.TriggerInvokedByAPI__c);
        System.assertEquals('Processed', subObj4.IE_Sync_Status__c);

        Subscription__c subObj5 = [select Id, Name, Serial_Number__c, Start_Date__c, End_Date__c, Active__c, TriggerInvokedByAPI__c, IE_Sync_Status__c from Subscription__c where Id =: subTemp5.Id];
		System.assertEquals(true, subObj5.Active__c);
        System.assertEquals(false, subObj5.TriggerInvokedByAPI__c);
        System.assertEquals('Processed', subObj5.IE_Sync_Status__c);



 		Asset gwAsset1 = [SELECT Id, SIM_Card_Active__c from Asset Where Id = :relatedAsset1.Id];
 		System.assertEquals(true, gwAsset1.SIM_Card_Active__c); // Connectivity type is Cellular

 		Asset gwAsset2 = [SELECT Id, SIM_Card_Active__c from Asset Where Id = :relatedAsset3.Id];
 		System.assertEquals(false, gwAsset2.SIM_Card_Active__c); // Connectivity type is WiFi/LAN

 		Asset pAsset1 = [SELECT Id, IE_Sync_Status__c from Asset Where Id = :parentAsset1.Id];
 		System.assertEquals('Processed', pAsset1.IE_Sync_Status__c);

		// Had to comment out these since it was giving me a "Too many SOQL queries limit" exception
 		Asset pAsset2 = [SELECT Id, IE_Sync_Status__c from Asset Where Id = :parentAsset2.Id];
 		System.assertEquals('Processed', pAsset2.IE_Sync_Status__c);



 		Account[] acctObjs = [select IE_Sync_Status__c from Account];
        System.assert(acctObjs != null);
        System.assertEquals('Processed', acctObjs[0].IE_Sync_Status__c);
        System.assertEquals('Pending', acctObjs[1].IE_Sync_Status__c);

        Contact[] contactObjs = [select IE_Sync_Status__c from Contact];
        System.assert(contactObjs != null);
		// The first 3 contacts will be at Processed and the rest at Pending
		integer cnt=0;
        for (Contact c : contactObjs) {
			//System.debug(LoggingLevel.ERROR, c.IE_Sync_Status__c);
			if (cnt < 3)
        		System.assertEquals('Processed', c.IE_Sync_Status__c);
			else 
				System.assertEquals('Pending', c.IE_Sync_Status__c);

			cnt++;
        }

	}


	/*
	static testMethod void testGetIntlPlan() {
		Test.startTest();
			//System.assertEquals('DataXoom – 0kB Plan', IERenewal_ExtWebServiceCallouts.GetIntlPlan('DataXoom – 0kB Plan'));
			
        	System.assertEquals('Daikin Applied - 50MB US_CAN_MEX Plan', IERenewal_ExtWebServiceCallouts.GetIntlPlan('Daikin Applied - 50MB Plan'));
        	System.assertEquals('Daikin Applied - 100MB US_CAN_MEX Plan', IERenewal_ExtWebServiceCallouts.GetIntlPlan('Daikin Applied - 100MB Plan'));
        	System.assertEquals('Daikin Applied - 10MB US_CAN_MEX Plan', IERenewal_ExtWebServiceCallouts.GetIntlPlan('Daikin Applied - 10MB Plan'));
        	System.assertEquals('Daikin Applied - 150MB Intl Plan', IERenewal_ExtWebServiceCallouts.GetIntlPlan('Daikin Applied - 150MB Plan'));
        	System.assertEquals('Daikin Applied - 1GB US_CAN_MEX Plan', IERenewal_ExtWebServiceCallouts.GetIntlPlan('Daikin Applied - 1GB Plan'));
        	System.assertEquals('Daikin Applied - 20MB US_CAN_MEX Plan', IERenewal_ExtWebServiceCallouts.GetIntlPlan('Daikin Applied - 20MB Plan'));
        	System.assertEquals('Daikin Applied - 500MB US_CAN_MEX Plan', IERenewal_ExtWebServiceCallouts.GetIntlPlan('Daikin Applied - 500MB Plan'));
        Test.stopTest();
	}*/


	/*
	static testMethod void testGetDomesticPlan() {
		Test.startTest();
			//System.assertEquals('DataXoom – 0kB Plan', IERenewal_ExtWebServiceCallouts.GetDomesticPlan('DataXoom – 0kB Plan'));
			
        	System.assertEquals('Daikin Applied - 50MB Plan', IERenewal_ExtWebServiceCallouts.GetDomesticPlan('Daikin Applied - 50MB US_CAN_MEX Plan'));
        	System.assertEquals('Daikin Applied - 100MB Plan', IERenewal_ExtWebServiceCallouts.GetDomesticPlan('Daikin Applied - 100MB US_CAN_MEX Plan'));
        	System.assertEquals('Daikin Applied - 10MB Plan', IERenewal_ExtWebServiceCallouts.GetDomesticPlan('Daikin Applied - 10MB US_CAN_MEX Plan'));
        	System.assertEquals('Daikin Applied - 150MB Plan', IERenewal_ExtWebServiceCallouts.GetDomesticPlan('Daikin Applied - 150MB Intl Plan'));
        	System.assertEquals('Daikin Applied - 1GB Plan', IERenewal_ExtWebServiceCallouts.GetDomesticPlan('Daikin Applied - 1GB US_CAN_MEX Plan'));
        	System.assertEquals('Daikin Applied - 20MB Plan', IERenewal_ExtWebServiceCallouts.GetDomesticPlan('Daikin Applied - 20MB US_CAN_MEX Plan'));
        	System.assertEquals('Daikin Applied - 500MB Plan', IERenewal_ExtWebServiceCallouts.GetDomesticPlan('Daikin Applied - 500MB US_CAN_MEX Plan'));
        Test.stopTest();
	}*/



	static testMethod void testBatchExecution_ExceptionThrown_syncIeCloudIndividuals() {
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

        // Create Product2, Order__c, Asset records
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
        
        Order__c orderTemp1 = null;
        orderTemp1 = new Order__c();
        orderTemp1.Job_Name__c = 'Test Order Job Name 1';
        orderTemp1.Order_Type_ID__c = 'International'; //'Domestic'
        orderTemp1.Order_Entry_Date__c = Date.today();
        orderTemp1.SO_Number__c = 'SO #999';
        insert orderTemp1;
        
        Asset assetTemp1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test1', Tag__c='Order Tag 1');
        assetTemp1.Product2Id = prodTemp1.Id;
        assetTemp1.Order__c = orderTemp1.Id;
		assetTemp1.Asset_Address__c = addrTemp.Id;
		assetTemp1.IE_Asset__c = true;
        insert assetTemp1;

		//Create Asset Address record
		Asset_Address__c aa = new Asset_Address__c(Asset__c = assetTemp1.Id
								,Address__c = addrTemp.Id
								,Building_Identifier__c = '123');
		insert aa;


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
        contactTemp1.IE_Sync_Status__c = 'Pending';
        contactTemp1.IE_Contact__c = true;
        insert contactTemp1;


        //Subscription whose end date > current date (ie, not expired, uses Post operation)
        Datetime currDateTime = Datetime.now();
        Subscription__c subTemp1 = new Subscription__c();
        subTemp1.TriggerInvokedByAPI__c = true;
        subTemp1.Start_Date__c = currDateTime;
        subTemp1.End_Date__c = currDateTime.addMonths(12);
        subTemp1.Type__c = 'TechReadWrite';
        subTemp1.Active__c = true;
        subTemp1.IE_Subscription__c = true;
        subTemp1.Asset__c = assetTemp1.Id;
        subTemp1.Buyer_ID__c = acctTemp.Id;
        subTemp1.Renewal_Notice_Current_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month__c = false;
        subTemp1.Renewal_Notice_Last_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp1.Renewal_Notice_Last_Month_Minus_1__c = false;
        insert subTemp1;
        
        Contact_Subscription__c contSubTemp1 = new Contact_Subscription__c();
        contSubTemp1.Role__c = 'CustomerAdministrator;RenewalAdministrator';
        contSubTemp1.Contact__c = contactTemp1.Id;
        contSubTemp1.Subscription__c = subTemp1.Id;
        contSubTemp1.Asset__c = assetTemp1.Id;
        insert contSubTemp1;



        //------------------------------Start Test----------------------------------
        Test.startTest();
        
        Batch_IE_CallExtWebServices iecews = new Batch_IE_CallExtWebServices();
        

        // Force an exception to be thrown
        Batch_IE_CallExtWebServices.crash_syncIeCloudIndividuals_TestByException = true;

        ID batchProcessId = Database.executeBatch(iecews);
        
        Test.stopTest();
        //------------------------------End Test------------------------------------
        
        
        //------------------------------Verify Test Results---------------------------
        Integration_Error__c[] errObjs = [select Error_Description__c, Integration_Object__c, Integration_Point__c, Request_Data__c from Integration_Error__c where Integration_Object__c = 'Contact'];
        System.assert(errObjs != null);
        System.assertEquals('CALLOUT_EXCEPTION', (errObjs[0].Error_Description__c).substring(0, 17));
        System.assertEquals('General Exception from Batch_IE_CallExtWebServices', errObjs[1].Error_Description__c);

        Contact cObj1 = [select Id, IE_Sync_Status__c from Contact where Id =: contactTemp1.Id];
        System.assertEquals('Pending', cObj1.IE_Sync_Status__c);
	}


	static testMethod void testBatchExecution_ResponseStatusCodeError_syncIeCloudIndividuals() {
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
        acctTemp.IE_Sync_Status__c = 'Pending';
        insert acctTemp;
        
        acctAddrJunctionObj = new Account_Address__c();
        acctAddrJunctionObj.Account__c = acctTemp.Id;
        acctAddrJunctionObj.Address__c = addrTemp.Id;
        acctAddrJunctionObj.Active__c = true;
        acctAddrJunctionObj.Physical__c = true;
        insert acctAddrJunctionObj;
        

        // Create Product2, Order__c, Asset records
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
        
        Order__c orderTemp1 = null;
        orderTemp1 = new Order__c();
        orderTemp1.Job_Name__c = 'Test Order Job Name 1';
        orderTemp1.Order_Type_ID__c = 'International'; //'Domestic'
        orderTemp1.Order_Entry_Date__c = Date.today();
        orderTemp1.SO_Number__c = 'SO #999';
        insert orderTemp1;
        
        Asset assetTemp1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test1', Tag__c='Order Tag 1');
        assetTemp1.Product2Id = prodTemp1.Id;
        assetTemp1.Order__c = orderTemp1.Id;
		assetTemp1.Asset_Address__c = addrTemp.Id;
		assetTemp1.IE_Asset__c = true;
        insert assetTemp1;

		//Create Asset Address record
		Asset_Address__c aa = new Asset_Address__c(Asset__c = assetTemp1.Id
								,Address__c = addrTemp.Id
								,Building_Identifier__c = '123');
		insert aa;


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
        contactTemp1.IE_Sync_Status__c = 'Pending';
        contactTemp1.IE_Contact__c = true;
        insert contactTemp1;


        //Subscription whose end date > current date (ie, not expired, uses Post operation)
        Datetime currDateTime = Datetime.now();
        Subscription__c subTemp1 = new Subscription__c();
        subTemp1.TriggerInvokedByAPI__c = true;
        subTemp1.Start_Date__c = currDateTime;
        subTemp1.End_Date__c = currDateTime.addMonths(12);
        subTemp1.Type__c = 'TechReadWrite';
        subTemp1.Active__c = true;
        subTemp1.IE_Subscription__c = true;
        subTemp1.Asset__c = assetTemp1.Id;
        subTemp1.Buyer_ID__c = acctTemp.Id;
        subTemp1.Renewal_Notice_Current_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month__c = false;
        subTemp1.Renewal_Notice_Last_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp1.Renewal_Notice_Last_Month_Minus_1__c = false;
        insert subTemp1;
        
        Contact_Subscription__c contSubTemp1 = new Contact_Subscription__c();
        contSubTemp1.Role__c = 'CustomerAdministrator;RenewalAdministrator';
        contSubTemp1.Contact__c = contactTemp1.Id;
        contSubTemp1.Subscription__c = subTemp1.Id;
        contSubTemp1.Asset__c = assetTemp1.Id;
        insert contSubTemp1;



        //------------------------------Start Test----------------------------------
        Test.startTest();

        Batch_IE_CallExtWebServices iecews = new Batch_IE_CallExtWebServices();
        

        // Force an unsuccessful http response status code
        Batch_IE_CallExtWebServices.crash_syncIeCloudIndividuals_TestByResponseStatusCode = true;

        ID batchProcessId = Database.executeBatch(iecews);

        
        Test.stopTest();
        //------------------------------End Test------------------------------------
        
        
        //------------------------------Verify Test Results---------------------------
        Integration_Error__c[] errObjs = [select Error_Description__c, Integration_Object__c, Integration_Point__c, Request_Data__c from Integration_Error__c where Integration_Object__c = 'Contact'];
        System.assert(errObjs != null);
        System.assertEquals('Transmission Error [0]', errObjs[0].Error_Description__c);
        System.assertEquals('General Exception from Batch_IE_CallExtWebServices', errObjs[1].Error_Description__c);

        Contact cObj1 = [select Id, IE_Sync_Status__c from Contact where Id =: contactTemp1.Id];
        System.assertEquals('Pending', cObj1.IE_Sync_Status__c);

	}


	static testMethod void testBatchExecution_ExceptionThrown_syncIeCloudOrganizations() {
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

        // Create Product2, Order__c, Asset records
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
        
        Order__c orderTemp1 = null;
        orderTemp1 = new Order__c();
        orderTemp1.Job_Name__c = 'Test Order Job Name 1';
        orderTemp1.Order_Type_ID__c = 'International'; //'Domestic'
        orderTemp1.Order_Entry_Date__c = Date.today();
        orderTemp1.SO_Number__c = 'SO #999';
        insert orderTemp1;
        
        Asset assetTemp1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test1', Tag__c='Order Tag 1');
        assetTemp1.Product2Id = prodTemp1.Id;
        assetTemp1.Order__c = orderTemp1.Id;
		assetTemp1.Asset_Address__c = addrTemp.Id;
		assetTemp1.IE_Asset__c = true;
        insert assetTemp1;

		//Create Asset Address record
		Asset_Address__c aa = new Asset_Address__c(Asset__c = assetTemp1.Id
								,Address__c = addrTemp.Id
								,Building_Identifier__c = '123');
		insert aa;


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
        contactTemp1.IE_Sync_Status__c = 'Pending';
        contactTemp1.IE_Contact__c = true;
        insert contactTemp1;


        //Subscription whose end date > current date (ie, not expired, uses Post operation)
        Datetime currDateTime = Datetime.now();
        Subscription__c subTemp1 = new Subscription__c();
        subTemp1.TriggerInvokedByAPI__c = true;
        subTemp1.Start_Date__c = currDateTime;
        subTemp1.End_Date__c = currDateTime.addMonths(12);
        subTemp1.Type__c = 'TechReadWrite';
        subTemp1.Active__c = true;
        subTemp1.IE_Subscription__c = true;
        subTemp1.Asset__c = assetTemp1.Id;
        subTemp1.Buyer_ID__c = acctTemp.Id;
        subTemp1.Renewal_Notice_Current_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month__c = false;
        subTemp1.Renewal_Notice_Last_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp1.Renewal_Notice_Last_Month_Minus_1__c = false;
        insert subTemp1;
        
        Contact_Subscription__c contSubTemp1 = new Contact_Subscription__c();
        contSubTemp1.Role__c = 'CustomerAdministrator;RenewalAdministrator';
        contSubTemp1.Contact__c = contactTemp1.Id;
        contSubTemp1.Subscription__c = subTemp1.Id;
        contSubTemp1.Asset__c = assetTemp1.Id;
        insert contSubTemp1;



        //------------------------------Start Test----------------------------------
        Test.startTest();
        
        Batch_IE_CallExtWebServices iecews = new Batch_IE_CallExtWebServices();
        

        // Force an exception to be thrown
        Batch_IE_CallExtWebServices.crash_syncIeCloudOrganizations_TestByException = true;

        ID batchProcessId = Database.executeBatch(iecews);
        
        Test.stopTest();
        //------------------------------End Test------------------------------------
        
        
        //------------------------------Verify Test Results---------------------------
        Integration_Error__c[] errObjs = [select Error_Description__c, Integration_Object__c, Integration_Point__c, Request_Data__c from Integration_Error__c where Integration_Object__c = 'Account'];
        System.assert(errObjs != null);
        System.assertEquals('CALLOUT_EXCEPTION', errObjs[0].Error_Description__c);
        System.assertEquals('General Exception from Batch_IE_CallExtWebServices', errObjs[1].Error_Description__c);

        Account aObj1 = [select Id, IE_Sync_Status__c from Account where Id =: acctTemp.Id];
        System.assertEquals('Pending', aObj1.IE_Sync_Status__c);
	}


	static testMethod void testBatchExecution_ResponseStatusCodeError_syncIeCloudOrganizations() {
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
        acctTemp.IE_Sync_Status__c = 'Pending';
        insert acctTemp;
        
        acctAddrJunctionObj = new Account_Address__c();
        acctAddrJunctionObj.Account__c = acctTemp.Id;
        acctAddrJunctionObj.Address__c = addrTemp.Id;
        acctAddrJunctionObj.Active__c = true;
        acctAddrJunctionObj.Physical__c = true;
        insert acctAddrJunctionObj;
        

        // Create Product2, Order__c, Asset records
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
        
        Order__c orderTemp1 = null;
        orderTemp1 = new Order__c();
        orderTemp1.Job_Name__c = 'Test Order Job Name 1';
        orderTemp1.Order_Type_ID__c = 'International'; //'Domestic'
        orderTemp1.Order_Entry_Date__c = Date.today();
        orderTemp1.SO_Number__c = 'SO #999';
        insert orderTemp1;
        
        Asset assetTemp1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test1', Tag__c='Order Tag 1');
        assetTemp1.Product2Id = prodTemp1.Id;
        assetTemp1.Order__c = orderTemp1.Id;
		assetTemp1.Asset_Address__c = addrTemp.Id;
		assetTemp1.IE_Asset__c = true;
        insert assetTemp1;

		//Create Asset Address record
		Asset_Address__c aa = new Asset_Address__c(Asset__c = assetTemp1.Id
								,Address__c = addrTemp.Id
								,Building_Identifier__c = '123');
		insert aa;


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
        contactTemp1.IE_Sync_Status__c = 'Pending';
        contactTemp1.IE_Contact__c = true;
        insert contactTemp1;


        //Subscription whose end date > current date (ie, not expired, uses Post operation)
        Datetime currDateTime = Datetime.now();
        Subscription__c subTemp1 = new Subscription__c();
        subTemp1.TriggerInvokedByAPI__c = true;
        subTemp1.Start_Date__c = currDateTime;
        subTemp1.End_Date__c = currDateTime.addMonths(12);
        subTemp1.Type__c = 'TechReadWrite';
        subTemp1.Active__c = true;
        subTemp1.IE_Subscription__c = true;
        subTemp1.Asset__c = assetTemp1.Id;
        subTemp1.Buyer_ID__c = acctTemp.Id;
        subTemp1.Renewal_Notice_Current_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month__c = false;
        subTemp1.Renewal_Notice_Last_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp1.Renewal_Notice_Last_Month_Minus_1__c = false;
        insert subTemp1;
        
        Contact_Subscription__c contSubTemp1 = new Contact_Subscription__c();
        contSubTemp1.Role__c = 'CustomerAdministrator;RenewalAdministrator';
        contSubTemp1.Contact__c = contactTemp1.Id;
        contSubTemp1.Subscription__c = subTemp1.Id;
        contSubTemp1.Asset__c = assetTemp1.Id;
        insert contSubTemp1;



        //------------------------------Start Test----------------------------------
        Test.startTest();

        Batch_IE_CallExtWebServices iecews = new Batch_IE_CallExtWebServices();
        

        // Force an unsuccessful http response status code
        Batch_IE_CallExtWebServices.crash_syncIeCloudOrganizations_TestByResponseStatusCode = true;

        ID batchProcessId = Database.executeBatch(iecews);

        
        Test.stopTest();
        //------------------------------End Test------------------------------------
        
        
        //------------------------------Verify Test Results---------------------------
        Integration_Error__c[] errObjs = [select Error_Description__c, Integration_Object__c, Integration_Point__c, Request_Data__c from Integration_Error__c where Integration_Object__c = 'Account'];
        System.assert(errObjs != null);
        System.assertEquals('Transmission Error [0]', errObjs[0].Error_Description__c);
        System.assertEquals('General Exception from Batch_IE_CallExtWebServices', errObjs[1].Error_Description__c);

        Account aObj1 = [select Id, IE_Sync_Status__c from Account where Id =: acctTemp.Id];
        System.assertEquals('Pending', aObj1.IE_Sync_Status__c);

	}


	static testMethod void testBatchExecution_ExceptionThrown_syncIeCloudSubscriptions() {
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
        

        // Create Product2, Order__c, Asset records
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
        
        Order__c orderTemp1 = null;
        orderTemp1 = new Order__c();
        orderTemp1.Job_Name__c = 'Test Order Job Name 1';
        orderTemp1.Order_Type_ID__c = 'International'; //'Domestic'
        orderTemp1.Order_Entry_Date__c = Date.today();
        orderTemp1.SO_Number__c = 'SO #999';
        insert orderTemp1;
        
        Asset assetTemp1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test1', Tag__c='Order Tag 1');
        assetTemp1.Product2Id = prodTemp1.Id;
        assetTemp1.Order__c = orderTemp1.Id;
		assetTemp1.Asset_Address__c = addrTemp.Id;
		assetTemp1.IE_Asset__c = true;
        insert assetTemp1;

		//Create Asset Address record
		Asset_Address__c aa = new Asset_Address__c(Asset__c = assetTemp1.Id
								,Address__c = addrTemp.Id
								,Building_Identifier__c = '123');
		insert aa;


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


        //Subscription whose end date > current date (ie, not expired, uses Post operation)
        Datetime currDateTime = Datetime.now();
        Subscription__c subTemp1 = new Subscription__c();
        subTemp1.TriggerInvokedByAPI__c = true;
        subTemp1.Start_Date__c = currDateTime;
        subTemp1.End_Date__c = currDateTime.addMonths(12);
        subTemp1.Type__c = 'TechReadWrite';
        subTemp1.Active__c = true;
        subTemp1.IE_Subscription__c = true;
        subTemp1.Asset__c = assetTemp1.Id;
        subTemp1.Buyer_ID__c = acctTemp.Id;
        subTemp1.Renewal_Notice_Current_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month__c = false;
        subTemp1.Renewal_Notice_Last_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp1.Renewal_Notice_Last_Month_Minus_1__c = false;
        insert subTemp1;
        
        Contact_Subscription__c contSubTemp1 = new Contact_Subscription__c();
        contSubTemp1.Role__c = 'CustomerAdministrator;RenewalAdministrator';
        contSubTemp1.Contact__c = contactTemp1.Id;
        contSubTemp1.Subscription__c = subTemp1.Id;
        contSubTemp1.Asset__c = assetTemp1.Id;
        insert contSubTemp1;



        //------------------------------Start Test----------------------------------
        Test.startTest();
        
        Batch_IE_CallExtWebServices iecews = new Batch_IE_CallExtWebServices();
        

        // Force an exception to be thrown
        Batch_IE_CallExtWebServices.crash_syncIeCloudSubscriptions_TestByException = true;

        ID batchProcessId = Database.executeBatch(iecews);
        
        Test.stopTest();
        //------------------------------End Test------------------------------------
        
        
        //------------------------------Verify Test Results---------------------------
        Integration_Error__c[] errObjs = [select Error_Description__c, Integration_Object__c, Integration_Point__c, Request_Data__c from Integration_Error__c where Integration_Object__c = 'Subscription__c'];
        System.assert(errObjs != null);
        System.assertEquals('CALLOUT_EXCEPTION', errObjs[0].Error_Description__c);
        System.assertEquals('General Exception from Batch_IE_CallExtWebServices', errObjs[1].Error_Description__c);

        Subscription__c subObj1 = [select Id, Name, Serial_Number__c, Start_Date__c, End_Date__c, Active__c, TriggerInvokedByAPI__c, IE_Sync_Status__c from Subscription__c where Id =: subTemp1.Id];
		System.assertEquals(true, subObj1.Active__c);
        System.assertEquals(false, subObj1.TriggerInvokedByAPI__c);
        System.assertEquals('Pending', subObj1.IE_Sync_Status__c);

	}


	static testMethod void testBatchExecution_ResponseStatusCodeError_syncIeCloudSubscriptions() {
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
        

        // Create Product2, Order__c, Asset records
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
        
        Order__c orderTemp1 = null;
        orderTemp1 = new Order__c();
        orderTemp1.Job_Name__c = 'Test Order Job Name 1';
        orderTemp1.Order_Type_ID__c = 'International'; //'Domestic'
        orderTemp1.Order_Entry_Date__c = Date.today();
        orderTemp1.SO_Number__c = 'SO #999';
        insert orderTemp1;
        
        Asset assetTemp1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test1', Tag__c='Order Tag 1');
        assetTemp1.Product2Id = prodTemp1.Id;
        assetTemp1.Order__c = orderTemp1.Id;
		assetTemp1.Asset_Address__c = addrTemp.Id;
        assetTemp1.IE_Asset__c = true;
        insert assetTemp1;

		//Create Asset Address record
        Asset_Address__c aa = new Asset_Address__c(Asset__c = assetTemp1.Id
                                                  ,Address__c = addrTemp.Id
                                                  ,Building_Identifier__c = '123');
        insert aa;


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


        //Subscription whose end date > current date (ie, not expired, uses Post operation)
        Datetime currDateTime = Datetime.now();
        Subscription__c subTemp1 = new Subscription__c();
        subTemp1.TriggerInvokedByAPI__c = true;
        subTemp1.Start_Date__c = currDateTime;
        subTemp1.End_Date__c = currDateTime.addMonths(12);
        subTemp1.Type__c = 'TechReadWrite';
        subTemp1.Active__c = true;
        subTemp1.IE_Subscription__c = true;
        subTemp1.Asset__c = assetTemp1.Id;
        subTemp1.Buyer_ID__c = acctTemp.Id;
        subTemp1.Renewal_Notice_Current_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month__c = false;
        subTemp1.Renewal_Notice_Last_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp1.Renewal_Notice_Last_Month_Minus_1__c = false;
        insert subTemp1;
        
        Contact_Subscription__c contSubTemp1 = new Contact_Subscription__c();
        //Role__c needs to be set to 'TechnicianAdministrator' or 'CustomerAdministrator'
        contSubTemp1.Role__c = 'CustomerAdministrator;RenewalAdministrator';
        contSubTemp1.Contact__c = contactTemp1.Id;
        contSubTemp1.Subscription__c = subTemp1.Id;
        contSubTemp1.Asset__c = assetTemp1.Id;
        insert contSubTemp1;



        //------------------------------Start Test----------------------------------
        Test.startTest();

        Batch_IE_CallExtWebServices iecews = new Batch_IE_CallExtWebServices();
        

        // Force an unsuccessful http response status code
        Batch_IE_CallExtWebServices.crash_syncIeCloudSubscriptions_TestByResponseStatusCode = true;

        ID batchProcessId = Database.executeBatch(iecews);

        
        Test.stopTest();
        //------------------------------End Test------------------------------------
        
        
        //------------------------------Verify Test Results---------------------------
        Integration_Error__c[] errObjs = [select Error_Description__c, Integration_Object__c, Integration_Point__c, Request_Data__c from Integration_Error__c where Integration_Object__c = 'Subscription__c'];
        System.assert(errObjs != null);
        System.assertEquals('Transmission Error [0]', errObjs[0].Error_Description__c);
        System.assertEquals('General Exception from Batch_IE_CallExtWebServices', errObjs[1].Error_Description__c);

        Subscription__c subObj1 = [select Id, Name, Serial_Number__c, Start_Date__c, End_Date__c, Active__c, TriggerInvokedByAPI__c, IE_Sync_Status__c from Subscription__c where Id =: subTemp1.Id];
		System.assertEquals(true, subObj1.Active__c);
        System.assertEquals(false, subObj1.TriggerInvokedByAPI__c);
        System.assertEquals('Pending', subObj1.IE_Sync_Status__c);

	}


	static testMethod void testBatchExecution_ExceptionThrown_syncIeCloudUnits() {
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
        orderTemp1.Order_Entry_Date__c = Date.today();
        orderTemp1.SO_Number__c = 'SO #999';
        insert orderTemp1;
        

        // Create Parent Asset records
        Asset parentAsset1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test1', Tag__c='Order Tag 1');
        parentAsset1.Product2Id = prodTemp1.Id;
        parentAsset1.Order__c = orderTemp1.Id;
		parentAsset1.Asset_Address__c = addrTemp.Id;
        parentAsset1.IE_Asset__c = true;
        insert parentAsset1;

		//Create Asset Address records
        Asset_Address__c aa = new Asset_Address__c(Asset__c = parentAsset1.Id
                                                  ,Address__c = addrTemp.Id
                                                  ,Building_Identifier__c = '123');
        insert aa;


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

        	Batch_IE_CallExtWebServices iecews = new Batch_IE_CallExtWebServices();
        

	        // Force an exception to be thrown
	        Batch_IE_CallExtWebServices.crash_syncIeCloudUnits_TestByException = true;

	        ID batchProcessId = Database.executeBatch(iecews);

        	
        Test.stopTest();
        //------------------------------End Test------------------------------------
        
        
        //------------------------------Verify Test Results---------------------------
        Integration_Error__c[] errObjs = [select Error_Description__c, Integration_Object__c, Integration_Point__c, Request_Data__c from Integration_Error__c where Integration_Object__c = 'Asset'];
        System.assert(errObjs != null);
        System.assertEquals('CALLOUT_EXCEPTION', errObjs[0].Error_Description__c);
        System.assertEquals('General Exception from Batch_IE_CallExtWebServices', errObjs[1].Error_Description__c);

        Asset pa1 = [SELECT Id, IE_Id__c, IE_Sync_Status__c from Asset Where Id = :parentAsset1.Id];
 		System.assertEquals(null, pa1.IE_Id__c);
 		System.assertEquals('Pending', pa1.IE_Sync_Status__c);

	}


	static testMethod void testBatchExecution_ResponseStatusCodeError_syncIeCloudUnits() {
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
        orderTemp1.Order_Entry_Date__c = Date.today();
        orderTemp1.SO_Number__c = 'SO #999';
        insert orderTemp1;
         

        // Create Parent Asset records
        Asset parentAsset1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test1', Tag__c='Order Tag 1');
        parentAsset1.Product2Id = prodTemp1.Id;
        parentAsset1.Order__c = orderTemp1.Id;
		parentAsset1.Asset_Address__c = addrTemp.Id;
        parentAsset1.IE_Asset__c = true;
        insert parentAsset1;

		//Create Asset Address records
        Asset_Address__c aa = new Asset_Address__c(Asset__c = parentAsset1.Id
                                                  ,Address__c = addrTemp.Id
                                                  ,Building_Identifier__c = '123');
        insert aa;


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
        	Batch_IE_CallExtWebServices iecews = new Batch_IE_CallExtWebServices();
        

        	// Force an unsuccessful http response status code
        	Batch_IE_CallExtWebServices.crash_syncIeCloudUnits_TestByResponseStatusCode = true;

        	ID batchProcessId = Database.executeBatch(iecews);
        
        Test.stopTest();
        //------------------------------End Test------------------------------------
        
        
        //------------------------------Verify Test Results---------------------------
        Integration_Error__c[] errObjs = [select Error_Description__c, Integration_Object__c, Integration_Point__c, Request_Data__c from Integration_Error__c where Integration_Object__c = 'Asset'];
        System.assert(errObjs != null);
        System.assertEquals('Transmission Error [0]', errObjs[0].Error_Description__c);
        System.assertEquals('General Exception from Batch_IE_CallExtWebServices', errObjs[1].Error_Description__c);

        Asset pa1 = [SELECT Id, IE_Id__c, IE_Sync_Status__c from Asset Where Id = :parentAsset1.Id];
 		System.assertEquals(null, pa1.IE_Id__c);
 		System.assertEquals('Pending', pa1.IE_Sync_Status__c);

	}


	static testmethod void testBatch_IE_CallExtWebServices_Sched() {
      Test.startTest();
      //define the CRON Expression, format: Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
      String CRON_EXP;
      CRON_EXP = '0 0 3 * * ?'; //class runs every day at 3am
      Batch_IE_CallExtWebServices_Sched s = new Batch_IE_CallExtWebServices_Sched();
      SchedulableContext sc;
      s.execute(sc);
      System.schedule('test-Batch_IE_CallExtWebServices_Sched', CRON_EXP, s);
      Test.stopTest();
   }
	
}