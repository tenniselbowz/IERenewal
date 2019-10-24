public class CaseServiceCodeTriggerHelper {
    private Map<Id, Case_Service_Code__c> oldMap;
    private Map<Id, Case_Service_Code__c> newMap;
    
    public CaseServiceCodeTriggerHelper(Map<Id, Case_Service_Code__c> oldMap, Map<Id, Case_Service_Code__c> newMap){
        this.oldMap = oldMap;
        this.newMap = newMap;
    }

/*    
    private Decimal getValue(Decimal oldval, Decimal newval, Decimal cval){
        if(oldval == null)
            oldval = 0.00;
        if(newval == null)
            newval = 0.00;
        if(cval==null)
            cval=0.00;                
            
        if(newval != oldval){
            if(newval>oldval){
                cval += (newval-oldval);
            } else if(cval>0){
                cval -= (oldval-newval);
            }
        }
        return cval;
    }
*/
    
    public void rollupToParentCase()
    {         
        Map<Id, Case_Service_Code__c> codes;
        if(newMap!=null)
            codes = newMap;
        else
            codes = oldMap;

         //add cases to update
         Set<Id> caseIds = new Set<Id>();
         for(ID idKey : codes.keySet()){
             Case_Service_Code__c csc = codes.get(idKey);
             if(!caseIds.contains(csc.Case__c))
                 caseIds.add(csc.Case__c);
         }
         //add parents too
         List<Case> cases = [select Id, ParentId from Case where Id in :caseIds];
         if(cases.size()>0){
             caseIds = new Set<Id>();
             for(Case c :cases){
                 if(!caseIds.contains(c.ParentId))
                     caseIds.add(c.ParentId);                 
             }
             if(caseIds.size()>0){
                 cases.addAll([select Id from Case where Id in :caseIds]);
             }
             update cases;//trigger so warrantytotals will calculate
             TriggerUtility.tau.get('CaseServiceCode').reset();
         }
         
    }
    


/*
    public void rollupToParentCaseOLD(){        
        List<Case> pcases = new List<Case>();
        Set<Id> codes = null;
        if(newMap!=null)
            codes = newMap.keySet();
        else
            codes = oldMap.keySet();
          
        List<Case_Service_Code__c> cscs = [select Id, Case__c, Case__r.ParentId
                                            , Case__r.Hours_Approved__c, Case__r.Labor_Amount_Approved__c, Case__r.Daikin_Parts_Amount_Approved__c, Case__r.X3rd_Party_Parts_Amount_Approved__c, Case__r.Additional_Materials_Amount_Approved__c
                                            , Case__r.Parent.Hours_Approved__c, Case__r.Parent.Labor_Amount_Approved__c, Case__r.Parent.Daikin_Parts_Amount_Approved__c, Case__r.Parent.X3rd_Party_Parts_Amount_Approved__c, Case__r.Parent.Additional_Materials_Amount_Approved__c 
                                            , Case__r.Hours_Requested__c, Case__r.Labor_Amount_Requested__c, Case__r.Daikin_Parts_Amount_Requested__c, Case__r.X3rd_Party_Parts_Amount_Requested__c, Case__r.Additional_Materials_Amount_Requested__c
                                            , Case__r.Parent.Hours_Requested__c, Case__r.Parent.Labor_Amount_Requested__c, Case__r.Parent.Daikin_Parts_Amount_Requested__c, Case__r.Parent.X3rd_Party_Parts_Amount_Requested__c, Case__r.Parent.Additional_Materials_Amount_Requested__c 
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
            
            if(oldMap != null){
                oldval = oldMap.get(csc.ID).Hours_Approved__c;
                oldval_labor = oldMap.get(csc.ID).Labor_Amount_Approved__c;
                oldval_dparts = oldMap.get(csc.ID).Daikin_Parts_Amount_Approved__c;
                oldval_tparts = oldMap.get(csc.ID).X3rd_Party_Parts_Amount_Approved__c;
                oldval_mats = oldMap.get(csc.ID).Additional_Materials_Amount_Approved__c;
                oldval_req = oldMap.get(csc.ID).Hours_Requested__c;
                oldval_labor_req = oldMap.get(csc.ID).Labor_Amount_Requested__c;
                oldval_dparts_req = oldMap.get(csc.ID).Daikin_Parts_Amount_Requested__c;
                oldval_tparts_req = oldMap.get(csc.ID).X3rd_Party_Parts_Amount_Requested__c;
                oldval_mats_req = oldMap.get(csc.ID).Additional_Materials_Amount_Requested__c;
            }
                
            Decimal newval = null;
            Decimal newval_labor = null;
            Decimal newval_dparts = null;
            Decimal newval_tparts = null;
            Decimal newval_mats = null;
            Decimal newval_req = null;
            Decimal newval_labor_req = null;
            Decimal newval_dparts_req = null;
            Decimal newval_tparts_req = null;
            Decimal newval_mats_req = null;
            
            if(newMap != null){
                newval = newMap.get(csc.ID).Hours_Approved__c;
                newval_labor = newMap.get(csc.ID).Labor_Amount_Approved__c;
                newval_dparts = newMap.get(csc.ID).Daikin_Parts_Amount_Approved__c;
                newval_tparts = newMap.get(csc.ID).X3rd_Party_Parts_Amount_Approved__c;
                newval_mats = newMap.get(csc.ID).Additional_Materials_Amount_Approved__c;
                newval_req = newMap.get(csc.ID).Hours_Requested__c;
                newval_labor_req = newMap.get(csc.ID).Labor_Amount_Requested__c;
                newval_dparts_req = newMap.get(csc.ID).Daikin_Parts_Amount_Requested__c;
                newval_tparts_req = newMap.get(csc.ID).X3rd_Party_Parts_Amount_Requested__c;
                newval_mats_req = newMap.get(csc.ID).Additional_Materials_Amount_Requested__c;
            }

            csc.Case__r.Hours_Approved__c=getValue(oldval, newval, csc.Case__r.Hours_Approved__c);
            csc.Case__r.Parent.Hours_Approved__c=getValue(oldval, newval, csc.Case__r.Parent.Hours_Approved__c);
            csc.Case__r.Labor_Amount_Approved__c=getValue(oldval_labor, newval_labor, csc.Case__r.Labor_Amount_Approved__c);
            csc.Case__r.Parent.Labor_Amount_Approved__c=getValue(oldval_labor, newval_labor, csc.Case__r.Parent.Labor_Amount_Approved__c);
            csc.Case__r.Daikin_Parts_Amount_Approved__c=getValue(oldval_dparts, newval_dparts, csc.Case__r.Daikin_Parts_Amount_Approved__c);
            csc.Case__r.Parent.Daikin_Parts_Amount_Approved__c=getValue(oldval_dparts, newval_dparts, csc.Case__r.Parent.Daikin_Parts_Amount_Approved__c);
            csc.Case__r.X3rd_Party_Parts_Amount_Approved__c=getValue(oldval_tparts, newval_tparts, csc.Case__r.X3rd_Party_Parts_Amount_Approved__c);
            csc.Case__r.Parent.X3rd_Party_Parts_Amount_Approved__c=getValue(oldval_tparts, newval_tparts, csc.Case__r.Parent.X3rd_Party_Parts_Amount_Approved__c);
            csc.Case__r.Additional_Materials_Amount_Approved__c=getValue(oldval_mats, newval_mats, csc.Case__r.Additional_Materials_Amount_Approved__c);
            csc.Case__r.Parent.Additional_Materials_Amount_Approved__c=getValue(oldval_mats, newval_mats, csc.Case__r.Parent.Additional_Materials_Amount_Approved__c);

            csc.Case__r.Hours_Requested__c=getValue(oldval_req, newval_req, csc.Case__r.Hours_Requested__c);
            csc.Case__r.Parent.Hours_Requested__c=getValue(oldval_req, newval_req, csc.Case__r.Parent.Hours_Requested__c);
            csc.Case__r.Labor_Amount_Requested__c=getValue(oldval_labor_req, newval_labor_req, csc.Case__r.Labor_Amount_Requested__c);
            csc.Case__r.Parent.Labor_Amount_Requested__c=getValue(oldval_labor_req, newval_labor_req, csc.Case__r.Parent.Labor_Amount_Requested__c);
            csc.Case__r.Daikin_Parts_Amount_Requested__c=getValue(oldval_dparts_req, newval_dparts_req, csc.Case__r.Daikin_Parts_Amount_Requested__c);
            csc.Case__r.Parent.Daikin_Parts_Amount_Requested__c=getValue(oldval_dparts_req, newval_dparts_req, csc.Case__r.Parent.Daikin_Parts_Amount_Requested__c);
            csc.Case__r.X3rd_Party_Parts_Amount_Requested__c=getValue(oldval_tparts_req, newval_tparts_req, csc.Case__r.X3rd_Party_Parts_Amount_Requested__c);
            csc.Case__r.Parent.X3rd_Party_Parts_Amount_Requested__c=getValue(oldval_tparts_req, newval_tparts_req, csc.Case__r.Parent.X3rd_Party_Parts_Amount_Requested__c);
            csc.Case__r.Additional_Materials_Amount_Requested__c=getValue(oldval_mats_req, newval_mats_req, csc.Case__r.Additional_Materials_Amount_Requested__c);
            csc.Case__r.Parent.Additional_Materials_Amount_Requested__c=getValue(oldval_mats_req, newval_mats_req, csc.Case__r.Parent.Additional_Materials_Amount_Requested__c);
            
            if(!pcases.contains(csc.Case__r))
                pcases.add(csc.Case__r);
            if(!pcases.contains(csc.Case__r.Parent))
                pcases.add(csc.Case__r.Parent);            
        }    
        
        if(pcases.size()>0){
            System.Debug('NUMBER OF CASES: '+pcases.size());
            update pcases;
        }
    }
*/
    
    public static void caseServiceCodeCurrency(List<Case_Service_Code__c> serviceCodelist)
    {
        //Update case service code currency with parent case currency while inserting case service code
        map<String,String> caseCurrencies = new Map<String,String>();
        Set<String> caseIds = new Set<String>();
        for(Case_Service_Code__c cserviceCode : serviceCodelist)
        {
            if(cserviceCode.Case__c !=null)
            {
                caseIds.add(cserviceCode.Case__c);
            }
        }
        for(Case c :[select id,CurrencyIsoCode from Case where id IN : caseIds AND Recordtype.DeveloperName='Warranty'])
        {
            caseCurrencies.put(c.id,c.CurrencyIsoCode);
        }
        for(Case_Service_Code__c csCode : serviceCodelist)
        {
            if(csCode.Case__c != NULL && caseCurrencies.containsKey(csCode.Case__c))
            {
                cscode.CurrencyIsoCode = caseCurrencies.get(csCode.Case__c);
            }
        }
    }
}