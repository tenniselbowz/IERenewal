@isTest
private class CloneWarningExtTest {
	public static Id recType = [SELECT Id, Name 
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


    @testsetup public static void setUp() {
		AVA_SFCORE__TaxNowSetting__c ts1 = (AVA_SFCORE__TaxNowSetting__c) SObjectFactory.create(AVA_SFCORE__TaxNowSetting__c.SobjectType);
    }
	public static void setupQuoteProposal() {
        Account acc = (Account) SObjectFactory.create(Account.SobjectType);
		opp = (Opportunity) SObjectFactory.create(Opportunity.SobjectType, new Map<Schema.SobjectField, Object>{Opportunity.accountId =>acc.id, Opportunity.RecordTypeId => recType, Opportunity.StageName  => 'No Bid', Opportunity.Vertical_Market__c => 'Airports & Transportation'});

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
        proposalFieldMap.put(Apttus_Proposal__Proposal__c.Line_of_Business__c, 'Test');

        quoteProp = (Apttus_Proposal__Proposal__c) 
                     SObjectFactory.create(Apttus_Proposal__Proposal__c.SobjectType, proposalFieldMap);

        testUser = (User)SObjectFactory.create(User.SobjectType,  new Map<Schema.SobjectField, Object>{User.DM_District_Manager__c => UserInfo.getUserId()});
	}

	@isTest static void cloneQuoteProposalConstructorTest() {
		setupQuoteProposal();
		ApexPages.StandardController sc = new ApexPages.StandardController(quoteProp);

		Test.startTest();
       		CloneWarningExt cloneExt = new CloneWarningExt(sc);
       	Test.stopTest();

       	System.assertEquals(cloneExt.recId, quoteProp.Id, 'This should be the correct Id');
	}

	@isTest static void cloneQuoteProposalCloneTest() {
		setupQuoteProposal();
		ApexPages.StandardController sc = new ApexPages.StandardController(quoteProp);
		CloneWarningExt cloneExt = new CloneWarningExt(sc);
		
		List<Apttus_Proposal__Proposal__c> beforeClone = [SELECT Id FROM Apttus_Proposal__Proposal__c];
		Test.startTest();
       		cloneExt.cloneSobject();
       		cloneExt.saveQuoteClone();
       	Test.stopTest();
       	
       	List<Apttus_Proposal__Proposal__c> afterClone = [SELECT Id FROM Apttus_Proposal__Proposal__c];

       	System.assertEquals(beforeClone.size()+1, afterClone.size(), 'There should have been one Quote/Proposal made');
	}
	
	@isTest static void cloneOpportunityConstructorTest() {
		setupQuoteProposal();

		ApexPages.StandardController sc = new ApexPages.StandardController(opp);

		Test.startTest();
       		CloneWarningExt cloneExt = new CloneWarningExt(sc);
       	Test.stopTest();

       	System.assertEquals(cloneExt.recId, opp.Id, 'This should be the correct Id');
	}

	@isTest static void cloneOpportunityPrimaryCloneTest() {
		setupQuoteProposal();
		ApexPages.StandardController sc = new ApexPages.StandardController(opp);
		CloneWarningExt cloneExt = new CloneWarningExt(sc);
		
		List<Apttus_Proposal__Proposal__c> beforeQuoteClone = [SELECT Id FROM Apttus_Proposal__Proposal__c];
		List<Apttus_Proposal__Proposal__c> beforeOppClone = [SELECT Id FROM Apttus_Proposal__Proposal__c];
		
		Test.startTest();
       		cloneExt.cloneSobject();
       		cloneExt.saveQuoteClone();
       	Test.stopTest();

       	List<Apttus_Proposal__Proposal__c> afterQuoteClone = [SELECT Id FROM Apttus_Proposal__Proposal__c];
       	List<Apttus_Proposal__Proposal__c> afterOppClone = [SELECT Id FROM Apttus_Proposal__Proposal__c];

       	System.assertEquals(beforeQuoteClone.size()+1, afterQuoteClone.size(), 'There should have been one Quote/Proposal made');
       	System.assertEquals(beforeQuoteClone.size()+1, afterOppClone.size(), 'There should have been one Quote/Proposal made');
	}

	@isTest static void cancelTest() {
		setupQuoteProposal();
		ApexPages.StandardController sc = new ApexPages.StandardController(opp);
		CloneWarningExt cloneExt = new CloneWarningExt(sc);
		List<Apttus_Proposal__Proposal__c> beforeOppClone = [SELECT Id FROM Apttus_Proposal__Proposal__c];

		cloneExt.cloneSobject();
		Test.startTest();
			PageReference pg = cloneExt.cancel();
		Test.stopTest();

       	List<Apttus_Proposal__Proposal__c> afterOppClone = [SELECT Id FROM Apttus_Proposal__Proposal__c];


		System.assert(pg.getUrl().contains(quoteProp.Id), 'This should have the opportunityId');
		System.assertEquals(beforeOppClone, afterOppClone, 'The size should not change');

	}
	
}