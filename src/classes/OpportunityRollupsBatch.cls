global class OpportunityRollupsBatch implements Database.Batchable<sObject> {
  
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
       
        String North_America_DSO_RecordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('North America - DSO').getRecordTypeId(); 
        String query = 'SELECT Id, Contact_Rollup__c,Bidder_Rollup__c,Product_Rollup__c, '+
            '(SELECT Id,ContactId,Role FROM OpportunityContactRoles),'+
            ' (SELECT Product2.Name FROM OpportunityLineItems Order By Product2.Name),'+
            ' (SELECT Bidder_Name__r.Name,ownerId, Owner.Name, Apparent_Winning_Bidder__c FROM Bidders__r WHERE Inactive__c=False Order By Bidder_Name__r.Name) '+
            ' FROM Opportunity '+
            ' WHERE RecordTypeId = :North_America_DSO_RecordTypeId AND Edited__c =true ';
        System.debug('query'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> oppList) {
        opportunityRollupsBatchHelper.opportunityRollupsUpdate(oppList);
        
    } 
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
                
    }
}