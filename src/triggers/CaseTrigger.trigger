trigger CaseTrigger on Case (before update, before delete, after update, after insert) 
{   
    if(TriggerAccessUtility.tau.get('Case').isAccessible()){
        if(trigger.IsUpdate && trigger.isBefore){
            CaseTriggerHandler.onBeforeUpdate(trigger.newMap, trigger.oldMap);
        } else if(trigger.isUpdate && trigger.isAfter){
            //System.debug('=====>DML Statements: '+Limits.getDMLStatements());
            //System.debug('=====>SOQL Queries: '+Limits.getQueries());
            
            if(!System.isFuture() && !System.isBatch()){
                for(Case c : trigger.newMap.values()){
                    if(c.AssetId != null && (trigger.oldMap == null || trigger.oldMap.get(c.Id).AssetId != c.AssetId)){WarrantyOracleHandler.getWarrantyInfo(c.AssetId);
                    }
                }
                CaseTriggerHandler.onAfterUpdate(trigger.newMap, trigger.oldMap);
            }
        } else if(trigger.isDelete && trigger.isBefore){
            List<Case_Service_Code__c> cscs = [select Id from Case_Service_Code__c where Case__r.Id in :trigger.old];
            System.debug('DELETING CSCS: '+cscs.size());
            if(cscs.size()>0){delete cscs;
            }
        } else if(trigger.isInsert && trigger.isAfter && !System.isFuture() && !System.isBatch()){
            List<String> aIds = new List<String>();
            for(Case c : trigger.newMap.values()){
                if(c.AssetId != null && (trigger.oldMap == null || trigger.oldMap.get(c.Id).AssetId != c.AssetId))
                    aIds.add(c.AssetId);//WarrantyOracleHandler.getWarrantyInfo(c.AssetId);
            }
            if(aIds.size()>0){
                WarrantyOracleHandler.getWarrantyInfo(aIds);
            }
        }
    }
}