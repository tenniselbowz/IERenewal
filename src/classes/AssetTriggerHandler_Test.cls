@isTest
private class AssetTriggerHandler_Test {

    static testMethod void testProcessGatewayAsset() {
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
        prodTemp3.Product_Group__c = 'IE Gateway';
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
        prodTemp4.Product_Group__c = 'IE EMM';
        insert prodTemp4;
        
        
        Test.startTest();

        // Create Parent Asset records
        Asset parentAsset1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test1', Tag__c='Order Tag 1');
        parentAsset1.Product2Id = prodTemp1.Id;
        parentAsset1.Order__c = orderTemp1.Id;
        //parentAsset1.IE_Asset__c = true;
        insert parentAsset1;

        Asset parentAsset2 = new Asset(Name = 'Asset Test2', AccountId = acctTemp.Id, SerialNumber='SN123Test2', Tag__c='Order Tag 2');
        parentAsset2.Product2Id = prodTemp2.Id;
        parentAsset2.Order__c = orderTemp1.Id;
        //parentAsset2.IE_Asset__c = true;
        insert parentAsset2;


        // Create Related Asset Records for each Parent Asset
        Asset relatedAsset1 = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-075', Parent_Asset__c = parentAsset1.Id);
        relatedAsset1.Product2Id = prodTemp3.Id;
        relatedAsset1.SIM_Card_Active__c = true;
        relatedAsset1.SIM_Card_ICCID__c = '89011704258018735310';
        //relatedAsset1.Status = 'Obsolete';
        insert relatedAsset1;

        Asset relatedAsset2 = new Asset(Name = 'Intelligent Equipment Energy Management Module', AccountId = acctTemp.Id, SerialNumber = 'MESF04115', Parent_Asset__c = parentAsset1.Id);
        relatedAsset2.Product2Id = prodTemp4.Id;
        relatedAsset2.SIM_Card_Active__c = true;
        insert relatedAsset2;

        Asset relatedAsset3 = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-075', Parent_Asset__c = parentAsset2.Id);
        relatedAsset3.Product2Id = prodTemp3.Id;
        relatedAsset3.SIM_Card_Active__c = true;
        relatedAsset3.SIM_Card_ICCID__c = 'some text89011704258018735310some text';
        //relatedAsset3.Status = 'Obsolete';
        insert relatedAsset3;

        Asset relatedAsset4 = new Asset(Name = 'Intelligent Equipment Energy Management Module', AccountId = acctTemp.Id, SerialNumber = 'MESF04115', Parent_Asset__c = parentAsset2.Id);
        relatedAsset4.Product2Id = prodTemp4.Id;
        relatedAsset4.SIM_Card_Active__c = true;
        insert relatedAsset4;

        Test.stopTest();
 

        //------------------------------Verify Test Results---------------------------
        Asset pa1 = [SELECT Id, IE_Asset__c, IE_Sync_Status__c from Asset Where Id = :parentAsset1.Id];
        System.assertEquals(true, pa1.IE_Asset__c);
        System.assertEquals('Pending', pa1.IE_Sync_Status__c);

        Asset pa2 = [SELECT Id, IE_Asset__c, IE_Sync_Status__c from Asset Where Id = :parentAsset2.Id];
        System.assertEquals(true, pa2.IE_Asset__c);
        System.assertEquals('Pending', pa2.IE_Sync_Status__c);

    }


	static testMethod void testReplaceGatewayAsset() {
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
        prodTemp3.Product_Group__c = 'IE Gateway';
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
        prodTemp4.Product_Group__c = 'IE EMM';
        insert prodTemp4;
        
        
        Test.startTest();

        // Create Parent Asset records
        Asset parentAsset1 = new Asset(Name = 'Asset Test1', AccountId = acctTemp.Id, SerialNumber='SN123Test1', Tag__c='Order Tag 1');
        parentAsset1.Product2Id = prodTemp1.Id;
        parentAsset1.Order__c = orderTemp1.Id;
        insert parentAsset1;


        // Create Related Asset Records for the Parent Asset
        Asset relatedAsset1 = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-075', Parent_Asset__c = parentAsset1.Id);
        relatedAsset1.Product2Id = prodTemp3.Id;
        relatedAsset1.SIM_Card_Active__c = true;
        relatedAsset1.SIM_Card_ICCID__c = '89011704258018735310';
        insert relatedAsset1;

        Asset relatedAsset2 = new Asset(Name = 'Intelligent Equipment Energy Management Module', AccountId = acctTemp.Id, SerialNumber = 'MESF04115', Parent_Asset__c = parentAsset1.Id);
        relatedAsset2.Product2Id = prodTemp4.Id;
        insert relatedAsset2;

		// Create a subscription for the asset
		Datetime currDateTime = Datetime.now();
		Subscription__c subTemp1 = new Subscription__c();
        subTemp1.TriggerInvokedByAPI__c = false;
        subTemp1.IE_Subscription__c = true;
        subTemp1.Start_Date__c = currDateTime;
        subTemp1.End_Date__c = currDateTime.addMonths(12);
        subTemp1.Type__c = 'Standard';
        subTemp1.Active__c = true;
        subTemp1.Asset__c = parentAsset1.Id;
        subTemp1.Buyer_ID__c = acctTemp.Id;
        subTemp1.Renewal_Counter__c = 0;
        subTemp1.Connectivity_Type__c = 'Cellular';
        subTemp1.Term_Years__c = 1.0;
        insert subTemp1;

		// Insert a new GW so the other one becomes obsolete and the subscription trigger flag is set for IE processing
        Asset relatedAsset3 = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = acctTemp.Id, SerialNumber = 'PO112711-2-076', Parent_Asset__c = parentAsset1.Id);
        relatedAsset3.Product2Id = prodTemp3.Id;
        relatedAsset3.SIM_Card_Active__c = true;
        relatedAsset3.SIM_Card_ICCID__c = '79011704258018735310';
        insert relatedAsset3;

        Test.stopTest();
 

        //------------------------------Verify Test Results---------------------------
        Asset ra1 = [SELECT Id, Status from Asset Where Id = :relatedAsset1.Id];
        System.assertEquals('Obsolete', ra1.Status);

		Subscription__c subObj1 = [select Id, TriggerInvokedByAPI__c from Subscription__c where Id =: subTemp1.Id];
        System.assertEquals(true, subObj1.TriggerInvokedByAPI__c);

    }

}