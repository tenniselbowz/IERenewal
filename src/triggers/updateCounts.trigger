trigger updateCounts on Customer_Documents__c (after insert, after delete, after update) {
    
    set<String> proposalIds = new set<String>();
    System.debug('called');
    if(trigger.isInsert){
        System.debug(LoggingLevel.Info, 'Your info');
        System.debug(LoggingLevel.Info,'called');
        for(Customer_Documents__c c :trigger.new){
            System.debug(LoggingLevel.Info,'new');
            proposalIds.add(c.Quote_Proposal__c);    
        }    
    }
    if(trigger.isDelete){
        for(Customer_Documents__c c :trigger.old){
            proposalIds.add(c.Quote_Proposal__c);    
        }   
    }
    if(trigger.isupdate){
        for(Customer_Documents__c c :trigger.new){
            if(c.Document_Type__c != trigger.oldMap.get(c.Id).Document_Type__c){
            	proposalIds.add(c.Quote_Proposal__c);      
            }
              
        }   
    }
    
    System.debug('LoggingLevel.Info,'+proposalIds);
    Map<String, Apttus_Proposal__Proposal__c> countMap = new Map<String, Apttus_Proposal__Proposal__c>();
    for(Apttus_Proposal__Proposal__c a :[SELECT Id, Customer_PO_Count__c, Customer_Signature_Count__c,
                                         	(SELECT Id,Document_Type__c FROM Customer_Documents__r 
                                             WHERE (Document_Type__c = 'Customer PO' OR Document_Type__c = 'Customer Signature'))
                                         FROM Apttus_Proposal__Proposal__c WHERE Id IN :proposalIds]){
                                             Integer pocount = 0;
                                             Integer signCount = 0;
                                             for(Customer_Documents__c cd :a.Customer_Documents__r){
                                                 if(cd.Document_Type__c == 'Customer PO'){
                                                     pocount++;
                                                     System.debug(LoggingLevel.Info,+pocount);
                                                       
                                                 }else if(cd.Document_Type__c == 'Customer Signature'){
                                                     signCount++; 
                                                     
                                                 }
                                             }
                                             a.Customer_PO_Count__c =  pocount;
                                             System.debug(LoggingLevel.Info,+pocount);
                                             a.Customer_Signature_Count__c = signCount; 
                                             countMap.put(a.Id, a);
                                         }
    if(countMap.values().size() > 0){
        update countMap.values();    
    }
}