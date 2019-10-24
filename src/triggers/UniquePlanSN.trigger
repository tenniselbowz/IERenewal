trigger UniquePlanSN on Case_Plan_Asset__c (before insert, before update) {
    
    List<Id> plans = new List<Id>();
    List<Id> assets = new List<Id>();
    List<Id> caseplanassets = new List<Id>();    
    for(Case_Plan_Asset__c cpa : Trigger.new){
        plans.add(cpa.Case_Plan__c);
        assets.add(cpa.Asset__c);
        if(cpa.Id != null)
            caseplanassets.add(cpa.Id);
    }
    
    List<Case_Plan_Asset__c> cpas = [select Id, Case_Plan__c, Case_Plan__r.Name, Asset__c, Asset__r.SerialNumber from Case_Plan_Asset__c where Case_Plan__c in :plans and Asset__c in :assets and Id not in :caseplanassets];
    Map<Id, Asset> asts = new Map<Id, Asset>([select Id, SerialNumber from Asset where Id in :assets]); 
    for(Case_Plan_Asset__c cpa :Trigger.new){
        for(Case_Plan_Asset__c cpa2 :cpas){
            if(cpa.Case_Plan__c==cpa2.Case_Plan__c && cpa.Asset__c==cpa2.Asset__c){
                cpa.Asset__c.addError('Asset ('+cpa2.Asset__r.SerialNumber+') is already associated to the Plan ('+cpa2.Case_Plan__r.Name+')');
            }
        }
        cpa.Serial_Number_Searchable__c=asts.get(cpa.Asset__c).SerialNumber;
    }    
}