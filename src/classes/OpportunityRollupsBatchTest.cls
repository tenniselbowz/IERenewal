@isTest
public class OpportunityRollupsBatchTest {
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
    @isTest
    public static void OptyRollTest()
    {
        setupData();
        List<Opportunity> opps = new List<Opportunity>();
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'testinguser@daikinapplied.com',
            Username = 'testinguser@daikinapplied.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            //Department = 'IT',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US');
            insert u;
               
        acct.Name = 'Testing Opportunity';
        acct.Type = 'Competetor';
        acct.OwnerId = u.id;
        insert acct;
        Contact con = new Contact();
        con.AccountId = acct.id;
        con.LastName = 'Test Contact Name';
        con.Phone  ='99999999';
        insert con;
        
        Product2 pd = new Product2();
        pd.Name = 'Dell Crop';
        insert pd;
        Id RecordTypeIdContact = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('North America - DSO').getRecordTypeId();
        
        Opportunity Opty = new Opportunity();
        Opty.RecordTypeId =RecordTypeIdContact;
        Opty.Name        ='Test Oppty';
        Opty.CloseDate   = system.today()+20;
        Opty.AccountId = acct.id;
       /* Opty.Project_Type__c = '';
        OPty.Secured_Date__c=system.today();
        opty.Won_Lost_Against_Other__c ='';
        Opty.Job_Won_Lost_Against__c='';
       Opty.Contact_Rollup__c='test';
     Opty.Bidder_Rollup__c  = 'test bidder roll';
        Opty.Product_Rollup__c = 'test';
        Opty.Job_Address__c  = addy.id;
       Opty.Bid_Date__c = system.today()+20;
        Opty.Won_Lost_Reason__c='';*/
        Opty.Probability=50;
        Opty.StageName = 'Customer Validation';   
        Opty.Vertical_Market__c='Airports & Transportation';
        Opty.Edited__c = True;
        insert Opty;
        opps.add(Opty);
        
        
        //update opps;
        
        OpportunityContactRole opcr = new OpportunityContactRole();
        opcr.OpportunityId = Opty.id;
        opcr.ContactId = con.id;
        opcr.Role = 'Contract Engineer';
        insert opcr;
        
        /*OpportunityContactRole opcr1 = new OpportunityContactRole();
        opcr1.OpportunityId = Opty.id;
        opcr1.ContactId = con.id;
        opcr1.Role = 'Approver';
        insert opcr1;*/
        
        String pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.Pricebook2Id = pricebookId;
        pbe.Product2Id = pd.id;
        pbe.UnitPrice = 50;
        //pbe.StandardPrice = 10000;
        pbe.IsActive = true;
        pbe.UseStandardPrice = false;
        insert pbe;

        OpportunityLineItem oplt = new OpportunityLineItem();
        oplt.Product2Id= pd.id;
        oplt.OpportunityId = Opty.id;
        oplt.Quantity = 2.0;
        oplt.TotalPrice = 1000;
        oplt.PricebookEntryId =pbe.id;
        insert oplt;
        
        OpportunityLineItem oplt1 = new OpportunityLineItem();
        oplt1.Product2Id= pd.id;
        oplt1.OpportunityId = Opty.id;
        oplt1.Quantity = 3.0;
        oplt1.TotalPrice = 600;
        oplt1.PricebookEntryId =pbe.id;
        insert oplt1;
        
        Bidder__c bdr = new Bidder__c();
        bdr.Apparent_Winning_Bidder__c = false;
        bdr.Opportunity__c = opty.id;
        bdr.OwnerId = u.id;
        bdr.Inactive__c = false;
       // insert bdr;
        
       /* Bidder__c bdr1 = new Bidder__c();
        bdr1.Apparent_Winning_Bidder__c = false;
        bdr1.Opportunity__c = opty.id;
       // bdr1.Bidder_Name__c = acct.id;
       // bdr1.OwnerId = u.id;
        bdr1.Inactive__c = false;
        insert bdr1;*/
        
        Test.startTest();
        OpportunityRollupsBatch orb = new OpportunityRollupsBatch();
        orb.execute(null, opps);
        Database.executeBatch(orb);
        Test.stopTest();
    }
    
}