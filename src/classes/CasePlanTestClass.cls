@isTest 
private class CasePlanTestClass {  
    @TestSetup
    private static void loadTestData(){
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

        Case_Plan__c cp = new Case_Plan__c();
        cp.Name='TEST';
        insert cp;
        
        Case_Plan_Asset__c cpa = new Case_Plan_Asset__c();
        cpa.Case_Plan__c = cp.Id;
        cpa.Asset__c = asset.Id;
        insert cpa;
    }  
    static testMethod void CasePlanAssetTriggerTest(){
        System.assertEquals(1, [select Id from Case_Plan_Asset__c].size());
    }
}