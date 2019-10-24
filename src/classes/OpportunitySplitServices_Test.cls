@isTest
private class OpportunitySplitServices_Test
{
    //Initial Test Data
    static OpportunitySplitServices instance = null;
    static list<OpportunitySplit> opportunitysplitlist = null;
    static OpportunitySplit opptsspl;
    static Opportunity oppts;
    
    /*TEST SETUP*/
    static void setUp(){
        date myDate = Date.today();
        Account accts=new Account();
        Address__c addre=new Address__c();
        oppts=new Opportunity();
        opptsspl=new OpportunitySplit();
        addre.Address_Line_1__c='IBM INdia Pvt Ltd';
        addre.Address_line_2__c='A 26';
        addre.Address_line_3__c='Block A';
        addre.Address_line_4__c='Sector 62';
        addre.State_Province__c='Uttar Pradesh';
        addre.Postal_Code__c='201309';
        addre.City__c='Noida';
        addre.Country__c='India';
        accts.Name='sfdc';
        accts.Type='Architect';
        oppts.Name='sfdc';
        oppts.Line_of_Business__c='Equipment Only';
        oppts.CloseDate= myDate;
        oppts.StageName='Qualify Opportunity';
        oppts.Probability=10;
        oppts.Opp_City__c='delhi';
        oppts.Opp_State__c='Delhi';
        oppts.Vertical_Market__c='Healthcare';
        oppts.Next_Step__c='Close';
        //Managed package setting
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        
        insert ts1;    
        insert addre;
        insert accts;
        //Opportunity
        oppts.stageName='Closed Won';
        oppts.Won_Lost_Reason__c='closed succesffuly';
        oppts.AccountId = accts.id;
        insert oppts;
        //Profile
        Profile p = [SELECT Id FROM Profile limit 1]; 
        //User
        User platuser = new User(Alias = 'standt10', Email='standardplatform@bluewolfgroup.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = p.Id, 
                                 TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@bluewolfgroup.com');
        insert platuser;
        platuser = [Select id from User where Email='standardplatform@bluewolfgroup.com' Limit 1 ];
        //Opportunity split
        opptsspl.OpportunityId= oppts.Id;
        opptsspl.SplitOwnerId = platuser.ID;
        opptsspl.Closed_Won_Amount__c=100.50;
        opptsspl.Pipeline_Amount__c=100.50;
            
            
            //opportunitySplit.Closed_Won_Amount__c = null;
            //opportunitySplit.Pipeline_Amount__c=null;
        insert opptsspl;
        
        opptsspl =[Select id,OpportunityId,SplitOwnerId,SplitAmount,Closed_Won_Amount__c,
                   Pipeline_Amount__c ,SplitPercentage ,Opportunity.name, Opportunity.StageName
                   ,Opportunity_Splits_for_Template__r.Opportunity__c
                   ,SplitOwner.Id ,Opportunity.id from OpportunitySplit Limit 1];
        instance = new OpportunitySplitServices();
        opportunitysplitlist = new list<OpportunitySplit>();
        opportunitysplitlist.add(opptsspl);
       
    }
    
    
    // Test Method: filterOpportunitySplits
    public static testmethod void filterOpportunitySplitsTest(){
        SetUp();
        Test.StartTest();
        OpportunitySplitServices.filterOpportunitySplits(opportunitysplitlist, null, false);
        Test.StopTest();
        for (OpportunitySplit  opportunitySplit :opportunitysplitlist ){
        System.assertEquals(opportunitySplit.Closed_Won_Amount__c, opportunitySplit.SplitAmount,
                           'Closed won amount should be set equal to split amount');
        }    
    }
    
    // Test Method: filterOpportunitySplits
    public static testmethod void filterOpportunitySplitsWithOtherStagesTest(){
        SetUp();
        
        oppts.stageName='Discover Needs';
		update oppts;        
        Test.StartTest();
        OpportunitySplitServices.filterOpportunitySplits(opportunitysplitlist, null, false);
        Test.StopTest();
        for (OpportunitySplit  opportunitySplit :opportunitysplitlist ){
        System.assertEquals(opportunitySplit.Pipeline_Amount__c, opportunitySplit.SplitAmount,
                            'Pipeline amount should be set equal to split amount');
            
        }    
    }
    
    // Test Method: afterStampFields
    public static testmethod void afterStampFieldsTest(){
        SetUp();
        list<OpportunitySplit> newopportunitysplitlist = new list<OpportunitySplit>();
        Map<Id, OpportunitySplit> oldopportunitysplitmap = new Map<Id,OpportunitySplit>();
        newopportunitysplitlist=opportunitysplitlist;
        oldopportunitysplitmap.put(opptsspl.Id, opptsspl);
        
        string dmlmode = 'INSERT';
        Test.StartTest();
        OpportunitySplitServices.afterStampFields(newopportunitysplitlist, oldopportunitysplitmap, dmlmode);
        Test.StopTest();
        OpportunitySplit oppsplit =[select Id, Opportunity_Splits_for_Template__c 
                                    from OpportunitySplit where Id=:opptsspl.Id];
        System.assert(oppsplit.Opportunity_Splits_for_Template__c!=null,'Opportunity split template should not be null');
    }
    // Test Method: afterStampFields
    public static testmethod void afterStampFieldsUpdateTest(){
        SetUp();
        list<OpportunitySplit> newopportunitysplitlist = new list<OpportunitySplit>();
        Map<Id, OpportunitySplit> oldopportunitysplitmap = new Map<Id,OpportunitySplit>();
        newopportunitysplitlist=opportunitysplitlist;
        oldopportunitysplitmap.put(opptsspl.Id, opptsspl);
       OpportunitySplit oldSplit = oldOpportunitySplitMap.get(newopportunitysplitlist[0].id);
       // system.debug(newopportunitysplitlist[0].Opportunity_Splits_for_Template__c);
        
        string dmlmode = 'UPDATE';
        Test.StartTest();
        OpportunitySplitServices.afterStampFields(newopportunitysplitlist, oldopportunitysplitmap, dmlmode);
        Test.StopTest();
    }
    // Test Method: afterStampFields
    public static testmethod void afterStampFieldsUpdateWithTemplateTest(){
        SetUp();
        list<OpportunitySplit> newopportunitysplitlist = new list<OpportunitySplit>();
        Map<Id, OpportunitySplit> oldopportunitysplitmap = new Map<Id,OpportunitySplit>();
        Test.StartTest();
        string dmlmode = 'UPDATE';
        Opportunity_Splits_for_Templates__c optemplate = new Opportunity_Splits_for_Templates__c ();
        optemplate.Name='OppTemplate' ;
        optemplate.SplitAmount__c=20;
        optemplate.Opportunity__c = oppts.Id;
        insert optemplate;
        optemplate=[select Id, Name, SplitAmount__c, SplitOwner__c, SplitPercent__c,Opportunity__c,Opportunity__r.id from Opportunity_Splits_for_Templates__c limit 1];
        opptsspl.Opportunity_Splits_for_Template__c= optemplate.Id;
        update opptsspl;
        opptsspl.Opportunity_Splits_for_Template__c= null;
        update opptsspl;
        newopportunitysplitlist.add(opptsspl);
        oldopportunitysplitmap.put(opptsspl.Id, opptsspl);
        
        OpportunitySplitServices.afterStampFields(newopportunitysplitlist, oldopportunitysplitmap, dmlmode);
        Test.StopTest();
    }
    public static testmethod void afterStampFieldsUpdateWithTemplateTest2(){
        SetUp();
        list<OpportunitySplit> newopportunitysplitlist = new list<OpportunitySplit>();
        Map<Id, OpportunitySplit> oldopportunitysplitmap = new Map<Id,OpportunitySplit>();
        Test.StartTest();
        string dmlmode = 'UPDATE';
        Opportunity_Splits_for_Templates__c optemplate = new Opportunity_Splits_for_Templates__c ();
        optemplate.Name='OppTemplate' ;
        optemplate.SplitAmount__c=20;
        optemplate.Opportunity__c = oppts.Id;
        insert optemplate;
        optemplate=[select Id, Name, SplitAmount__c, SplitOwner__c, SplitPercent__c,Opportunity__c,Opportunity__r.id from Opportunity_Splits_for_Templates__c limit 1];
        opptsspl.Opportunity_Splits_for_Template__c= optemplate.Id;
        update opptsspl;
       // opptsspl.Opportunity_Splits_for_Template__c= null;
        //update opptsspl;
        newopportunitysplitlist.add(opptsspl);
        oldopportunitysplitmap.put(opptsspl.Id, opptsspl);
        
        OpportunitySplitServices.afterStampFields(newopportunitysplitlist, oldopportunitysplitmap, dmlmode);
        Test.StopTest();
    }
    
    // Test Method: afterStampFields
    public static testmethod void afterStampFieldsDeleteTest(){
        SetUp();
        list<OpportunitySplit> newopportunitysplitlist = new list<OpportunitySplit>();
        Map<Id, OpportunitySplit> oldopportunitysplitmap = new Map<Id,OpportunitySplit>();
        string dmlmode = 'DELETE';
        newopportunitysplitlist=opportunitysplitlist;
        oldopportunitysplitmap.put(opptsspl.Id, opptsspl);
        Test.StartTest();
        OpportunitySplitServices.afterStampFields(newopportunitysplitlist, oldopportunitysplitmap, dmlmode);
        Test.StopTest();
        OpportunitySplit oppsplit =[select Id, Opportunity_Splits_for_Template__c 
                                    from OpportunitySplit where Id=:opptsspl.Id];
        System.assert(oppsplit.Opportunity_Splits_for_Template__c==null,'Opportunity split template should not be null');
   
    }
    
    public static testMethod void clearFieldsTest()
    {
		SetUp();
       
        OpportunitySplit oppsplit =[select Id, Closed_Won_Amount__c,Pipeline_Amount__c 
                                  from OpportunitySplit where Id=:opptsspl.Id];
        Test.StartTest(); 
        OpportunitySplitServices.clearFields(oppsplit);
        Test.stopTest();
        
        System.assert(oppsplit.Closed_Won_Amount__c==null,'Closed_Won_Amount__c sould be null');
        System.assert(oppsplit.Pipeline_Amount__c==null,'Pipeline_Amount__c sould be null');
        
        
        
    }
   public testmethod static void updateOpptys()
        
    {
        SetUp();
        List<OpportunitySplit> updateSplitlist = new List<OpportunitySplit>();
        updateSplitlist =opportunitysplitlist;
        
		Test.startTest();
        OpportunitySplitServices.updateOpportunities(updateSplitlist);
        Test.stopTest();
         
    }
}