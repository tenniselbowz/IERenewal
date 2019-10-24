@isTest(SeeAllData=true)
public class PageMapsPlanningQuotaController_Test{
   
   /* public static TestMethod void testCase1(){
        
        Profile pr = [select id from profile where name='System Administrator'];
        User u = new User(alias = 'qqqrte', email='standarduser@daikinapplied.com',
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                          localesidkey='en_US', profileid = pr.Id,
                          timezonesidkey='America/Los_Angeles', username='stansdfwefdarduser@daikinapplied.com',
                          User_Division__c = 'IT', Title='test');
        
        insert u;
        
        Sales_Rep_Quota__c s = new Sales_Rep_Quota__c();
        //s.Quarterly_Quota__c = 100.05;
        s.Q4_M3_MA_Quota__c = 100.05;
        s.Q4_M2_MA_Quota__c= 100.05;
        s.Q4_M1_MA_Quota__c= 100.05;
        s.Q3_M3_MA_Quota__c = 100.05;
        s.Q3_M2_MA_Quota__c= 100.05;
        s.Q3_M1_MA_Quota__c= 100.05;
        s.Q2_M3_MA_Quota__c = 100.05;
        s.Q2_M2_MA_Quota__c= 100.05;
        s.Q2_M1_MA_Quota__c= 100.05;
        s.Q1_M3_MA_Quota__c = 100.05;
        s.Q1_M2_MA_Quota__c= 100.05;
        s.Q1_M1_MA_Quota__c= 100.05;
        s.Q4_M3_SR_Quota__c = 100.05;
        s.Q4_M2_SR_Quota__c= 100.05;
        s.Q4_M1_SR_Quota__c= 100.05;
        s.Q3_M3_SR_Quota__c = 100.05;
        s.Q3_M2_SR_Quota__c= 100.05;
        s.Q3_M1_SR_Quota__c= 100.05;
        s.Q2_M3_SR_Quota__c = 100.05;
        s.Q2_M2_SR_Quota__c= 100.05;
        s.Q2_M1_SR_Quota__c= 100.05;
        s.Q1_M3_SR_Quota__c = 100.05;
        s.Q1_M2_SR_Quota__c= 100.05;
        s.Q1_M1_SR_Quota__c= 100.05;
        s.Q4_M3_TK_Quota__c = 100.05;
        s.Q4_M2_TK_Quota__c= 100.05;
        s.Q4_M1_TK_Quota__c= 100.05;
        s.Q3_M3_TK_Quota__c= 100.05;
        s.Q3_M2_TK_Quota__c= 100.05;
        s.Q3_M1_TK_Quota__c= 100.05;
        s.Q2_M3_TK_Quota__c= 100.05;
        s.Q2_M2_TK_Quota__c= 100.05;
        s.Q2_M1_TK_Quota__c= 100.05;
        s.Q1_M3_TK_Quota__c= 100.05;
        s.Q1_M2_TK_Quota__c= 100.05;
        s.Q1_M1_TK_Quota__c= 100.05;
        s.Q4_M3_RC_Quota__c= 100.05;
        s.Q4_M2_RC_Quota__c= 100.05;
        s.Q4_M1_RC_Quota__c= 100.05;
        s.Q3_M3_RC_Quota__c= 100.05;
        s.Q3_M2_RC_Quota__c= 100.05;
        s.Q3_M1_RC_Quota__c= 100.05;
        s.Q2_M3_RC_Quota__c= 100.05;
        s.Q2_M2_RC_Quota__c= 100.05;
        s.Q2_M1_RC_Quota__c= 100.05;
        s.Q1_M3_RC_Quota__c= 100.05;
        s.Q1_M2_RC_Quota__c= 100.05;
        s.Q1_M1_RC_Quota__c= 100.05;
        s.Q4_M3_MCP_Quota__c= 100.05;
        s.Q4_M2_MCP_Quota__c= 100.05;
        s.Q4_M1_MCP_Quota__c= 100.05;
        s.Q3_M3_MCP_Quota__c= 100.05;
        s.Q3_M2_MCP_Quota__c= 100.05;
        s.Q3_M1_MCP_Quota__c= 100.05;
        s.Q2_M3_MCP_Quota__c= 100.05;
        s.Q2_M2_MCP_Quota__c= 100.05;
        s.Q2_M1_MCP_Quota__c= 100.05;
        s.Q1_M3_MCP_Quota__c= 100.05;
        s.Q1_M2_MCP_Quota__c= 100.05;
        s.Q1_M1_MCP_Quota__c= 100.05;
        s.Q4_M3_Other_Quota__c= 100.05;
        s.Q4_M2_Other_Quota__c= 100.05;
        s.Q4_M1_Other_Quota__c= 100.05;
        s.Q3_M2_Other_Quota__c= 100.05;
        s.Q3_M3_Other_Quota__c= 100.05;
        s.Q3_M1_Other_Quota__c= 100.05;
        s.Q2_M3_Other_Quota__c= 100.05;
        s.Q2_M2_Other_Quota__c= 100.05;
        s.Q2_M1_Other_Quota__c= 100.05;
        s.Q1_M3_Other_Quota__c= 100.05;
        s.Q1_M2_Other_Quota__c= 100.05;
        s.Q1_M1_Other_Quota__c = 100.00;
        s.User__c = u.Id; 
        insert s;
        
        RecordType objRT = [select id,name,developername from RecordType where SobjectType = 'Opportunity' and developername = 'North_America' limit 1];
         Account acct = new Account(OwnerId=u.Id,National_Account__c=true,
                                        Japanese_Company__c=true,
                                        Account_Type__c='Strategic', 
                                        name='testAcc1',
                                        Company_Type__c='Architect',
                                        IE_Sync_Status__c = 'Pending' );
       
        
                       
        
        
        
        Insert acct;
       
        Address__c addre=new Address__c();
        addre.Address_Line_1__c='IBM INdia Pvt Ltd';
        addre.Address_line_2__c='A 26';
        addre.Address_line_3__c='Block A';
        addre.Address_line_4__c='Sector 62';
        addre.State_Province__c='Uttar Pradesh';
        addre.Postal_Code__c='201309';
        addre.City__c='Noida';
        addre.Country__c='India';
        insert addre;*/
       
       /* Account_Address__c aad = new Account_Address__c();
      
       
        aad.Bill_To__c = true;
        aad.Mail_To__c = true;
        aad.Physical__c = true;
        aad.Primary_Bill_To__c = true;
        aad.Primary_Mail_To__c = true;
        aad.Primary_Ship_To__c = true;
        aad.Active__c = true;
        aad.Address__c = addre.id;
        aad.Account__c = acct.id;
        aad.Bill_To__c = true;
        
        insert aad;
        
       
        
        List<Account> testAcc1new = new List<Account>([select id , name,owner.name from Account limit 1]);
        System.debug('****acc owner :'+testAcc1new[0].owner.name+'  id:'+testAcc1new[0].owner.ID);
        
        List<Opportunity> lstOpp = new List<Opportunity>();
        
        
          
        Opportunity testOpp1 = new Opportunity(OwnerId=u.Id, Line_of_Business__c = 'MA - Maintenance Agreement', StageName='Develop Customer Solution/In Design', name='testOpp1',amount=300000.0,AccountId=acct.id,CloseDate=system.today()+180,Vertical_Market__c='Healthcare',RecordTypeId = objRT.Id);
        Opportunity testOpp2 = new Opportunity(OwnerId=u.Id, Line_of_Business__c = 'Service & Repair - Quoted', StageName='Develop Customer Solution/In Design', name='testOpp2',amount=300000.0,AccountId=acct.id,CloseDate=system.today()+30,Vertical_Market__c='Healthcare',RecordTypeId = objRT.Id);
        Opportunity testOpp3 = new Opportunity(OwnerId=u.Id, Line_of_Business__c = 'TK - Turnkey Contracting', StageName='Develop Customer Solution/In Design', name='testOpp3',amount=30000.0,AccountId=acct.id,CloseDate=system.today()+40,Vertical_Market__c='Healthcare',RecordTypeId = objRT.Id);
        Opportunity testOpp4 = new Opportunity(OwnerId=u.Id, Line_of_Business__c = 'Rental Chillers', StageName='Develop Customer Solution/In Design', name='testOpp4',amount=3000.0,AccountId=acct.id,CloseDate=system.today()+69,Vertical_Market__c='Healthcare',RecordTypeId = objRT.Id);
        Opportunity testOpp5 = new Opportunity(OwnerId=u.Id, Line_of_Business__c = 'MA - Renewal', StageName='Develop Customer Solution/In Design',  name='testOpp5',amount=300.0,AccountId=acct.id,CloseDate=system.today()+95,Vertical_Market__c='Healthcare',RecordTypeId = objRT.Id);
        Opportunity testOpp6 = new Opportunity(OwnerId=u.Id, Line_of_Business__c = 'TK', StageName='Develop Customer Solution/In Design', name='testOpp1',amount=3000.0,AccountId=acct.id,CloseDate=system.today()+180,Vertical_Market__c='Healthcare',RecordTypeId = objRT.Id);
        Opportunity testOpp7 = new Opportunity(OwnerId=u.Id, Line_of_Business__c = 'Service & Repair - T&M', StageName='Develop Customer Solution/In Design', name='testOpp2',amount=300000.0,AccountId=acct.id,CloseDate=system.today()+30,Vertical_Market__c='Healthcare',RecordTypeId = objRT.Id);
        Opportunity testOpp8 = new Opportunity(OwnerId=u.Id, Line_of_Business__c = 'TK - Turnkey Contracting', StageName='Develop Customer Solution/In Design', name='testOpp3',amount=30000.0,AccountId=acct.id,CloseDate=system.today()+40,Vertical_Market__c='Healthcare',RecordTypeId = objRT.Id);
        Opportunity testOpp9 = new Opportunity(OwnerId=u.Id, Line_of_Business__c = 'Rental Chillers', StageName='Develop Customer Solution/In Design', name='testOpp4',amount=3000.0,AccountId=acct.id,CloseDate=system.today()+69,Vertical_Market__c='Healthcare',RecordTypeId = objRT.Id);        Opportunity testOpp10 = new Opportunity(OwnerId=u.Id, Line_of_Business__c = 'Other', StageName='Develop Customer Solution/In Design',  name='testOpp5',amount=300.0,AccountId=acct.id,CloseDate=system.today()+95,Vertical_Market__c='Healthcare',RecordTypeId = objRT.Id);
        Opportunity testOpp11 = new Opportunity(OwnerId=u.Id, Line_of_Business__c = 'TK - Turnkey Contracting', StageName='Develop Customer Solution/In Design', name='testOpp3',amount=30000.0,AccountId=acct.id,CloseDate=system.today()+40,Vertical_Market__c='Healthcare',RecordTypeId = objRT.Id);
        Opportunity testOpp12 = new Opportunity(OwnerId=u.Id, Line_of_Business__c = 'MCP', StageName='Develop Customer Solution/In Design', name='testOpp3',amount=30000.0,AccountId=acct.id,CloseDate=system.today()+40,Vertical_Market__c='Healthcare',RecordTypeId = objRT.Id);
        Opportunity testOpp13 = new Opportunity(OwnerId=u.Id, Line_of_Business__c = 'MCP', StageName='Develop Customer Solution/In Design', name='testOpp3',amount=30000.0,AccountId=acct.id,CloseDate=system.today()+40,Vertical_Market__c='Healthcare',RecordTypeId = objRT.Id);
        
        lstOpp.add(testOpp1);
        lstOpp.add(testOpp2);
        lstOpp.add(testOpp3);
        lstOpp.add(testOpp4);
        lstOpp.add(testOpp5);
        
        lstOpp.add(testOpp6);
        lstOpp.add(testOpp7);
        lstOpp.add(testOpp8);
        lstOpp.add(testOpp9);
        lstOpp.add(testOpp10);
        
        lstOpp.add(testOpp11);
        lstOpp.add(testOpp12);
        lstOpp.add(testOpp13);
        
        insert lstOpp;
        
        test.startTest();
        List<Opportunity> lstOpp1 = new List<Opportunity>();*/
        //lstOpp1 =[select id,ownerid from opportunity limit 1];
        //PageReference p = new PageReference('apex/vfMapsPlanningQuota');
        
        // p.setRedirect(true);
        //Test.setCurrentPage(p);
       // Opportunity opp = [select Id,name,MAPS_LOB_Type__c,amount,closedate,StageName,ownerid,Accountid,owner.name from Opportunity where name = 'testOpp1' LIMIT 1][0];
       // System.debug('###oppowner Name:'+opp.owner.name+'  id :'+opp.owner.id);
        /******
ApexPages.StandardController stdOpp = new ApexPages.StandardController(opp);
PageMapsPlanningQuotaController con  = new PageMapsPlanningQuotaController(stdOpp);
*******/
      
       /* Integer totAmount = 0;
        Integer totMAAmount = 0;
        Integer totSRAmount = 0;
        Integer totTKAmount = 0;
        Integer totRCAmount  = 0;
        Integer totMCPAmount = 0;
        Integer totOtherAmount = 0;
        
         PageMapsPlanningQuotaController.accWrapper ppqacc = new PageMapsPlanningQuotaController.accWrapper
             (acct.id,acct.Name,acct.OwnerId,u.Name,acct.National_Account__c,acct.Japanese_Company__c,totAmount,totMAAmount,totSRAmount,totTKAmount,totRCAmount,totMCPAmount,totOtherAmount);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(testOpp1);
        PageMapsPlanningQuotaController con  = new PageMapsPlanningQuotaController(sc);
        
        con.selectedValues = u.Id;
        System.assertequals(u.id,con.selectedValues);
        
        con.getAccTypeList();
        con.generatePdf();
        con.accType = '0';
        con.accWrap('Strategic');
        Map<String,decimal> testObj = new Map<String,decimal>();
        testObj.put('apr',1000.0);
        List<PageMapsPlanningQuotaController.oppAmtCalc> lstoppAMt = new List<PageMapsPlanningQuotaController.oppAmtCalc>();
        lstoppAMt = con.tableWrap;
        con.accnts = testAcc1new;
        
        Map<String,List<PageMapsPlanningQuotaController.MajorAccounts>> mapTemp = new Map<String,List<PageMapsPlanningQuotaController.MajorAccounts>>();
        mapTemp = con.getMajorAccounts;*/
        
       // p.setRedirect(true);
        
        //PageMapsPlanningQuotaController.accWrapper accWrap2 = new PageMapsPlanningQuotaController.accWrapper('005C0000004fmsI', 'Test', '005C0000004fmsI', 'Test', true, true, true, 23.00, 23.00, 23.00, 23.00, 23.00, 23.00);
        //con.selectedValues = '005C0000004fmsI';
       // test.stopTest();
        
        
  //  }
  /*  public static TestMethod void testCase2(){
        
        Profile pr = [select id from profile where name='System Administrator'];
        User u = new User(alias = 'qqqrte', email='standarduser@daikinapplied.com',
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                          localesidkey='en_US', profileid = pr.Id,
                          timezonesidkey='America/Los_Angeles', username='stansdfwefdarduser@daikinapplied.com',
                          User_Division__c = 'IT', Title='test');
        
        insert u;
        
        Sales_Rep_Quota__c s = new Sales_Rep_Quota__c();
        //s.Quarterly_Quota__c = 100.05;
        s.Q4_M3_MA_Quota__c = 100.05;
        s.Q4_M2_MA_Quota__c= 100.05;
        s.Q4_M1_MA_Quota__c= 100.05;
        s.Q3_M3_MA_Quota__c = 100.05;
        s.Q3_M2_MA_Quota__c= 100.05;
        s.Q3_M1_MA_Quota__c= 100.05;
        s.Q2_M3_MA_Quota__c = 100.05;
        s.Q2_M2_MA_Quota__c= 100.05;
        s.Q2_M1_MA_Quota__c= 100.05;
        s.Q1_M3_MA_Quota__c = 100.05;
        s.Q1_M2_MA_Quota__c= 100.05;
        s.Q1_M1_MA_Quota__c= 100.05;
        s.Q4_M3_SR_Quota__c = 100.05;
        s.Q4_M2_SR_Quota__c= 100.05;
        s.Q4_M1_SR_Quota__c= 100.05;
        s.Q3_M3_SR_Quota__c = 100.05;
        s.Q3_M2_SR_Quota__c= 100.05;
        s.Q3_M1_SR_Quota__c= 100.05;
        s.Q2_M3_SR_Quota__c = 100.05;
        s.Q2_M2_SR_Quota__c= 100.05;
        s.Q2_M1_SR_Quota__c= 100.05;
        s.Q1_M3_SR_Quota__c = 100.05;
        s.Q1_M2_SR_Quota__c= 100.05;
        s.Q1_M1_SR_Quota__c= 100.05;
        s.Q4_M3_TK_Quota__c = 100.05;
        s.Q4_M2_TK_Quota__c= 100.05;
        s.Q4_M1_TK_Quota__c= 100.05;
        s.Q3_M3_TK_Quota__c= 100.05;
        s.Q3_M2_TK_Quota__c= 100.05;
        s.Q3_M1_TK_Quota__c= 100.05;
        s.Q2_M3_TK_Quota__c= 100.05;
        s.Q2_M2_TK_Quota__c= 100.05;
        s.Q2_M1_TK_Quota__c= 100.05;
        s.Q1_M3_TK_Quota__c= 100.05;
        s.Q1_M2_TK_Quota__c= 100.05;
        s.Q1_M1_TK_Quota__c= 100.05;
        s.Q4_M3_RC_Quota__c= 100.05;
        s.Q4_M2_RC_Quota__c= 100.05;
        s.Q4_M1_RC_Quota__c= 100.05;
        s.Q3_M3_RC_Quota__c= 100.05;
        s.Q3_M2_RC_Quota__c= 100.05;
        s.Q3_M1_RC_Quota__c= 100.05;
        s.Q2_M3_RC_Quota__c= 100.05;
        s.Q2_M2_RC_Quota__c= 100.05;
        s.Q2_M1_RC_Quota__c= 100.05;
        s.Q1_M3_RC_Quota__c= 100.05;
        s.Q1_M2_RC_Quota__c= 100.05;
        s.Q1_M1_RC_Quota__c= 100.05;
        s.Q4_M3_MCP_Quota__c= 100.05;
        s.Q4_M2_MCP_Quota__c= 100.05;
        s.Q4_M1_MCP_Quota__c= 100.05;
        s.Q3_M3_MCP_Quota__c= 100.05;
        s.Q3_M2_MCP_Quota__c= 100.05;
        s.Q3_M1_MCP_Quota__c= 100.05;
        s.Q2_M3_MCP_Quota__c= 100.05;
        s.Q2_M2_MCP_Quota__c= 100.05;
        s.Q2_M1_MCP_Quota__c= 100.05;
        s.Q1_M3_MCP_Quota__c= 100.05;
        s.Q1_M2_MCP_Quota__c= 100.05;
        s.Q1_M1_MCP_Quota__c= 100.05;
        s.Q4_M3_Other_Quota__c= 100.05;
        s.Q4_M2_Other_Quota__c= 100.05;
        s.Q4_M1_Other_Quota__c= 100.05;
        s.Q3_M2_Other_Quota__c= 100.05;
        s.Q3_M3_Other_Quota__c= 100.05;
        s.Q3_M1_Other_Quota__c= 100.05;
        s.Q2_M3_Other_Quota__c= 100.05;
        s.Q2_M2_Other_Quota__c= 100.05;
        s.Q2_M1_Other_Quota__c= 100.05;
        s.Q1_M3_Other_Quota__c= 100.05;
        s.Q1_M2_Other_Quota__c= 100.05;
        s.Q1_M1_Other_Quota__c = 100.00;
        s.User__c = u.Id; 
        
        insert s;
        
        RecordType objRT = [select id,name,developername from RecordType where SobjectType = 'Opportunity' and developername = 'North_America' limit 1];
        
        Account testAcc1 = new Account(OwnerId=u.Id,National_Account__c=true,Japanese_Company__c=true,Account_Type__c='Strategic', name='testAcc1',Company_Type__c='Architect');
        Insert testAcc1;
        
        List<Account> testAcc1new = new List<Account>([select id , name,owner.name from Account limit 1]);
        System.debug('****acc owner :'+testAcc1new[0].owner.name+'  id:'+testAcc1new[0].owner.ID);
        
        List<Opportunity> lstOpp = new List<Opportunity>();
        
        
        Opportunity testOpp1 = new Opportunity(OwnerId=u.Id, Line_of_Business__c = 'MA', StageName='Develop Customer Solution/In Design', name='testOpp1',amount=3000.0,AccountId=testAcc1.id,CloseDate=system.today()+180,Vertical_Market__c='Healthcare',RecordTypeId = objRT.id);
        Opportunity testOpp2 = new Opportunity(OwnerId=u.Id, Line_of_Business__c = 'Service & Repair', StageName='Develop Customer Solution/In Design', name='testOpp2',amount=300000.0,AccountId=testAcc1.id,CloseDate=system.today()+30,Vertical_Market__c='Healthcare',RecordTypeId = objRT.id);
        Opportunity testOpp3 = new Opportunity(OwnerId=u.Id, Line_of_Business__c = 'TK - Turnkey Contracting', StageName='Develop Customer Solution/In Design', name='testOpp3',amount=30000.0,AccountId=testAcc1.id,CloseDate=system.today()+40,Vertical_Market__c='Healthcare',RecordTypeId = objRT.id);
        Opportunity testOpp4 = new Opportunity(OwnerId=u.Id, Line_of_Business__c = 'Rental Chillers', StageName='Develop Customer Solution/In Design', name='testOpp4',amount=3000.0,AccountId=testAcc1.id,CloseDate=system.today()+69,Vertical_Market__c='Healthcare',RecordTypeId = objRT.id);
        Opportunity testOpp5 = new Opportunity(OwnerId=u.Id, Line_of_Business__c = 'MA', StageName='Develop Customer Solution/In Design',  name='testOpp5',amount=300.0,AccountId=testAcc1.id,CloseDate=system.today()+95,Vertical_Market__c='Healthcare',RecordTypeId = objRT.id);
        Opportunity testOpp6 = new Opportunity(OwnerId=u.Id, Line_of_Business__c = 'MA', StageName='Develop Customer Solution/In Design', name='testOpp1',amount=3000.0,AccountId=testAcc1.id,CloseDate=system.today()+180,Vertical_Market__c='Healthcare',RecordTypeId = objRT.id);
        Opportunity testOpp7 = new Opportunity(OwnerId=u.Id, Line_of_Business__c = 'Service & Repair', StageName='Develop Customer Solution/In Design', name='testOpp2',amount=300000.0,AccountId=testAcc1.id,CloseDate=system.today()+30,Vertical_Market__c='Healthcare',RecordTypeId = objRT.id);
        Opportunity testOpp8 = new Opportunity(OwnerId=u.Id, Line_of_Business__c = 'TK - Turnkey Contracting', StageName='Develop Customer Solution/In Design', name='testOpp3',amount=30000.0,AccountId=testAcc1.id,CloseDate=system.today()+40,Vertical_Market__c='Healthcare',RecordTypeId = objRT.id);
        Opportunity testOpp9 = new Opportunity(OwnerId=u.Id, Line_of_Business__c = 'Rental Chillers', StageName='Develop Customer Solution/In Design', name='testOpp4',amount=3000.0,AccountId=testAcc1.id,CloseDate=system.today()+69,Vertical_Market__c='Healthcare',RecordTypeId = objRT.id);
        Opportunity testOpp10 = new Opportunity(OwnerId=u.Id, Line_of_Business__c = 'Other', StageName='Develop Customer Solution/In Design',  name='testOpp5',amount=300.0,AccountId=testAcc1.id,CloseDate=system.today()+95,Vertical_Market__c='Healthcare',RecordTypeId = objRT.id);
        Opportunity testOpp11 = new Opportunity(OwnerId=u.Id, Line_of_Business__c = 'TK - Turnkey Contracting', StageName='Develop Customer Solution/In Design', name='testOpp3',amount=30000.0,AccountId=testAcc1.id,CloseDate=system.today()+40,Vertical_Market__c='Healthcare',RecordTypeId = objRT.id);
        Opportunity testOpp12 = new Opportunity(OwnerId=u.Id, Line_of_Business__c = 'MCP', StageName='Develop Customer Solution/In Design', name='testOpp3',amount=30000.0,AccountId=testAcc1.id,CloseDate=system.today()+40,Vertical_Market__c='Healthcare',RecordTypeId = objRT.id);
        Opportunity testOpp13 = new Opportunity(OwnerId=u.Id, Line_of_Business__c = 'MCP', StageName='Develop Customer Solution/In Design', name='testOpp3',amount=30000.0,AccountId=testAcc1.id,CloseDate=system.today()+40,Vertical_Market__c='Healthcare',RecordTypeId = objRT.id);
        
        lstOpp.add(testOpp1);
        lstOpp.add(testOpp2);
        lstOpp.add(testOpp3);
        lstOpp.add(testOpp4);
        lstOpp.add(testOpp5);
        
        lstOpp.add(testOpp6);
        lstOpp.add(testOpp7);
        lstOpp.add(testOpp8);
        lstOpp.add(testOpp9);
        lstOpp.add(testOpp10);
        
        lstOpp.add(testOpp11);
        lstOpp.add(testOpp12);
        lstOpp.add(testOpp13);
        
        insert lstOpp;
      
        
        test.startTest();
        List<Opportunity> lstOpp1 = new List<Opportunity>();
        //lstOpp1 =[select id,ownerid from opportunity limit 1];
        PageReference p = new PageReference('apex/vfMapsPlanningQuota');
        
        // p.setRedirect(true);
        Test.setCurrentPage(p);
        Opportunity opp = [select Id,name,MAPS_LOB_Type__c,amount,closedate,StageName,ownerid,Accountid,owner.name from Opportunity where name = 'testOpp1' LIMIT 1];
        System.debug('###oppowner Name:'+opp.owner.name+'  id :'+opp.owner.id);
        /******
ApexPages.StandardController stdOpp = new ApexPages.StandardController(opp);
PageMapsPlanningQuotaController con  = new PageMapsPlanningQuotaController(stdOpp);
*******/
        
     /*   ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        PageMapsPlanningQuotaController con  = new PageMapsPlanningQuotaController(sc);
        
        con.selectedValues = u.Id+','+userinfo.getUserId();
        System.assertequals(u.id,con.selectedValues);
        
        
        con.getAccTypeList();
        con.generatePdf();
        //con.accType = '0';
        con.accWrap('Strategic');
        Map<String,decimal> testObj = new Map<String,decimal>();
        testObj.put('apr',1000.0);
        List<PageMapsPlanningQuotaController.oppAmtCalc> lstoppAMt = new List<PageMapsPlanningQuotaController.oppAmtCalc>();
        lstoppAMt = con.tableWrap;
        con.accnts = testAcc1new;
        
        Map<String,List<PageMapsPlanningQuotaController.MajorAccounts>> mapTemp = new Map<String,List<PageMapsPlanningQuotaController.MajorAccounts>>();
        mapTemp = con.getMajorAccounts;
        
        p.setRedirect(true);
        
        //PageMapsPlanningQuotaController.accWrapper accWrap2 = new PageMapsPlanningQuotaController.accWrapper('005C0000004fmsI', 'Test', '005C0000004fmsI', 'Test', true, true, true, 23.00, 23.00, 23.00, 23.00, 23.00, 23.00);
        //con.selectedValues = '005C0000004fmsI';
        test.stopTest();
        
        
        
    }*/

    
}