@isTest
public class PageMapsPlanningQuotaController_Test1 {
   @isTest
    public static  void testCase2()
    {
        Profile pr = [select id from profile where name='System Administrator'];
        User u = new User(alias = 'qqqrte', email='standarduser@daikinapplied.com',
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                          localesidkey='en_US', profileid = pr.Id,
                          timezonesidkey='America/Los_Angeles', username='stansdfwefdarduser@daikinapplied.com',
                          User_Division__c = 'IT', Title='test');
        
        insert u;
        
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;
        
        Account acct = new Account();
        acct.name = 'Test Account';
        acct.National_Account__c = true;
        acct.Japanese_Company__c = true;
        acct.Company_Type__c ='Architect';
        acct.Account_Type__c = 'Strategic';
        //acct.Total_Opportunity_Amount__c  = 200;
        insert acct;
        
        Account acct1 = new Account();
        acct1.name = 'Test Account';
        acct1.National_Account__c = true;
        acct1.Japanese_Company__c = true;
        acct1.Company_Type__c ='Architect';
        acct1.Account_Type__c = 'New';
        insert acct1;
        
        Account acct2 = new Account();
        acct2.name = 'Test Account';
        acct2.National_Account__c = true;
        acct2.Japanese_Company__c = true;
        acct2.Company_Type__c ='Architect';
        acct2.Account_Type__c = 'Growth';
        insert acct2;
        List<Account> accountsList = new List<Account>();
        accountsList.add(acct);
         accountsList.add(acct2);
         accountsList.add(acct2);
        
        Address__c addre=new Address__c();
        addre.Address_Line_1__c='IBM INdia Pvt Ltd';
        addre.Address_line_2__c='A 26';
        addre.Address_line_3__c='Block A';
        addre.Address_line_4__c='Sector 62';
        addre.State_Province__c='Uttar Pradesh';
        addre.Postal_Code__c='201309';
        addre.City__c='Noida';
        addre.Country__c='India';
        insert addre;
        
        Account_Address__c aad = new Account_Address__c();
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
       
        List<Opportunity> lstOpp = new List<Opportunity>();
       
	test.startTest();
        
        Opportunity testOpp1 = new Opportunity(OwnerId=u.Id, Line_of_Business__c = 'MA - Maintenance Agreement', StageName='Develop Customer Solution/In Design', name='testOpp1',amount=300000.0,AccountId=acct.id,CloseDate=system.today()+180,Vertical_Market__c='Healthcare',RecordTypeId = objRT.Id);
       // insert testOpp1;
        Opportunity testOpp2 = new Opportunity(OwnerId=u.Id, Line_of_Business__c = 'Service & Repair - Quoted', StageName='Develop Customer Solution/In Design', name='testOpp2',amount=300000.0,AccountId=acct.id,CloseDate=system.today()+30,Vertical_Market__c='Healthcare',RecordTypeId = objRT.Id);
       // insert testOpp2;
        Opportunity testOpp3 = new Opportunity(OwnerId=u.Id, Line_of_Business__c = 'TK - Turnkey Contracting', StageName='Develop Customer Solution/In Design', name='testOpp3',amount=30000.0,AccountId=acct.id,CloseDate=system.today()+40,Vertical_Market__c='Healthcare',RecordTypeId = objRT.Id);
       // insert testOpp3;
        Opportunity testOpp4 = new Opportunity(OwnerId=u.Id, Line_of_Business__c = 'Rental Chillers', StageName='Develop Customer Solution/In Design', name='testOpp4',amount=3000.0,AccountId=acct.id,CloseDate=system.today()+69,Vertical_Market__c='Healthcare',RecordTypeId = objRT.Id);
       // insert testOpp4;
        Opportunity testOpp5 = new Opportunity(OwnerId=u.Id, Line_of_Business__c = 'MA - Renewal', StageName='Develop Customer Solution/In Design',  name='testOpp5',amount=300.0,AccountId=acct.id,CloseDate=system.today()+95,Vertical_Market__c='Healthcare',RecordTypeId = objRT.Id);
       // insert testOpp5;
        Opportunity testOpp6 = new Opportunity(OwnerId=u.Id, Line_of_Business__c = 'TK', StageName='Develop Customer Solution/In Design', name='testOpp1',amount=3000.0,AccountId=acct.id,CloseDate=system.today()+180,Vertical_Market__c='Healthcare',RecordTypeId = objRT.Id);
       // insert testOpp6;
        Opportunity testOpp7 = new Opportunity(OwnerId=u.Id, Line_of_Business__c = 'Service & Repair - T&M', StageName='Develop Customer Solution/In Design', name='testOpp2',amount=300000.0,AccountId=acct.id,CloseDate=system.today()+30,Vertical_Market__c='Healthcare',RecordTypeId = objRT.Id);
       // insert testOpp7;
        Opportunity testOpp8 = new Opportunity(OwnerId=u.Id, Line_of_Business__c = 'TK - Turnkey Contracting', StageName='Develop Customer Solution/In Design', name='testOpp3',amount=30000.0,AccountId=acct.id,CloseDate=system.today()+40,Vertical_Market__c='Healthcare',RecordTypeId = objRT.Id);
        //insert testOpp8;
        Opportunity testOpp9 = new Opportunity(OwnerId=u.Id, Line_of_Business__c = 'Rental Chillers', StageName='Develop Customer Solution/In Design', name='testOpp4',amount=3000.0,AccountId=acct.id,CloseDate=system.today()+69,Vertical_Market__c='Healthcare',RecordTypeId = objRT.Id);
        //insert testOpp9;
        Opportunity testOpp10 = new Opportunity(OwnerId=u.Id, Line_of_Business__c = 'Other', StageName='Develop Customer Solution/In Design',  name='testOpp5',amount=300.0,AccountId=acct.id,CloseDate=system.today()+95,Vertical_Market__c='Healthcare',RecordTypeId = objRT.Id);
        //insert testOpp10;
        Opportunity testOpp11 = new Opportunity(OwnerId=u.Id, Line_of_Business__c = 'TK - Turnkey Contracting', StageName='Develop Customer Solution/In Design', name='testOpp3',amount=30000.0,AccountId=acct.id,CloseDate=system.today()+40,Vertical_Market__c='Healthcare',RecordTypeId = objRT.Id);
        //insert testOpp11;
        Opportunity testOpp12 = new Opportunity(OwnerId=u.Id, Line_of_Business__c = 'MCP', StageName='Develop Customer Solution/In Design', name='testOpp3',amount=30000.0,AccountId=acct.id,CloseDate=system.today()+40,Vertical_Market__c='Healthcare',RecordTypeId = objRT.Id);
        //insert testOpp12;
        Opportunity testOpp13 = new Opportunity(OwnerId=u.Id, Line_of_Business__c = 'MCP', StageName='Develop Customer Solution/In Design', name='testOpp3',amount=30000.0,AccountId=acct.id,CloseDate=system.today()+40,Vertical_Market__c='Healthcare',RecordTypeId = objRT.Id);
        //insert testOpp13;
        
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
    

        Opportunity Opty = [select Id,name,MAPS_LOB_Type__c,amount,closedate,StageName,ownerid,Accountid,owner.name from Opportunity where name = 'testOpp1' limit 1];
      
        Integer totAmount = 0;
        Integer totMAAmount = 0;
        Integer totSRAmount = 0;
        Integer totTKAmount = 0;
        Integer totRCAmount  = 0;
        Integer totMCPAmount = 0;
        Integer totOtherAmount = 0;
        
        
        
        String lobType = 'TK';
        String accName = acct.name;
        String OppName  = Opty.id;
        String oppOwner = Opty.OwnerId;
        Decimal totalOppValue = 0;
        Boolean nationalAcc = acct.National_Account__c;
        Boolean japanCompany = acct.Japanese_Company__c;
        String AccId = acct.id;
        String OppId = Opty.id;
        
        // Id accId=acct.id;
        // String accName=acct.name;
        String accNumber=acct.Account_Number__c;
        String accPhone=acct.Phone;
        decimal totOppSum=100;
        Batch_Maps_Helper bph = new Batch_Maps_Helper();
        
        PageMapsPlanningQuotaController.accWrapper ppqacc = new PageMapsPlanningQuotaController.accWrapper
            (acct.id,acct.Name,acct.OwnerId,u.Name,acct.National_Account__c,acct.Japanese_Company__c,totAmount,totMAAmount,totSRAmount,totTKAmount,totRCAmount,totMCPAmount,totOtherAmount);
        // PageMapsPlanningQuotaController.oppAmtCalc opamt = new PageMapsPlanningQuotaController.oppAmtCalc(tableName,mapAmt,mapAmtQuota,mapAmt2,mapAmtQuota2,mapFacAmt,mapFacAmt2,boolAccType,boolGrandSet,boolGrandSet7,ownername);
        PageMapsPlanningQuotaController.MajorAccounts maTAcc =  new PageMapsPlanningQuotaController.MajorAccounts(lobType,accName,OppName,oppOwner,totalOppValue,nationalAcc,japanCompany,AccId,OppId);
      
		ApexPages.StandardController sc = new ApexPages.StandardController(Opty);
        PageMapsPlanningQuotaController con  = new PageMapsPlanningQuotaController(sc);
        
        
        con.selectedValues = u.Id+','+userinfo.getUserId();
        //con.getAccLst('Strategic');
        //System.assertequals(u.id,con.selectedValues);        
        con.getAccTypeList();
        con.generatePdf();
        con.accType = '0';
        con.accWrap('Strategic');
        list<PageMapsPlanningQuotaController.accWrapper> wrapList = con.accWrapStrategic;
        list<PageMapsPlanningQuotaController.accWrapper> growthList = con.accWrapGrowth;
        list<PageMapsPlanningQuotaController.accWrapper> accWrapNewList = con.accWrapNew;

        Map<String,decimal> testObj = new Map<String,decimal>();
        testObj.put('apr',1000.0);
        List<PageMapsPlanningQuotaController.oppAmtCalc> lstoppAMt = new List<PageMapsPlanningQuotaController.oppAmtCalc>();
        lstoppAMt = con.tableWrap;
      con.accnts = accountsList;
        List<PageMapsPlanningQuotaController.MajorAccounts> ListMaList = new List<PageMapsPlanningQuotaController.MajorAccounts>();
        //ListMaList.add(maTAcc);
        Map<String,List<PageMapsPlanningQuotaController.MajorAccounts>> mapTemp = new Map<String,List<PageMapsPlanningQuotaController.MajorAccounts>>();
       // mapTemp.put('MA', ListMaList);
             
        mapTemp = con.getMajorAccounts;
        PageMapsPlanningQuotaController.accOppSum wrapObj = new PageMapsPlanningQuotaController.accOppSum(acct.id,acct.Name,acct.Account_Number__c,acct.phone,opty.Amount);
        list<PageMapsPlanningQuotaController.accOppSum> listOfaccOppSum = new list<PageMapsPlanningQuotaController.accOppSum>();
        listOfaccOppSum.add(wrapObj);
        PageMapsPlanningQuotaController.oppCategory oppWrapobj = new PageMapsPlanningQuotaController.oppCategory('cat',listOfaccOppSum);
        list<PageMapsPlanningQuotaController.oppCategory> listOfCategory = new list<PageMapsPlanningQuotaController.oppCategory>();
        listOfCategory.add(oppWrapobj);
        PageMapsPlanningQuotaController.accOppWrapper accWrap = new PageMapsPlanningQuotaController.accOppWrapper(acct.OwnerId,acct.owner.Name,listOfCategory,listOfCategory,listOfCategory);
        test.stopTest();
        
        //p.setRedirect(true);
        
    }
    
    
}