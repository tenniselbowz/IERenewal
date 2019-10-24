@isTest
private class CloneSObjectTest {
    public static Id oppRecType = [SELECT Id, Name 
                                   
                                   FROM RecordType 
                                   WHERE DeveloperName = 'North_America' 
                                   AND SobjectType = 'Opportunity'
                                   limit 1].Id;
    public static Id quoteRecType = [SELECT Id, Name 
                                     FROM RecordType 
                                     WHERE DeveloperName = 'North_America_Proposal' 
                                     AND SobjectType = 'Apttus_Proposal__Proposal__c'
                                     limit 1].Id;
    public static Opportunity opp;
    public static Apttus_Proposal__Proposal__c quoteProp;  
    public static User testUser;
    public static Map<String, List<Custom_Clone_System_Fields__mdt>> systemFields = GroupBy.strings('Object_Name__c', [SELECT Is_Lookup__c, Field_Api__c, Location__c, Object_Name__c, Type__c, Value__c, Copy_Clone__c FROM Custom_Clone_System_Fields__mdt]);
    public static Map<String, List<Clone_Field_Set_To_Clone__mdt>> cloneFieldSets = GroupBy.strings('Object_Name__c', [SELECT Field_Set_Name__c, Object_Name__c FROM Clone_Field_Set_To_Clone__mdt]);
    public static Map<String, List<Custom_Clone_Child_Object__mdt>> cloneChildObjects = GroupBy.strings('Object_Name__c', [SELECT Required_Fields__c, User_Lookup_Field__c, Copy_User_Field__c, Child_Field_on_Parent__c, Child_Object_Api__c, Parent_Lookup_Field__c, Object_Name__c FROM Custom_Clone_Child_Object__mdt]);
    
    @testsetup public static void setUp() {
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;    
    }
    public static void setupOpportunity() {
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;   
        
        Account acc = (Account) SObjectFactory.create(Account.SobjectType);
        opp = (Opportunity) SObjectFactory.create(Opportunity.SobjectType, new Map<Schema.SobjectField, Object>{Opportunity.accountId =>acc.id, Opportunity.RecordTypeId => oppRecType, Opportunity.StageName  => 'No Bid', Opportunity.Vertical_Market__c => 'Airports & Transportation'});
        
    }
    public static void setupQuoteProposal() {
        AVA_SFCORE__TaxNowSetting__c ts1 = (AVA_SFCORE__TaxNowSetting__c) SObjectFactory.create(AVA_SFCORE__TaxNowSetting__c.SobjectType);
        
        Account acc = (Account) SObjectFactory.create(Account.SobjectType);
        opp = (Opportunity) SObjectFactory.create(Opportunity.SobjectType, new Map<Schema.SobjectField, Object>{Opportunity.accountId =>acc.id, Opportunity.RecordTypeId => oppRecType, Opportunity.StageName  => 'No Bid', Opportunity.Vertical_Market__c => 'Airports & Transportation'});
        
        Apttus_Config2__PriceList__c priceList = (Apttus_Config2__PriceList__c) 
            SObjectFactory.create(Apttus_Config2__PriceList__c.SobjectType);
        
        Map<Schema.SobjectField, Object> proposalFieldMap = new Map<Schema.SobjectField, Object>();
        proposalFieldMap.put(Apttus_Proposal__Proposal__c.Apttus_Proposal__Opportunity__c, opp.id);
        proposalFieldMap.put(Apttus_Proposal__Proposal__c.Apttus_Proposal__Account__c, acc.id);
        proposalFieldMap.put(Apttus_Proposal__Proposal__c.Apttus_QPConfig__PriceListId__c, priceList.id);
        proposalFieldMap.put(Apttus_Proposal__Proposal__c.Apttus_Proposal__Primary__c, true);
        proposalFieldMap.put(Apttus_Proposal__Proposal__c.Proposal_Valid_for_Days__c, '30');
        proposalFieldMap.put(Apttus_Proposal__Proposal__c.T_C_Country__c, 'USA');
        proposalFieldMap.put(Apttus_Proposal__Proposal__c.Emergency_Service_Level__c, 'Not included - available on T&M basis');
        proposalFieldMap.put(Apttus_Proposal__Proposal__c.RecordTypeId, quoteRecType);
        proposalFieldMap.put(Apttus_Proposal__Proposal__c.Document_Presentation_Language__c, 'English');
        proposalFieldMap.put(Apttus_Proposal__Proposal__c.Billing_Terms__c, 'Due Upon Receipt');
        proposalFieldMap.put(Apttus_Proposal__Proposal__c.Quote_Presentation_Currency__c, 'USD');
        proposalFieldMap.put(Apttus_Proposal__Proposal__c.Line_of_Business__c, 'MA - Renewal');
       
        quoteProp = (Apttus_Proposal__Proposal__c) 
            SObjectFactory.create(Apttus_Proposal__Proposal__c.SobjectType, proposalFieldMap);
       
        testUser = (User)SObjectFactory.create(User.SobjectType,  new Map<Schema.SobjectField, Object>{User.DM_District_Manager__c => UserInfo.getUserId()});
    }
    
    @isTest static void OpportunityCloneTest() {
        setupOpportunity();
        Test.startTest();
        CloneSObject clone = new CloneSObject((Sobject)opp, 'Opportunity', 'Clone_Field_Mapping', systemFields.get('Opportunity'), cloneChildObjects.get('Opportunity'));
        clone.getCurrentRunningUser(UserInfo.getUserId());
        clone.populateMasterClone();
        clone.cloneFields();
        Test.stopTest();
        System.assert(clone.cloneObject instanceof Opportunity, 'This should be an opportunity');
        System.assertEquals(UserInfo.getUserId(), clone.currentUser.Id, 'This should be the correct User');
        for(Schema.FieldSetMember field : Schema.getGlobalDescribe().get('Opportunity').getDescribe().FieldSets.getMap().get('Clone_Field_Mapping').getFields()) {
            System.assertEquals(clone.masterObject.get(field.getFieldPath()), clone.cloneObject.get(field.getFieldPath()), field.getFieldPath() + ' field should match');
        }
        System.assertEquals(UserInfo.getUserId(), (String)clone.cloneObject.get('OwnerId'), 'This should be set correctly');
        System.assertEquals('Target/Lead Verification', (String)clone.cloneObject.get('StageName'), 'This should be set correctly');
        System.assertEquals(0, (Decimal)clone.cloneObject.get('Probability'), 'This should be set correctly');
    }
    
    @isTest static void QuoteProposalCloneTest() {
        setupQuoteProposal();
        CloneSObject clone;
        System.runAs(testUser) {
            Test.startTest();
            clone = new CloneSObject((Sobject)quoteProp, 'Apttus_Proposal__Proposal__c', 'Quote_Clone_Mapping', systemFields.get('Apttus_Proposal__Proposal__c'), cloneChildObjects.get('Apttus_Proposal__Proposal__c'));
            clone.getCurrentRunningUser(UserInfo.getUserId());
            clone.cloneFields();
            Test.stopTest();
        }
        System.assert(clone.cloneObject instanceof Apttus_Proposal__Proposal__c, 'This should be an Quote/Proposal');
        System.assertEquals(testUser.Id, clone.currentUser.Id, 'This should be the correct User');
        for(Schema.FieldSetMember field : Schema.getGlobalDescribe().get('Apttus_Proposal__Proposal__c').getDescribe().FieldSets.getMap().get('Quote_Clone_Mapping').getFields()) {
            System.assertEquals(clone.masterObject.get(field.getFieldPath()), clone.cloneObject.get(field.getFieldPath()), field.getFieldPath() + ' field should Match');
            
        }
        System.assert(((String)clone.cloneObject.get('Apttus_Proposal__Proposal_Name__c')).contains('- CLONED'), 'This should have the correct name');
        System.assertEquals('Draft', (String)clone.cloneObject.get('Apttus_Proposal__Approval_Stage__c'), 'This should be set correctly');
        System.assertEquals(null, (String)clone.cloneObject.get('DM_Approval_Name__c'), 'This should be the current User Name');
        System.assertEquals(UserInfo.getUserId(), (String)clone.cloneObject.get('DM_District_Manager__c'), 'This should be set to the correct User');
    }
    
    @isTest static void QuoteProposalCloneChildrenTest() {
        setupQuoteProposal();
        List<MA_Model__c> maModels = (List<MA_Model__c>)SObjectFactory.create(10, MA_Model__c.SObjectType,  new Map<Schema.SobjectField, Object>{MA_Model__c.Proposal__c => quoteProp.Id});
        
        CloneSObject clone;
        System.runAs(testUser) {
            clone = new CloneSObject((Sobject)quoteProp, 'Apttus_Proposal__Proposal__c', 'Quote_Clone_Mapping', systemFields.get('Apttus_Proposal__Proposal__c'), cloneChildObjects.get('Apttus_Proposal__Proposal__c'));
            clone.getCurrentRunningUser(UserInfo.getUserId());
            clone.populateMasterClone();
            clone.cloneFields();
            clone.saveCloneObject();
            
            Test.startTest();
            clone.cloneAndSaveChildObjects();	
            Test.stopTest();
        }
        
        
        
        //List<Apttus_Config2__ProductConfiguration__c> productConfigs = [SELECT Id, Apttus_Config2__Status__c FROM Apttus_Config2__ProductConfiguration__c WHERE Apttus_QPConfig__Proposald__c =: clone.cloneObject.Id];
        //System.assertEquals(1, productConfigs.size(), 'This should have created only one');
        //List<Apttus_Config2__LineItem__c> lineItems = [SELECT Id FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ConfigurationId__c =: productConfigs[0].Id];
        //System.assertEquals(5, lineItems.size(), 'This should be the same size as the master line items');
        
        
        
    }
    
    @isTest static void OpportunityCloneSaveTest() {
        setupOpportunity();
        
        CloneSObject clone = new CloneSObject((Sobject)opp, 'Opportunity', 'Clone_Field_Mapping', systemFields.get('Opportunity'), cloneChildObjects.get('Opportunity'));
        clone.getCurrentRunningUser(UserInfo.getUserId());
        clone.populateMasterClone();
        clone.cloneFields();
        
        Test.startTest();
        clone.saveCloneObject();		
        Test.stopTest();
        System.assertNotEquals(null, clone.cloneObject, 'This should have been properly inserted');
        List<Apexpages.Message> msgs =  ApexPages.getMessages();
        System.assert(msgs.isEmpty(), 'There should be no messages on the page');
    }
    
    @isTest static void OpportunityChildSaveTest() {
        setupOpportunity();
        testUser = (User)SObjectFactory.create(User.SobjectType,  new Map<Schema.SobjectField, Object>{User.DM_District_Manager__c => UserInfo.getUserId()});
        UnitTest.addData(SObjectFactory.create(10, OpportunityTeamMember.SObjectType, new Map<Schema.SobjectField, Object>{OpportunityTeamMember.OpportunityId => opp.Id, OpportunityTeamMember.UserId => testUser.Id}))
            .tag('Team Members');
        
        UnitTest.addData(SObjectFactory.create(10, Product2.SObjectType))
            .tag('Products');
        
        UnitTest.addData(SObjectFactory.build(10, PricebookEntry.SObjectType, new Map<Schema.SobjectField, Object>{PricebookEntry.isActive => true}))
            .tag('Pbe');
        UnitTest.get('Pbe').property('Product2Id').assignFrom('Products');
        UnitTest.get('Pbe').insertAll();
        
        UnitTest.addData(SObjectFactory.build(10, OpportunityLineItem.SObjectType , new Map<Schema.SobjectField, Object>{OpportunityLineItem.OpportunityId => opp.Id, OpportunityLineItem.Quantity => 1, OpportunityLineItem.TotalPrice => 0}))
            .tag('Oli');
        UnitTest.get('Oli').property('PricebookEntryId').assignFrom('Pbe');
        UnitTest.get('Oli').insertAll();
        
        CloneSObject clone = new CloneSObject((Sobject)opp, 'Opportunity', 'Clone_Field_Mapping', systemFields.get('Opportunity'), cloneChildObjects.get('Opportunity'));
        clone.getCurrentRunningUser(UserInfo.getUserId());
        clone.populateMasterClone();
        clone.cloneFields();
        clone.saveCloneObject();
        Test.startTest();
        clone.cloneAndSaveChildObjects();	
        Test.stopTest();
        
        List<OpportunityLineItem> clonedOlis = [SELECT Id, OpportunityId FROM OpportunityLineItem WHERE OpportunityId =: opp.Id];
        System.assertEquals(10, clonedOlis.size(), 'These should be the same size');
        Id userId = UserInfo.getUserId();
        List<OpportunityTeamMember> cloneTeamMembers = [SELECT Id, OpportunityId FROM OpportunityTeamMember WHERE OpportunityId =: opp.Id And UserId =: userId];
        System.assertEquals(1, cloneTeamMembers.size(), 'These should be the same size');
    }
    
}