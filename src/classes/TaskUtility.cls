public class TaskUtility {
    public static void getCaseTasksCount(List<Task> taskRecords){
        list<Task> caseRelatedTasks = new List<Task>();
        set<Id> caseIds = new set<Id>();
        for(Task t: taskRecords){
            if(t.WhatId != NULL){
                String myIdPrefix = String.valueOf(t.WhatId).substring(0,3);
            	if(myIdPrefix == '500'){
                	caseRelatedTasks.add(t);
                	caseIds.add(t.whatId);
            	}
            
            }
        }
        List<AggregateResult> groupedResults = [Select  Count(Id), WhatId from task Where WhatId in: caseIds Group By WhatId];
        List<Case> casestobeUpdated = New List<Case>();
        
        for (AggregateResult ar : groupedResults)  {
			Case c = new case();
            c.id =  (id)ar.get('WhatId');
            c.Number_of_Tasks__c = (Integer)ar.get('expr0');
            
            casestobeUpdated.add(c);
    		System.debug('Case Id:' + ar.get('WhatId'));

    		System.debug('Number Of Tasks:' + ar.get('expr0'));

		}
        
        for(Case cc: [SELECT Id, Number_of_Tasks__c FROM Case WHERE Id in:caseIds and Id Not in:casestobeUpdated and Number_of_Tasks__c != 0]){
            cc.Number_of_Tasks__c =0;
            casestobeUpdated.add(cc);
        }
        if(casestobeUpdated.size()>0)
        update casestobeUpdated;

        
    }
    
    public static void hasAttachment(List<Task> tasks){
        Set<Id> taskIds = new set<Id>();
        Set<Id> taskwithAttachments = new set<Id>();
        List<Task> updateTasks = new List<Task>();
        for(Task t: tasks){
            if(t.Attachment__c == FALSE)
            	taskIds.add(t.id);
        }
        for(Attachment a: [SELECT Id, ParentId FROM Attachment Where ParentId in: taskIds]){
            taskwithAttachments.add(a.ParentId);
        }
        
        for(task t: [SELECT Id, Attachment__c FROM Task WHERE Id in: taskwithAttachments AND Attachment__c = FALSE]){
            T.Attachment__c =true;
            updateTasks.add(T);
        }
        if(updateTasks.size()>0)
            update updateTasks;
    }
    
   
}