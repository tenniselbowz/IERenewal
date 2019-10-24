public class OpportunitySplitTriggerHelper {
    
    public static void handleAfterInsert(list<OpportunitySplit> newOpportunitySplitList )
    {
        OpportunitySplitServices.afterStampFields(newOpportunitySplitList,null, OpportunitySplitServices.INSERT_OPERATION);
         OpportunitySplitServices.updateOpportunities(newOpportunitySplitList);
    }
    
    public static void handleAfterUpdate(list<OpportunitySplit> newOpportunitySplitList, 
                                         Map<Id,OpportunitySplit> oldOpportunitySplitMap)
    {
        OpportunitySplitServices.afterStampFields(newOpportunitySplitList,oldOpportunitySplitMap, 
                                                  OpportunitySplitServices.UPDATE_OPERATION);
      //  OpportunitySplitServices.updateOpportunities(newOpportunitySplitList);
        
        
        
        
    }
    
    public static void handleAfterDelete(Map<Id,OpportunitySplit> oldOpportunitySplitMap)
    {
        OpportunitySplitServices.afterStampFields(null,oldOpportunitySplitMap,
                                                  OpportunitySplitServices.DELETE_OPERATION);
        List<OpportunitySplit> oppSplits = new List<OpportunitySplit>();
        for(OpportunitySplit s :oldOpportunitySplitMap.values()){
        	oppSplits.add(s);    
        }
        OpportunitySplitServices.updateOpportunities(oppSplits);
    }
    
    public static void handleBeforeUpdate(list<OpportunitySplit> opportunitySplitList )
    {
        OpportunitySplitServices.filterOpportunitySplits(opportunitySplitList, null, false);
       
    }
    
    public static void handleBeforeInsert(list<OpportunitySplit> opportunitySplitList )
    {
        OpportunitySplitServices.filterOpportunitySplits(opportunitySplitList, null, false);
        
    }
    
}