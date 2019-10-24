@isTest
private class APTPS_QuoteLineItemTriggerHandlerTest {
    @isTest
    public static void isDeleteTriggertestMethod()
    {
          AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;
        
        //Need a quote and some line items with attribute values, etc.
        Account acc = (Account) SObjectFactory.create(Account.SobjectType);
        Opportunity opp = getOpportunity(acc);
        OpportunityLineItem oli = (OpportunityLineItem)SObjectFactory.build(OpportunityLineItem.SObjectType, new Map<Schema.SObjectField, Object>{OpportunityLineItem.OpportunityId => opp.Id, OpportunityLineItem.Quantity => 1});
        Apttus_Proposal__Proposal__c proposal = getProposal(acc, opp);
        System.debug('Proposal Quote :::'+proposal);
        
    
      
       Apttus_Proposal__Proposal_Line_Item__c lineItem = (Apttus_Proposal__Proposal_Line_Item__c)SObjectFactory.create(
            Apttus_Proposal__Proposal_Line_Item__c.SObjectType, new Map<Schema.SObjectField, Object>{
                Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__NetPrice__c => 120.00,
                    Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__BaseExtendedCost__c=>110.00,
                    Apttus_Proposal__Proposal_Line_Item__c.Term_in_Years__c => 1.0, 
                    Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__LineType__c => 'Product/Service',
                    Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__ClassificationHierarchy__c =>'Risk',
                    Apttus_Proposal__Proposal_Line_Item__c.Apttus_Proposal__Proposal__c => proposal.Id});
        
        Apttus_Proposal__Proposal_Line_Item__c lineItem1 = (Apttus_Proposal__Proposal_Line_Item__c)SObjectFactory.create(
            Apttus_Proposal__Proposal_Line_Item__c.SObjectType, new Map<Schema.SObjectField, Object>{
                Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__NetPrice__c => 140.00,
                    Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__BaseExtendedCost__c=>110.00,
                    Apttus_Proposal__Proposal_Line_Item__c.Term_in_Years__c => 1.0, 
                    Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__LineType__c => 'Product/Service',
                    Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__ClassificationHierarchy__c =>'Contingency',
                    Apttus_Proposal__Proposal_Line_Item__c.Apttus_Proposal__Proposal__c => proposal.Id});
        
        Apttus_Proposal__Proposal_Line_Item__c lineItem3 = (Apttus_Proposal__Proposal_Line_Item__c)SObjectFactory.create(Apttus_Proposal__Proposal_Line_Item__c.SObjectType, new Map<Schema.SObjectField, Object>{
            Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__NetPrice__c => 160.00,
                
                Apttus_Proposal__Proposal_Line_Item__c.Term_in_Years__c => 1.0, 
                Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__LineType__c => 'Product/Service',
                Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__ClassificationHierarchy__c =>'Warranty (Equipment)',
                Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__AdjustmentAmount__c=>100.00,
                Apttus_Proposal__Proposal_Line_Item__c.Apttus_Proposal__Proposal__c => proposal.Id});
        //Id, 
        //Apttus_Proposal__Proposal__c,
        // Apttus_Proposal__Proposal__r.Warranty_Parts_Material_Amt__c, 
        // Apttus_Proposal__Proposal__r.Warranty_Parts_Material__c,
        //  Apttus_Proposal__Proposal__r.Warranty_Equipment_Amt__c, 
        //  Apttus_Proposal__Proposal__r.Warranty_Equipment__c, 
        //  Apttus_QPConfig__ClassificationHierarchy__c, 
        //  Apttus_QPConfig__LineType__c from Apttus_Proposal__Proposal_Line_Item__c 
        Apttus_Proposal__Proposal_Line_Item__c lineItem2 = (Apttus_Proposal__Proposal_Line_Item__c)SObjectFactory.create(Apttus_Proposal__Proposal_Line_Item__c.SObjectType, new Map<Schema.SObjectField, Object>{
            Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__NetPrice__c => 180.00,
                Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__BaseExtendedCost__c=>190.00,
                Apttus_Proposal__Proposal_Line_Item__c.Term_in_Years__c => 1.0,
                Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__LineType__c => 'Product/Service',
                Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__ClassificationHierarchy__c =>'Warranty (Parts & Material)',
                Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__AdjustmentAmount__c=>100.00,
                Apttus_Proposal__Proposal_Line_Item__c.Apttus_Proposal__Proposal__c => proposal.Id});
           
        List<Apttus_Proposal__Proposal_Line_Item__c> l = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        l.add(lineItem);
        l.add(lineItem1);
        l.add(lineItem2);
        l.add(lineItem3);
        delete l;
        
       
        
    }
    
    @isTest static void setBlendedRateOnQuotesTest() {
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;
        
        //Need a quote and some line items with attribute values, etc.
        Account acc = (Account) SObjectFactory.create(Account.SobjectType);
        Opportunity opp = getOpportunity(acc);
        OpportunityLineItem oli = (OpportunityLineItem)SObjectFactory.build(OpportunityLineItem.SObjectType, new Map<Schema.SObjectField, Object>{OpportunityLineItem.OpportunityId => opp.Id, OpportunityLineItem.Quantity => 1});
        Apttus_Proposal__Proposal__c proposal = getProposal(acc, opp);
        System.debug('Proposal Quote :::'+proposal);
        
    
      
       Apttus_Proposal__Proposal_Line_Item__c lineItem = (Apttus_Proposal__Proposal_Line_Item__c)SObjectFactory.create(
            Apttus_Proposal__Proposal_Line_Item__c.SObjectType, new Map<Schema.SObjectField, Object>{
                Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__NetPrice__c => 120.00,
                    Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__BaseExtendedCost__c=>110.00,
                    Apttus_Proposal__Proposal_Line_Item__c.Term_in_Years__c => 1.0, 
                    Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__LineType__c => 'Product/Service',
                    Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__ClassificationHierarchy__c =>'Risk',
                    Apttus_Proposal__Proposal_Line_Item__c.Apttus_Proposal__Proposal__c => proposal.Id});
        
        Apttus_Proposal__Proposal_Line_Item__c lineItem1 = (Apttus_Proposal__Proposal_Line_Item__c)SObjectFactory.create(
            Apttus_Proposal__Proposal_Line_Item__c.SObjectType, new Map<Schema.SObjectField, Object>{
                Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__NetPrice__c => 140.00,
                    Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__BaseExtendedCost__c=>110.00,
                    Apttus_Proposal__Proposal_Line_Item__c.Term_in_Years__c => 1.0, 
                    Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__LineType__c => 'Product/Service',
                    Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__ClassificationHierarchy__c =>'Contingency',
                    Apttus_Proposal__Proposal_Line_Item__c.Apttus_Proposal__Proposal__c => proposal.Id});
        
        Apttus_Proposal__Proposal_Line_Item__c lineItem3 = (Apttus_Proposal__Proposal_Line_Item__c)SObjectFactory.create(Apttus_Proposal__Proposal_Line_Item__c.SObjectType, new Map<Schema.SObjectField, Object>{
            Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__NetPrice__c => 160.00,
                
                Apttus_Proposal__Proposal_Line_Item__c.Term_in_Years__c => 1.0, 
                Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__LineType__c => 'Product/Service',
                Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__ClassificationHierarchy__c =>'Warranty (Equipment)',
                Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__AdjustmentAmount__c=>100.00,
                Apttus_Proposal__Proposal_Line_Item__c.Apttus_Proposal__Proposal__c => proposal.Id});
        
        Apttus_Proposal__Proposal_Line_Item__c lineItem2 = (Apttus_Proposal__Proposal_Line_Item__c)SObjectFactory.create(Apttus_Proposal__Proposal_Line_Item__c.SObjectType, new Map<Schema.SObjectField, Object>{
            Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__NetPrice__c => 180.00,
                Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__BaseExtendedCost__c=>190.00,
                Apttus_Proposal__Proposal_Line_Item__c.Term_in_Years__c => 1.0,
                Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__LineType__c => 'Product/Service',
                Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__ClassificationHierarchy__c =>'Warranty (Parts & Material)',
                Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__AdjustmentAmount__c=>100.00,
                Apttus_Proposal__Proposal_Line_Item__c.Apttus_Proposal__Proposal__c => proposal.Id});
        List<Apttus_Proposal__Proposal_Line_Item__c> l = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        Apttus_QPConfig__ProposalProductAttributeValue__c proProductAtrValue = new Apttus_QPConfig__ProposalProductAttributeValue__c();
        proProductAtrValue.Apttus_QPConfig__LineItemId__c  = lineItem.id;
        proProductAtrValue.Center__c = 'Minneapolis District';
        insert proProductAtrValue;
        
        Apttus_QPConfig__ProposalProductAttributeValue__c proProductAtrValue1 = new Apttus_QPConfig__ProposalProductAttributeValue__c();
        proProductAtrValue1.Apttus_QPConfig__LineItemId__c  = lineItem1.id;
        proProductAtrValue1.Center__c = 'Princeton District';
        insert proProductAtrValue1;
        
        Apttus_QPConfig__ProposalProductAttributeValue__c proProductAtrValue2 = new Apttus_QPConfig__ProposalProductAttributeValue__c();
        proProductAtrValue2.Apttus_QPConfig__LineItemId__c  = lineItem2.id;
        proProductAtrValue2.Center__c = 'Nashville Center';
     //   insert proProductAtrValue2;
        
        l.add(lineItem);
        l.add(lineItem1);
        l.add(lineItem2);
        l.add(lineItem3);
          
        Apttus_Config2__PriceRuleset__c priceRuleSet = new Apttus_Config2__PriceRuleset__c();
        priceRuleSet.Apttus_Config2__Active__c = true;
        priceRuleSet.Apttus_Config2__Category__c = 'Proposal';
        priceRuleSet.Name = 'usd rule name';
        priceRuleSet.Apttus_Config2__ApplicationMethod__c = 'Line Item';
        priceRuleSet.Apttus_Config2__Sequence__c = 22.00;
        insert priceRuleSet;
        
        Apttus_Config2__PriceRule__c priceRule = new Apttus_Config2__PriceRule__c();
        priceRule.Apttus_Config2__Sequence__c = 22.00;
        priceRule.Apttus_Config2__Description__c = 'test description';
        priceRule.Apttus_Config2__RulesetId__c = priceRuleSet.id;
        insert priceRule;
        Apttus_Config2__PriceRuleEntry__c priceRuleEntryObj = new Apttus_Config2__PriceRuleEntry__c();
        priceRuleEntryObj.Apttus_Config2__Dimension1Value__c = 'Minneapolis District';
        priceRuleEntryObj.Apttus_Config2__AdjustmentAmount__c = 100.00;
        priceRuleEntryObj.Apttus_Config2__Sequence__c = 3;
        priceRuleEntryObj.Apttus_Config2__PriceRuleId__c = priceRule.id;
        insert priceRuleEntryObj;

        Test.startTest();
        
        APTPS_QuoteLineItemTriggerHandler.assignRecordTypeOnQuoteLineFromParentQuote(l);
        APTPS_QuoteLineItemTriggerHandler.setConfigFinalizedDateOnQuotes(l, false);
        APTPS_QuoteLineItemTriggerHandler.setBlendedRateOnQuotes(l);
        Test.stopTest();
       
    }    
    
    private static Opportunity getOpportunity(Account acc){
        List<RecordType> recType = [SELECT Id, Name 
                                    FROM RecordType 
                                    WHERE DeveloperName = 'North_America' 
                                    AND SobjectType = 'Opportunity'];
        return (Opportunity) SObjectFactory.create(Opportunity.SobjectType, new Map<Schema.SobjectField, Object>{Opportunity.accountId =>acc.id, Opportunity.RecordTypeId => recType[0].Id, Opportunity.StageName  => 'No Bid'});
    }
    
    private static Apttus_Proposal__Proposal__c getProposal(Account acc, Opportunity opp){
        Apttus_Config2__PriceList__c priceList = (Apttus_Config2__PriceList__c) SObjectFactory.create(Apttus_Config2__PriceList__c.SobjectType);
        
        Map<Schema.SobjectField, Object> proposalFieldMap = new Map<Schema.SobjectField, Object>();
        proposalFieldMap.put(Apttus_Proposal__Proposal__c.Apttus_Proposal__Opportunity__c, opp.id);
        proposalFieldMap.put(Apttus_Proposal__Proposal__c.Apttus_Proposal__Account__c, acc.id);
        proposalFieldMap.put(Apttus_Proposal__Proposal__c.Apttus_QPConfig__PriceListId__c, priceList.id);
        proposalFieldMap.put(Apttus_Proposal__Proposal__c.Contingency_Amt__c, 14.1205);
        proposalFieldMap.put(Apttus_Proposal__Proposal__c.Contingency_pct__c, 5);
        proposalFieldMap.put(Apttus_Proposal__Proposal__c.Warranty_Equipment_Amt__c, 2210);
        proposalFieldMap.put(Apttus_Proposal__Proposal__c.Warranty_Equipment__c, 5);
        proposalFieldMap.put(Apttus_Proposal__Proposal__c.Warranty_Parts_Material_Amt__c, 14.1205);
        proposalFieldMap.put(Apttus_Proposal__Proposal__c.Warranty_Parts_Material__c, 5);
       
        
        
        return (Apttus_Proposal__Proposal__c)SObjectFactory.create(Apttus_Proposal__Proposal__c.SObjectType, proposalFieldMap);
    }
}