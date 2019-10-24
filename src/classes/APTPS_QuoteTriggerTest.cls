@isTest(seeAllData = false)
private class APTPS_QuoteTriggerTest {

   /* @testSetup static void setup() {
        RecordType rtNAQuote = [Select Id from RecordType where sObjectType = 'Apttus_Proposal__Proposal__c' AND Name = 'North America Proposal'];
        //RecordType rtLAQuote = [Select Id from RecordType where sObjectType = 'Apttus_Proposal__Proposal__c' AND Name = 'Latin America Proposal'];

        String standardPricebookId =Test.getStandardPricebookId();

        Pricebook2 stdPriceBook = new Pricebook2(Id = standardPricebookId, IsActive = true);
        upsert stdPricebook;

        Id stndrdPBId = APTPS_DaikinTestDataUtility.getStandardPricebookId();
        Pricebook2 customPriceBook = new Pricebook2(Name = 'Custom Price Book', Description = 'Price Book', IsActive = true);
        insert customPriceBook;

        Product2 testProduct1 = APTPS_DaikinTestDataUtility.getProduct('Test Cab1');
        Product2 testProduct2 = APTPS_DaikinTestDataUtility.getProduct('Test Cab2');
        List<Product2> productList = new List<Product2>();
        productList.add(testProduct1); productList.add(testProduct2);
        insert productList;
         testProduct1 = [Select Id from Product2 where Name = 'Test Cab1' limit 1];
         testProduct2 = [Select Id from Product2 where Name = 'Test Cab2' limit 1];

        List<PricebookEntry> entries = new List<PricebookEntry>();
        entries.add(new PricebookEntry(Pricebook2Id = standardPricebookId, Product2Id = testProduct1.Id, IsActive = true, UnitPrice = 100));
        entries.add(new PricebookEntry(Pricebook2Id = standardPricebookId, Product2Id = testProduct2.Id, IsActive = true, UnitPrice = 100));
        insert entries;

        Apttus_Config2__PriceList__c testPL = APTPS_DaikinTestDataUtility.getPriceList('USD Price List');
        insert testPL;
        APTPS_Configurable_Variables__c northAmericaQuoteCS = APTPS_DaikinTestDataUtility.getNorthAmericaQuoteCS();
        insert northAmericaQuoteCS;

        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c();
        ts1.AVA_SFCORE__Active_Setting__c = true;
        ts1.Name='Test Account';
        insert ts1;

        Account testAccount = APTPS_DaikinTestDataUtility.getAccount('Test Account NA - 1');
        insert testAccount;
        Contact testContact = APTPS_DaikinTestDataUtility.getContact(testAccount);
        insert testContact;

        Opportunity testOppNA = APTPS_DaikinTestDataUtility.getOpp(testAccount);
        testOppNA.Name = 'Test Opp - NA';
        testOppNA.Pricebook2Id = customPriceBook.Id;
        insert testOppNA;

        Opportunity testOppLA = APTPS_DaikinTestDataUtility.getOpp(testAccount);
        testOppLA.Name = 'Test Opp - LA';
        testOppLA.Pricebook2Id = customPriceBook.Id;
        insert testOppLA;

        PricebookEntry cbPB1 = new PricebookEntry(Pricebook2Id = customPriceBook.Id, Product2Id = testProduct2.Id, IsActive = true, UnitPrice = 100);
        insert cbPB1;

        OpportunityLineItem oppLine11 = APTPS_DaikinTestDataUtility.getOppLineItem(testOppNA.Id, cbPB1.Id);
        oppLine11.OpportunityId = testOppNA.Id;
        oppLine11.APTPS_Product_Id__c = testProduct2.Id;
        oppLine11.DST_ID__c = 'DST_ID__c';
        insert oppLine11;

        OpportunityLineItem oppLineLA11 = APTPS_DaikinTestDataUtility.getOppLineItem(testOppNA.Id, cbPB1.Id);
        oppLineLA11.OpportunityId = testOppLA.Id;
        oppLineLA11.APTPS_Product_Id__c = testProduct2.Id;
        oppLineLA11.DST_ID__c = 'DST_ID__c';
        insert oppLineLA11;

        Apttus_Proposal__Proposal__c testQuoteNA1 = APTPS_DaikinTestDataUtility.getQuote(testAccount, testContact, testOppNA, testPL);
        testQuoteNA1.Apttus_Proposal__Proposal_Name__c = 'Test Quote 1 - NA';
        testQuoteNA1.RecordTypeId = rtNAQuote.Id;
        testQuoteNA1.Primary__c = true;
        insert testQuoteNA1;
        System.assert(testQuoteNA1.Primary__c == true);

        //Apttus_Proposal__Proposal__c testQuoteLA1 = APTPS_DaikinTestDataUtility.getQuote(testAccount, testContact, testOppNA, testPL);
        //testQuoteLA1.Apttus_Proposal__Proposal_Name__c = 'Test Quote 1 - NA';
        //testQuoteLA1.RecordTypeId = rtLAQuote.Id;
        //testQuoteLA1.Primary__c = true;
        //insert testQuoteLA1;
        //System.assert(testQuoteLA1.Primary__c == true);

        Test.startTest();


        //insert document line items, these shoud get deleted once associated quote gets Accepted.
        List<APTPS_Document_Line_Item__c> docLineItems =  new List<APTPS_Document_Line_Item__c>();
        docLineItems.add(new APTPS_Document_Line_Item__c(APTPS_Quote_Proposal__c = testQuoteNA1.Id));
        insert docLineItems;


        Apttus_Proposal__Proposal_Line_Item__c testQuoteLineNA11 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = testQuoteNA1.Id,
            Apttus_Proposal__Product__c = testProduct1.Id, Apttus_QPConfig__Quantity2__c = 1, Apttus_Proposal__Quantity__c = 1,
            Apttus_QPConfig__ItemSequence__c = 1, Apttus_QPConfig__LineNumber__c = 1, Apttus_QPConfig__LineStatus__c = 'New',
            Apttus_QPConfig__LineType__c = 'Product/Service', Apttus_Proposal__Unit_Price__c = 100, Apttus_QPConfig__NetPrice__c = 100);
        insert testQuoteLineNA11;

        Apttus_Proposal__Proposal_Line_Item__c testQuoteLineNA12 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = testQuoteNA1.Id,
            Apttus_Proposal__Product__c = testProduct2.Id, Apttus_QPConfig__Quantity2__c = 1, Apttus_Proposal__Quantity__c = 1,
            Apttus_QPConfig__ItemSequence__c = 1, Apttus_QPConfig__LineNumber__c = 1, Apttus_QPConfig__LineStatus__c = 'New',
            Apttus_QPConfig__LineType__c = 'Product/Service', Apttus_Proposal__Unit_Price__c = 100, Apttus_QPConfig__NetPrice__c = 100);
            //DST_ID__c = 'test dst id 2');
        insert testQuoteLineNA12;

        Apttus_Proposal__Proposal__c testQuoteNA1Cln = APTPS_DaikinTestDataUtility.getQuote(testAccount, testContact, testOppNA, testPL);
        testQuoteNA1Cln.Apttus_Proposal__Proposal_Name__c = 'Test Quote 1 - NA-Clone';
        testQuoteNA1Cln.RecordTypeId = rtNAQuote.Id;
        testQuoteNA1Cln.Primary__c = true;
//        insert testQuoteNA1Cln;

//        APTPS_QuoteTriggerHandler.primaryQuoteUtility(new List<Apttus_Proposal__Proposal__c>{testQuoteNA1Cln});
    }
    
    private static testMethod void testDeleteItem(){
        Test.startTest();
        
        Apttus_Proposal__Proposal__c testQuoteNA1 = [select Id from Apttus_Proposal__Proposal__c where Apttus_Proposal__Proposal_Name__c='Test Quote 1 - NA' limit 1];
        Product2 testProduct4 = APTPS_DaikinTestDataUtility.getProduct('Test Cab4');
    
        Apttus_Proposal__Proposal_Line_Item__c deleteTestItem = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = testQuoteNA1.Id,
                                                                                                              Apttus_Proposal__Product__c = testProduct4.Id, Apttus_QPConfig__Quantity2__c = 1, Apttus_Proposal__Quantity__c = 1,
                                                                                                              Apttus_QPConfig__ItemSequence__c = 1, Apttus_QPConfig__LineNumber__c = 1, Apttus_QPConfig__LineStatus__c = 'New',
                                                                                                              Apttus_QPConfig__LineType__c = 'Product/Service', Apttus_Proposal__Unit_Price__c = 100, Apttus_QPConfig__NetPrice__c = 100
                                                                                                              ,Apttus_QPConfig__ClassificationHierarchy__c = 'Warranty (Parts & Material)');
        insert deleteTestItem;
        delete deleteTestItem;

        deleteTestItem = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = testQuoteNA1.Id,
                                                                                                              Apttus_Proposal__Product__c = testProduct4.Id, Apttus_QPConfig__Quantity2__c = 1, Apttus_Proposal__Quantity__c = 1,
                                                                                                              Apttus_QPConfig__ItemSequence__c = 1, Apttus_QPConfig__LineNumber__c = 1, Apttus_QPConfig__LineStatus__c = 'New',
                                                                                                              Apttus_QPConfig__LineType__c = 'Product/Service', Apttus_Proposal__Unit_Price__c = 100, Apttus_QPConfig__NetPrice__c = 100
                                                                                                              ,Apttus_QPConfig__ClassificationHierarchy__c = 'Warranty (Equipment)');
        insert deleteTestItem;
        delete deleteTestItem;
        
        Test.stopTest();
    }

    private static testMethod void testQuoteSynchModule() {
        Id stndrdPBId = APTPS_DaikinTestDataUtility.getStandardPricebookId();
        String standardPricebookId =Test.getStandardPricebookId();

        Product2 testProduct3 = APTPS_DaikinTestDataUtility.getProduct('Test Cab3');
        Product2 testProduct4 = APTPS_DaikinTestDataUtility.getProduct('Test Cab4');
        List<Product2> productList = new List<Product2>();
        productList.add(testProduct3); productList.add(testProduct4);
        insert productList;

        List<PricebookEntry> stdEntries = new List<PricebookEntry>();
        stdEntries.add(new PricebookEntry(Pricebook2Id = stndrdPBId, Product2Id = testProduct3.Id, IsActive = true, UnitPrice = 100));
        stdEntries.add(new PricebookEntry(Pricebook2Id = stndrdPBId, Product2Id = testProduct4.Id, IsActive = true, UnitPrice = 100));
        insert stdEntries;

        PricebookEntry standardPrice3 = [Select Id from PricebookEntry where Product2Id = :testProduct3.Id limit 1];
        PricebookEntry standardPrice4 = [Select Id from PricebookEntry where Product2Id = :testProduct4.Id limit 1];


        Account testAccount = [Select Id, Name from Account where Name='Test Account NA - 1' limit 1];
        Contact testContact = [select Id from Contact where AccountId=:testAccount.Id Limit 1];
        Apttus_Config2__PriceList__c testPL = [select Id from Apttus_Config2__PriceList__c where Name='USD Price List' limit 1];
        RecordType rtNAQuote = [Select Id from RecordType where sObjectType = 'Apttus_Proposal__Proposal__c' AND Name = 'North America Proposal'];
        Opportunity testOppNA = [select Id from Opportunity where Name='Test Opp - NA' and AccountId=:testAccount.Id Limit 1];
        

        Test.startTest();


        Opportunity testOpp = APTPS_DaikinTestDataUtility.getOpp(testAccount);
        testOpp.Pricebook2Id = standardPricebookId;
        testOpp.Name = 'Test Opp';
        insert testOpp;

        //Opportunity testOpp1 = APTPS_DaikinTestDataUtility.getOpp(testAccount);
        //testOpp.Name = 'Test Opp - LA';
        //insert testOpp1;

        OpportunityLineItem oppLine1 = APTPS_DaikinTestDataUtility.getOppLineItem(testOpp.Id, standardPrice3.Id);
        oppLine1.OpportunityId = testOpp.Id;
        oppLine1.APTPS_Product_Id__c = testProduct3.Id;
        oppLine1.DST_ID__c = 'DST_ID__c';
        insert oppLine1;

        OpportunityLineItem oppLine2 = APTPS_DaikinTestDataUtility.getOppLineItem(testOpp.Id, standardPrice4.Id);
        oppLine2.OpportunityId = testOpp.Id;
        oppLine2.APTPS_Product_Id__c = testProduct4.Id;
        insert oppLine2;

        Apttus_Proposal__Proposal__c testQuoteNA2 = APTPS_DaikinTestDataUtility.getQuote(testAccount, testContact, testOpp, testPL);
        testQuoteNA2.Apttus_Proposal__Proposal_Name__c = 'Test Quote 2 - NA';
        testQuoteNA2.RecordTypeId = rtNAQuote.Id;
        testQuoteNA2.Primary__c = false;
        insert testQuoteNA2;
        System.assert(testQuoteNA2.Primary__c == false);

        //Apttus_Proposal__Proposal__c testQuoteLA3 = APTPS_DaikinTestDataUtility.getQuote(testAccount, testContact, testOpp1, testPL);
        //testQuoteLA3.Apttus_Proposal__Proposal_Name__c = 'Test Quote 1 - LA';
        //testQuoteLA3.RecordTypeId = rtNAQuote.Id;
        //testQuoteLA3.Primary__c = true;
        //insert testQuoteLA3;

        Apttus_Proposal__Proposal_Line_Item__c testQuoteLineNA21 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = testQuoteNA2.Id,
            Apttus_Proposal__Product__c = testProduct3.Id, Apttus_QPConfig__Quantity2__c = 1, Apttus_Proposal__Quantity__c = 1,
            Apttus_QPConfig__ItemSequence__c = 1, Apttus_QPConfig__LineNumber__c = 1, Apttus_QPConfig__LineStatus__c = 'New',
            Apttus_QPConfig__LineType__c = 'Product/Service', Apttus_Proposal__Unit_Price__c = 100, Apttus_QPConfig__NetPrice__c = 100,
            DST_ID__c = 'DST_ID__c',
            Apttus_QPConfig__ClassificationHierarchy__c = 'AC Scroll | AC Screw | WC Scroll | WC Screw');
            testQuoteNA2.Apttus_Proposal__Opportunity__c = testOppNA.Id;
        insert testQuoteLineNA21;

        Apttus_Proposal__Proposal_Line_Item__c testQuoteLineNA22 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = testQuoteNA2.Id,
            Apttus_Proposal__Product__c = testProduct4.Id, Apttus_QPConfig__Quantity2__c = 1, Apttus_Proposal__Quantity__c = 1,
            Apttus_QPConfig__ItemSequence__c = 1, Apttus_QPConfig__LineNumber__c = 1, Apttus_QPConfig__LineStatus__c = 'New',
            Apttus_QPConfig__LineType__c = 'Product/Service', Apttus_Proposal__Unit_Price__c = 100, Apttus_QPConfig__NetPrice__c = 100);
        insert testQuoteLineNA22;
        testQuoteNA2.Primary__c = true;
        testQuoteNA2.Apttus_Proposal__Opportunity__c = testOppNA.Id;
//        update testQuoteNA2;

        Map<String,Id> quoteLOBToClaueRT = APTPS_QuoteTriggerHandler.quoteLOBToClaueRT;
        Test.stopTest();
    }*/

}