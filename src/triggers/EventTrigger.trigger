/**************************************************************************************
 Author       :   Amarendar Junuthula
 Created Date :   December 08, 2015
 Description  :   Trigger on Events to count number of activities related to Accounts, Contacts, Opportunities, Cases and Change Requests
***************************************************************************************/
trigger EventTrigger on Event (after insert, after update, after delete, after undelete) {
	//This trigger has to go and update the Number of Activities field on Case after a task is Created or Updated or Deleted or after undeleted.
    
    //Before events
    //if(trigger.isBefore){
        /*if(trigger.isInsert){
            
        }
        if(trigger.isUpdate){
            
        }
        if(trigger.isDelete){
            
        }*/
    //}
    
    //After Events
    if(trigger.isAfter){
        
        /*sObject[] triggerRecords;
    	if(!trigger.isDelete) triggerRecords = trigger.new;
    	else triggerRecords = trigger.old;
 
    	//Update Open Activity Count
    	ActivityUtils au = new ActivityUtils(triggerRecords);
    	au.updateAccountActivityCount();
    	au.updateContactActivityCount();
    	au.updateLeadActivityCount();
    	au.updateOpportunityActivityCount();
    	au.updateLeadActivityCount();
        au.updateCaseActivityCount();
        au.updateChangeRequestActivityCount();*/
        if(trigger.isInsert){
       		EventUtility.getCaseEventsCount(Trigger.new);
            EventUtility.hasAttachment(Trigger.new);
        }
        if(trigger.isUpdate){
            EventUtility.getCaseEventsCount(Trigger.new);
            EventUtility.hasAttachment(Trigger.new);
        }
        if(trigger.isDelete){
            EventUtility.getCaseEventsCount(Trigger.old); 
        }
        if(trigger.isUndelete){
            EventUtility.getCaseEventsCount(Trigger.new);
            EventUtility.hasAttachment(Trigger.new);
        }
    }
}