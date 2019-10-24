@isTest
// Assumption - The "Dummy GWotGo Unit Asset" and "Holding GWotGo Unit Asset" must exist in your testing environment.
// NOTE: Need to use the @isTest(SeeAllData=true) annotation because some of the test methods need to access
// the Dummy and Holding Unit Asset records

// Before running the test make sure you check your Deliverability settings under Setup > Email Administration > Deliverability in your sandbox.
// It must be set to All Email

private class Batch_IE_Subscription_NotificationTest {
    static testMethod void testBatchExecution() {
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
        insert orderTemp1;
        
        Asset assetTemp1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test1', Tag__c='Order Tag 1');
        //Can't set these fields directly since they are formula text fields:
        //Job_Name__c = Order__r.Job_Name__c
        //Equipment_Description__c = Product2.DW_PCL_Description__c
        //Product_Description__c = Product2.Description
        assetTemp1.Product2Id = prodTemp1.Id;
        assetTemp1.Order__c = orderTemp1.Id;
        insert assetTemp1;
        
        Asset assetTemp2 = new Asset(Name = 'Asset Test2', AccountId = acctTemp.Id, SerialNumber='SN123Test2', Tag__c='Order Tag 2');
        assetTemp2.Product2Id = prodTemp1.Id;
        assetTemp2.Order__c = orderTemp1.Id;
        insert assetTemp2;
        
        Asset assetTemp3 = new Asset(Name = 'Asset Test3', AccountId = acctTemp.Id, SerialNumber='SN123Test3', Tag__c='Order Tag 3');
        assetTemp3.Product2Id = prodTemp1.Id;
        assetTemp3.Order__c = orderTemp1.Id;
        insert assetTemp3;
        
        Asset assetTemp4 = new Asset(Name = 'Asset Test4', AccountId = acctTemp.Id, SerialNumber='SN123Test4', Tag__c='Order Tag 4');
        assetTemp4.Product2Id = prodTemp1.Id;
        assetTemp4.Order__c = orderTemp1.Id;
        insert assetTemp4;
        
        Asset assetTemp5 = new Asset(Name = 'Asset Test5', AccountId = acctTemp.Id, SerialNumber='SN123Test5', Tag__c='Order Tag 5');
        assetTemp5.Product2Id = prodTemp1.Id;
        assetTemp5.Order__c = orderTemp1.Id;
        insert assetTemp5;
        
        Asset assetTemp6 = new Asset(Name = 'Asset Test6', AccountId = acctTemp.Id, SerialNumber='SN123Test6', Tag__c='Order Tag 6');
        assetTemp6.Product2Id = prodTemp1.Id;
        assetTemp6.Order__c = orderTemp1.Id;
        insert assetTemp6;
        
        Asset assetTemp7 = new Asset(Name = 'Asset Test7', AccountId = acctTemp.Id, SerialNumber='SN123Test7', Tag__c='Order Tag 7');
        assetTemp7.Product2Id = prodTemp1.Id;
        assetTemp7.Order__c = orderTemp1.Id;
        insert assetTemp7;
        
        
        // Create Contact records
        Contact contactTemp1 = null;
        Contact contactTemp2 = null;
        Contact contactTemp3 = null;
        Contact contactTemp4 = null;
        Contact contactTemp5 = null;
        Contact contactTemp6 = null;
        Contact contactTemp7 = null;
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
        
        contactTemp2 = new Contact();
        contactTemp2.Eprise_Login_ID__c = 'RoesslKS2';
        contactTemp2.RecordTypeId = recordTypeTemp.Id;
        contactTemp2.AccountId = acctTemp.Id;
        contactTemp2.Status__c = 'Active';
        contactTemp2.Email = 'kent.roessler@daikinapplied.com';
        contactTemp2.FirstName = 'Kent2';
        contactTemp2.LastName = 'Roessler2';
        insert contactTemp2;
        
        contactTemp3 = new Contact();
        contactTemp3.Eprise_Login_ID__c = 'RoesslKS3';
        contactTemp3.RecordTypeId = recordTypeTemp.Id;
        contactTemp3.AccountId = acctTemp.Id;
        contactTemp3.Status__c = 'Active';
        contactTemp3.Email = 'kent.roessler@daikinapplied.com';
        contactTemp3.FirstName = 'Kent3';
        contactTemp3.LastName = 'Roessler3';
        insert contactTemp3;
        
        contactTemp4 = new Contact();
        contactTemp4.Eprise_Login_ID__c = 'RoesslKS4';
        contactTemp4.RecordTypeId = recordTypeTemp.Id;
        contactTemp4.AccountId = acctTemp.Id;
        contactTemp4.Status__c = 'Active';
        contactTemp4.Email = 'kent.roessler@daikinapplied.com';
        contactTemp4.FirstName = 'Kent4';
        contactTemp4.LastName = 'Roessler4';
        insert contactTemp4;
        
        contactTemp5 = new Contact();
        contactTemp5.Eprise_Login_ID__c = 'RoesslKS5';
        contactTemp5.RecordTypeId = recordTypeTemp.Id;
        contactTemp5.AccountId = acctTemp.Id;
        contactTemp5.Status__c = 'Active';
        contactTemp5.Email = 'kent.roessler@daikinapplied.com';
        contactTemp5.FirstName = 'Kent5';
        contactTemp5.LastName = 'Roessler5';
        insert contactTemp5;
        
        contactTemp6 = new Contact();
        contactTemp6.Eprise_Login_ID__c = 'RoesslKS6';
        contactTemp6.RecordTypeId = recordTypeTemp.Id;
        contactTemp6.AccountId = acctTemp.Id;
        contactTemp6.Status__c = 'Active';
        contactTemp6.Email = 'kent.roessler@daikinapplied.com';
        contactTemp6.FirstName = 'Kent6';
        contactTemp6.LastName = 'Roessler6';
        insert contactTemp6;
        
        contactTemp7 = new Contact();
        contactTemp7.Eprise_Login_ID__c = 'RoesslKS7';
        contactTemp7.RecordTypeId = recordTypeTemp.Id;
        contactTemp7.AccountId = acctTemp.Id;
        contactTemp7.Status__c = 'Active';
        contactTemp7.Email = 'kent.roessler@daikinapplied.com';
        contactTemp7.FirstName = 'Kent7';
        contactTemp7.LastName = 'Roessler7';
        insert contactTemp7;
        
        
        // Create Subscription__c, Contact_Subscription__c records
        Date currentDate = Date.today();
        Datetime currDateTime = Datetime.now();
        
        //TEST CASE#1: Subscription that is due in the current month
        Subscription__c subTemp1 = new Subscription__c();
        //Type__c needs to be set to 'TechReadWrite'
        subTemp1.Start_Date__c = currDateTime.addMonths(-6);
        subTemp1.End_Date__c = currDateTime;
        subTemp1.Type__c = 'TechReadWrite';
        subTemp1.Active__c = true;
        subTemp1.Asset__c = assetTemp1.Id;
        subTemp1.Buyer_ID__c = acctTemp.Id;
        subTemp1.Renewal_Notice_Current_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month__c = false;
        subTemp1.Renewal_Notice_Last_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp1.Renewal_Notice_Last_Month_Minus_1__c = false;
        //Can't set these fields directly since they are formula text fields:
        //Serial_Number__c = Asset__r.SerialNumber
        insert subTemp1;
        
        Contact_Subscription__c contSubTemp1 = new Contact_Subscription__c();
        //Role__c needs to be set to 'RenewalAdministrator', 'TechnicianAdministrator' or 'SalesRep'
        contSubTemp1.Role__c = 'RenewalAdministrator';
        contSubTemp1.Contact__c = contactTemp1.Id;
        contSubTemp1.Subscription__c = subTemp1.Id;
        contSubTemp1.Asset__c = assetTemp1.Id;
		contSubTemp1.Active_Subscription1__c = true;
        insert contSubTemp1;
        
        
        //TEST CASE#2: Subscription that was due in the last month
        Subscription__c subTemp2 = new Subscription__c();
        //Type__c needs to be set to 'TechReadWrite'
        subTemp2.Start_Date__c = currDateTime.addMonths(-6);
        subTemp2.End_Date__c = currDateTime.addMonths(-1);
        subTemp2.Type__c = 'TechReadWrite';
        subTemp2.Active__c = true;
        subTemp2.Asset__c = assetTemp2.Id;
        subTemp2.Buyer_ID__c = acctTemp.Id;
        subTemp2.Renewal_Notice_Current_Month__c = false;
        subTemp2.Renewal_Notice_Next_Month__c = false;
        subTemp2.Renewal_Notice_Last_Month__c = false;
        subTemp2.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp2.Renewal_Notice_Last_Month_Minus_1__c = false;
        //Can't set these fields directly since they are formula text fields:
        //Serial_Number__c = Asset__r.SerialNumber
        insert subTemp2;
        
        Contact_Subscription__c contSubTemp2 = new Contact_Subscription__c();
        //Role__c needs to be set to 'RenewalAdministrator', 'TechnicianAdministrator' or 'SalesRep'
        contSubTemp2.Role__c = 'RenewalAdministrator';
        contSubTemp2.Contact__c = contactTemp2.Id;
        contSubTemp2.Subscription__c = subTemp2.Id;
        contSubTemp2.Asset__c = assetTemp2.Id;
		contSubTemp2.Active_Subscription1__c = true;
        insert contSubTemp2;
        
        
        //TEST CASE#3: Subscription that is due in the next month
        Subscription__c subTemp3 = new Subscription__c();
        //Type__c needs to be set to 'TechReadWrite'
        subTemp3.Start_Date__c = currDateTime.addMonths(-6);
        subTemp3.End_Date__c = currDateTime.addMonths(1);
        subTemp3.Type__c = 'TechReadWrite';
        subTemp3.Active__c = true;
        subTemp3.Asset__c = assetTemp3.Id;
        subTemp3.Buyer_ID__c = acctTemp.Id;
        subTemp3.Renewal_Notice_Current_Month__c = false;
        subTemp3.Renewal_Notice_Next_Month__c = false;
        subTemp3.Renewal_Notice_Last_Month__c = false;
        subTemp3.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp3.Renewal_Notice_Last_Month_Minus_1__c = false;
        //Can't set these fields directly since they are formula text fields:
        //Serial_Number__c = Asset__r.SerialNumber
        insert subTemp3;
        
        Contact_Subscription__c contSubTemp3 = new Contact_Subscription__c();
        //Role__c needs to be set to 'RenewalAdministrator', 'TechnicianAdministrator' or 'SalesRep'
        contSubTemp3.Role__c = 'RenewalAdministrator';
        contSubTemp3.Contact__c = contactTemp3.Id;
        contSubTemp3.Subscription__c = subTemp3.Id;
        contSubTemp3.Asset__c = assetTemp3.Id;
		contSubTemp3.Active_Subscription1__c = true;
        insert contSubTemp3;
        
        
        //TEST CASE#4: Subscription that is due in the last month - 1
        Subscription__c subTemp4 = new Subscription__c();
        //Type__c needs to be set to 'TechReadWrite'
        subTemp4.Start_Date__c = currDateTime.addMonths(-6);
        subTemp4.End_Date__c = currDateTime.addMonths(-2);
        subTemp4.Type__c = 'TechReadWrite';
        subTemp4.Active__c = true;
        subTemp4.Asset__c = assetTemp4.Id;
        subTemp4.Buyer_ID__c = acctTemp.Id;
        subTemp4.Renewal_Notice_Current_Month__c = false;
        subTemp4.Renewal_Notice_Next_Month__c = false;
        subTemp4.Renewal_Notice_Last_Month__c = false;
        subTemp4.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp4.Renewal_Notice_Last_Month_Minus_1__c = false;
        //Can't set these fields directly since they are formula text fields:
        //Serial_Number__c = Asset__r.SerialNumber
        insert subTemp4;
        
        Contact_Subscription__c contSubTemp4 = new Contact_Subscription__c();
        //Role__c needs to be set to 'RenewalAdministrator', 'TechnicianAdministrator' or 'SalesRep'
        contSubTemp4.Role__c = 'RenewalAdministrator';
        contSubTemp4.Contact__c = contactTemp4.Id;
        contSubTemp4.Subscription__c = subTemp4.Id;
        contSubTemp4.Asset__c = assetTemp4.Id;
		contSubTemp4.Active_Subscription1__c = true;
        insert contSubTemp4;
        
        
        //TEST CASE#5: Subscription that is due in the next month + 1
        Subscription__c subTemp5 = new Subscription__c();
        //Type__c needs to be set to 'TechReadWrite'
        subTemp5.Start_Date__c = currDateTime.addMonths(-6);
        subTemp5.End_Date__c = currDateTime.addMonths(2);
        subTemp5.Type__c = 'TechReadWrite';
        subTemp5.Active__c = true;
        subTemp5.Asset__c = assetTemp5.Id;
        subTemp5.Buyer_ID__c = acctTemp.Id;
        subTemp5.Renewal_Notice_Current_Month__c = false;
        subTemp5.Renewal_Notice_Next_Month__c = false;
        subTemp5.Renewal_Notice_Last_Month__c = false;
        subTemp5.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp5.Renewal_Notice_Last_Month_Minus_1__c = false;
        //Can't set these fields directly since they are formula text fields:
        //Serial_Number__c = Asset__r.SerialNumber
        insert subTemp5;
        
        Contact_Subscription__c contSubTemp5 = new Contact_Subscription__c();
        //Role__c needs to be set to 'RenewalAdministrator', 'TechnicianAdministrator' or 'SalesRep'
        contSubTemp5.Role__c = 'TechnicianAdministrator';
        contSubTemp5.Contact__c = contactTemp5.Id;
        contSubTemp5.Subscription__c = subTemp5.Id;
        contSubTemp5.Asset__c = assetTemp5.Id;
		contSubTemp5.Active_Subscription1__c = true;
        insert contSubTemp5;
        
        
        //TEST CASE#6: Subscription that has no end date
        Subscription__c subTemp6 = new Subscription__c();
        //Type__c needs to be set to 'TechReadWrite'
        subTemp6.Start_Date__c = currDateTime.addMonths(-6);
        subTemp6.End_Date__c = null;
        subTemp6.Type__c = 'TechReadWrite';
        subTemp6.Active__c = true;
        subTemp6.Asset__c = assetTemp6.Id;
        subTemp6.Buyer_ID__c = acctTemp.Id;
        subTemp6.Renewal_Notice_Current_Month__c = false;
        subTemp6.Renewal_Notice_Next_Month__c = false;
        subTemp6.Renewal_Notice_Last_Month__c = false;
        subTemp6.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp6.Renewal_Notice_Last_Month_Minus_1__c = false;
        //Can't set these fields directly since they are formula text fields:
        //Serial_Number__c = Asset__r.SerialNumber
        insert subTemp6;
        
        Contact_Subscription__c contSubTemp6 = new Contact_Subscription__c();
        //Role__c needs to be set to 'RenewalAdministrator', 'TechnicianAdministrator' or 'SalesRep'
        contSubTemp6.Role__c = 'RenewalAdministrator';
        contSubTemp6.Contact__c = contactTemp6.Id;
        contSubTemp6.Subscription__c = subTemp6.Id;
        contSubTemp6.Asset__c = assetTemp6.Id;
		contSubTemp6.Active_Subscription1__c = true;
        insert contSubTemp6;
        
        
        //TEST CASE#7: Subscription that has no contacts defined
        Subscription__c subTemp7 = new Subscription__c();
        //Type__c needs to be set to 'TechReadWrite'
        subTemp7.Start_Date__c = currDateTime.addMonths(-6);
        subTemp7.End_Date__c = currDateTime;
        subTemp7.Type__c = 'TechReadWrite';
        subTemp7.Active__c = true;
        subTemp7.Asset__c = assetTemp7.Id;
        subTemp7.Buyer_ID__c = acctTemp.Id;
        subTemp7.Renewal_Notice_Current_Month__c = false;
        subTemp7.Renewal_Notice_Next_Month__c = false;
        subTemp7.Renewal_Notice_Last_Month__c = false;
        subTemp7.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp7.Renewal_Notice_Last_Month_Minus_1__c = false;
        //Can't set these fields directly since they are formula text fields:
        //Serial_Number__c = Asset__r.SerialNumber
        insert subTemp7; //commented out since this insert causes the Process Builder Flow, "Contact IE Subscription Active" to fail since this has no contact-subscription records 4/9/18

        
        
        //------------------------------Start Test----------------------------------
        Test.startTest();
        
        Batch_IE_Subscription_Notification ieSubscriptNotif = new Batch_IE_Subscription_Notification();
        ID batchProcessId = Database.executeBatch(ieSubscriptNotif);
        
        Test.stopTest();
        //------------------------------End Test------------------------------------
        
        
        //------------------------------Verify Test Results---------------------------
		/* Comment all these verification queries out since the Process Builder Flow, "Contact IE Subscription Active" triggers and causes SOQL query limit exception 4/9/18*/
        Subscription__c subObj1 = [select Id, Name, Serial_Number__c, Start_Date__c, End_Date__c, Renewal_Notice_Current_Month__c, Renewal_Notice_Last_Month__c,Renewal_Notice_Last_Month_Minus_1__c, Renewal_Notice_Next_Month__c, Renewal_Notice_Next_Month_Plus_1__c from Subscription__c where Serial_Number__c = :assetTemp1.SerialNumber];
        System.debug(LoggingLevel.ERROR,'end date ' + subObj1.End_Date__c);
		System.assertEquals(true, subObj1.Renewal_Notice_Current_Month__c);
        System.assertEquals(false, subObj1.Renewal_Notice_Next_Month__c);
        System.assertEquals(false, subObj1.Renewal_Notice_Last_Month__c);
        System.assertEquals(false, subObj1.Renewal_Notice_Next_Month_Plus_1__c);
        System.assertEquals(false, subObj1.Renewal_Notice_Last_Month_Minus_1__c);
        
        Subscription__c subObj2 = [select Id, Name, Serial_Number__c, Start_Date__c, End_Date__c, Renewal_Notice_Current_Month__c, Renewal_Notice_Last_Month__c,Renewal_Notice_Last_Month_Minus_1__c, Renewal_Notice_Next_Month__c, Renewal_Notice_Next_Month_Plus_1__c from Subscription__c where Serial_Number__c = :assetTemp2.SerialNumber];
		System.assertEquals(false, subObj2.Renewal_Notice_Current_Month__c);
        System.assertEquals(false, subObj2.Renewal_Notice_Next_Month__c);
        System.assertEquals(true, subObj2.Renewal_Notice_Last_Month__c);
        System.assertEquals(false, subObj2.Renewal_Notice_Next_Month_Plus_1__c);
        System.assertEquals(false, subObj2.Renewal_Notice_Last_Month_Minus_1__c);
        
        Subscription__c subObj3 = [select Id, Name, Serial_Number__c, Start_Date__c, End_Date__c, Renewal_Notice_Current_Month__c, Renewal_Notice_Last_Month__c,Renewal_Notice_Last_Month_Minus_1__c, Renewal_Notice_Next_Month__c, Renewal_Notice_Next_Month_Plus_1__c from Subscription__c where Serial_Number__c = :assetTemp3.SerialNumber];
		System.assertEquals(false, subObj3.Renewal_Notice_Current_Month__c);
        System.assertEquals(true, subObj3.Renewal_Notice_Next_Month__c);
        System.assertEquals(false, subObj3.Renewal_Notice_Last_Month__c);
        System.assertEquals(false, subObj3.Renewal_Notice_Next_Month_Plus_1__c);
        System.assertEquals(false, subObj3.Renewal_Notice_Last_Month_Minus_1__c);
        
        Subscription__c subObj4 = [select Id, Name, Serial_Number__c, Start_Date__c, End_Date__c, Renewal_Notice_Current_Month__c, Renewal_Notice_Last_Month__c,Renewal_Notice_Last_Month_Minus_1__c, Renewal_Notice_Next_Month__c, Renewal_Notice_Next_Month_Plus_1__c from Subscription__c where Serial_Number__c = :assetTemp4.SerialNumber];
		System.assertEquals(false, subObj4.Renewal_Notice_Current_Month__c);
        System.assertEquals(false, subObj4.Renewal_Notice_Next_Month__c);
        System.assertEquals(false, subObj4.Renewal_Notice_Last_Month__c);
        System.assertEquals(false, subObj4.Renewal_Notice_Next_Month_Plus_1__c);
        System.assertEquals(true, subObj4.Renewal_Notice_Last_Month_Minus_1__c);
        
        Subscription__c subObj5 = [select Id, Name, Serial_Number__c, Start_Date__c, End_Date__c, Renewal_Notice_Current_Month__c, Renewal_Notice_Last_Month__c,Renewal_Notice_Last_Month_Minus_1__c, Renewal_Notice_Next_Month__c, Renewal_Notice_Next_Month_Plus_1__c from Subscription__c where Serial_Number__c = :assetTemp5.SerialNumber];
		System.assertEquals(false, subObj5.Renewal_Notice_Current_Month__c);
        System.assertEquals(false, subObj5.Renewal_Notice_Next_Month__c);
        System.assertEquals(false, subObj5.Renewal_Notice_Last_Month__c);
        System.assertEquals(true, subObj5.Renewal_Notice_Next_Month_Plus_1__c);
        System.assertEquals(false, subObj5.Renewal_Notice_Last_Month_Minus_1__c);
        
        Subscription__c subObj6 = [select Id, Name, Serial_Number__c, Start_Date__c, End_Date__c, Renewal_Notice_Current_Month__c, Renewal_Notice_Last_Month__c,Renewal_Notice_Last_Month_Minus_1__c, Renewal_Notice_Next_Month__c, Renewal_Notice_Next_Month_Plus_1__c from Subscription__c where Serial_Number__c = :assetTemp6.SerialNumber];
		System.assertEquals(false, subObj6.Renewal_Notice_Current_Month__c);
        System.assertEquals(false, subObj6.Renewal_Notice_Next_Month__c);
        System.assertEquals(false, subObj6.Renewal_Notice_Last_Month__c);
        System.assertEquals(false, subObj6.Renewal_Notice_Next_Month_Plus_1__c);
        System.assertEquals(false, subObj6.Renewal_Notice_Last_Month_Minus_1__c);

		// Had to comment out since it was giving me a "Too many SOQL queries limit" exception
        Subscription__c subObj7 = [select Id, Name, Serial_Number__c, Start_Date__c, End_Date__c, Renewal_Notice_Current_Month__c, Renewal_Notice_Last_Month__c,Renewal_Notice_Last_Month_Minus_1__c, Renewal_Notice_Next_Month__c, Renewal_Notice_Next_Month_Plus_1__c from Subscription__c where Serial_Number__c = :assetTemp7.SerialNumber];
		System.assertEquals(false, subObj7.Renewal_Notice_Current_Month__c);
        System.assertEquals(false, subObj7.Renewal_Notice_Next_Month__c);
        System.assertEquals(false, subObj7.Renewal_Notice_Last_Month__c);
        System.assertEquals(false, subObj7.Renewal_Notice_Next_Month_Plus_1__c);
        System.assertEquals(false, subObj7.Renewal_Notice_Last_Month_Minus_1__c);

    }
    
    
    static testMethod void testBatchExecution_NoSubscriptions() {
        //!!!!!!!!!!! Need to add this code snippet for AvaTax- AccountAddressTrigger to run successfully on Before Insert into the Account table !!!!!!!!!!!!!!!!!
    	AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c();
        ts1.AVA_SFCORE__Active_Setting__c = true;
        ts1.Name='Test Account';
        insert ts1;
        
        Test.startTest();
        
        Batch_IE_Subscription_Notification ieSubscriptNotif = new Batch_IE_Subscription_Notification();
        ID batchProcessId = Database.executeBatch(ieSubscriptNotif);
        
        Test.stopTest();
    }


	@isTest(SeeAllData=true) static void testBatchExecution_GWotGoSubscriptions() {
        //!!!!!!!!!!! Need to add this code snippet for AvaTax- AccountAddressTrigger to run successfully on Before Insert into the Account table !!!!!!!!!!!!!!!!!
    	AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c();
        ts1.AVA_SFCORE__Active_Setting__c = true;
        ts1.Name='Test Account';
        insert ts1;
        
        
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

        Order__c orderTemp1 = null;
        orderTemp1 = new Order__c();
        orderTemp1.Job_Name__c = 'Test Order Job Name 1';
        insert orderTemp1;
        
        
		// Create GWotGo Asset Record for the Dummy Asset
        Asset relatedAsset1 = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-075', Parent_Asset__c = dummyUnitAsset.Id, Tag__c='GW Order Tag');
        relatedAsset1.Product2Id = prodTemp3.Id;
		relatedAsset1.Order__c = orderTemp1.Id;
        relatedAsset1.SIM_Card_Active__c = true;
        relatedAsset1.SIM_Card_ICCID__c = '89011704258018735310';
		relatedAsset1.GWotGo__c = true;
		relatedAsset1.Commissioned__c = true;
		relatedAsset1.ResetSuccessful__c = 'None';
		relatedAsset1.MAC_Address__c = '000000000001';
        insert relatedAsset1;

        
        // Create Contact record
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
        
        
        // Create Subscription__c, Contact_Subscription__c records
        Datetime currDateTime = Datetime.now();
        
        //TEST CASE#1: Subscription that is due in the current month
        Subscription__c subTemp1 = new Subscription__c();
        subTemp1.Start_Date__c = currDateTime.addMonths(-6);
        subTemp1.End_Date__c = currDateTime;
        subTemp1.Type__c = 'TechReadWrite';
        subTemp1.Active__c = true;
        subTemp1.Asset__c = dummyUnitAsset.Id;
		subTemp1.GWotGoAsset__c = relatedAsset1.Id;
		subTemp1.Connectivity_Type__c = 'Cellular';
        subTemp1.Buyer_ID__c = acctTemp.Id;
        subTemp1.Renewal_Notice_Current_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month__c = false;
        subTemp1.Renewal_Notice_Last_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp1.Renewal_Notice_Last_Month_Minus_1__c = false;
        //Can't set these fields directly since they are formula text fields:
        //Serial_Number__c = Asset__r.SerialNumber
        insert subTemp1;
        
        Contact_Subscription__c contSubTemp1 = new Contact_Subscription__c();
        contSubTemp1.Role__c = 'TechnicianAdministrator';
        contSubTemp1.Contact__c = contactTemp1.Id;
        contSubTemp1.Subscription__c = subTemp1.Id;
        contSubTemp1.Asset__c = dummyUnitAsset.Id;
		contSubTemp1.GWotGoAsset__c = relatedAsset1.Id;
		contSubTemp1.GWotGoPermAssoc__c = true;
        insert contSubTemp1;
        
        
        
        //------------------------------Start Test----------------------------------
        Test.startTest();
        
        Batch_IE_Subscription_Notification ieSubscriptNotif = new Batch_IE_Subscription_Notification();
        ID batchProcessId = Database.executeBatch(ieSubscriptNotif);
        
        Test.stopTest();
        //------------------------------End Test------------------------------------
        
        
        //------------------------------Verify Test Results---------------------------
        Subscription__c subObj1 = [select Id, Name, Serial_Number__c, Start_Date__c, End_Date__c, Renewal_Notice_Current_Month__c, Renewal_Notice_Last_Month__c,Renewal_Notice_Last_Month_Minus_1__c, Renewal_Notice_Next_Month__c, Renewal_Notice_Next_Month_Plus_1__c from Subscription__c where Id = :subTemp1.Id];
		System.assertEquals(true, subObj1.Renewal_Notice_Current_Month__c);
        System.assertEquals(false, subObj1.Renewal_Notice_Next_Month__c);
        System.assertEquals(false, subObj1.Renewal_Notice_Last_Month__c);
        System.assertEquals(false, subObj1.Renewal_Notice_Next_Month_Plus_1__c);
        System.assertEquals(false, subObj1.Renewal_Notice_Last_Month_Minus_1__c);
                
    }

    
    
    static testMethod void testBatchExecution_ContactWithMultipleSubscriptions() {
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
        insert orderTemp1;
        
        Asset assetTemp1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test1', Tag__c='Order Tag 1');
        assetTemp1.Product2Id = prodTemp1.Id;
        assetTemp1.Order__c = orderTemp1.Id;
        insert assetTemp1;
        
        Asset assetTemp2 = new Asset(Name = 'Asset Test2', AccountId = acctTemp.Id, SerialNumber='SN123Test2', Tag__c='Order Tag 2');
        assetTemp2.Product2Id = prodTemp1.Id;
        assetTemp2.Order__c = orderTemp1.Id;
        insert assetTemp2;

        
        // Create Contact record
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
        
        
        // Create Subscription__c, Contact_Subscription__c records
        Datetime currDateTime = Datetime.now();
        
        //TEST CASE#1: Subscription that is due in the current month
        Subscription__c subTemp1 = new Subscription__c();
        //Type__c needs to be set to 'TechReadWrite'
        subTemp1.Start_Date__c = currDateTime.addMonths(-6);
        subTemp1.End_Date__c = currDateTime;
        subTemp1.Type__c = 'TechReadWrite';
        subTemp1.Active__c = true;
        subTemp1.Asset__c = assetTemp1.Id;
        subTemp1.Buyer_ID__c = acctTemp.Id;
        subTemp1.Renewal_Notice_Current_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month__c = false;
        subTemp1.Renewal_Notice_Last_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp1.Renewal_Notice_Last_Month_Minus_1__c = false;
        //Can't set these fields directly since they are formula text fields:
        //Serial_Number__c = Asset__r.SerialNumber
        insert subTemp1;
        
        Contact_Subscription__c contSubTemp1 = new Contact_Subscription__c();
        //Role__c needs to be set to 'RenewalAdministrator', 'TechnicianAdministrator' or 'SalesRep'
        contSubTemp1.Role__c = 'RenewalAdministrator';
        contSubTemp1.Contact__c = contactTemp1.Id;
        contSubTemp1.Subscription__c = subTemp1.Id;
        contSubTemp1.Asset__c = assetTemp1.Id;
        insert contSubTemp1;
        
        
        //TEST CASE#2: Subscription that was due in the last month
        Subscription__c subTemp2 = new Subscription__c();
        //Type__c needs to be set to 'TechReadWrite'
        subTemp2.Start_Date__c = currDateTime.addMonths(-6);
        subTemp2.End_Date__c = currDateTime.addMonths(-1);
        subTemp2.Type__c = 'TechReadWrite';
        subTemp2.Active__c = true;
        subTemp2.Asset__c = assetTemp2.Id;
        subTemp2.Buyer_ID__c = acctTemp.Id;
        subTemp2.Renewal_Notice_Current_Month__c = false;
        subTemp2.Renewal_Notice_Next_Month__c = false;
        subTemp2.Renewal_Notice_Last_Month__c = false;
        subTemp2.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp2.Renewal_Notice_Last_Month_Minus_1__c = false;
        //Can't set these fields directly since they are formula text fields:
        //Serial_Number__c = Asset__r.SerialNumber
        insert subTemp2;
        
        Contact_Subscription__c contSubTemp2 = new Contact_Subscription__c();
        //Role__c needs to be set to 'RenewalAdministrator', 'TechnicianAdministrator' or 'SalesRep'
        contSubTemp2.Role__c = 'SalesRep';
        contSubTemp2.Contact__c = contactTemp1.Id;
        contSubTemp2.Subscription__c = subTemp2.Id;
        contSubTemp2.Asset__c = assetTemp2.Id;
        insert contSubTemp2;

        
        
        //------------------------------Start Test----------------------------------
        Test.startTest();
        
        Batch_IE_Subscription_Notification ieSubscriptNotif = new Batch_IE_Subscription_Notification();
        ID batchProcessId = Database.executeBatch(ieSubscriptNotif);
        
        Test.stopTest();
        //------------------------------End Test------------------------------------
        
        
        //------------------------------Verify Test Results---------------------------
        Subscription__c subObj1 = [select Id, Name, Serial_Number__c, Start_Date__c, End_Date__c, Renewal_Notice_Current_Month__c, Renewal_Notice_Last_Month__c,Renewal_Notice_Last_Month_Minus_1__c, Renewal_Notice_Next_Month__c, Renewal_Notice_Next_Month_Plus_1__c from Subscription__c where Serial_Number__c = :assetTemp1.SerialNumber];
		System.assertEquals(true, subObj1.Renewal_Notice_Current_Month__c);
        System.assertEquals(false, subObj1.Renewal_Notice_Next_Month__c);
        System.assertEquals(false, subObj1.Renewal_Notice_Last_Month__c);
        System.assertEquals(false, subObj1.Renewal_Notice_Next_Month_Plus_1__c);
        System.assertEquals(false, subObj1.Renewal_Notice_Last_Month_Minus_1__c);
        
        Subscription__c subObj2 = [select Id, Name, Serial_Number__c, Start_Date__c, End_Date__c, Renewal_Notice_Current_Month__c, Renewal_Notice_Last_Month__c,Renewal_Notice_Last_Month_Minus_1__c, Renewal_Notice_Next_Month__c, Renewal_Notice_Next_Month_Plus_1__c from Subscription__c where Serial_Number__c = :assetTemp2.SerialNumber];
		System.assertEquals(false, subObj2.Renewal_Notice_Current_Month__c);
        System.assertEquals(false, subObj2.Renewal_Notice_Next_Month__c);
        System.assertEquals(true, subObj2.Renewal_Notice_Last_Month__c);
        System.assertEquals(false, subObj2.Renewal_Notice_Next_Month_Plus_1__c);
        System.assertEquals(false, subObj2.Renewal_Notice_Last_Month_Minus_1__c);
        
    }
    
    
    static testMethod void testBatchExecution_SubscriptionsNotDue() {
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
        insert orderTemp1;
        
        Asset assetTemp1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test1', Tag__c='Order Tag 1');
        assetTemp1.Product2Id = prodTemp1.Id;
        assetTemp1.Order__c = orderTemp1.Id;
        insert assetTemp1;
        
        Asset assetTemp2 = new Asset(Name = 'Asset Test2', AccountId = acctTemp.Id, SerialNumber='SN123Test2', Tag__c='Order Tag 2');
        assetTemp2.Product2Id = prodTemp1.Id;
        assetTemp2.Order__c = orderTemp1.Id;
        insert assetTemp2;

        
        // Create Contact record
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
        
        
        // Create Subscription__c, Contact_Subscription__c records
        Datetime currDateTime = Datetime.now();
        
        //TEST CASE#1: Subscription whose end date is outside the range
        Subscription__c subTemp1 = new Subscription__c();
        //Type__c needs to be set to 'TechReadWrite'
        subTemp1.Start_Date__c = currDateTime.addMonths(-6);
        subTemp1.End_Date__c = currDateTime.addMonths(-3);
        subTemp1.Type__c = 'TechReadWrite';
        subTemp1.Active__c = true;
        subTemp1.Asset__c = assetTemp1.Id;
        subTemp1.Buyer_ID__c = acctTemp.Id;
        subTemp1.Renewal_Notice_Current_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month__c = false;
        subTemp1.Renewal_Notice_Last_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp1.Renewal_Notice_Last_Month_Minus_1__c = false;
        //Can't set these fields directly since they are formula text fields:
        //Serial_Number__c = Asset__r.SerialNumber
        insert subTemp1;
        
        Contact_Subscription__c contSubTemp1 = new Contact_Subscription__c();
        //Role__c needs to be set to 'RenewalAdministrator', 'TechnicianAdministrator' or 'SalesRep'
        contSubTemp1.Role__c = 'RenewalAdministrator';
        contSubTemp1.Contact__c = contactTemp1.Id;
        contSubTemp1.Subscription__c = subTemp1.Id;
        contSubTemp1.Asset__c = assetTemp1.Id;
        insert contSubTemp1;
        
        
        //TEST CASE#2: Subscription whose end date is outside the range
        Subscription__c subTemp2 = new Subscription__c();
        //Type__c needs to be set to 'TechReadWrite'
        subTemp2.Start_Date__c = currDateTime.addMonths(-6);
        subTemp2.End_Date__c = currDateTime.addMonths(3);
        subTemp2.Type__c = 'TechReadWrite';
        subTemp2.Active__c = true;
        subTemp2.Asset__c = assetTemp2.Id;
        subTemp2.Buyer_ID__c = acctTemp.Id;
        subTemp2.Renewal_Notice_Current_Month__c = false;
        subTemp2.Renewal_Notice_Next_Month__c = false;
        subTemp2.Renewal_Notice_Last_Month__c = false;
        subTemp2.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp2.Renewal_Notice_Last_Month_Minus_1__c = false;
        //Can't set these fields directly since they are formula text fields:
        //Serial_Number__c = Asset__r.SerialNumber
        insert subTemp2;
        
        Contact_Subscription__c contSubTemp2 = new Contact_Subscription__c();
        //Role__c needs to be set to 'RenewalAdministrator', 'TechnicianAdministrator' or 'SalesRep'
        contSubTemp2.Role__c = 'RenewalAdministrator';
        contSubTemp2.Contact__c = contactTemp1.Id;
        contSubTemp2.Subscription__c = subTemp2.Id;
        contSubTemp2.Asset__c = assetTemp2.Id;
        insert contSubTemp2;

        
        
        //------------------------------Start Test----------------------------------
        Test.startTest();
        
        Batch_IE_Subscription_Notification ieSubscriptNotif = new Batch_IE_Subscription_Notification();
        ID batchProcessId = Database.executeBatch(ieSubscriptNotif);
        
        Test.stopTest();
        //------------------------------End Test------------------------------------
        
        
        //------------------------------Verify Test Results---------------------------
        Subscription__c subObj1 = [select Id, Name, Serial_Number__c, Start_Date__c, End_Date__c, Renewal_Notice_Current_Month__c, Renewal_Notice_Last_Month__c,Renewal_Notice_Last_Month_Minus_1__c, Renewal_Notice_Next_Month__c, Renewal_Notice_Next_Month_Plus_1__c from Subscription__c where Serial_Number__c = :assetTemp1.SerialNumber];
		System.assertEquals(false, subObj1.Renewal_Notice_Current_Month__c);
        System.assertEquals(false, subObj1.Renewal_Notice_Next_Month__c);
        System.assertEquals(false, subObj1.Renewal_Notice_Last_Month__c);
        System.assertEquals(false, subObj1.Renewal_Notice_Next_Month_Plus_1__c);
        System.assertEquals(false, subObj1.Renewal_Notice_Last_Month_Minus_1__c);
        
        Subscription__c subObj2 = [select Id, Name, Serial_Number__c, Start_Date__c, End_Date__c, Renewal_Notice_Current_Month__c, Renewal_Notice_Last_Month__c,Renewal_Notice_Last_Month_Minus_1__c, Renewal_Notice_Next_Month__c, Renewal_Notice_Next_Month_Plus_1__c from Subscription__c where Serial_Number__c = :assetTemp2.SerialNumber];
		System.assertEquals(false, subObj2.Renewal_Notice_Current_Month__c);
        System.assertEquals(false, subObj2.Renewal_Notice_Next_Month__c);
        System.assertEquals(false, subObj2.Renewal_Notice_Last_Month__c);
        System.assertEquals(false, subObj2.Renewal_Notice_Next_Month_Plus_1__c);
        System.assertEquals(false, subObj2.Renewal_Notice_Last_Month_Minus_1__c);
        
    }
    
    
    static testMethod void testBatchExecution_ExceptionThrown() {
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
        insert orderTemp1;
        
        Asset assetTemp1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test1', Tag__c='Order Tag 1');
        assetTemp1.Product2Id = prodTemp1.Id;
        assetTemp1.Order__c = orderTemp1.Id;
        insert assetTemp1;
        
        
        // Create Contact record
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
        
        
        // Create Subscription__c, Contact_Subscription__c records
        Datetime currDateTime = Datetime.now();
        
        //TEST CASE#1: Subscription that is due in the current month
        Subscription__c subTemp1 = new Subscription__c();
        //Type__c needs to be set to 'TechReadWrite'
        subTemp1.Start_Date__c = currDateTime.addMonths(-6);
        subTemp1.End_Date__c = currDateTime;
        subTemp1.Type__c = 'TechReadWrite';
        subTemp1.Active__c = true;
        subTemp1.Asset__c = assetTemp1.Id;
        subTemp1.Buyer_ID__c = acctTemp.Id;
        subTemp1.Renewal_Notice_Current_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month__c = false;
        subTemp1.Renewal_Notice_Last_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp1.Renewal_Notice_Last_Month_Minus_1__c = false;
        //Can't set these fields directly since they are formula text fields:
        //Serial_Number__c = Asset__r.SerialNumber
        insert subTemp1;
        
        Contact_Subscription__c contSubTemp1 = new Contact_Subscription__c();
        //Role__c needs to be set to 'RenewalAdministrator', 'TechnicianAdministrator' or 'SalesRep'
        contSubTemp1.Role__c = 'RenewalAdministrator';
        contSubTemp1.Contact__c = contactTemp1.Id;
        contSubTemp1.Subscription__c = subTemp1.Id;
        contSubTemp1.Asset__c = assetTemp1.Id;
        insert contSubTemp1;
        
        
        //------------------------------Start Test----------------------------------
        Test.startTest();
        
        //Delete the asset record to force an exception to be thrown
        //delete assetTemp1;
        //
        //Mark the asset record with a custom error message to prevent any DML operation from occurring
        //assetTemp1.Id.addError('Bad');
        
        Batch_IE_Subscription_Notification ieSubscriptNotif = new Batch_IE_Subscription_Notification();
        // Force an exception to be thrown
        ieSubscriptNotif.crashTest = true;
        
        ID batchProcessId = Database.executeBatch(ieSubscriptNotif);
        
        Test.stopTest();
        //------------------------------End Test------------------------------------
        
        
        //------------------------------Verify Test Results---------------------------
        Integration_Error__c errObj = [select Error_Description__c, Integration_Object__c, Integration_Point__c, Request_Data__c from Integration_Error__c where Integration_Object__c = 'Subscription__c'];
        System.assert(errObj != null);
        
    }
    
    
    /*
    static testMethod void test_SubscriptionUpdateTrigger() {
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
        insert orderTemp1;
        
        Asset assetTemp1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test1', Tag__c='Order Tag 1');
        assetTemp1.Product2Id = prodTemp1.Id;
        assetTemp1.Order__c = orderTemp1.Id;
        insert assetTemp1;
        
        
        // Create Contact record
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
        
        
        // Create Subscription__c, Contact_Subscription__c records
        Datetime currDateTime = Datetime.now();
        
        //TEST CASE#1: Subscription that is due in the current month
        Subscription__c subTemp1 = new Subscription__c();
        //Type__c needs to be set to 'TechReadWrite'
        subTemp1.Start_Date__c = currDateTime.addMonths(-6);
        subTemp1.End_Date__c = currDateTime;
        subTemp1.Type__c = 'TechReadWrite';
        subTemp1.Active__c = true;
        subTemp1.Asset__c = assetTemp1.Id;
        subTemp1.Buyer_ID__c = acctTemp.Id;
        subTemp1.Renewal_Notice_Current_Month__c = true;
        subTemp1.Renewal_Notice_Next_Month__c = false;
        subTemp1.Renewal_Notice_Last_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp1.Renewal_Notice_Last_Month_Minus_1__c = false;
        //Can't set these fields directly since they are formula text fields:
        //Serial_Number__c = Asset__r.SerialNumber
        insert subTemp1;
        
        Contact_Subscription__c contSubTemp1 = new Contact_Subscription__c();
        //Role__c needs to be set to 'TechnicianAdministrator' or 'CustomerAdministrator'
        contSubTemp1.Role__c = 'CustomerAdministrator';
        contSubTemp1.Contact__c = contactTemp1.Id;
        contSubTemp1.Subscription__c = subTemp1.Id;
        contSubTemp1.Asset__c = assetTemp1.Id;
        insert contSubTemp1;
        
        
        //------------------------------Start Test----------------------------------
        Test.startTest();
        
        Subscription__c s1 = [select Id, Name, Start_Date__c, End_Date__c, Renewal_Notice_Current_Month__c, Renewal_Notice_Last_Month__c,Renewal_Notice_Last_Month_Minus_1__c, Renewal_Notice_Next_Month__c, Renewal_Notice_Next_Month_Plus_1__c from Subscription__c where Id = :subTemp1.Id];
		s1.End_Date__c = DateTime.newinstance(currDateTime.year()+1, 08, 03); //new date in the future
		update s1;
        
        Test.stopTest();
        //------------------------------End Test------------------------------------
        
        
        //------------------------------Verify Test Results---------------------------
        Subscription__c s2 = [select Id, Name, Start_Date__c, End_Date__c, Renewal_Notice_Current_Month__c, Renewal_Notice_Last_Month__c,Renewal_Notice_Last_Month_Minus_1__c, Renewal_Notice_Next_Month__c, Renewal_Notice_Next_Month_Plus_1__c from Subscription__c where Id = :subTemp1.Id];
        System.assertEquals(false, s2.Renewal_Notice_Current_Month__c);
    }
    */

    
    static testMethod void test_SubscriptionInsertTrigger() {
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
        insert orderTemp1;
        
        Asset assetTemp1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test1', Tag__c='Order Tag 1');
        assetTemp1.Product2Id = prodTemp1.Id;
        assetTemp1.Order__c = orderTemp1.Id;
        insert assetTemp1;
        
        
        // Create Contact record
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
        
        
        // Create Subscription__c, Contact_Subscription__c records
        Datetime currDateTime = Datetime.now();
        
        //------------------------------Start Test----------------------------------
        Test.startTest();

        //test case 1
        Subscription__c subTemp1 = new Subscription__c();
        //Type__c needs to be set to 'TechReadWrite'
        subTemp1.Start_Date__c = currDateTime.addMonths(-6);
        subTemp1.End_Date__c = currDateTime;
        subTemp1.Type__c = 'TechReadWrite';
        subTemp1.Active__c = true;
        subTemp1.Asset__c = assetTemp1.Id;
        subTemp1.Buyer_ID__c = acctTemp.Id;
        subTemp1.Renewal_Notice_Current_Month__c = true;
        subTemp1.Renewal_Notice_Next_Month__c = false;
        subTemp1.Renewal_Notice_Last_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp1.Renewal_Notice_Last_Month_Minus_1__c = false;
        subTemp1.IE_Subscription__c = true;
        subTemp1.IE_Sync_Status__c = null;
        subTemp1.Record_Usage__c = null;
        //Can't set these fields directly since they are formula text fields:
        //Serial_Number__c = Asset__r.SerialNumber
        insert subTemp1;
        
        Contact_Subscription__c contSubTemp1 = new Contact_Subscription__c();
        //Role__c needs to be set to 'RenewalAdministrator', 'TechnicianAdministrator' or 'SalesRep'
        contSubTemp1.Role__c = 'SalesRep';
        contSubTemp1.Contact__c = contactTemp1.Id;
        contSubTemp1.Subscription__c = subTemp1.Id;
        contSubTemp1.Asset__c = assetTemp1.Id;
        insert contSubTemp1;
        
        
        //test case 2
        Subscription__c subTemp2 = new Subscription__c();
        //Type__c needs to be set to 'TechReadWrite'
        subTemp2.Start_Date__c = currDateTime.addMonths(-6);
        subTemp2.End_Date__c = currDateTime;
        subTemp2.Type__c = 'TechReadWrite';
        subTemp2.Active__c = true;
        subTemp2.Asset__c = assetTemp1.Id;
        subTemp2.Buyer_ID__c = acctTemp.Id;
        subTemp2.Renewal_Notice_Current_Month__c = true;
        subTemp2.Renewal_Notice_Next_Month__c = false;
        subTemp2.Renewal_Notice_Last_Month__c = false;
        subTemp2.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp2.Renewal_Notice_Last_Month_Minus_1__c = false;
        subTemp2.IE_Subscription__c = true;
        subTemp2.IE_Sync_Status__c = null;
        subTemp2.Record_Usage__c = 'Test';
        //Can't set these fields directly since they are formula text fields:
        //Serial_Number__c = Asset__r.SerialNumber
        insert subTemp2;
        
        Contact_Subscription__c contSubTemp2 = new Contact_Subscription__c();
        //Role__c needs to be set to 'RenewalAdministrator', 'TechnicianAdministrator' or 'SalesRep'
        contSubTemp2.Role__c = 'RenewalAdministrator';
        contSubTemp2.Contact__c = contactTemp1.Id;
        contSubTemp2.Subscription__c = subTemp2.Id;
        contSubTemp2.Asset__c = assetTemp1.Id;
        insert contSubTemp2;

        Test.stopTest();
        //------------------------------End Test------------------------------------
        
        
        //------------------------------Verify Test Results---------------------------
        Subscription__c s1 = [select Id, Name, Start_Date__c, End_Date__c, Renewal_Notice_Current_Month__c, Renewal_Notice_Last_Month__c,Renewal_Notice_Last_Month_Minus_1__c, Renewal_Notice_Next_Month__c, Renewal_Notice_Next_Month_Plus_1__c from Subscription__c where Id = :subTemp1.Id];
        System.assert(s1 != null);
        
        Subscription__c s2 = [select Id, Name, Start_Date__c, End_Date__c, Renewal_Notice_Current_Month__c, Renewal_Notice_Last_Month__c,Renewal_Notice_Last_Month_Minus_1__c, Renewal_Notice_Next_Month__c, Renewal_Notice_Next_Month_Plus_1__c from Subscription__c where Id = :subTemp2.Id];
        System.assert(s2 != null);
    }

    
    static testMethod void test_SubscriptionDeleteTrigger() {
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
        insert orderTemp1;
        
        Asset assetTemp1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test1', Tag__c='Order Tag 1');
        assetTemp1.Product2Id = prodTemp1.Id;
        assetTemp1.Order__c = orderTemp1.Id;
        insert assetTemp1;
        
        
        // Create Contact record
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
        
        
        // Create Subscription__c, Contact_Subscription__c records
        Datetime currDateTime = Datetime.now();
        
        //TEST CASE#1: Subscription that is due in the current month
        Subscription__c subTemp1 = new Subscription__c();
        //Type__c needs to be set to 'TechReadWrite'
        subTemp1.Start_Date__c = currDateTime.addMonths(-6);
        subTemp1.End_Date__c = currDateTime;
        subTemp1.Type__c = 'TechReadWrite';
        subTemp1.Active__c = true;
        subTemp1.Asset__c = assetTemp1.Id;
        subTemp1.Buyer_ID__c = acctTemp.Id;
        subTemp1.Renewal_Notice_Current_Month__c = true;
        subTemp1.Renewal_Notice_Next_Month__c = false;
        subTemp1.Renewal_Notice_Last_Month__c = false;
        subTemp1.Renewal_Notice_Next_Month_Plus_1__c = false;
        subTemp1.Renewal_Notice_Last_Month_Minus_1__c = false;
        //Can't set these fields directly since they are formula text fields:
        //Serial_Number__c = Asset__r.SerialNumber
        insert subTemp1;
        
        Contact_Subscription__c contSubTemp1 = new Contact_Subscription__c();
        //Role__c needs to be set to 'RenewalAdministrator', 'TechnicianAdministrator' or 'SalesRep'
        contSubTemp1.Role__c = 'RenewalAdministrator';
        contSubTemp1.Contact__c = contactTemp1.Id;
        contSubTemp1.Subscription__c = subTemp1.Id;
        contSubTemp1.Asset__c = assetTemp1.Id;
        insert contSubTemp1;
        
        
        //------------------------------Start Test----------------------------------
        Test.startTest();
        
        Subscription__c s1 = [select Id, Name, Start_Date__c, End_Date__c, Renewal_Notice_Current_Month__c, Renewal_Notice_Last_Month__c,Renewal_Notice_Last_Month_Minus_1__c, Renewal_Notice_Next_Month__c, Renewal_Notice_Next_Month_Plus_1__c from Subscription__c where Id = :subTemp1.Id];
		delete s1;
        
        Test.stopTest();
        //------------------------------End Test------------------------------------
        
        
        //------------------------------Verify Test Results---------------------------
        Subscription__c s2 = null;
        try {
            s2 = [select Id, Name, Start_Date__c, End_Date__c, Renewal_Notice_Current_Month__c, Renewal_Notice_Last_Month__c,Renewal_Notice_Last_Month_Minus_1__c, Renewal_Notice_Next_Month__c, Renewal_Notice_Next_Month_Plus_1__c from Subscription__c where Id = :subTemp1.Id];
        }
        catch (Exception e) {
            System.assertEquals(null, s2);
        }
        
    }

    
    static testmethod void testBatch_IE_Subscription_Notification_Sched() {
      Test.startTest();
      //define the CRON Expression, format: Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
      String CRON_EXP;
      CRON_EXP = '0 0 2 * * ?'; //class runs every day at 2am
      Batch_IE_Subscription_Notification_Sched s = new Batch_IE_Subscription_Notification_Sched();
      SchedulableContext sc;
      s.execute(sc);
      System.schedule('test-Batch_IE_Subscription_Notification_Sched', CRON_EXP, s);
      Test.stopTest();
   }
}