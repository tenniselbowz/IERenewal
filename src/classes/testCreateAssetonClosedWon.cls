@isTest 

private class testCreateAssetonClosedWon {
    
    static testMethod void testCreateAssetonClosedWon(){
        
        //Account a = [select Id from Account limit 1];
        
        
        Account a = new Account();
        a.Name = 'Test Account';
        a.Type = 'Architect';
        a.Industry = 'Healthcare';
        
        insert a;  
        
        PricebookEntry pbID = [select Id from PricebookEntry where Pricebook2.Name='Standard Price Book' and IsActive = true limit 1];
        Opportunity o = new Opportunity();
        OpportunityLineItem ol = new OpportunityLineItem();
        
        o.AccountId = a.Id;
        o.Name = 'test';
        o.StageName = 'Develop Customer Solution/In Design';
        o.Won_Lost_Reason__c = 'win';
        o.CloseDate = date.today();
        o.Vertical_Market__c = 'Healthcare';
        insert o;
        
        ol.OpportunityId = o.Id;
        ol.Quantity = 1;
        ol.UnitPrice = 2.00;
        ol.PricebookEntryId = pbId.Id;
        
        insert ol;
        
        o.StageName= 'Closed Won';
        o.Won_Lost_Reason__c = 'Price';
        update o;
        
        delete ol;
        delete o;
        
        
        
    }
    
    
}