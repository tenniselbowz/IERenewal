@isTest 
private class WarrantyTestClass {    

    @TestSetup
    private static void loadTestWar(){
            AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c();
            ts1.AVA_SFCORE__Active_Setting__c = true;
            ts1.Name='Test Account';
            insert ts1;
            
            Address__c address = new Address__c();
            address.Address_Line_1__c = 'TEST';
            address.City__c = 'Minneapolis';
            address.Postal_Code__c = '55421';
            address.Country__c = 'United States';
            address.State_Province__c = 'Minnesota';
            insert address;
    
            Account a = new Account();
            a.Name = 'TEST';
            a.Type = 'Developer';
            a.Physical_Address__c = address.Id;
            insert a;
            
            Account_Address__c aa = new Account_Address__c();
            aa.Account__c = a.Id;
            aa.Address__c = address.Id;
            aa.Active__c = true;
            aa.Physical__c = true;
            insert aa;
            
            Contact c = new Contact();
            c.AccountId = a.Id;
            c.LastName = 'TEST';
            c.Email = 'test@test.com';
            insert c;
            
            Product2 p = new Product2();
            p.Name = 'TEST';
            p.IsActive = true;
            p.ProductCode = 'TEST';
            p.DW_Product_Business_Unit__c = 'Applied Air Handler';
            insert p;
            
            Order__c order = new Order__c();
            insert order;
            
            Asset asset = new Asset();
            asset.Name = 'TEST';
            asset.SerialNumber = 'TEST';
            asset.Product2Id = p.Id;
            asset.AccountId = a.Id;
            asset.ContactId = c.Id;
            asset.Order__c = order.Id;
            insert asset;

            Case war = new Case();
            war.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Warranty Claim Authorization').getRecordTypeId();
            war.Subject = 'TEST';
            war.Origin = 'Email';
            war.AccountId = a.Id;
            war.ContactId = c.Id;
            war.Date_of_Failure__c = System.today();
            war.Date_Received__c = System.today();
            war.Reason_for_Authorization_Request__c = 'TEST';
            war.Case_Category__c = 'Claim';
            war.Business_Unit_Picklist__c = 'AAH';
            war.AssetId = asset.Id;
            war.Order__c = order.Id;
            insert war;

        Case wc = war.clone();
        wc.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Warranty').getRecordTypeId();
        wc.Case_Category__c = 'Claim';
        wc.ParentId = war.Id;
        insert wc;
        
        wc = wc.clone();
        insert wc;
        
        Case_Service_Code__c csc = new Case_Service_Code__c();
        csc.Case__c = wc.Id;
        csc.Labor_Amount_Approved__c = 100.00;
        csc.Hours_Approved__c=1;
        csc.Daikin_Parts_Amount_Approved__c=100.00;
        csc.X3rd_Party_Parts_Amount_Approved__c=100.00;
        csc.Additional_Materials_Amount_Approved__c=100.00;
        Test.startTest();
        TriggerUtility.tau.get('CaseServiceCode').reset();
        TriggerAccessUtility.tau.get('Case').reset();
        insert csc;

        TriggerUtility.tau.get('CaseServiceCode').reset();
        TriggerAccessUtility.tau.get('Case').reset();
        insert csc.clone();

        Service_Code__c sc = new Service_Code__c();
        sc.Name='IN06';
        sc.Label__c='Sales Concession';
        sc.Active__c=true;
        sc.Type__c='Warranty Class';
        sc.Warranty_Class_Type__c='Sales Concession';
        insert sc;
        
        TriggerUtility.tau.get('CaseServiceCode').reset();
        TriggerAccessUtility.tau.get('Case').reset();
        Case_Service_Code__c csc2 = csc.clone();
        csc2.WarrantyClassCode__c=sc.Id;
        insert csc2;
        //Test.stopTest();
    }
    private static Case getTestWar(){
        return [select Id, Subject, Origin, AccountId, ContactId, Date_of_Failure__c, Date_Received__c, Reason_for_Authorization_Request__c, Business_Unit_Picklist__c, AssetId, Order__c from Case Limit 1];
    }
    private static Case_Service_Code__c getTestData(){
        return [select Id, Case__c, Labor_Amount_Approved__c, Hours_Approved__c, Daikin_Parts_Amount_Approved__c, Additional_Materials_Amount_Approved__c from Case_Service_Code__c Limit 1];
    }
    
    static testMethod void CaseServiceCodeTriggerTest() {
        
        Case_Service_Code__c csc = getTestData();
        csc = [select Id, Case__r.ParentId from Case_Service_Code__c where Id=:csc.Id];
        Case war = [select Id, Labor_Amount_Approved__c, Hours_Approved__c, Daikin_Parts_Amount_Approved__c, X3rd_Party_Parts_Amount_Approved__c, Additional_Materials_Amount_Approved__c from Case where Id=:csc.Case__r.ParentId];
        System.assertEquals(300, war.Labor_Amount_Approved__c);
        System.assertEquals(3, war.Hours_Approved__c);
        System.assertEquals(300, war.Daikin_Parts_Amount_Approved__c);
        System.assertEquals(300, war.X3rd_Party_Parts_Amount_Approved__c);
        System.assertEquals(300, war.Additional_Materials_Amount_Approved__c);

        Test.startTest();
        delete csc;
        Test.stopTest();
        
        war = [select Id, Labor_Amount_Approved__c, Hours_Approved__c, Daikin_Parts_Amount_Approved__c, X3rd_Party_Parts_Amount_Approved__c, Additional_Materials_Amount_Approved__c from Case where Id=:war.Id];
        System.assertEquals(200, war.Labor_Amount_Approved__c);
        System.assertEquals(2, war.Hours_Approved__c);
        System.assertEquals(200, war.Daikin_Parts_Amount_Approved__c);
        System.assertEquals(200, war.X3rd_Party_Parts_Amount_Approved__c);
        System.assertEquals(200, war.Additional_Materials_Amount_Approved__c);    
    }    
    
    static testMethod void CaseServiceCodeControllerExtensionTest() {
        Case_Service_Code__c csc = getTestData();
        csc = [select Id, Case__c, Case__r.Business_Unit__c, Case__r.Serial_Number__c, Case__r.Model__c from Case_Service_Code__c where Id=:csc.Id];
        
        Service_Code__c bu = new Service_Code__c();
        bu.Name='AAH';
        bu.Label__c = 'Applied Air Handler';
        bu.Type__c = 'Business Unit';
        bu.Active__c = true;
        insert bu;
        
        Service_Code__c mode = new Service_Code__c();
        mode.Name='TEST';
        mode.Label__c = 'TEST';
        mode.Type__c = 'Mode';
        mode.Active__c = true;
        insert mode;

        Service_Code__c unit = new Service_Code__c();
        unit.Name='TEST';
        unit.Label__c = 'TEST';
        unit.Type__c = 'Unit';
        unit.Active__c = true;
        unit.Parent__c = bu.Id;
        insert unit;

        List<Service_Code__c> scs = new List<Service_Code__c>();
        Service_Code__c sc = new Service_Code__c();
        sc.Name='TEST';
        sc.Label__c = 'TEST';
        sc.Type__c = 'Warranty Class';
        sc.Active__c = true;
        sc.Parent__c = bu.Id;
        scs.add(sc);

        sc = new Service_Code__c();
        sc.Name='TEST';
        sc.Label__c = 'TEST';
        sc.Type__c = 'Type';
        sc.Active__c = true;
        sc.Parent__c = mode.Id;
        sc.Unit_Code__c = unit.Id;
        scs.add(sc);

        insert scs;
        
        Service_Code__c major = new Service_Code__c();
        major.Name='TEST';
        major.Label__c = 'TEST';
        major.Type__c = 'Major';
        major.Active__c = true;
        major.Parent__c = bu.Id;
        major.Unit_Code__c = unit.Id;
        insert major;

        sc = new Service_Code__c();
        sc.Name='TEST';
        sc.Label__c = 'TEST';
        sc.Type__c = 'Specific';
        sc.Active__c = true;
        sc.Parent__c = major.Id;
        sc.Unit_Code__c = unit.Id;
        insert sc;

        ApexPages.StandardController scontroller = new ApexPages.StandardController(csc);
        CaseServiceCodeControllerExtension controller = new CaseServiceCodeControllerExtension(scontroller);
        
        PageReference pageRef = Page.CaseServiceCodeEdit;
        pageRef.getParameters().put('id', String.valueOf(csc.Id));
        Test.setCurrentPage(pageRef);    
 
        Test.startTest();       
        System.assertEquals('TEST', controller.getSerialNumber());
        System.assertEquals('TEST', controller.getModel());
        System.assertEquals('AAH', controller.getCaseBusinessUnit());
        System.assertEquals(bu.Id, controller.getCaseBusinessUnitId());
        System.assertEquals(1, controller.getBusinessUnits().size());        
        System.assertEquals(1, CaseServiceCodeControllerExtension.getUnits(bu.Id).size());        
        System.assertEquals(1, controller.getModes().size());        
        System.assertEquals(1, CaseServiceCodeControllerExtension.getTypes(mode.Id, unit.Id).size());        
        System.assertEquals(1, CaseServiceCodeControllerExtension.getMajors(bu.Id, unit.Id).size());        
        System.assertEquals(1, CaseServiceCodeControllerExtension.getSpecifics(major.Id, unit.Id).size());        
        System.assertEquals(1, CaseServiceCodeControllerExtension.getClassifications(bu.Id).size());        
        
        pageRef = Page.CaseServiceCodeEdit2;
        pageRef.getParameters().put('id', String.valueOf(csc.Id));
        Test.setCurrentPage(pageRef);    

        CaseServiceCodeControllerExtension2 controller2 = new CaseServiceCodeControllerExtension2(scontroller);
        System.assertEquals('TEST', controller2.getSerialNumber());
        System.assertEquals('TEST', controller2.getModel());
        System.assertEquals('AAH', controller2.getCaseBusinessUnit());
        System.assertEquals(bu.Id, controller2.getCaseBusinessUnitId());
        System.assertEquals(1, controller2.getBusinessUnits().size());        
        System.assertEquals(0, CaseServiceCodeControllerExtension2.getUnits(bu.Id).size());        
        System.assertEquals(1, controller2.getModes().size());        
        System.assertEquals(0, CaseServiceCodeControllerExtension2.getTypes(mode.Id, unit.Id).size());        
        System.assertEquals(0, CaseServiceCodeControllerExtension2.getMajors(bu.Id, unit.Id).size());        
        System.assertEquals(0, CaseServiceCodeControllerExtension2.getSpecifics(major.Id, unit.Id).size());        
        System.assertEquals(0, CaseServiceCodeControllerExtension2.getClassifications(bu.Id).size());        
        System.assertEquals(0, CaseServiceCodeControllerExtension2.getResponsibility(bu.Id).size());        
        System.assertEquals(0, CaseServiceCodeControllerExtension2.getSpecialTypes(bu.Id).size());        
        System.assertEquals('', controller2.getStartupDate());        
        System.assertEquals('', controller2.getShipDate());        
        System.assertEquals(null, controller2.getPCL());        
        Test.stopTest();
    }

    static testMethod void WarrantyOrderAssetControllerExtensionTest() {
        Case war = getTestWar();

        WarrantyOrderAssetControllerExtension controller = new WarrantyOrderAssetControllerExtension();
        System.assertEquals(null, controller.getId());   
        System.assertEquals(null, controller.getOrderAssets());   

        PageReference pageRef = Page.WarrantyOrderAssetAssociation;
        pageRef.getParameters().put('id', String.valueOf(war.Id));
        Test.setCurrentPage(pageRef);    
        
        controller = new WarrantyOrderAssetControllerExtension();

        System.assertNotEquals(null, controller.getId());   
        System.assertEquals(0, WarrantyOrderAssetControllerExtension.createOrderAssets(war.Id, new List<Id>(new Map<Id, Asset>(controller.getOrderAssets()).keySet())));
        controller.save();
        controller.cancel();
        controller.close();
        
    }
    static testMethod void WarrantyOrderAssetControllerExtensionTest2() {    
        Case war = getTestWar();
        Test.startTest();
        List<String> lst = new List<String>();
            Asset a = [select Id, AccountId, Product2Id, ContactId, Order__c from Asset where Id=:war.AssetId];
            Asset a1 = a.clone();
            a1.Name = 'TEST1';
            a1.SerialNumber = 'TEST1';
            insert a1;
            lst.add(a1.Id);

            a1 = a.clone();
            a1.Name = 'TEST1';
            a1.SerialNumber = 'TEST1';
            insert a1;
            lst.add(a1.Id);
        
        WarrantyOrderAssetControllerExtension controller = new WarrantyOrderAssetControllerExtension(lst, war);
        DataBase.executeBatch(controller);
        Test.stopTest();        
        System.assertNotEquals(lst.size(), [select Id from Case where Id!=:war.Id].size());   
    }

    static testMethod void WarrantyHelperTest() {
        Case_Service_Code__c csc = getTestData();
        Test.startTest();        
        System.assertEquals(1, WarrantyHelper.associateCaseServiceCodes(csc.Id, true));
        Test.stopTest();
    }
    static testMethod void WarrantyHelperTest2() {
        Case_Service_Code__c csc = getTestData();
        Test.startTest();        
        System.assertEquals(1, WarrantyHelper.associateCaseServiceCodes(csc.Id, false));
        Test.stopTest();
    }

    static testMethod void WarrantyHelperTest3() {
        Case war = getTestWar();
  
        Case wc = war.clone();
        wc.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Warranty').getRecordTypeId();
        wc.Case_Category__c = 'Claim';
        wc.ParentId = war.Id;
        Test.startTest();
        insert wc;
//        Test.stopTest();
        wc = [select Id, Asset.Product2Id, Account.Id, Contact.Id, Order__r.Id from Case where Id=:wc.Id];

        Asset asset = new Asset();
        asset.Name = 'TEST';
        asset.SerialNumber = 'TEST';
        asset.Product2Id = wc.Asset.Product2Id;
        asset.AccountId = wc.Account.Id;
        asset.ContactId = wc.Contact.Id;
        asset.Order__c = wc.Order__r.Id;
//        Test.startTest();
        insert asset;  
        System.assertEquals(1, WarrantyHelper.associateOrderAssets(war.Id));
        Test.stopTest();
    }
    static testMethod void WarrantyAuthorizationRelatedChildCasesTestCoverage() {
        WarrantyAuthorizationRelatedChildCases controller = new WarrantyAuthorizationRelatedChildCases(null);
        Case war = getTestWar();        
        controller.CaseIdvalue = war.Id;
        System.assertEquals(2, controller.casess.size());
        System.assertEquals(2, controller.getservicecodes.size());
        
    }    
}