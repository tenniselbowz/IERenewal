public class EventUtility {

    public static void getCaseEventsCount(List<Event> eventRecords){
        list<Event> caseRelatedEvents = new List<Event>();
        set<Id> caseIds = new set<Id>();
        for(Event e: eventRecords){
            if(e.whatId != NULL){
                String myIdPrefix = String.valueOf(e.WhatId).substring(0,3);
            	if(myIdPrefix == '500'){
                	caseRelatedEvents.add(e);
                	caseIds.add(e.whatId);
            	}
                
            }
        }
        List<AggregateResult> groupedResults = [Select Count(Id), WhatId from Event Where WhatId in: caseIds Group By WhatId];
        system.debug('groupedResults:' + groupedResults);
        List<Case> casestobeUpdated = New List<Case>();
        
        if(groupedResults != NULL){
            for (AggregateResult ar : groupedResults)  {
				Case c = new case();
                c.id =  (id)ar.get('WhatId');
            	c.Number_of_Events__c =   (Integer)ar.get('expr0');
            
            	casestobeUpdated.add(c);
    			System.debug('Case Id:' + ar.get('WhatId'));

    			System.debug('Number Of Events:' + ar.get('expr0'));

            } 
        }
        
        for(Case cc: [SELECT Id, Number_of_Events__c FROM Case WHERE Id in:caseIds and Id Not in:casestobeUpdated and Number_of_Events__c != 0]){
            cc.Number_of_Events__c =0;
            casestobeUpdated.add(cc);
        }
        
        If(casestobeUpdated.size() >0)
        update casestobeUpdated;

        
    }
    
    public static void hasAttachment(List<Event> events){
        Set<Id> eventIds = new set<Id>();
        Set<Id> eventswithAttachments = new set<Id>();
        List<Event> updateEvents = new List<Event>();
        for(Event e: events){
            if(e.Attachment__c == FALSE)
            	eventIds.add(e.id);
        }
        for(Attachment a: [SELECT Id, ParentId FROM Attachment Where ParentId in: eventIds]){
            eventswithAttachments.add(a.ParentId);
        }
        
        for(event e: [SELECT Id, Attachment__c FROM Event WHERE Id in: eventswithAttachments AND Attachment__c = FALSE]){
            e.Attachment__c =true;
            updateEvents.add(e);
        }
        if(updateEvents.size()>0)
            update updateEvents;
    }
}