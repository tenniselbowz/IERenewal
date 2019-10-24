trigger AddressTrigger on Address__c (before update, after update, before insert, before delete) {
    if(!getGoogleMapsLocationAsync.isLocationUpdate){
        if(trigger.isUpdate)
        {
            if(trigger.isBefore)
                AddressTriggerHandler.onBeforeUpdate(trigger.newMap, trigger.oldMap);
    
            if(trigger.isAfter){
                AddressTriggerHandler.onAfterUpdate(trigger.newMap, trigger.oldMap);
            }
        }
        
        if(trigger.isDelete)
        {
            if(trigger.isBefore)
                AddressTriggerHandler.onBeforeDelete(trigger.oldMap);
        }
        
        if(trigger.isInsert)
        {
            if(trigger.isBefore)
                AddressTriggerHandler.onBeforeInsert(trigger.new);
        }
    
    } else {
        System.debug('Trigger bypassed due to Geolocation update');
    }

    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate) && !getGoogleMapsLocationAsync.isLocationUpdate && !system.isFuture() && !system.isBatch() && !Test.isRunningTest())
        getGoogleMapsLocationAsync.getLocation(trigger.newMap.keyset());
}