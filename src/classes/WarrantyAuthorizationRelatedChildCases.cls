public class WarrantyAuthorizationRelatedChildCases {
    public Id CaseIdvalue {Set;get;}
    public List<Case> caseToDisplay;
    public Map<String, List<Case_Service_Code__c>> caseServiceCodesList;
    public  WarrantyAuthorizationRelatedChildCases(ApexPages.StandardController acon)
    {
          CaseIdvalue = ApexPages.currentPage().getParameters().get('id');
    }
    public List<Case> casess{
        get{        
            
            caseToDisplay = new List<Case>();
            system.debug('CaseIdvalue::'+CaseIdvalue);
            List<Case> caseList = [SELECT Id,(SELECT Id,Serial_Number__c,Model__c,Total_Summed_Amount_Approved__c,CaseNumber,Hours_Approved__c,Labor_Amount_Approved__c,Additional_Materials_Amount_Approved__c,X3rd_Party_Parts_Amount_Approved__c,Daikin_Parts_Amount_Approved__c from Cases LIMIT 1000) FROM Case WHERE Case.Id=:CaseIdvalue LIMIT 1000];
            for(Case cc:caseList){
                {
                    for(Case cs : cc.Cases)
                    {
                        system.debug('cs--'+cs);
                        if(cs.Hours_Approved__c != null && cs.Hours_Approved__c>0)
                            cs.Hours_Approved__c = cs.Hours_Approved__c.setScale(2);
                        system.debug('cs--'+cs);
                        caseToDisplay.add(cs);
                        System.debug('Child Cases Ids::::::::'+cs.id);
                    }
                }
              
            }
          
            return caseToDisplay;
        }
        set;
    }
    
    public Map<String, List<Case_Service_Code__c>> getservicecodes{
        get{
            caseServiceCodesList = new Map<String, List<Case_Service_Code__c>>();
            System.debug(caseToDisplay);
            List<Case> caseList = [select (SELECT Id,Name, Case__c,WarrantyClassCode__r.Name,Asset_PCL__c,WarrantyClassCode__r.Label__c,Hours_Approved__c,
                                           Labor_Amount_Approved__c,Additional_Materials_Amount_Approved__c,X3rd_Party_Parts_Amount_Approved__c,ModeCode__r.Name,ModeCode__r.Label__c,
                                           Case__r.Business_Unit__c,TypeCode__r.Name,TypeCode__r.Label__c,MajorCode__r.Name,MajorCode__r.Label__c,SpecificCode__r.Name,SpecificCode__r.Label__c,
                                           Daikin_Parts_Amount_Approved__c,Total_Amount_Approved__c,Responsibility__c,Responsibility__r.Name FROM Case_Service_Codes__r ) from Case WHERE ID IN:  caseToDisplay LIMIT 1000];
            // List<Case_Service_Code__c> csccodes = [SELECT Id, Name, Case__c,WarrantyClassCode__r.Name,Asset_PCL__c,WarrantyClassCode__r.Label__c FROM Case_Service_Code__c where caseToDisplay];
            //System.debug(csccodes);
            
            for(Case ccsc : caseList)
            {
                caseServiceCodesList.put(ccsc.id, new List<Case_Service_Code__c>());
                
                for(Case_Service_Code__c cscode : ccsc.Case_Service_Codes__r)
                {
                    caseServiceCodesList.get(ccsc.id).add(cscode); 
                    
                    
                }
            }
            system.debug('Map ::'+caseServiceCodesList.keySet());
            return caseServiceCodesList;
        } 
        
        set;
    }
}