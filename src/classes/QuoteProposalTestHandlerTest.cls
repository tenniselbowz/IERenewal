@isTest
public class QuoteProposalTestHandlerTest {
    static Account acct;
    static Address__c addy;
    static Account_Address__c aAddy;
    
    static void setupData(){
        
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;
        
        acct = TestingUtils.createAccounts(1, 'TestAccount', false)[0];
        addy = TestingUtils.createAddresses(1, true)[0];
        
    }
   /* static testMethod void constructorTest(){
        
        setupData();
        Test.startTest();
        acct.Type = 'AccountFormsTest';
        //acct.Company_Logo__c = 'https://www.hpac.com/sites/hpac.com/files/styles/article_featured_standard/public/Daikin%20logo3_0.jpg?itok=SrB9Mu1L';
        insert acct;
        
        Opportunity oppObj = new opportunity();
        oppObj.Name='test';
        oppObj.CloseDate = system.today();
        oppObj.StageName='Proposal/Price Quote/Bid';
        oppObj.Vertical_Market__c='Airports & Transportation';
        oppObj.AccountId=acct.id;
        oppObj.Job_Address__c = addy.id;
        insert oppObj;
        system.debug('oppObj synced prp--'+oppObj.Synced_Quote_Proposal__c);
        //Creating Testing Queue
        Group testGroup = new Group(Name='Service Credit', Type='Queue');
        insert testGroup;
        
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Apttus_Proposal__Proposal__c');
            insert testQueue;
        }
        Apttus_Proposal__Proposal__c quoteObj = new Apttus_Proposal__Proposal__c(OwnerId = testGroup.Id);
        quoteObj.Apttus_Proposal__Account__c = acct.id;
        quoteObj.Apttus_Proposal__Opportunity__c = oppObj.id;
        quoteObj.Credit_Approved__c = 1;
        quoteObj.Credit_Rejected__c = 0;
        quoteObj.Credit_Status__c='Approved';
        quoteObj.Apttus_QPConfig__ConfigurationFinalizedDate__c = system.today()+55;
        quoteObj.Approval_Status__c = 'Mgmt Approved';
        quoteObj.Approval_Action__c = 'Submitted';
        //quoteObj.OwnerId =q1.Id; 
        //quoteObj.Document_Image__c = false;//Link Primary Quote Proposal to Opportunity
        insert quoteObj;
        
        List<Apttus_Proposal__Proposal__c> quoteList = new List<Apttus_Proposal__Proposal__c>();
        Apttus_Proposal__Proposal__c quoteObj1 = new Apttus_Proposal__Proposal__c(OwnerId = testGroup.Id);
        quoteObj1.Apttus_Proposal__Account__c = acct.id;
        quoteObj1.Apttus_Proposal__Opportunity__c = oppObj.id;
        quoteObj1.Credit_Approved__c = 1;
        quoteObj1.Credit_Rejected__c = 0;
        quoteObj1.Credit_Status__c='Approved';
        quoteObj1.Apttus_QPConfig__ConfigurationFinalizedDate__c = system.today()+55;
        quoteObj1.Approval_Status__c = 'Mgmt Approved';
         quoteObj1.Approval_Action__c = 'Submitted';
       quoteObj1.Apttus_Proposal__Approval_Stage__c = 'Credit Approval Requested';
        //quoteObj.OwnerId =q1.Id; 
        //quoteObj.Document_Image__c = false;//Link Primary Quote Proposal to Opportunity
        insert quoteObj1;
        System.debug('Owner ID of Quote'+quoteObj.OwnerId);
        SysteM.debug('Owner Name'+quoteObj.Owner);
        //quoteObj.Owner = 'Service Credit';
        
        quoteList.add(quoteObj);
        quoteList.add(quoteObj1);
        for(Apttus_Proposal__Proposal__c qq : quoteList)
        {
             qq.Approval_Action__c = 'Approved';
            qq.Apttus_QPConfig__ConfigurationFinalizedDate__c = system.today()+100;
        }
        update quoteList;
        
        quoteObj1.Approval_Action__c = 'Rejected';
        update quoteObj1;
        system.debug('quoteObj--'+quoteObj); 
        Test.stopTest();
    }*/
      static testMethod void constructorTest2(){
        
        setupData();
        Test.startTest();
        acct.Type = 'AccountFormsTest';
        //acct.Company_Logo__c = 'https://www.hpac.com/sites/hpac.com/files/styles/article_featured_standard/public/Daikin%20logo3_0.jpg?itok=SrB9Mu1L';
        insert acct;
        
        Opportunity oppObj = new opportunity();
        oppObj.Name='test';
        oppObj.CloseDate = system.today();
        oppObj.StageName='Proposal/Price Quote/Bid';
        oppObj.Vertical_Market__c='Airports & Transportation';
        oppObj.AccountId=acct.id;
        oppObj.Job_Address__c = addy.id;
        insert oppObj;
        system.debug('oppObj synced prp--'+oppObj.Synced_Quote_Proposal__c);
        //Creating Testing Queue
        Group testGroup = new Group(Name='Service Credit', Type='Queue');
        insert testGroup;
        
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Apttus_Proposal__Proposal__c');
            insert testQueue;
        }
        Apttus_Proposal__Proposal__c quoteObj = new Apttus_Proposal__Proposal__c(OwnerId = testGroup.Id);
        quoteObj.Apttus_Proposal__Account__c = acct.id;
        quoteObj.Apttus_Proposal__Opportunity__c = oppObj.id;
        quoteObj.Credit_Approved__c = 1;
        quoteObj.Credit_Rejected__c = 0;
        quoteObj.Credit_Status__c='Approved';
        quoteObj.Apttus_QPConfig__ConfigurationFinalizedDate__c = system.today()+55;
        quoteObj.Approval_Status__c = 'Mgmt Approved';
        quoteObj.Approval_Action__c = 'Approved';
        //quoteObj.OwnerId =q1.Id; 
        //quoteObj.Document_Image__c = false;//Link Primary Quote Proposal to Opportunity
        insert quoteObj;
        
        List<Apttus_Proposal__Proposal__c> quoteList = new List<Apttus_Proposal__Proposal__c>();
        Apttus_Proposal__Proposal__c quoteObj1 = new Apttus_Proposal__Proposal__c(OwnerId = testGroup.Id);
        quoteObj1.Apttus_Proposal__Account__c = acct.id;
        quoteObj1.Apttus_Proposal__Opportunity__c = oppObj.id;
        quoteObj1.Credit_Approved__c = 1;
        quoteObj1.Credit_Rejected__c = 0;
        quoteObj1.Credit_Status__c='Approved';
        quoteObj1.Apttus_QPConfig__ConfigurationFinalizedDate__c = system.today()+55;
        quoteObj1.Approval_Status__c = 'Mgmt Approved';
         quoteObj1.Approval_Action__c = 'Submitted';
       quoteObj1.Apttus_Proposal__Approval_Stage__c = 'Credit Approval Requested';
        //quoteObj.OwnerId =q1.Id; 
        //quoteObj.Document_Image__c = false;//Link Primary Quote Proposal to Opportunity
        insert quoteObj1;
        System.debug('Owner ID of Quote'+quoteObj.OwnerId);
        SysteM.debug('Owner Name'+quoteObj.Owner);
        //quoteObj.Owner = 'Service Credit';
        
        quoteList.add(quoteObj);
        quoteList.add(quoteObj1);
        for(Apttus_Proposal__Proposal__c qq : quoteList)
        {
             qq.Approval_Action__c = 'Rejected';
            qq.Apttus_QPConfig__ConfigurationFinalizedDate__c = system.today()+100;
        }
        update quoteList;
        
       
        system.debug('quoteObj--'+quoteObj); 
        Test.stopTest();
    }
}