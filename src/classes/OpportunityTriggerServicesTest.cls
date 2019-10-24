@isTest
private class OpportunityTriggerServicesTest {
	public static Account acc;
	static void setupOpporuntities() {
		AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c();
        ts1.AVA_SFCORE__Active_Setting__c = true;
        ts1.Name='Test Account';
        insert ts1;
        List<RecordType> recType = [SELECT Id, Name
                                    FROM RecordType
                                    WHERE DeveloperName = 'North_America'
                                    AND SobjectType = 'Opportunity'];
         

        acc = (Account) SObjectFactory.create(Account.SobjectType);
       	UnitTest.addData((List<Opportunity>)SObjectFactory.build(10, Opportunity.SobjectType, new Map<Schema.SobjectField, Object>{Opportunity.accountId =>acc.id, Opportunity.RecordTypeId => recType[0].Id}))
       	  .tag('All Opportunities');

	}
	@isTest static void filterOpporunitiyStageTest() {
		setupOpporuntities();

       	UnitTest.get('All Opportunities')
       	.branch('Closed/Won|Not Closed/Won');
       	UnitTest.get('Closed/Won').assign('StageName', OpportunityTriggerServices.CLOSED_WON);
       	UnitTest.get('Not Closed/Won').assign('StageName', 'No Bid');
       	UnitTest.get('All Opportunities').dummyInsert();

       	Test.startTest();
       		List<Opportunity> filteredOpps = OpportunityTriggerServices.filterClosedWon(UnitTest.get('All Opportunities').getList());
       	Test.stopTest();

   		UnitTest.analyze('Closed/Won').assertEquivalence(filteredOpps, 'This should have made it through the filter');
  }

  @isTest static void processOpportunitySplitsTest() {
    setupOpporuntities();
    UnitTest.get('All Opportunities')
      .assign('Amount', 100).insertAll();

    UnitTest.get('All Opportunities')
      .branch('Closed Won | Abandoned/Lost | Other');

    UnitTest.get('Closed Won')
      .assign('StageName', 'Closed Won')
      .assign('Won_Lost_Reason__c', 'Price');

    UnitTest.get('Abandoned/Lost')
      .assign('StageName', 'Abandoned');

    UnitTest.get('Other')
      .assign('StageName', 'Discover Needs');

    Test.startTest();
      UnitTest.get('All Opportunities').updateAll();
    Test.stopTest();

    Map<Id, List<OpportunitySplit>> oppIdToOppSplits = GroupBy.ids('OpportunityId', [SELECT SplitAmount, Closed_Won_Amount__c, Pipeline_Amount__c, OpportunityId
                                                                                      FROM OpportunitySplit
                                                                                      WHERE OpportunityId IN :UnitTest.getIds('All Opportunities')]);

    List<Opportunity> closedWonOpps = UnitTest.get('Closed Won').getList();
    for (Opportunity closedWonOpp : closedWonOpps) {
      List<OpportunitySplit> closedWonOppSplits = oppIdToOppSplits.get(closedWonOpp.Id);
      for (OpportunitySplit closedWonOppSplit : closedWonOppSplits) {
        //System.assertEquals(100, closedWonOppSplit.Closed_Won_Amount__c, 'The Closed Won Amount should be equal to $100');
       // System.assertEquals(null, closedWonOppSplit.Pipeline_Amount__c, 'The Closed Won Amount should be equal to null');
      }
    }

    List<Opportunity> lostOpps = UnitTest.get('Abandoned/Lost').getList();
    for (Opportunity lostOpp : lostOpps) {
      List<OpportunitySplit> lostOppSplits = oppIdToOppSplits.get(lostOpp.Id);
      for (OpportunitySplit lostOppSplit : lostOppSplits) {
     //   System.assertEquals(null, lostOppSplit.Closed_Won_Amount__c, 'The Closed Won Amount should be equal to null');
      //  System.assertEquals(null, lostOppSplit.Pipeline_Amount__c, 'The Closed Won Amount should be equal to null');
      }
    }

    List<Opportunity> otherOpps = UnitTest.get('Other').getList();
    for (Opportunity otherOpp : otherOpps) {
      List<OpportunitySplit> otherOppSplits = oppIdToOppSplits.get(otherOpp.Id);
      for (OpportunitySplit otherOppSplit : otherOppSplits) {
     //   System.assertEquals(null, otherOppSplit.Closed_Won_Amount__c, 'The Closed Won Amount should be equal to null');
     //   System.assertEquals(100, otherOppSplit.Pipeline_Amount__c, 'The Closed Won Amount should be equal to $100');
      }
    }

  }

	@isTest static void kickOffApprovalProcessTest() {
    setupOpporuntities();

		UnitTest.get('All Opportunities').insertAll();
    UnitTest.get('All Opportunities').assign('StageName', OpportunityTriggerServices.CLOSED_WON);

    Apttus_Config2__PriceList__c priceList = (Apttus_Config2__PriceList__c)
                                                   SObjectFactory.create(Apttus_Config2__PriceList__c.SobjectType);
    Map<Schema.SobjectField, Object> proposalFieldMap = new Map<Schema.SobjectField, Object>();
    proposalFieldMap.put(Apttus_Proposal__Proposal__c.Apttus_Proposal__Account__c, acc.id);
    proposalFieldMap.put(Apttus_Proposal__Proposal__c.Line_of_Business__c, 'Service & Repair - Quoted');
    proposalFieldMap.put(Apttus_Proposal__Proposal__c.Apttus_QPConfig__PriceListId__c, priceList.id);
    proposalFieldMap.put(Apttus_Proposal__Proposal__c.Credit_Pre_Approval_Required__c, true);
    proposalFieldMap.put(Apttus_Proposal__Proposal__c.Apttus_Proposal__Primary__c, true);

    UnitTest.addData((List<Apttus_Proposal__Proposal__c>)SObjectFactory.build(10, Apttus_Proposal__Proposal__c.SobjectType, proposalFieldMap))
      .tag('All Quote/Proposals');
    UnitTest.get('All Quote/Proposals')
        .branch('Checked|Not Checked');
    UnitTest.get('All Quote/Proposals').property('Apttus_Proposal__Opportunity__c').assignFrom('All Opportunities');
    UnitTest.get('All Quote/Proposals').insertAll();


    UnitTest.addData((List<Apttus_Proposal__Proposal_Line_Item__c>)SObjectFactory.build(10, Apttus_Proposal__Proposal_Line_Item__c.SobjectType))
        .tag('All line items');
    UnitTest.get('All line items')
        .branch('Less Then 5000|Greater Then 5000');
    UnitTest.get('Less Then 5000').property('Apttus_Proposal__Proposal__c').assignFrom('Not Checked');
    UnitTest.get('Less Then 5000').assign('Apttus_QPConfig__NetPrice__c',400);
    UnitTest.get('Greater Then 5000').property('Apttus_Proposal__Proposal__c').assignFrom('Checked');
    UnitTest.get('Greater Then 5000').assign('Apttus_QPConfig__NetPrice__c',5001);
   // UnitTest.get('All line items').insertAll();

   // UnitTest.get('All Quote/Proposals').updateAll();

    List<Opportunity> opps = UnitTest.get('All Opportunities').getList();
    Map<Id, Opportunity> idToOpp = new Map<Id, Opportunity>(opps);
    
        test.startTest();
    List<Apttus_Proposal__Proposal__c> quoteProposals = [SELECT Id, Apttus_Proposal__Primary__c, Credit_Approvals__c, Apttus_Proposal__Opportunity__c
                                                          FROM Apttus_Proposal__Proposal__c
                                                          WHERE Apttus_Proposal__Opportunity__c IN :opps];
    
      OpportunityTriggerServices.kickOffApprovalProcess(quoteProposals, idToOpp);
   

    List<ProcessInstance> processInstances = [SELECT Id, TargetObjectId FROM ProcessInstance];
 Test.stopTest();
    //System.assert(!processInstances.isEmpty(), 'This should not be empty');
   // System.assertEquals(10, processInstances.size(), 'This should have submitted a process');
	}


    @isTest static void processOpportunitySplitsOnAmountChange(){
        final Integer NEW_AMOUNT = 700;

        User testUser = (User)  SObjectFactory.create(User.SobjectType, new Map<Schema.SobjectField, Object>());
        Opportunity testOpportunity = (Opportunity)  SObjectFactory.create(Opportunity.SobjectType, new Map<Schema.SobjectField, Object>{Opportunity.Amount => 400});
        OpportunitySplit testSplit = (OpportunitySplit) SObjectFactory.create(OpportunitySplit.SobjectType, new Map<Schema.SobjectField, Object>{
            OpportunitySplit.OpportunityId => testOpportunity.Id,
            OpportunitySplit.SplitOwnerId => testUser.Id,
            OpportunitySplit.SplitPercentage => 50
        });

        final Decimal EXPECTED_AMOUNT = NEW_AMOUNT*(testSplit.SplitPercentage/100);

        testOpportunity.Amount = NEW_AMOUNT;

        Test.startTest();
        update testOpportunity;
        Test.stopTest();

        Opportunity_Splits_for_Templates__c outputTemplate = [select SplitAmount__c, SplitOwner__c, SplitPercent__c,Opportunity__c from Opportunity_Splits_for_Templates__c WHERE SplitOwner__c = :testUser.Id];

        System.assertEquals(
            EXPECTED_AMOUNT,
            outputTemplate.SplitAmount__c,
            'When an the amount on an opportunity is updated, the SplitAmount on the related opportunity split template should be updated as well.'
        );

        System.assertEquals(
            testSplit.SplitOwnerId,
            outputTemplate.SplitOwner__c,
            'When an the amount on an opportunity is updated, the SplitOwnerId on the related opportunity split template should be updated as well.'
        );

        System.assertEquals(
            testSplit.SplitPercentage,
            outputTemplate.SplitPercent__c,
            'When an the amount on an opportunity is updated, the SplitPercentage on the related opportunity split template should be updated as well.'
        );

        System.assertEquals(
            testSplit.OpportunityId,
            outputTemplate.Opportunity__c,
            'When an the amount on an opportunity is updated, the opportunityId on the related opportunity split template should be updated as well.'
        );
}
   
  /*  @isTest
    public static void updateRollupFieldsTest()
    {
        
         set<String> accountIds = new set<String>();
        set<String> userIds = new set<String>();
           Map<Id, Account> accObj = new Map<Id, Account>([Select id,name, Owner.Name, Owner.User_Department__c 
                                                        from Account WHERE Id IN  :accountIds]);
        
        Map<Id, User> userObj = new Map<Id, User>([SELECT Id, Name,User_Department__c from User WHERE id IN :userIds]);
   list<user> u =[SELECT Id, Name,User_Department__c from User];
        
     List<Account> ab= [select id,Name,OwnerId from Account limit 1];
        
        //user u = [select id,Name from User limit 1];
        List<Opportunity> optylist = new List<Opportunity>();
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c();
        ts1.AVA_SFCORE__Active_Setting__c = true;
        ts1.Name='Test Account';

         Profile p = [SELECT Id FROM Profile limit 1];
        
        user us = new user();
        us.LastName = 'test';
        us.Alias = 'standt10';
        us.EmailEncodingKey='UTF-8';
        us.LanguageLocaleKey='en_US';
        us.LocaleSidKey='en_US';
        us.ProfileId = p.Id;
        us.TimeZoneSidKey='America/Los_Angeles';
        us.User_Department__c = 'IT';
        us.UserName='standarduser@bluewolfgroup.com';
        us.Email='pavan.k@solunuscorp.com';
        insert us;
        
        insert ts1;
        Account a = new Account();
        a.OwnerId= u[0].id;
        a.Type = '';
        a.CurrencyIsoCode = '';
        a.Name = 'test';
        insert a;
        Opportunity o = new opportunity();
        o.Name ='test1';
        o.Vertical_Market__c ='Not Applicable';
        o.StageName='Abandoned';
        o.Probability=20;
        o.CloseDate = system.today();
        o.Consulting_Engineer_Owner__c=us.id;
        o.General_Contract_Owner__c = us.id;
        o.Architect_Owner__c =us.id;
        o.Mechanical_Contract_Owner__c=us.id;
        o.Owner_End_User_Info__c =us.id;
        o.Active_Bidder__c ='';
        o.Opportunity_Split_Owner__c ='';
        o.OwnerId=us.Id;
        o.Take_Off__c=us.Id;
        o.Consulting_Engineer__c=a.id;
        o.Project_Engineer__c=us.Id;
        o.Job_Captain_CE__c=us.Id;
        o.Job_Captain_Sales__c=us.Id;
        
        
        insert o;
       
        
        optylist.add(o);
        //  UnitTest.get('All Opportunities').assign('OwnerId', platuser.id);
          //UnitTest.get('All Opportunities').assign('Job_Captain_CE__c', acc.id);
        // UnitTest.get('All Opportunities').assign('Architect__c', acc.id);
       // UnitTest.get('All Opportunities').insertall();
       
        //List<Opportunity> newOpps =new List<Opportunity>();
       
        OpportunityTriggerServices.updateRollupFields(optylist);
        OpportunityTriggerServices.getPrimaryQuoteProposal(optylist);
    }*/
}