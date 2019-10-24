@isTest
private class Batch_IE_DeactivateExpiredSubscrip_Test {

    static testMethod void testBatchExecution_ExpiredEndDates() {
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


        // Create Contact records
        Contact contactTemp1 = null;
        Contact contactTemp2 = null;
        Contact contactTemp3 = null;
        Contact contactTemp4 = null;
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


        // Create Subscription__c, Contact_Subscription__c records
        Date currentDate = Date.today();
        Datetime currDateTime = Datetime.now();
        
        //TEST CASE#1: Subscription whose end date < current date (ie, expired)
        Subscription__c subTemp1 = new Subscription__c();
        subTemp1.Start_Date__c = currDateTime.addMonths(-6);
        subTemp1.End_Date__c = currDateTime.addMonths(-1);
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
        
        
        //TEST CASE#2: Subscription whose end date < current date (ie, expired)
        Subscription__c subTemp2 = new Subscription__c();
        subTemp2.Start_Date__c = currDateTime.addMonths(-10);
        subTemp2.End_Date__c = currDateTime.addMonths(-2);
        subTemp2.Type__c = 'TechReadWrite';
        subTemp2.Active__c = true;
        subTemp2.IE_Subscription__c = true;
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
        //Role__c needs to be set to 'TechnicianAdministrator' or 'CustomerAdministrator'
        contSubTemp2.Role__c = 'CustomerAdministrator';
        contSubTemp2.Contact__c = contactTemp2.Id;
        contSubTemp2.Subscription__c = subTemp2.Id;
        contSubTemp2.Asset__c = assetTemp2.Id;
        insert contSubTemp2;


        //TEST CASE#3: Subscription whose end date >= current date (ie, not expired)
        Subscription__c subTemp3 = new Subscription__c();
        subTemp3.Start_Date__c = currDateTime.addMonths(-6);
        subTemp3.End_Date__c = currDateTime.addMonths(1);
        subTemp3.Type__c = 'TechReadWrite';
        subTemp3.Active__c = true;
        subTemp3.IE_Subscription__c = true;
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
        //Role__c needs to be set to 'TechnicianAdministrator' or 'CustomerAdministrator'
        contSubTemp3.Role__c = 'CustomerAdministrator';
        contSubTemp3.Contact__c = contactTemp3.Id;
        contSubTemp3.Subscription__c = subTemp3.Id;
        contSubTemp3.Asset__c = assetTemp3.Id;
        insert contSubTemp3;


        //TEST CASE#4: Subscription whose end date < current date and it already has an IE ID (ie, expired)
        Subscription__c subTemp4 = new Subscription__c();
        subTemp4.Start_Date__c = currDateTime.addMonths(-6);
        subTemp4.End_Date__c = currDateTime.addMonths(-2);
        subTemp4.Type__c = 'TechReadWrite';
        subTemp4.Active__c = true;
        subTemp4.IE_Subscription__c = true;
        subTemp4.IE_ID__c = '999';
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
        //Role__c needs to be set to 'TechnicianAdministrator' or 'CustomerAdministrator'
        contSubTemp4.Role__c = 'CustomerAdministrator';
        contSubTemp4.Contact__c = contactTemp4.Id;
        contSubTemp4.Subscription__c = subTemp4.Id;
        contSubTemp4.Asset__c = assetTemp4.Id;
        insert contSubTemp4;




        //------------------------------Start Test----------------------------------
        Test.startTest();
        
        Batch_IE_DeactivateExpiredSubscriptions ieSubscriptExp = new Batch_IE_DeactivateExpiredSubscriptions();
        ID batchProcessId = Database.executeBatch(ieSubscriptExp);
        
        Test.stopTest();
        //------------------------------End Test------------------------------------
        
        
        //------------------------------Verify Test Results---------------------------
        Subscription__c subObj1 = [select Id, Name, Serial_Number__c, Start_Date__c, End_Date__c, Active__c, TriggerInvokedByAPI__c, IE_Sync_Status__c from Subscription__c where Id =: subTemp1.Id];
        //System.debug(LoggingLevel.ERROR,'end date ' + subObj1.End_Date__c);
        System.assertEquals(false, subObj1.Active__c);
        System.assertEquals(true, subObj1.TriggerInvokedByAPI__c);
        System.assertEquals('Pending', subObj1.IE_Sync_Status__c);
        
        Subscription__c subObj2 = [select Id, Name, Serial_Number__c, Start_Date__c, End_Date__c, Active__c, TriggerInvokedByAPI__c, IE_Sync_Status__c from Subscription__c where Id =: subTemp2.Id];
        System.assertEquals(false, subObj2.Active__c);
        System.assertEquals(true, subObj2.TriggerInvokedByAPI__c);
        System.assertEquals('Pending', subObj2.IE_Sync_Status__c);
        
        Subscription__c subObj3 = [select Id, Name, Serial_Number__c, Start_Date__c, End_Date__c, Active__c, TriggerInvokedByAPI__c, IE_Sync_Status__c from Subscription__c where Id =: subTemp3.Id];
        System.assertEquals(true, subObj3.Active__c);
        System.assertEquals(true, subObj3.TriggerInvokedByAPI__c);
        System.assertEquals('Pending', subObj3.IE_Sync_Status__c);

        Subscription__c subObj4 = [select Id, Name, Serial_Number__c, Start_Date__c, End_Date__c, Active__c, TriggerInvokedByAPI__c, IE_Sync_Status__c from Subscription__c where Id =: subTemp4.Id];
        System.assertEquals(false, subObj4.Active__c);
        System.assertEquals(true, subObj4.TriggerInvokedByAPI__c);
        System.assertEquals('Pending', subObj4.IE_Sync_Status__c);

    }


    static testmethod void testBatch_IE_DeactivateExpiredSubscrip_Sched() {
      Test.startTest();
      //define the CRON Expression, format: Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
      String CRON_EXP;
      CRON_EXP = '0 0 3 * * ?'; //class runs every day at 3am
      Batch_IE_DeactivateExpiredSubscrip_Sched s = new Batch_IE_DeactivateExpiredSubscrip_Sched();
      SchedulableContext sc;
      s.execute(sc);
      System.schedule('test-Batch_IE_DeactivateExpiredSubscrip_Sched', CRON_EXP, s);
      Test.stopTest();
   }
}