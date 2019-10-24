trigger OrderTrigger on Order__c (after update, before update, after insert, before insert) {

    // First check if there are any records in the order list whose Bypass field is set to true => Don't execute the trigger!
    // Useful for updating fields for a set of records from a script where you don't want the trigger to fire.
    // Assumption: All records in the list either have this field set to true or all the records have this field set to false.
    // So break out of the for loop after checking the first record.
    Boolean skip = false;
    if (!trigger.isDelete)
    {
        // only applies to updates and inserts
        for (Order__c o : trigger.new)
        {
            if (o.Bypass__c == true)
                skip = true;
                
            break;
        }
    }
    if (!trigger.isInsert)
    {
        // only applies to updates and deletes
        // if any existing order records have a Bypass of true then don't execute the trigger since we are only trying to reset the value back to false
        for (Order__c o : trigger.old)
        {
            if (o.Bypass__c == true)
                skip = true;
                
            break;
        }
    }
 
 
    if (!skip)
    {
        if(trigger.isUpdate)
        {
            if(trigger.isBefore)
               //OrderTriggerHandler.onBeforeUpdate(trigger.new, trigger.oldMap);
            
            if(trigger.isAfter)
            {
                OrderTriggerHandler.onAfterUpdate(trigger.newMap, trigger.oldMap);
            }
        }
        
        if(trigger.isInsert)
        {
            if(trigger.isBefore)
            {
                OrderTriggerHandler.onBeforeInsert(trigger.new);
            }
            
            if(trigger.isAfter)
            {
                //OrderTriggerHandler.onAfterInsert(trigger.newMap);
            }
        }
    }
    else
        System.debug('Order Trigger bypassed due to a bulk data update');

}