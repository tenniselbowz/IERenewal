public class AttachmentUtility {
    public static void getCheckforAttachment (List<Attachment> hasAttachments){
        List<Attachment> TaskRelatedAttachments = new List<Attachment> ();
        List<Attachment> EventRelatedAttachments = new List<Attachment> ();
        
        set<Id> TaskIds = new set<Id>();
        set<Id> EventIds = new set<Id>();

        
        for(Attachment a: hasAttachments){
            String myIdPrefix = String.valueOf(a.ParentId).substring(0,3);
            if(myIdPrefix == '00T' ){
                TaskRelatedAttachments.add(a);
                TaskIds.add(a.ParentId);
            }
            
            else if(myIdPrefix == '00U'){
                EventRelatedAttachments.add(a);
                EventIds.add(a.ParentId);
            }
        }
        
        
        
        List<AggregateResult> groupedTaskResults = [Select  Count(Id), ParentId from Attachment Where ParentId in: TaskIds Group By ParentId];
        List<Task> tasksToBeUpdated = new List<Task>();
                
        List<AggregateResult> groupedEventResults = [Select  Count(Id), ParentId from Attachment Where ParentId in: EventIds Group By ParentId];
        List<Event> eventsToBeUpdated = new List<Event>();
        
        
        for (AggregateResult ar : groupedTaskResults)  {
			Task t = new Task();
            t.id =  (id)ar.get('ParentId');
            Integer i = (Integer)ar.get('expr0');
            if(i >0){
                t.attachment__c = TRUE;
            }
            tasksToBeUpdated.add(t);
    		System.debug('Case Id:' + t.id);

    		System.debug('Number Of Tasks:' +i);

		}
        
        for (AggregateResult ar : groupedEventResults)  {
			Event e = new Event();
            e.id =  (id)ar.get('ParentId');
            Integer i = (Integer)ar.get('expr0');
            if(i >0){
                e.attachment__c = TRUE;
            }
            eventsToBeUpdated.add(e);
    		System.debug('Case Id:' + e.id);

    		System.debug('Number Of Tasks:' +i);

		}
        
        for(Task tt: [SELECT Id, Attachment__c FROM Task WHERE Id in:TaskIds and Id Not in:tasksToBeUpdated and Attachment__c = TRUE]){
            tt.Attachment__c = FALSE;
            tasksToBeUpdated.add(tt);
        }
        
        for(Event ee: [SELECT Id, Attachment__c FROM Event WHERE Id in:EventIds and Id Not in:eventsToBeUpdated and Attachment__c = TRUE]){
            ee.Attachment__c = FALSE;
            eventsToBeUpdated.add(ee);
        }
        
        
        
        
        
        /*if(TaskIds != NULL && TaskIds.size()>0){
            for(Task t: [SELECT Id, Attachment__c FROM Task WHERE Id in:TaskIds]){
                t.attachment__c = TRUE;
                tasksToBeUpdated.add(t);
            }
        }
        
        if(EventIds != NULL && EventIds.size()>0){
            for(Event e: [SELECT Id, Attachment__c FROM Event WHERE Id in:EventIds]){
                e.attachment__c = TRUE;
                eventsToBeUpdated.add(e);
            }
        }*/
        
        
        if(tasksToBeUpdated.size() >0)
        update tasksToBeUpdated;
        
        if(eventsToBeUpdated.size() >0)
        update eventsToBeUpdated;
    }
    
   
}