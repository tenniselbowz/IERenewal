@isTest
public class CaseTriggerHandlerTest {
    
    @testSetup static void setup() {
        test.startTest();
        Id accountRecordTypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Daikin Applied').getRecordTypeId();
        Id warrantyRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Warranty').getRecordTypeId();   
        Id warrantyAuthClaimRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Warranty Claim Authorization').getRecordTypeId();
        
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;
        
        //INsert product
        List<Product2> ProductList = New list<Product2>();
        Product2 Product_1 = new Product2();
        Product_1.Name ='Test - Voice and Data';
        Product_1.ProductCode = 'V0001';
        Product_1.DW_Product_Class__c='0010';
        Product_1.Family ='Smartshare';        
        ProductList.add(Product_1);
        
        Product2 Product_2 = new Product2();
        Product_2.Name ='Test - Voice and Data (Unlimited)';
        Product_2.ProductCode = 'V0002';
        Product_2.DW_Product_Class__c='0011';
        Product_2.Family ='Smartshare'; 
        ProductList.add(Product_2);
        Insert Productlist;
        
        //Insert Order
        Order__c order = new Order__c();
        insert order;
        
        Account testAccount = APTPS_DaikinTestDataUtility.getAccount('accName');
        insert testAccount;
        Contact testContact = APTPS_DaikinTestDataUtility.getContact(testAccount);
        insert testContact; 
        
        //Insert Asset
        Asset asset = new Asset();
        asset.Name = 'TEST';
        asset.SerialNumber = 'TEST';
        asset.Product2Id = Product_1.Id;
        asset.AccountId = testAccount.Id;
        asset.Order__c = order.Id;
        insert asset;
        
        //Insert PCL Notification
        PCL_Notification__c pclNoti=new PCL_Notification__c();
        pclNoti.Business_unit__c='AAH';
        pclNoti.Name='0010';
        pclNoti.Users_to_Notify__c='onesh.k@solunuscorp.com,pavan.k@solunuscorp.com';
        insert pclNoti;
        system.debug('pclNoti');
        
        Case war = new Case();
        war.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Warranty Claim Authorization').getRecordTypeId();
        war.Subject = 'TEST';
        war.Origin = 'Email';
        war.AccountId = testAccount.Id;
        war.ContactId = testContact.Id;
        war.Date_of_Failure__c = System.today();
        war.Date_Received__c = System.today();
        war.Reason_for_Authorization_Request__c = 'TEST';
        war.Case_Category__c = 'Claim';
        war.Business_Unit_Picklist__c = 'AAH';
        war.Reject_Comments__c = '';
        war.Status = 'Warranty Review';
        war.Warranty_Approver__c = UserInfo.getUserId();
        war.Approval_Status__c = 'Submitted';
        war.Warranty_Approved_Ttl__c = 15000;
        war.CurrencyIsoCode ='CAD';
        insert war;
        
        //Insert case to cover the serviceCode rollups
        Case casse=war.clone();
        casse.Subject= 'Test 2';
        insert casse;
        
        Case wc = war.clone();
        wc.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Warranty').getRecordTypeId();
        wc.AssetId=asset.id;
        wc.Case_Category__c = 'Claim';
        wc.ParentId = war.Id;
        wc.CurrencyIsoCode=war.CurrencyIsoCode;
        insert wc;
        
        wc = wc.clone();
        insert wc;
        
        //Insert Warranty class 
        Service_Code__c serCode=new Service_Code__c();
        serCode.Type__c='Type';
        serCode.Warranty_Class_Type__c='Sales Concession';
        insert serCode;
        
        Case_Service_Code__c csc1= new Case_Service_Code__c();// Insert service code with requested/approved amounts as null
        csc1.Case__c=wc.id;
        csc1.WarrantyClassCode__c=serCode.id;
         TriggerUtility.tau.get('CaseServiceCode').reset();
        insert csc1;
        
        Case_Service_Code__c csc = new Case_Service_Code__c();
        csc.Case__c = wc.Id;
        csc.Labor_Amount_Requested__c=100.00;
        csc.Labor_Amount_Approved__c = 100.00;
        csc.Hours_Requested__c=1;
        csc.Hours_Approved__c=1;
        csc.Daikin_Parts_Amount_Requested__c=10000.00;
        csc.Daikin_Parts_Amount_Approved__c=10000.00;
        csc.X3rd_Party_Parts_Amount_Requested__c=100.00;
        csc.X3rd_Party_Parts_Amount_Approved__c=100.00;
        csc.Additional_Materials_Amount_Requested__c=100.00;
        csc.Additional_Materials_Amount_Approved__c=100.00;
        
        // csc.CurrencyIsoCode='CAD';
        TriggerUtility.tau.get('CaseServiceCode').reset();
        insert csc;
        
        Case_Service_Code__c css= new Case_Service_Code__c();
        css=csc.clone();
        TriggerUtility.tau.get('CaseServiceCode').reset();
        insert css;
         
        TriggerUtility.tau.get('CaseServiceCode').reset();
        
        /*   //Submit Quote for Approval
Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
app.setObjectId(war.id);
Approval.ProcessResult result = Approval.process(app);*/
        test.stopTest();
        
    }    @isTest static void testApprovalProcess(){
        Case c = [SELECT Id,subject,Approval_Status__c FROM Case Limit 1];
        c.Approval_Status__c = 'Approved';
        c.Reject_Comments__c = 'test';
        c.Warranty_Approved_Ttl__c = 200000;
        system.debug('Case 1 '+c.Subject);
        update c;
        delete c;
    }
    
    
    
    @isTest static void test10KWarrantyEmailNotification(){
        Case cas = [SELECT Id, Approval_Status__c,Warranty_Approved_Ttl__c,Business_Unit_Picklist__c,CurrencyIsoCode FROM Case where Business_Unit_Picklist__c = 'AAH' Limit 1];
        cas.Approval_Status__c='Warranty Approved';
        cas.CurrencyIsoCode ='CAD';
        update cas;
    }
    
    @isTest static void testForCoverage(){    
        CaseTriggerHandler.validateCaseAsset([select Id, RecordType.Name, Status from Case]);
        CaseTriggerHandler.updateCaseStatus(new Map<Id, Case>([select Id, Approval_Status__c, Reject_Comments__c from Case]), new Map<Id, Case>([select Id, Approval_Status__c, Reject_Comments__c from Case]));
        CaseTriggerHandler.sendEmaiLNotification(new Map<Id, Case>([select Id, Business_Unit_Picklist__c from Case]), new Map<Id, Case>([select Id, Business_Unit_Picklist__c from Case]));
        
        System.assertEquals(TriggerUtility.getCountryFromIsoCode('ZWE'), 'Zimbabwe');
        System.assertEquals(TriggerUtility.getStateFromCountryStateIsoCode('TTO', 'WTO'), 'Western Tobago');
    }
}