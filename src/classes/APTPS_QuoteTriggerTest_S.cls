@isTest
public class APTPS_QuoteTriggerTest_S {
    @testSetUp
    public static void testData()
    {
        RecordType rtNAQuote = [Select Id from RecordType where sObjectType = 'Apttus_Proposal__Proposal__c' AND Name = 'North America Proposal'];
        String standardPricebookId =Test.getStandardPricebookId();
        Pricebook2 stdPriceBook = new Pricebook2(Id = standardPricebookId, IsActive = true);
        upsert stdPricebook;
        
        Id stndrdPBId = APTPS_DaikinTestDataUtility.getStandardPricebookId();
        Pricebook2 customPriceBook = new Pricebook2(Name = 'Custom Price Book', Description = 'Price Book', IsActive = true);
        insert customPriceBook;
        Product2 testProduct1 = APTPS_DaikinTestDataUtility.getProduct('Test Cab1');
        insert testProduct1;
        Product2 testProduct2 = APTPS_DaikinTestDataUtility.getProduct('Test Cab2');
        insert testProduct2;
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
        
        Opportunity testOpp = APTPS_DaikinTestDataUtility.getOpp(testAccount);
        testOpp.Name = 'Test Opp - LA';
        testOpp.Pricebook2Id = stndrdPBId;
        insert testOpp;
        
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
        test.startTest();
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
        testQuoteNA1.Risk_Amt__c =100;
        //testQuoteNA1.Contingency_Amt__c = 102;
        //testQuoteNA1.Contingency_pct__c = 10;
        insert testQuoteNA1;
        List<APTPS_Document_Line_Item__c> docLineItems =  new List<APTPS_Document_Line_Item__c>();
        docLineItems.add(new APTPS_Document_Line_Item__c(APTPS_Quote_Proposal__c = testQuoteNA1.Id));
        insert docLineItems;
        Apttus_Proposal__Proposal__c testQuoteNA2 = APTPS_DaikinTestDataUtility.getQuote(testAccount, testContact, testOpp, testPL);
        testQuoteNA2.Apttus_Proposal__Proposal_Name__c = 'Test Quote 2 - NA';
        testQuoteNA2.RecordTypeId = rtNAQuote.Id;
        testQuoteNA2.Risk_Amt__c =100;
        testQuoteNA2.Contingency_Amt__c = 102;
        testQuoteNA2.Contingency_pct__c = 10;
        testQuoteNA2.Primary__c = false;
        insert testQuoteNA2;
        Product2 testProduct3 = APTPS_DaikinTestDataUtility.getProduct('Test Cab3');
        insert testProduct3;
        Product2 testProduct4 = APTPS_DaikinTestDataUtility.getProduct('Test Cab4');
        insert testProduct4;
        test.stopTest();
    }
    public static testmethod void testQuoteSynchModule()
    {
        Apttus_Proposal__Proposal__c testQuoteNA2 = [select id,Name from Apttus_Proposal__Proposal__c limit 1];
        Product2 testProduct3 = [select id,Name from Product2 limit 1];
        Opportunity testOppLA = [select id,name from Opportunity limit 1];
        Product2 testProduct4 = [select id,Name from Product2 limit 1];
        test.startTest();
        Apttus_Proposal__Proposal_Line_Item__c testQuoteLineNA21 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = testQuoteNA2.Id,
                                                                                                              Apttus_Proposal__Product__c = testProduct3.Id, Apttus_QPConfig__Quantity2__c = 1, Apttus_Proposal__Quantity__c = 1,
                                                                                                              Apttus_QPConfig__ItemSequence__c = 1, Apttus_QPConfig__LineNumber__c = 1, Apttus_QPConfig__LineStatus__c = 'New',
                                                                                                              Apttus_QPConfig__LineType__c = 'Product/Service', Apttus_Proposal__Unit_Price__c = 100, Apttus_QPConfig__NetPrice__c = 100,
                                                                                                              DST_ID__c = 'DST_ID__c',
                                                                                                              Apttus_QPConfig__ClassificationHierarchy__c = 'Warranty (Parts & Material)',Apttus_QPConfig__BaseExtendedCost__c =121);
        testQuoteNA2.Apttus_Proposal__Opportunity__c = testOppLA.Id;
        insert testQuoteLineNA21;
 		delete testQuoteLineNA21;
        Apttus_Proposal__Proposal_Line_Item__c testQuoteLineNA211 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = testQuoteNA2.Id,
                                                                                                              Apttus_Proposal__Product__c = testProduct3.Id, Apttus_QPConfig__Quantity2__c = 1, Apttus_Proposal__Quantity__c = 1,
                                                                                                              Apttus_QPConfig__ItemSequence__c = 1, Apttus_QPConfig__LineNumber__c = 1, Apttus_QPConfig__LineStatus__c = 'New',
                                                                                                              Apttus_QPConfig__LineType__c = 'Product/Service', Apttus_Proposal__Unit_Price__c = 100, Apttus_QPConfig__NetPrice__c = 100,
                                                                                                              DST_ID__c = 'DST_ID__c',
                                                                                                              Apttus_QPConfig__ClassificationHierarchy__c = 'Warranty (Equipment)',Apttus_QPConfig__BaseExtendedCost__c =121);
        testQuoteNA2.Apttus_Proposal__Opportunity__c = testOppLA.Id;
        insert testQuoteLineNA211;
 		delete testQuoteLineNA211;
        test.stopTest();
    }
    public static testmethod void quoteLineItemTriggerHandlerTest()
    {
        Apttus_Proposal__Proposal__c testQuoteNA2 = [select id,Name from Apttus_Proposal__Proposal__c limit 1];
        Apttus_Proposal__Proposal__c testQuoteNA1 = [select id,Name from Apttus_Proposal__Proposal__c limit 1];
        testQuoteNA1.Contingency_pct__c = 80;
        update testQuoteNA1;
        Product2 testProduct3 = [select id,Name from Product2 limit 1];
        Opportunity testOppLA = [select id,name from Opportunity limit 1];
        Product2 testProduct4 = [select id,Name from Product2 limit 1];
        test.startTest();
        Apttus_Proposal__Proposal_Line_Item__c testQuoteLineNA21 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = testQuoteNA2.Id,
                                                                                                              Apttus_Proposal__Product__c = testProduct3.Id, Apttus_QPConfig__Quantity2__c = 1, Apttus_Proposal__Quantity__c = 1,
                                                                                                              Apttus_QPConfig__ItemSequence__c = 1, Apttus_QPConfig__LineNumber__c = 1, Apttus_QPConfig__LineStatus__c = 'New',
                                                                                                              Apttus_QPConfig__LineType__c = 'Product/Service', Apttus_Proposal__Unit_Price__c = 100, Apttus_QPConfig__NetPrice__c = 100,
                                                                                                              DST_ID__c = 'DST_ID__c',
                                                                                                              Apttus_QPConfig__ClassificationHierarchy__c = 'Risk',Apttus_QPConfig__BaseExtendedCost__c =121,Apttus_QPConfig__AdjustmentAmount__c =12);
        testQuoteNA2.Apttus_Proposal__Opportunity__c = testOppLA.Id;
        Apttus_Proposal__Proposal_Line_Item__c testQuoteLineNA22 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = testQuoteNA1.Id,
                                                                                                              Apttus_Proposal__Product__c = testProduct3.Id, Apttus_QPConfig__Quantity2__c = 1, Apttus_Proposal__Quantity__c = 1,
                                                                                                              Apttus_QPConfig__ItemSequence__c = 1, Apttus_QPConfig__LineNumber__c = 1, Apttus_QPConfig__LineStatus__c = 'New',
                                                                                                              Apttus_QPConfig__LineType__c = 'Product/Service', Apttus_Proposal__Unit_Price__c = 100, Apttus_QPConfig__NetPrice__c = 100,
                                                                                                              DST_ID__c = 'DST_ID__c',
                                                                                                              Apttus_QPConfig__ClassificationHierarchy__c = 'Contingency',Apttus_QPConfig__BaseExtendedCost__c =05,Apttus_QPConfig__AdjustmentAmount__c =55);
        testQuoteNA1.Apttus_Proposal__Opportunity__c = testOppLA.Id;
        Apttus_Proposal__Proposal_Line_Item__c testQuoteLineNA24 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = testQuoteNA1.Id,
                                                                                                              Apttus_Proposal__Product__c = testProduct3.Id, Apttus_QPConfig__Quantity2__c = 1, Apttus_Proposal__Quantity__c = 1,
                                                                                                              Apttus_QPConfig__ItemSequence__c = 1, Apttus_QPConfig__LineNumber__c = 1, Apttus_QPConfig__LineStatus__c = 'New',
                                                                                                              Apttus_QPConfig__LineType__c = 'Product/Service', Apttus_Proposal__Unit_Price__c = 100, Apttus_QPConfig__NetPrice__c = 100,
                                                                                                              DST_ID__c = 'DST_ID__c',
                                                                                                              Apttus_QPConfig__ClassificationHierarchy__c = 'Contingency',Apttus_QPConfig__BaseExtendedCost__c =05,Apttus_QPConfig__AdjustmentAmount__c =55);
        
        testQuoteNA2.Apttus_Proposal__Opportunity__c = testOppLA.Id;
        Apttus_Proposal__Proposal_Line_Item__c testQuoteLineNA23 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = testQuoteNA2.Id,
                                                                                                              Apttus_Proposal__Product__c = testProduct3.Id, Apttus_QPConfig__Quantity2__c = 1, Apttus_Proposal__Quantity__c = 1,
                                                                                                              Apttus_QPConfig__ItemSequence__c = 1, Apttus_QPConfig__LineNumber__c = 1, Apttus_QPConfig__LineStatus__c = 'New',
                                                                                                              Apttus_QPConfig__LineType__c = 'Product/Service', Apttus_Proposal__Unit_Price__c = 100, Apttus_QPConfig__NetPrice__c = 100,
                                                                                                              DST_ID__c = 'DST_ID__c',
                                                                                                              Apttus_QPConfig__ClassificationHierarchy__c = 'Warranty (Equipment)',Apttus_QPConfig__BaseExtendedCost__c =10,Apttus_QPConfig__AdjustmentAmount__c =12);
        testQuoteNA2.Apttus_Proposal__Opportunity__c = testOppLA.Id;
        list<Apttus_Proposal__Proposal_Line_Item__c> listOfLines = new list<Apttus_Proposal__Proposal_Line_Item__c>();
        listOfLines.add(testQuoteLineNA21);
        listOfLines.add(testQuoteLineNA22);
        listOfLines.add(testQuoteLineNA23);
        listOfLines.add(testQuoteLineNA24);
        insert listOfLines;
        Apttus_Config2__PriceRuleset__c ruleSet = new Apttus_Config2__PriceRuleset__c();
        ruleSet.Apttus_Config2__Sequence__c =1;
        insert ruleSet;
        Apttus_Config2__PriceRule__c priceRule = new Apttus_Config2__PriceRule__c();
        priceRule.Apttus_Config2__RulesetId__c = ruleSet.Id;
        priceRule.Apttus_Config2__Sequence__c = 2;
        insert priceRule;
        Apttus_Config2__PriceRuleEntry__c priceRuleEntry = new Apttus_Config2__PriceRuleEntry__c();
        priceRuleEntry.Apttus_Config2__Dimension1Value__c = 'Dallas District';
        priceRuleEntry.Apttus_Config2__AdjustmentAmount__c =120;
        priceRuleEntry.Apttus_Config2__PriceRuleId__c = priceRule.Id;
        priceRuleEntry.Apttus_Config2__Sequence__c = 3;
        insert priceRuleEntry;
        
        Apttus_QPConfig__ProposalProductAttributeValue__c   proposalAttribute = new Apttus_QPConfig__ProposalProductAttributeValue__c ();
        proposalAttribute.Center__c = 'Dallas District';
        proposalAttribute.Apttus_QPConfig__LineItemId__c = listOfLines[0].id;
        insert proposalAttribute;
        APTPS_QuoteLineItemTriggerHandler.assignRecordTypeOnQuoteLineFromParentQuote(listOfLines);
        APTPS_QuoteLineItemTriggerHandler.setConfigFinalizedDateOnQuotes(listOfLines,false);
        test.stopTest();
    }
    

}