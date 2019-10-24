public class OpportunitySplitServices {

    public static final STRING INSERT_OPERATION = 'INSERT';
    public static final STRING UPDATE_OPERATION = 'UPDATE';
    public static final STRING DELETE_OPERATION = 'DELETE';
    public static final Set<String> LOST_OPPORTUNITY_STAGES = new Set<String> {'Closed Lost' , 'Abandoned' };
    public static final Set<String> WON_OPPORTUNITY_STAGES = new Set<String>{'Closed Won','Closed Won-Pending Credit Approval'};

    /* @Author:IBM 
    * @Date: 26 Feb 2018
    * @Description : Will be invoked by before insert and before update triggers
    *           Replacing the workflow with trigger to update fields
    * */
    public static void filterOpportunitySplits(List<OpportunitySplit> opportunitySplitList, Map<Id, Opportunity> opps, boolean doUpdate){
        if(opps == null){
            opps = new Map<Id, Opportunity>([SELECT Id, StageName
                                                    FROM Opportunity
                                                    WHERE Id IN :Pluck.ids('OpportunityId', OpportunitySplitList)]);
        }
        for(OpportunitySplit split : opportunitySplitList) {
            Opportunity opp = opps.get(split.OpportunityId);
            if(WON_OPPORTUNITY_STAGES.contains(opp.StageName)) {
                stampFields(split, true);
            }
            else if(!LOST_OPPORTUNITY_STAGES.contains(opp.StageName)) {
                stampFields(split, false);
            }
            else {
                clearFields(split);
            }
        }
       
        if(doUpdate)
        {
            updateOpportunitySplitList(opportunitySplitList,opps);
        }
    }

    public static void updateOpportunitySplitList(List<OpportunitySplit> opportunitySplitList,Map<Id, Opportunity> idToOpportunity){
        
        
        Database.SaveResult[] srList = Database.update(OpportunitySplitList, false);
        Opportunity currentOpportunity;
        for(integer i = 0; i < srList.size(); i++)
        {
            Database.SaveResult sr= srList[i];
            if(!sr.isSuccess())
            {
                string errors;
                for(Database.Error err : sr.getErrors()) {
                    errors+=  err.getMessage();
                }
                Id oppId = OpportunitySplitList[i].OpportunityId;
                system.debug('oppId--'+oppId);
                currentOpportunity = idToOpportunity.get(oppId);
                if(currentOpportunity != null)
                {
                    currentOpportunity.addError(errors);
                }
            }
        }
        
    }

    /* @Author:IBM
    * @Date: 26 Feb 2018
    * @Description : Will be invoked by filterOpportunitySplits
    *          Replacing the workflow with trigger to update fields for each OpportunitySplit
    * */

    public static void stampFields(OpportunitySplit opportunitySplit ,Boolean isClosedWon){
        if(isClosedWon){
            opportunitySplit.Closed_Won_Amount__c = opportunitySplit.SplitAmount;
            opportunitySplit.Pipeline_Amount__c=null;
        }
        else{
            opportunitySplit.Pipeline_Amount__c  = opportunitySplit.SplitAmount;
            opportunitySplit.Closed_Won_Amount__c=null;
        }
    }


    /* @Author:IBM
    * @Date: 14 march 2018
    * @Description : This method will clear the Closed and Pipeline fields

    * */

    public static void clearFields(OpportunitySplit opportunitySplit ){

            opportunitySplit.Closed_Won_Amount__c = null;
            opportunitySplit.Pipeline_Amount__c=null;


    }

    /*
    * @Author:IBM
    * @Date: 26 Feb 2018
    * @Description : Refactoring from "opptysplitsfortemplatessync" trigger
    * Will be invoked by opportunity split helper class
    * to update either Closed_Won_Amount__c or Pipeline_Amount__c with SplitAmount conditionally
    * */
    public static void afterStampFields(list<OpportunitySplit> newOpportunitySplitList, Map<Id,OpportunitySplit> oldOpportunitySplitMap, String dmlMode ){

        if(!GlobalPropertySettings.isUpdatingOpptySplits){
            List<OpportunitySplit> los = new List<OpportunitySplit>();
            if(dmlMode == OpportunitySplitServices.INSERT_OPERATION){
                for(OpportunitySplit split : newOpportunitySplitList) {
                    Opportunity_Splits_for_Templates__c temp = new Opportunity_Splits_for_Templates__c();
                    temp.Name=String.valueof(DateTime.now().getTime());
                    temp.SplitAmount__c=split.SplitAmount;
                    temp.SplitOwner__c=split.SplitOwnerId;
                    temp.SplitPercent__c=split.SplitPercentage;
                    temp.Opportunity__c=split.OpportunityId;
                    insert temp;
                    OpportunitySplit split1 = [select Id, Opportunity_Splits_for_Template__c from OpportunitySplit where Id=:split.Id];
                    split1.Opportunity_Splits_for_Template__c=temp.Id;
                    los.add(split1);
                }
            } else if (dmlMode == OpportunitySplitServices.UPDATE_OPERATION){
                List<Opportunity_Splits_for_Templates__c> lost = new List<Opportunity_Splits_for_Templates__c>();
                for(OpportunitySplit split : newOpportunitySplitList)
                {
                    OpportunitySplit oldSplit = oldOpportunitySplitMap.get(split.Id);
                    if(oldSplit.Opportunity_Splits_for_Template__c!= null && split.Opportunity_Splits_for_Template__c == null)
                    {
                        List<Opportunity_Splits_for_Templates__c> temps = [select Id from Opportunity_Splits_for_Templates__c where Id=:oldSplit.Opportunity_Splits_for_Template__c];
                        System.debug('Templates ::::'+temps);
                        if(temps!=null && temps.size()>0)
                            delete temps;
                    } else 
                    {
                        List<Opportunity_Splits_for_Templates__c> temps = [select Id, Name, SplitAmount__c, SplitOwner__c, SplitPercent__c,Opportunity__c from Opportunity_Splits_for_Templates__c where Id=:split.Opportunity_Splits_for_Template__c];
                        if(temps == null || temps.size()==0){
                            Opportunity_Splits_for_Templates__c temp = new Opportunity_Splits_for_Templates__c();
                            temp.Name=String.valueof(DateTime.now().getTime());
                            temp.SplitAmount__c=split.SplitAmount;
                            temp.SplitOwner__c=split.SplitOwnerId;
                            temp.SplitPercent__c=split.SplitPercentage;
                            temp.Opportunity__c=split.OpportunityId;
                            insert temp;
                            OpportunitySplit split1 = [select Id, Opportunity_Splits_for_Template__c from OpportunitySplit where Id=:split.Id];
                            split1.Opportunity_Splits_for_Template__c=temp.Id;
                            los.add(split1);
                        } else if(temps!= null && temps.size()>0) {
                            for(Opportunity_Splits_for_Templates__c temp :temps){
                                if(temp.SplitAmount__c!=split.SplitAmount || temp.SplitOwner__c!=split.SplitOwner.Id || temp.SplitPercent__c!=split.SplitPercentage || temp.Opportunity__c!=split.OpportunityId){
                                    temp.SplitAmount__c=split.SplitAmount;
                                    temp.SplitOwner__c=split.SplitOwnerId;
                                    temp.SplitPercent__c=split.SplitPercentage;
                                    temp.Opportunity__c=split.OpportunityId;
                                    lost.add(temp);
                                }
                            }
                        }
                    }
                }
                if(lost.size()>0)
                    update lost;
            }
            
            else if (dmlMode== OpportunitySplitServices.DELETE_OPERATION){
                List<Opportunity_Splits_for_Templates__c> lost = new List<Opportunity_Splits_for_Templates__c>();
                for(OpportunitySplit split : oldOpportunitySplitMap.values()) {
                    if(split.Opportunity_Splits_for_Template__c != null){
                        Opportunity_Splits_for_Templates__c temp = [select Id from Opportunity_Splits_for_Templates__c where Id=:split.Opportunity_Splits_for_Template__c];
                        if(temp != null)
                            lost.add(temp);
                    }
                }
                if(lost.size()>0)
                    delete lost;
            }

            GlobalPropertySettings.isUpdatingOpptySplits = true;
            if(los.size()>0)
                update los;
            GlobalPropertySettings.isUpdatingOpptySplits = false;
        }
    }
   
    public static void updateOpportunities(list<OpportunitySplit> opportunitySplitList){
        List<Opportunity> oppList = new List<Opportunity>();
        Map<String, list<OpportunitySplit>> oppSplits = new Map<String, list<OpportunitySplit>>();
        set<String> oppIds = new set<String>();
        for(OpportunitySplit s :opportunitySplitList){
        	oppIds.add(s.OpportunityId);
        }
        set<String> userIds = new set<String>();
        List<Opportunity> opportunityList = [SELECT Id,Opportunity_Split_Owner__c,(SELECT Id,SplitOwnerId,OpportunityId
                                                                    FROM OpportunitySplits) FROM Opportunity WHERE Id IN :oppIds];
        for(Opportunity opp :opportunityList){
            for(OpportunitySplit split :opp.OpportunitySplits){
                userIds.add(split.SplitOwnerId);
                if(oppSplits.containsKey(split.OpportunityId))
                {
                    oppSplits.get(split.OpportunityId).add(split);
                }
                else
                {
                    oppSplits.put(split.OpportunityId, new list<OpportunitySplit>{split});
                }                                                                
            } 
        }
        Integer i = 0;
        Map<Id, User> userObj = new Map<Id, User>([SELECT Id, Name,User_Department__c from User WHERE id IN :userIds]);
        for(Opportunity opp :opportunityList){
            if(oppSplits.containsKey(opp.id)){
                opp.Opportunity_Split_Owner__c = '';
                for(OpportunitySplit s :oppSplits.get(opp.id)){
                    i++;
                    opp.Opportunity_Split_Owner__c += 'Opportunity Split Member'+' '+i+':'+ userObj.get(s.SplitOwnerId).Name
                        +' ('+userObj.get(s.SplitOwnerId).User_Department__c +'), ';     
                }    
                  opp.Opportunity_Split_Owner__c = opp.Opportunity_Split_Owner__c.removeEnd(', ');
            }
           /* else{
                opp.Opportunity_Split_Owner__c = ' ';
                system.debug('opp.Opportunity_Split_Owner__c::'+opp.Opportunity_Split_Owner__c);
            }   */
            oppList.add(opp);
        }
        if(oppList.size() > 0){
            update oppList;    
        }
    }
}