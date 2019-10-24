trigger AttachmentTrigger on Attachment (after insert, after update, after delete, after undelete) {
    
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
        
        if(trigger.isInsert){
       		AttachmentUtility.getCheckforAttachment(Trigger.new);
        }
        if(trigger.isUpdate){
            AttachmentUtility.getCheckforAttachment(Trigger.new);
        }
        if(trigger.isDelete){
            AttachmentUtility.getCheckforAttachment(Trigger.old); 
        }
        if(trigger.isUndelete){
            AttachmentUtility.getCheckforAttachment(Trigger.new);
        }
    }

}