@istest
public class FolloUpAttemptsTest {
    
    static testMethod void followUptest(){
        test.startTest();
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
        opp.Bid_Date__c = System.today()+20;
        insert opp;
        
        Bidder__c bidderObj = new Bidder__c();
        bidderObj.Opportunity__c = opp.id;
        bidderObj.Apparent_Winning_Bidder__c = FALSE;
        bidderObj.Daikin_Outcome_Feedback__c = 'Received firm commitment to use Daikin';
        bidderObj.Bidder_Outcome_Feedback__c = 'Pending';
        bidderObj.Inactive__c = false;
        bidderObj.Note__c = 'Follow up this bidder';
        insert bidderObj;
        bidderObj.Note__c = 'TEST FOLLOW UP THIS BIDDER';
        bidderObj.Inactive__c = TRUE;
        bidderObj.Apparent_Winning_Bidder__c = TRUE;
        bidderObj.Bidder_Outcome_Feedback__c = 'pending';
        bidderObj.Daikin_Outcome_Feedback__c = 'Received firm commitment to use Daikin';
        update bidderObj;
        test.stopTest();
            }
}