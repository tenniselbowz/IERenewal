trigger SubscriptionTrigger on Subscription__c (before insert, before delete, before update) {

    // First check if there are any records in the subscription list whose Bypass field is set to true => Don't execute the trigger!
    // Useful for updating fields for a set of records from a script where you don't want the trigger to fire.
    // Assumption: All records in the list either have this field set to true or all the records have this field set to false.
    // So break out of the for loop after checking the first record.
    Boolean skip = false;
    if (!trigger.isDelete)
    {
        // only applies to updates and inserts
        for (Subscription__c s : trigger.new)
        {
            if (s.Bypass__c == true)
                skip = true;
                
            break;
        }
    }
    if (!trigger.isInsert)
    {
        // only applies to updates and deletes
        // if any existing subscription records have a Bypass of true then don't execute the trigger since we are only trying to reset the value back to false
        for (Subscription__c s : trigger.old)
        {
            if (s.Bypass__c == true)
                skip = true;
                
            break;
        }
    }


    if (!skip)
    {
        if(trigger.isBefore)
        {
            if(trigger.isUpdate)
                SubscriptionTriggerHandler.onBeforeUpdate(trigger.newMap, trigger.oldMap);
            
            if(trigger.isDelete)
                SubscriptionTriggerHandler.onBeforedelete(trigger.oldMap);
            
            if(trigger.isInsert)
                SubscriptionTriggerHandler.onBeforeInsert(trigger.new);
                        
        }
    }
    else
        System.debug('Subscription Trigger bypassed due to a bulk data update');

}