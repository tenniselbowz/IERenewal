@isTest
private class QuoteTriggerTest {
    public static final string LOB ='Lob';
    private static testMethod void testClauseCreationOnQuoteInsert() {
/*        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;

        PreventDeleteHandler.bypassTrigger = true;
        RecordType rtLAQuote = [Select Id from RecordType where sObjectType = 'Apttus_Proposal__Proposal__c' AND Name = 'Latin America Proposal'];
        
        Apttus_Config2__PriceList__c testPL = APTPS_DaikinTestDataUtility.getPriceList('USD Price List');
        insert testPL;
        
        APTPS_Configurable_Variables__c northAmericaQuoteCS = APTPS_DaikinTestDataUtility.getNorthAmericaQuoteCS();
        insert northAmericaQuoteCS;
        
        Account testAccount = APTPS_DaikinTestDataUtility.getAccount('Test Account NA - 1');
        insert testAccount;
        Contact testContact = APTPS_DaikinTestDataUtility.getContact(testAccount);
        insert testContact;
        Id stndrdPBId = APTPS_DaikinTestDataUtility.getStandardPricebookId();
        
        Opportunity testOpp = APTPS_DaikinTestDataUtility.getOpp(testAccount);
        testOpp.Name = 'Test Opp - LA';
        testOpp.Pricebook2Id = stndrdPBId;
        insert testOpp;
        
        Id clauseRT = [Select Id from RecordType where sObjectType = 'Clause__c' Limit 1].id;
        
        insert new Quote_LOB_To_Clause_Record_Type__c(name = LOB,Clause_RecordType__c = clauseRT,Quote_LOB__c = LOB);
        Apttus_Proposal__Proposal__c testQuoteLA1 = APTPS_DaikinTestDataUtility.getQuote(testAccount, testContact, testOpp, testPL);
        testQuoteLA1.Apttus_Proposal__Proposal_Name__c = 'Test Quote 1 - LA';
        testQuoteLA1.RecordTypeId = rtLAQuote.Id;
        testQuoteLA1.Primary__c = true;
        
        Test.startTest();
        testQuoteLA1.Line_of_Business__c =LOB;
        insert testQuoteLA1;
        Test.stopTest();
        List<Clause__c> insertedClauses = [Select Id, recordtypeId, clause__c from Clause__c];
        System.assertEquals(1, insertedClauses.size(), 'On insert of quote a clause shhould be insered wih corresponding recordtype');
        System.assertEquals(clauseRT, insertedClauses[0].recordtypeId, 'On insert of quote a clause shhould be insered wih corresponding recordtype');
        System.assertEquals(testQuoteLA1.id, insertedClauses[0].clause__c, 'On insert of quote a clause shhould be insered wih corresponding recordtype');        
*/    }
}