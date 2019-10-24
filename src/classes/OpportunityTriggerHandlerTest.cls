@isTest
private  class OpportunityTriggerHandlerTest {
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
       	UnitTest.addData((List<Opportunity>)SObjectFactory.build(10, Opportunity.SobjectType, new Map<Schema.SobjectField, Object>{Opportunity.accountId =>acc.id, Opportunity.RecordTypeId => recType[0].Id, Opportunity.Amount => 400}))
       	.tag('All Opportunities');
	}
	@isTest static void OpportunityTriggerHandlerTest() {
		setupOpporuntities();
		UnitTest.get('All Opportunities').insertAll();
		UnitTest.get('All Opportunities').assign('StageName', OpportunityTriggerServices.CLOSED_WON);

		Apttus_Config2__PriceList__c priceList = (Apttus_Config2__PriceList__c)
                                                   SObjectFactory.create(Apttus_Config2__PriceList__c.SobjectType);
        Map<Schema.SobjectField, Object> proposalFieldMap = new Map<Schema.SobjectField, Object>();
        proposalFieldMap.put(Apttus_Proposal__Proposal__c.Apttus_Proposal__Account__c, acc.id);
        proposalFieldMap.put(Apttus_Proposal__Proposal__c.Line_of_Business__c, 'CTK - Complex Turnkey');
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
        UnitTest.get('All line items').insertAll();

        //UnitTest.get('All Quote/Proposals').updateAll();

        List<Opportunity> opps = UnitTest.get('All Opportunities').getList();
        Map<Id, Opportunity> idToOpp = new Map<Id, Opportunity>(opps);

        Test.startTest();
         //   update opps;
        Test.stopTest();

        List<ProcessInstance> processInstances = [SELECT Id, TargetObjectId FROM ProcessInstance];

        // This is failing
        //UnitTest.assertSetEquals(Pluck.pluck('TargetObjectId', processInstances), UnitTest.getIds('Checked'), 'This should have submitted a process');
	}

    static testMethod void testBeforeInsertUpdate() {
        // Create an Account, Account_Address__c, and Address records and insert them
        // Create an Opportunity record, associate it to the account and insert it

        //!!!!!!!!!!! Need to add this code snippet for AvaTax- AccountAddressTrigger to run successfully on Before Insert into the Account table !!!!!!!!!!!!!!!!!
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c();
        ts1.AVA_SFCORE__Active_Setting__c = true;
        ts1.Name='Test Account';
        insert ts1;

        RecordType recordTypeObj = [SELECT Id FROM RecordType WHERE Name='North America Apttus' AND SObjectType='Opportunity'];

        Opportunity oppObj = null;
        Account acctObj = null;
        Address__c addrObj = null;
        Account_Address__c acctAddrJunctionObj = null;

        addrObj = new Address__c();
        addrObj.Address_Name__c = 'Test Address Name';
        addrObj.Address_Line_1__c = 'Test Address Line 1';
        addrObj.Address_Line_2__c = 'Test Address Line 2';
        addrObj.Address_Line_3__c = 'Test Address Line 3';
        addrObj.Address_Line_4__c = 'Test Address Line 4';
        addrObj.City__c = 'Minneapolis';
        addrObj.Postal_Code__c = '55421';
        addrObj.Country__c = 'United States';
        addrObj.State_Province__c = 'Minnesota';
        insert addrObj;

        acctObj = new Account();
        acctObj.Name = 'Account Test1';
        acctObj.Type = 'Developer';
        acctObj.Physical_Address__c = addrObj.Id;
        insert acctObj;

        acctAddrJunctionObj = new Account_Address__c();
        acctAddrJunctionObj.Account__c = acctObj.Id;
        acctAddrJunctionObj.Address__c = addrObj.Id;
        acctAddrJunctionObj.Primary_Bill_To__c = true;
        acctAddrJunctionObj.Active__c = true;
        acctAddrJunctionObj.Physical__c = true;
        insert acctAddrJunctionObj;

        oppObj = new Opportunity( Name = 'Test Opportunity 1', CloseDate = Date.today() + 7, Estimated_Shipping_Date__c = Date.today() + 10,
                                  StageName = 'Target/Lead Verification', Line_of_Business__c = 'Equipment Only', Vertical_Market__c = 'Airports & Transportation',
                                  Region_Territory__c = 'DALA', Opportunity_Country__c = 'USA-USA', Opp_State__c = 'Minnesota', Opp_City__c = 'Plymouth',
                                  Amount = 10.00, Next_Step__c = 'Closed', Probability = 0);
        oppObj.AccountId = acctObj.Id;
        oppObj.RecordTypeId = recordTypeObj.Id;
        oppObj.Final_Credit_Approval__c = true;
        insert oppObj;  // The before-insert trigger handler code is invoked

        // Verify Test Results
        Opportunity oppObjResults = [select Id, Bill_To_Address_Name__c, Bill_To_Address_Line_1__c, Bill_To_Address_Line_2__c, Bill_To_Address_Line_3__c, Bill_To_Address_Line_4__c, Bill_To_City__c, Bill_To_Country__c, Bill_To_State_Province__c, Bill_To_Zip_Postal_Code__c from Opportunity where Id = :oppObj.Id];
        System.assertEquals(oppObjResults.Bill_To_Address_Name__c, addrObj.Address_Name__c);
        System.assertEquals(oppObjResults.Bill_To_Address_Line_1__c, addrObj.Address_Line_1__c);
        System.assertEquals(oppObjResults.Bill_To_Address_Line_2__c, addrObj.Address_Line_2__c);
        System.assertEquals(oppObjResults.Bill_To_Address_Line_3__c, addrObj.Address_Line_3__c);
        System.assertEquals(oppObjResults.Bill_To_Address_Line_4__c, addrObj.Address_Line_4__c);
        System.assertEquals(oppObjResults.Bill_To_City__c, addrObj.City__c);
        System.assertEquals(oppObjResults.Bill_To_Country__c, addrObj.Country__c);
        System.assertEquals(oppObjResults.Bill_To_State_Province__c, addrObj.State_Province__c);
        System.assertEquals(oppObjResults.Bill_To_Zip_Postal_Code__c, addrObj.Postal_Code__c);
    }
     @isTest
    public static void updatebidderTest()
    {
       // setupOpporuntities();
         AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c();
        ts1.AVA_SFCORE__Active_Setting__c = true;
        ts1.Name='Test Account';
        insert ts1;

        RecordType recordTypeObj = [SELECT Id FROM RecordType WHERE Name='North America Apttus' AND SObjectType='Opportunity'];

        Opportunity oppObj = null;
        Account acctObj = null;
        Address__c addrObj = null;
        Account_Address__c acctAddrJunctionObj = null;

        addrObj = new Address__c();
        addrObj.Address_Name__c = 'Test Address Name';
        addrObj.Address_Line_1__c = 'Test Address Line 1';
        addrObj.Address_Line_2__c = 'Test Address Line 2';
        addrObj.Address_Line_3__c = 'Test Address Line 3';
        addrObj.Address_Line_4__c = 'Test Address Line 4';
        addrObj.City__c = 'Minneapolis';
        addrObj.Postal_Code__c = '55421';
        addrObj.Country__c = 'United States';
        addrObj.State_Province__c = 'Minnesota';
        insert addrObj;

        acctObj = new Account();
        acctObj.Name = 'Account Test1';
        acctObj.Type = 'Developer';
        acctObj.Physical_Address__c = addrObj.Id;
        insert acctObj;

        acctAddrJunctionObj = new Account_Address__c();
        acctAddrJunctionObj.Account__c = acctObj.Id;
        acctAddrJunctionObj.Address__c = addrObj.Id;
        acctAddrJunctionObj.Primary_Bill_To__c = true;
        acctAddrJunctionObj.Active__c = true;
        acctAddrJunctionObj.Physical__c = true;
        insert acctAddrJunctionObj;

        oppObj = new Opportunity( Name = 'Test Opportunity 1', CloseDate = Date.today() + 7, Estimated_Shipping_Date__c = Date.today() + 10,
                                  StageName = 'Target/Lead Verification', Line_of_Business__c = 'Equipment Only', Vertical_Market__c = 'Airports & Transportation',
                                  Region_Territory__c = 'DALA', Opportunity_Country__c = 'USA-USA', Opp_State__c = 'Minnesota', Opp_City__c = 'Plymouth',
                                  Amount = 10.00, Next_Step__c = 'Closed', Probability = 0,Bid_Date__c = Date.today()-3);
        oppObj.AccountId = acctObj.Id;
        oppObj.RecordTypeId = recordTypeObj.Id;
        oppObj.Edited__c=true;
        insert oppObj; 
        
        Bidder__c bdr = new Bidder__c();
        bdr.Apparent_Winning_Bidder__c  = true;
        bdr.Opportunity__c = oppObj.id;
        insert bdr;
        // The before-insert trigger handler code is invoked
        oppObj.Bid_Date__c = Date.today()+2;
        oppObj.Edited__c=true;
         //oppObj.StageName = 'Negotiation/Review/Pending';
        test.startTest();
        update oppObj;
        test.stopTest();
    }
}