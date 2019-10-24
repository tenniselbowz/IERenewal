trigger opptysplitsfortemplatesync on OpportunitySplit (after insert, after update, after delete) {
if(!GlobalPropertySettings.isUpdatingOpptySplits){
    List<OpportunitySplit> los = new List<OpportunitySplit>();
    if(Trigger.isInsert){
        for(OpportunitySplit split : Trigger.New) {
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
    } else if (Trigger.isUpdate){
        List<Opportunity_Splits_for_Templates__c> lost = new List<Opportunity_Splits_for_Templates__c>();
        for(OpportunitySplit split : Trigger.New) {
            OpportunitySplit oldSplit = Trigger.oldMap.get(split.Id);
            if(oldSplit.Opportunity_Splits_for_Template__c!= null && split.Opportunity_Splits_for_Template__c == null){
                List<Opportunity_Splits_for_Templates__c> temps = [select Id from Opportunity_Splits_for_Templates__c where Id=:oldSplit.Opportunity_Splits_for_Template__c];
                if(temps!=null && temps.size()>0)
                    delete temps;
            } else {
                List<Opportunity_Splits_for_Templates__c> temps = [select Id, Name, SplitAmount__c, SplitOwner__c, SplitPercent__c from Opportunity_Splits_for_Templates__c where Id=:split.Opportunity_Splits_for_Template__c];
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
    } else if (Trigger.isDelete){
        List<Opportunity_Splits_for_Templates__c> lost = new List<Opportunity_Splits_for_Templates__c>();
        for(OpportunitySplit split : Trigger.Old) {
            if(split.Opportunity_Splits_for_Template__c != null){
                List<Opportunity_Splits_for_Templates__c> temp = [select Id from Opportunity_Splits_for_Templates__c where Id=:split.Opportunity_Splits_for_Template__c];
                if(temp != null && temp.size()>0){
                    for(Opportunity_Splits_for_Templates__c t : temp)
                        lost.add(t);
               }
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