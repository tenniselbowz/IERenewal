@isTest
private class APTMS_AttachmentTriggerTest {
    
      private static testMethod void test1() {
    
        RecordType rtNAQuote = [Select Id from RecordType where sObjectType = 'Apttus_Proposal__Proposal__c' AND Name = 'North America Proposal'];

        Pricebook2 customPriceBook = new Pricebook2(Name = 'Custom Price Book', Description = 'Price Book', IsActive = true);
        insert customPriceBook;
        
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c();
        ts1.AVA_SFCORE__Active_Setting__c = true;
        ts1.Name='Test Account';
        insert ts1;


        Apttus_Config2__PriceList__c testPL = APTPS_DaikinTestDataUtility.getPriceList('USD Price List');
        insert testPL;
        APTPS_Configurable_Variables__c northAmericaQuoteCS = APTPS_DaikinTestDataUtility.getNorthAmericaQuoteCS();
        insert northAmericaQuoteCS;

        Account testAccount = APTPS_DaikinTestDataUtility.getAccount('Test Account NA - 1');
        insert testAccount;
        Contact testContact = APTPS_DaikinTestDataUtility.getContact(testAccount);
        insert testContact;

        Opportunity testOppNA = APTPS_DaikinTestDataUtility.getOpp(testAccount);
        testOppNA.Name = 'Test Opp - NA';
        testOppNA.Pricebook2Id = customPriceBook.Id;
        insert testOppNA;



        Apttus_Proposal__Proposal__c testQuoteNA1 = APTPS_DaikinTestDataUtility.getQuote(testAccount, testContact, testOppNA, testPL);
        testQuoteNA1.Apttus_Proposal__Proposal_Name__c = 'Approval Process Test 3-13-19- CLONED 2019-03-18 20:34:33';
        //testQuoteNA1.Apttus_Proposal__Proposal_Name__c = 'Approval Process Test';
        testQuoteNA1.RecordTypeId = rtNAQuote.Id;
        testQuoteNA1.Primary__c = true;
        insert testQuoteNA1;
        
        Attachment attach=new Attachment();     
        attach.Name='Approval Process Test 3-13-19- CLONED 2019-03-18 20_34_33_North America Quoted V7_2019-03-28.pdf';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=testQuoteNA1.id;
        insert attach;

    }
}