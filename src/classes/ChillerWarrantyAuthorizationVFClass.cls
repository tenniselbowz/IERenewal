global class ChillerWarrantyAuthorizationVFClass {
    global String CaseIdvalue {set;get;}
    // global List<Case> cases{set;get;}
    global List<String> SerialNumber {set;get;}
    global string isTenKwarrantyNotification {set;get;}
    global List<String> CaseNumber  {set;get;}
    global Set<Id> csid;
    global List<Case> caseToDisplay;
    global List<Case> childcaseToDisplay;
    global Map<String, List<Case_Service_Code__c>> caseServiceCodesList;
    global Case caseValues{
        get { 
            caseValues = [Select Id from Case where id =: CaseIdvalue];
            return caseValues; }
        set;
    }
    
    global  ChillerWarrantyAuthorizationVFClass(){
        
        
    }
    
    global List<Case> casess{
        get{        
            caseToDisplay = new List<Case>();
            csid = new set<id>();
            SerialNumber  = new List<String>();
            CaseNumber    = new List<String>();
            List<Case> caseList = [SELECT Id,(SELECT Id,Serial_Number__c,CaseNumber,Hours_Approved__c,recordtypeid,Labor_Amount_Approved__c,Additional_Materials_Amount_Approved__c,X3rd_Party_Parts_Amount_Approved__c,asset.Product2.DW_Product_Class__c,asset.Product2.ProductCode,Daikin_Parts_Amount_Approved__c from Cases ) FROM Case WHERE Case.Id=:CaseIdvalue];
            for(Case cc:caseList){{
                for(Case cs : cc.Cases){               
                    caseToDisplay.add(cs);
                    csid.add(cs.id);                        
                }
            }                      
                                 }
            return caseToDisplay;
        }
        set;
    }
    
    global List<Case> warrantyChildcasess{ //Applied on warranty10Knotification email alert -- VF component-warranty_Clain_Approved_User
        get{        
            caseToDisplay = new List<Case>();
            childcaseToDisplay=  new List<Case>();
            csid = new set<id>();
            SerialNumber  = new List<String>();
            CaseNumber    = new List<String>();
            Id childRecordID=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Warranty').getRecordTypeId();     
            List<Case> caseList = [SELECT Id,(SELECT Id,Serial_Number__c,CaseNumber,Hours_Approved__c,recordtypeid,Labor_Amount_Approved__c,Additional_Materials_Amount_Approved__c,X3rd_Party_Parts_Amount_Approved__c,asset.Product2.DW_Product_Class__c,asset.Product2.ProductCode,Daikin_Parts_Amount_Approved__c from Cases where recordtypeid=:childRecordID and assetid != null) FROM Case WHERE Case.Id=:CaseIdvalue];
            for(Case cc:caseList){
                for(Case cs : cc.Cases){
                    caseToDisplay.add(cs);
                    csid.add(cs.id);
                }
            }
            return caseToDisplay;     
        }set;
    }
    
    global Map<String, List<Case_Service_Code__c>> getservicecodes{
        get{
            caseServiceCodesList = new Map<String, List<Case_Service_Code__c>>();
            
            List<Case> caseList = [select (SELECT Id,Name, Case__c,WarrantyClassCode__r.Name,Asset_PCL__c,WarrantyClassCode__r.Label__c,Hours_Approved__c,
                                           Labor_Amount_Approved__c,Additional_Materials_Amount_Approved__c,X3rd_Party_Parts_Amount_Approved__c,ModeCode__r.Name,ModeCode__r.Label__c,
                                           Case__r.Business_Unit__c,TypeCode__r.Name,TypeCode__r.Label__c,MajorCode__r.Name,MajorCode__r.Label__c,SpecificCode__r.Name,SpecificCode__r.Label__c,
                                           Daikin_Parts_Amount_Approved__c,Total_Amount_Approved__c,Responsibility__r.name FROM Case_Service_Codes__r ) from Case WHERE ID IN:  caseToDisplay];
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