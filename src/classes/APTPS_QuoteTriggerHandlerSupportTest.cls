@isTest
private class APTPS_QuoteTriggerHandlerSupportTest {
    
    @isTest static void populateOppLineItemNAOptionTest() {
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;
        Id recId = [SELECT Id FROM RecordType WHERE DeveloperName = 'North_America_Proposal' AND SObjectType = 'Apttus_Proposal__Proposal_Line_Item__c' Limit 1].Id;
        
        //DPL BEGIN 
        //Opportunity opp = (Opportunity)SObjectFactory.create(Opportunity.SObjectType);
        //OpportunityLineItem oli = (OpportunityLineItem)SObjectFactory.build(OpportunityLineItem.SObjectType, new Map<Schema.SObjectField, Object>{OpportunityLineItem.OpportunityId => opp.Id, OpportunityLineItem.Quantity => 1});
        //Apttus_Proposal__Proposal__c proposal = (Apttus_Proposal__Proposal__c)SObjectFactory.create(Apttus_Proposal__Proposal__c.SObjectType);
        Account acc = (Account) SObjectFactory.create(Account.SobjectType);
        Opportunity opp = getOpportunity(acc);
        OpportunityLineItem oli = (OpportunityLineItem)SObjectFactory.build(OpportunityLineItem.SObjectType, new Map<Schema.SObjectField, Object>{OpportunityLineItem.OpportunityId => opp.Id, OpportunityLineItem.Quantity => 1});
        Apttus_Proposal__Proposal__c proposal = getProposal(acc, opp);
        //DPL END
        Apttus_Proposal__Proposal_Line_Item__c lineItem = (Apttus_Proposal__Proposal_Line_Item__c)SObjectFactory.create(Apttus_Proposal__Proposal_Line_Item__c.SObjectType, new Map<Schema.SObjectField, Object>{Apttus_Proposal__Proposal_Line_Item__c.RecordTypeId => recId, Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__NetPrice__c => 150.00, Apttus_Proposal__Proposal_Line_Item__c.Term_in_Years__c => 2.0, Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__LineType__c => 'Option', Apttus_Proposal__Proposal_Line_Item__c.Apttus_Proposal__Proposal__c => proposal.Id});
        lineItem = [SELECT Id, Net_Term_Price__c,TAG_ID__c, RecordTypeId, Apttus_QPConfig__NetPrice__c, Estimated_Shipping_Date__c, Apttus_QPConfig__Quantity2__c, Apttus_Proposal__Quantity__c,List_price_Per_Unit__c, Cost_Net_per_Unit__c, Cost_per_unit__c, Additional_Description_Info__c, Multiplier__c, Margin__c, Actual_GM__c, GM_USD__c, Discount__c, Discount_USD__c,Misc_I__c,
                        Misc_Cost_I__c, Misc_II__c, Misc_Cost_II__c, Misc_Cost_III__c, Misc_III__c, Apttus_QPConfig__LineType__c, Item_Number__c, Apttus_Proposal__Proposal__c
                     FROM Apttus_Proposal__Proposal_Line_Item__c WHERE Id = :lineItem.Id];
        Test.startTest();
            OpportunityLineItem updatedOli = APTPS_QuoteTriggerHandlerSupport.populateOppLineItem(oli, lineItem);
        Test.stopTest();

        System.assertEquals(0, updatedOli.TotalPrice, 'This should be set to 0');
        System.assertEquals(lineItem.Net_Term_Price__c, updatedOli.Option_Selling_Price__c, 'This should be set the oli');
    }

    @isTest static void populateOppLineItemNANonOptionTest() {
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;
        Id recId = [SELECT Id FROM RecordType WHERE DeveloperName = 'North_America_Proposal' AND SObjectType = 'Apttus_Proposal__Proposal_Line_Item__c' Limit 1].Id;
        
        //DPL BEGIN
        //Opportunity opp = (Opportunity)SObjectFactory.create(Opportunity.SObjectType);
        //OpportunityLineItem oli = (OpportunityLineItem)SObjectFactory.build(OpportunityLineItem.SObjectType, new Map<Schema.SObjectField, Object>{OpportunityLineItem.OpportunityId => opp.Id, OpportunityLineItem.Quantity => 1});
        //Apttus_Proposal__Proposal__c proposal = (Apttus_Proposal__Proposal__c)SObjectFactory.create(Apttus_Proposal__Proposal__c.SObjectType);
        Account acc = (Account) SObjectFactory.create(Account.SobjectType);
        Opportunity opp = getOpportunity(acc);
        OpportunityLineItem oli = (OpportunityLineItem)SObjectFactory.build(OpportunityLineItem.SObjectType, new Map<Schema.SObjectField, Object>{OpportunityLineItem.OpportunityId => opp.Id, OpportunityLineItem.Quantity => 1});
        Apttus_Proposal__Proposal__c proposal = getProposal(acc, opp);
        //DPL END
        Apttus_Proposal__Proposal_Line_Item__c lineItem = (Apttus_Proposal__Proposal_Line_Item__c)SObjectFactory.create(Apttus_Proposal__Proposal_Line_Item__c.SObjectType, new Map<Schema.SObjectField, Object>{Apttus_Proposal__Proposal_Line_Item__c.RecordTypeId => recId, Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__NetPrice__c => 150.00, Apttus_Proposal__Proposal_Line_Item__c.Term_in_Years__c => 0.0, Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__LineType__c => 'Product/Service', Apttus_Proposal__Proposal_Line_Item__c.Apttus_Proposal__Proposal__c => proposal.Id});
        lineItem = [SELECT Id, Net_Term_Price__c,TAG_ID__c, RecordTypeId, Apttus_QPConfig__NetPrice__c, Estimated_Shipping_Date__c, Apttus_QPConfig__Quantity2__c, Apttus_Proposal__Quantity__c,List_price_Per_Unit__c, Cost_Net_per_Unit__c, Cost_per_unit__c, Additional_Description_Info__c, Multiplier__c, Margin__c, Actual_GM__c, GM_USD__c, Discount__c, Discount_USD__c,Misc_I__c,
                        Misc_Cost_I__c, Misc_Cost_II__c, Misc_II__c, Misc_Cost_III__c, Misc_III__c, Apttus_QPConfig__LineType__c, Item_Number__c, Apttus_Proposal__Proposal__c
                     FROM Apttus_Proposal__Proposal_Line_Item__c WHERE Id = :lineItem.Id];
        Test.startTest();
            OpportunityLineItem updatedOli = APTPS_QuoteTriggerHandlerSupport.populateOppLineItem(oli, lineItem);
        Test.stopTest();

        System.assertEquals(null, updatedOli.Option_Selling_Price__c, 'This should be set the oli');
        System.assertEquals(lineItem.Net_Term_Price__c, updatedOli.TotalPrice, 'This should be set to 0');
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

        return (Apttus_Proposal__Proposal__c)SObjectFactory.create(Apttus_Proposal__Proposal__c.SObjectType, proposalFieldMap);
    }

/*
    @isTest static void populateOppLineItemLATest() {
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;
        Id recId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Latin_America_Proposal' AND SObjectType = 'Apttus_Proposal__Proposal_Line_Item__c' Limit 1].Id;
        
        //DPL BEGIN TO fix flow trigger failure
        //Opportunity opp = (Opportunity)SObjectFactory.create(Opportunity.SObjectType);
        //OpportunityLineItem oli = (OpportunityLineItem)SObjectFactory.build(OpportunityLineItem.SObjectType, new Map<Schema.SObjectField, Object>{OpportunityLineItem.OpportunityId => opp.Id, OpportunityLineItem.Quantity => 1});
        //Apttus_Proposal__Proposal__c proposal = (Apttus_Proposal__Proposal__c)SObjectFactory.create(Apttus_Proposal__Proposal__c.SObjectType);
        Account acc = (Account) SObjectFactory.create(Account.SobjectType);
        Opportunity opp = getOpportunity(acc);
        OpportunityLineItem oli = (OpportunityLineItem)SObjectFactory.build(OpportunityLineItem.SObjectType, new Map<Schema.SObjectField, Object>{OpportunityLineItem.OpportunityId => opp.Id, OpportunityLineItem.Quantity => 1});
        Apttus_Proposal__Proposal__c proposal = getProposal(acc, opp);
        //DPL END

        Apttus_Proposal__Proposal_Line_Item__c lineItem = (Apttus_Proposal__Proposal_Line_Item__c)SObjectFactory.create(Apttus_Proposal__Proposal_Line_Item__c.SObjectType, new Map<Schema.SObjectField, Object>{Apttus_Proposal__Proposal_Line_Item__c.RecordTypeId => recId, Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__NetPrice__c => 150.00, Apttus_Proposal__Proposal_Line_Item__c.Term_in_Years__c => 1.0, Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__LineType__c => 'Option', Apttus_Proposal__Proposal_Line_Item__c.Apttus_Proposal__Proposal__c => proposal.Id});
        
        Test.startTest();
            OpportunityLineItem updatedOli = APTPS_QuoteTriggerHandlerSupport.populateOppLineItem(oli, lineItem);
        Test.stopTest();


        System.assertEquals(lineItem.Apttus_QPConfig__NetPrice__c, updatedOli.TotalPrice, 'This should be set to 0');
        System.assertEquals(null, updatedOli.Option_Selling_Price__c, 'This should be set the oli');
    }
*/    
}