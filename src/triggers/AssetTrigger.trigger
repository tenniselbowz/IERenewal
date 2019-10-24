trigger AssetTrigger on Asset (after update, before update, after insert, before insert, before delete) {

    // First check if there are any records in the asset list whose Bypass field is set to true => Don't execute the trigger!
    // Useful for updating fields for a set of records from a script where you don't want the trigger to fire.
    // Assumption: All records in the list either have this field set to true or all the records have this field set to false.
    // So break out of the for loop after checking the first record.
    Boolean skip = false;
    if (!trigger.isDelete)
    {
        // only applies to updates and inserts
        for (Asset a : trigger.new)
        {
            if (a.Bypass__c == true)
                skip = true;
                
            break;
        }
    }
    if (!trigger.isInsert)
    {
        // only applies to updates and deletes
        // if any existing asset records have a Bypass of true then don't execute the trigger since we are only trying to reset the value back to false
        for (Asset a : trigger.old)
        {
            if (a.Bypass__c == true)
                skip = true;
                
            break;
        }
    }
    
    
    if (!skip)
    {
        if(trigger.isUpdate)
        {
            if(trigger.isBefore)
               AssetTriggerHandler.onBeforeUpdate(trigger.new, trigger.oldMap);
            
            if(trigger.isAfter)
            {
                AssetTriggerHandler.onAfterUpdate(trigger.newMap, trigger.oldMap);
            }
        }
        
        if(trigger.isInsert)
        {
            if(trigger.isBefore)
            {
                AssetTriggerHandler.onBeforeInsert(trigger.new);
            }
            
            if(trigger.isAfter)
            {
                AssetTriggerHandler.onAfterInsert(trigger.newMap);
            }
        }
        
        if(trigger.isDelete)
        {
            if(trigger.isBefore)
            {
                AssetTriggerHandler.onBeforeDelete( trigger.oldMap);
            }
        }
    }
    else
        System.debug('Asset Trigger bypassed due to a bulk data update');

}