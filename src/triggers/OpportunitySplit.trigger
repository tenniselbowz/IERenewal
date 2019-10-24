trigger OpportunitySplit on OpportunitySplit (before insert, before update, after insert, after update, after delete) {
    
    //BEFORE Triggers - Update Amount fields based on opportunity stage
    if (Trigger.isBefore) {
        
        
        if (Trigger.isInsert) {
            OpportunitySplitTriggerHelper.handleBeforeInsert (trigger.new);
        }  
        else if (Trigger.isUpdate) {
            OpportunitySplitTriggerHelper.handleBeforeUpdate (trigger.new);
        }   
       
    }
    //After Triggers 
    else if (Trigger.isAfter) {
        
        if (Trigger.isInsert) {
        OpportunitySplitTriggerHelper.handleAfterInsert (trigger.new);
        }
        else if (Trigger.isUpdate) {
        OpportunitySplitTriggerHelper.handleAfterUpdate (trigger.new, trigger.oldMap);
        }
        else if (Trigger.isDelete) {
        OpportunitySplitTriggerHelper.handleAfterDelete (trigger.oldMap);
        }    
    }
}