trigger CaseServiceCodeTrigger on Case_Service_Code__c (before insert,after update, after insert, /*before*/after delete, after undelete) {
    
   // List<Case_Service_Code__c> csCodeList = new  List<Case_Service_Code__c>();
    if(trigger.isInsert && trigger.isBefore)
    { 
    	CaseServiceCodeTriggerHelper.caseServiceCodeCurrency(trigger.new);    
    }
    else
    {
    	new CaseServiceCodeTriggerHelper(Trigger.oldMap, Trigger.newMap).rollupToParentCase();    
    }
    
    /*    List<Case> pcases = new List<Case>();
Set<Id> codes = null;
if(Trigger.newMap!=null)
codes = Trigger.newMap.keySet();
else
codes = Trigger.oldMap.keySet();

List<Case_Service_Code__c> cscs = [select Id, Case__c, Case__r.ParentId
, Case__r.Hours_Approved__c, Case__r.Labor_Amount_Approved__c, Case__r.Daikin_Parts_Amount_Approved__c, Case__r.X3rd_Party_Parts_Amount_Approved__c, Case__r.Additional_Materials_Amount_Approved__c
, Case__r.Parent.Hours_Approved__c, Case__r.Parent.Labor_Amount_Approved__c, Case__r.Parent.Daikin_Parts_Amount_Approved__c, Case__r.Parent.X3rd_Party_Parts_Amount_Approved__c, Case__r.Parent.Additional_Materials_Amount_Approved__c 
from Case_Service_Code__c where Case__c != null and Case__r.ParentId != null and Id in :codes];
for(Case_Service_Code__c csc :cscs){
Decimal oldval = null;
Decimal oldval_labor = null;
Decimal oldval_dparts = null;
Decimal oldval_tparts = null;
Decimal oldval_mats = null;
Decimal oldval_req = null;
Decimal oldval_labor_req = null;
Decimal oldval_dparts_req = null;
Decimal oldval_tparts_req = null;
Decimal oldval_mats_req = null;

if(Trigger.oldMap != null){
oldval = Trigger.oldMap.get(csc.ID).Hours_Approved__c;
oldval_labor = Trigger.oldMap.get(csc.ID).Labor_Amount_Approved__c;
oldval_dparts = Trigger.oldMap.get(csc.ID).Daikin_Parts_Amount_Approved__c;
oldval_tparts = Trigger.oldMap.get(csc.ID).X3rd_Party_Parts_Amount_Approved__c;
oldval_mats = Trigger.oldMap.get(csc.ID).Additional_Materials_Amount_Approved__c;
}
if(oldval==null)
oldval = 0.00;
if(oldval_labor==null)
oldval_labor = 0.00;
if(oldval_dparts==null)
oldval_dparts = 0.00;
if(oldval_tparts==null)
oldval_tparts = 0.00;
if(oldval_mats==null)
oldval_mats = 0.00;

Decimal newval = null;
Decimal newval_labor = null;
Decimal newval_dparts = null;
Decimal newval_tparts = null;
Decimal newval_mats = null;
if(Trigger.newMap != null){
newval = Trigger.newMap.get(csc.ID).Hours_Approved__c;
newval_labor = Trigger.newMap.get(csc.ID).Labor_Amount_Approved__c;
newval_dparts = Trigger.newMap.get(csc.ID).Daikin_Parts_Amount_Approved__c;
newval_tparts = Trigger.newMap.get(csc.ID).X3rd_Party_Parts_Amount_Approved__c;
newval_mats = Trigger.newMap.get(csc.ID).Additional_Materials_Amount_Approved__c;
}
if(newval==null)
newval=0.00;
if(newval_labor==null)
newval_labor=0.00;
if(newval_dparts==null)
newval_dparts = 0.00;
if(newval_tparts==null)
newval_tparts = 0.00;
if(newval_mats==null)
newval_mats = 0.00;

if(newval != oldval){
if(csc.Case__r.Hours_Approved__c==null)
csc.Case__r.Hours_Approved__c=0;                
if(csc.Case__r.Parent.Hours_Approved__c==null)
csc.Case__r.Parent.Hours_Approved__c=0;                

if(newval>oldval){
csc.Case__r.Hours_Approved__c=csc.Case__r.Hours_Approved__c+(newval-oldval);
csc.Case__r.Parent.Hours_Approved__c=csc.Case__r.Parent.Hours_Approved__c+(newval-oldval);
} else if(csc.Case__r.Hours_Approved__c>0){
csc.Case__r.Hours_Approved__c=csc.Case__r.Hours_Approved__c-(oldval-newval);
csc.Case__r.Parent.Hours_Approved__c=csc.Case__r.Parent.Hours_Approved__c-(oldval-newval);
}
}

if(newval_labor != oldval_labor){
if(csc.Case__r.Labor_Amount_Approved__c==null)
csc.Case__r.Labor_Amount_Approved__c=0;                
if(csc.Case__r.Parent.Labor_Amount_Approved__c==null)
csc.Case__r.Parent.Labor_Amount_Approved__c=0;                

if(newval_labor>oldval_labor){
csc.Case__r.Labor_Amount_Approved__c=csc.Case__r.Labor_Amount_Approved__c+(newval_labor-oldval_labor);
csc.Case__r.Parent.Labor_Amount_Approved__c=csc.Case__r.Parent.Labor_Amount_Approved__c+(newval_labor-oldval_labor);
} else if(csc.Case__r.Labor_Amount_Approved__c>0){
csc.Case__r.Labor_Amount_Approved__c=csc.Case__r.Labor_Amount_Approved__c-(oldval_labor-newval_labor);
csc.Case__r.Parent.Labor_Amount_Approved__c=csc.Case__r.Parent.Labor_Amount_Approved__c-(oldval_labor-newval_labor);
}
}

if(newval_dparts != oldval_dparts){
if(csc.Case__r.Daikin_Parts_Amount_Approved__c==null)
csc.Case__r.Daikin_Parts_Amount_Approved__c=0;                
if(csc.Case__r.Parent.Daikin_Parts_Amount_Approved__c==null)
csc.Case__r.Parent.Daikin_Parts_Amount_Approved__c=0;                

if(newval_dparts>oldval_dparts){
csc.Case__r.Daikin_Parts_Amount_Approved__c=csc.Case__r.Daikin_Parts_Amount_Approved__c+(newval_dparts-oldval_dparts);
csc.Case__r.Parent.Daikin_Parts_Amount_Approved__c=csc.Case__r.Parent.Daikin_Parts_Amount_Approved__c+(newval_dparts-oldval_dparts);
} else if(csc.Case__r.Daikin_Parts_Amount_Approved__c>0){
csc.Case__r.Daikin_Parts_Amount_Approved__c=csc.Case__r.Daikin_Parts_Amount_Approved__c-(oldval_dparts-newval_dparts);
csc.Case__r.Parent.Daikin_Parts_Amount_Approved__c=csc.Case__r.Parent.Daikin_Parts_Amount_Approved__c-(oldval_dparts-newval_dparts);
}
}

if(newval_tparts != oldval_tparts){
if(csc.Case__r.X3rd_Party_Parts_Amount_Approved__c==null)
csc.Case__r.X3rd_Party_Parts_Amount_Approved__c=0;                
if(csc.Case__r.Parent.X3rd_Party_Parts_Amount_Approved__c==null)
csc.Case__r.Parent.X3rd_Party_Parts_Amount_Approved__c=0;                

if(newval_tparts>oldval_tparts){
csc.Case__r.X3rd_Party_Parts_Amount_Approved__c=csc.Case__r.X3rd_Party_Parts_Amount_Approved__c+(newval_tparts-oldval_tparts);
csc.Case__r.Parent.X3rd_Party_Parts_Amount_Approved__c=csc.Case__r.Parent.X3rd_Party_Parts_Amount_Approved__c+(newval_tparts-oldval_tparts);
} else if(csc.Case__r.X3rd_Party_Parts_Amount_Approved__c>0){
csc.Case__r.X3rd_Party_Parts_Amount_Approved__c=csc.Case__r.X3rd_Party_Parts_Amount_Approved__c-(oldval_tparts-newval_tparts);
csc.Case__r.Parent.X3rd_Party_Parts_Amount_Approved__c=csc.Case__r.Parent.X3rd_Party_Parts_Amount_Approved__c-(oldval_tparts-newval_tparts);
}
}

if(newval_mats != oldval_mats){
if(csc.Case__r.Additional_Materials_Amount_Approved__c==null)
csc.Case__r.Additional_Materials_Amount_Approved__c=0;                
if(csc.Case__r.Parent.Additional_Materials_Amount_Approved__c==null)
csc.Case__r.Parent.Additional_Materials_Amount_Approved__c=0;                

if(newval_mats>oldval_mats){
csc.Case__r.Additional_Materials_Amount_Approved__c=csc.Case__r.Additional_Materials_Amount_Approved__c+(newval_mats-oldval_mats);
csc.Case__r.Parent.Additional_Materials_Amount_Approved__c=csc.Case__r.Parent.Additional_Materials_Amount_Approved__c+(newval_mats-oldval_mats);
} else if(csc.Case__r.Additional_Materials_Amount_Approved__c>0){
csc.Case__r.Additional_Materials_Amount_Approved__c=csc.Case__r.Additional_Materials_Amount_Approved__c-(oldval_mats-newval_mats);
csc.Case__r.Parent.Additional_Materials_Amount_Approved__c=csc.Case__r.Parent.Additional_Materials_Amount_Approved__c-(oldval_mats-newval_mats);
}
}

if(!pcases.contains(csc.Case__r))
pcases.add(csc.Case__r);
if(!pcases.contains(csc.Case__r.Parent))
pcases.add(csc.Case__r.Parent);            
}    

if(pcases.size()>0){
update pcases;
}*/
}