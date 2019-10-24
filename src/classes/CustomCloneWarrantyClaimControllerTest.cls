@isTest
public class CustomCloneWarrantyClaimControllerTest {

    @testsetup
    public static void testsetup()
    {
        Id warrantyAuthClaimRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Warranty Claim Authorization').getRecordTypeId();
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;
        
        Account testAccount = APTPS_DaikinTestDataUtility.getAccount('accName');
        insert testAccount;
        Contact testContact = APTPS_DaikinTestDataUtility.getContact(testAccount);
        insert testContact; 
        
        Case c = new Case(
            AccountId = testAccount.Id,
            ContactId = testContact.Id,
            Subject = 'Test',
            Date_of_Failure__c = system.today(),
            Date_Received__c = system.today().addDays(10),
            Reason_for_Authorization_Request__c ='reason for authorization',
            Origin = 'Email',
            Priority ='Urgent',
            Case_Category__c = 'Claim',
            
            Business_Unit_Picklist__c ='AAH',
            //Status = UserInfo.getUserId(),
            RecordTypeId  = warrantyAuthClaimRecordType);    
        
        insert c;
        
    }
    
    @isTest
    public static void insertTest()
    {
        testsetup();
        List<Case> c = [select id,Subject,Status,Business_Unit_Picklist__c,RecordTypeId from Case where Case_Category__c='claim' limit 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(c[0]);

		Test.startTest();
       		CustomCloneWarrantyClaimController customeCloneCase = new CustomCloneWarrantyClaimController(sc);
            customeCloneCase.saveCase();
            customeCloneCase.saveAndClose();
        customeCloneCase.saveAndNewCase();
        //customeCloneCase.cancel();
       	Test.stopTest();
    }
    
}