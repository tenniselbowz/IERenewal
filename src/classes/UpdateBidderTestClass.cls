@istest
public class UpdateBidderTestClass {
    
    static testMethod void updateBidderValues(){
        
       
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;
        Account a = new Account(Name = 'Test');
        a.BillingState = 'California';
        a.BillingPostalCode = '90210';
        a.BillingCountry = 'United States';
        insert a; 
  
        Opportunity opp = New Opportunity();
        opp.Name = 'test Bidder Opportunity';
        opp.StageName ='Closed Won';
        opp.Vertical_Market__c = 'Mining';
        opp.Probability = 75;
        opp.AccountId = a.Id;
        opp.Won_Lost_Reason__c='Credit Terms';
        opp.CloseDate=system.today();
        insert opp;
         Bidder__c Bi = New Bidder__c();
        bi.Note__c = 'Test Bidder Note';
        Bi.Apparent_Winning_Bidder__c =TRUE;
        Bi.of_Follow_up_Attempts__c=1;
        Bi.Bidder_Outcome_Feedback__c='';
        bi.Inactive__c=false;
        Bi.CurrencyIsoCode='';
        Bi.Opportunity__c = opp.id;
        insert Bi;
    }
    static testMethod void updatevalues(){
       
        AVA_SFCORE__TaxNowSetting__c ts2 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts2.AVA_SFCORE__Active_Setting__c = true; 
        ts2.Name='Test Account2';
        upsert ts2;
        Account a = new Account(Name = 'Test');
        a.BillingState = 'Nevada';
        a.BillingCountry = 'United States';
        upsert a;
        Opportunity opp = New Opportunity();
        opp.Name = 'test1';
        opp.StageName ='Closed Won';
        opp.Vertical_Market__c = 'Mining';
        opp.Probability = 50;
        opp.AccountId = a.Id;
        opp.Won_Lost_Reason__c='Credit Terms';
        opp.CloseDate=system.today();
        upsert opp;
         Bidder__c B = New Bidder__c();
        B.Apparent_Winning_Bidder__c =TRUE;
        B.of_Follow_up_Attempts__c=1;
        B.Bidder_Outcome_Feedback__c='';
        B.CurrencyIsoCode='';
        B.Opportunity__c = opp.id;
        b.Inactive__c=false;
        insert B;
    }
   static testMethod void deleteValues()
   {   
      UpdateBidderTestClass.updateBidderValues();
     Opportunity delacc = [select id from Opportunity where Name = 'test Bidder Opportunity'];
     delete delacc; 
       Bidder__c delbid = [select id from Bidder__c where Note__c = 'Test Bidder Note'];
       delete delbid;
       
     
    }      
   /* void testdelete()
    {
          AVA_SFCORE__TaxNowSetting__c ts3 = new AVA_SFCORE__TaxNowSetting__c(); 
       ts3.AVA_SFCORE__Active_Setting__c = false; 
       ts3.Name='Test Account2';
       insert ts3;
       //delete ts3;
       Address__c address = new Address__C(Address_Line_1__c = 'line1',  City__c = 'City', Country__c = 'United States', State_Province__c = 'Minnesota');
       address.Postal_Code__c = '518000';
       insert address;
       //delete address;
       Account acct = new Account(Name = 'Test');
       acct.BillingState = 'Nevada';
       acct.BillingCountry = 'United States';
       insert acct;
       delete acct;
      
       Opportunity opp1 = New Opportunity();
       opp1.Name = 'test1';
       opp1.StageName ='Closed Won';
       opp1.Vertical_Market__c = 'Mining';
       opp1.Probability = 50;
       opp1.AccountId = acct.Id;
       opp1.Won_Lost_Reason__c='Credit Terms';
       opp1.CloseDate=system.today();
       insert opp1;
       delete opp1;
       Bidder__c Bidder = New Bidder__c();
       Bidder.Apparent_Winning_Bidder__c =TRUE;
       Bidder.of_Follow_up_Attempts__c=1;
       Bidder.Bidder_Outcome_Feedback__c='';
       Bidder.CurrencyIsoCode='';
       Bidder.Inactive__c=false;
       insert Bidder;
       delete Bidder;
       
    }*/
    
}