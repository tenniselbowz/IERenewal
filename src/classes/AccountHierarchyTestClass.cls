@isTest
public class AccountHierarchyTestClass {
    @testSetup public static void dataSetUp()
    {
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
       ts1.AVA_SFCORE__Active_Setting__c = true; 
       ts1.Name='Test Account';
       insert ts1;
        Account accountRecord = new Account();
        accountRecord.Name ='Parent Account';
        accountRecord.type = 'Developer';
        insert accountRecord;
        
        Account childAccount = new Account();
        childAccount.Name='Child Account 1';
        childAccount.Type='Developer';
        childAccount.ParentId = accountRecord.Id;
        insert childAccount;
        
        Opportunity opportunityRecord = new Opportunity();
        opportunityRecord.Name = 'Parent Opportunity';
        opportunityRecord.StageName = 'Closed Won';
        opportunityRecord.Won_Lost_Reason__c='Credit Terms';
        opportunityRecord.AccountId = accountRecord.Id;
        opportunityRecord.Amount = 10000;
        opportunityRecord.CloseDate = system.today();
        opportunityRecord.Line_of_Business__c = 'MCP';
        opportunityRecord.Vertical_Market__c = 'Healthcare';
        opportunityRecord.Prevailing_Wage__c = 'No';
		insert opportunityRecord;  
        
        Opportunity childOpportunity = new Opportunity();
        childOpportunity.Name = 'Parent Opportunity';
        childOpportunity.StageName = 'Closed Won';
        childOpportunity.Won_Lost_Reason__c='Credit Terms';
        childOpportunity.AccountId = accountRecord.Id;
        childOpportunity.Amount = 10000;
        childOpportunity.CloseDate = system.today();
        childOpportunity.Line_of_Business__c = 'MCP';
        childOpportunity.Vertical_Market__c = 'Healthcare';
        childOpportunity.Prevailing_Wage__c = 'No';
		insert childOpportunity;  
        
         Opportunity childOpportunity2 = new Opportunity();
        childOpportunity2.Name = 'Parent Opportunity';
        childOpportunity2.StageName = 'Closed Won';
        childOpportunity2.Won_Lost_Reason__c='Credit Terms';
        childOpportunity2.AccountId = accountRecord.Id;
        childOpportunity2.Amount = 10000;
        childOpportunity2.CloseDate = system.today();
        childOpportunity2.Line_of_Business__c = 'MCP';
        childOpportunity2.Vertical_Market__c = 'Healthcare';
        childOpportunity2.Prevailing_Wage__c = 'No';
		insert childOpportunity2; 
    }
    
    public static testmethod void NationalAccountsHierarchy()
    {
        Account accountRec = [select id,name from Account where Name = 'Parent Account'];
        Apexpages.StandardController sc = new Apexpages.StandardController(accountRec);
        AccountHierarchy hierarchy = new AccountHierarchy(sc);
        hierarchy.getOpportunityList();
    }

}