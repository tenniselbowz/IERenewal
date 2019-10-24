global without sharing class CaseTriggerHandler implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([select Id, RecordTypeId, AssetId, Business_Unit__c, Business_Unit_Picklist__c, Approval_Status__c, Warranty_Approved_Ttl__c from Case where Id in :newMap.keySet()]);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Case> tcs = (List<Case>)scope;
        processAfterUpdate(tcs, newMap, oldMap);
    }
    
    global void finish(Database.BatchableContext BC){
    }
    
    private map<Id,Case> newMap;
    private map<Id,Case> oldMap;
    
    public CaseTriggerHandler(map<Id,Case> newMap, map<Id,Case> oldMap){
        this.newMap = newMap;
        this.oldMap = oldMap;
    }
    
    public static void onAfterUpdate(map<Id,Case> newMap, map<Id,Case> oldMap)
    {
        if(newMap.size()>50)
            Database.executeBatch(new CaseTriggerHandler(newMap, oldMap));
        else {
            List<Case> tcs = [select Id, RecordTypeId, AssetId, Business_Unit__c, Business_Unit_Picklist__c, Approval_Status__c, Warranty_Approved_Ttl__c from Case where Id in :newMap.keySet()];
            processAfterUpdate(tcs, newMap, oldMap);
        }
    }
    
    private static void processAfterUpdate(List<Case> tcs, map<Id,Case> newMap, map<Id,Case> oldMap){
        CaseTriggerHandler.updateCaseServiceCodes(tcs);
        
        Map<id,case> newcaseMap=new Map<id,case>();
        Id parentRecordID=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Warranty_Claim_Authorization').getRecordTypeId();     
        Decimal warrantyApprTtl = Decimal.valueOf(Label.Case_Min_Warranty_Approved_ttl);
        for(Case cs:tcs){
            if(cs.recordtypeid ==parentRecordID && cs.Business_Unit__c != null && cs.Approval_Status__c=='Warranty Approved' && cs.Warranty_Approved_Ttl__c >= warrantyApprTtl && CaseTriggerHandler.runonce && oldMap.get(cs.ID).Approval_Status__c != cs.Approval_Status__c){newcaseMap.put(cs.id, cs);
                                                                                                                                                                                                                                                                              }
        }
        //Check for 10K warranty Notification criteria
        if (newcaseMap.size()>0){casetriggerhandler.sendEmailNotification(newcaseMap, oldMap);
                                }     
    }
    
    
    public static boolean runonce=true; // To restrict recursion of trigger
    public static id caseId;
    public static id checkrepeatId;
    public static string CLOSE_WITHOUT_FAILURE_MESSAGE = 'When closing a case with assets, you must add a Failure Cause to each associated Case Asset record.';
    
    public static void onBeforeUpdate(map<Id,Case> newMap, map<Id,Case> oldMap)
    {
        Id parentRecordID=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Warranty_Claim_Authorization').getRecordTypeId();     
        Id childRecordID=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Warranty').getRecordTypeId();     
        
        List<Case> cases = new List<Case>();
        Map<Id, Case> cases2 = new Map<Id, Case>();
        for(Case c : newMap.values()){
            if(c.RecordTypeId==parentRecordID || c.RecordTypeId==childRecordID){
                if(c.Approval_Status__c == 'Warranty Rejected' && oldMap.get(c.id).Approval_Status__c != c.Approval_Status__c){
                    if(TriggerAccessUtility.tau.get('Case').getIteration()<=1){
                        TriggerAccessUtility.tau.get('Case').reset(); 
                        break;
                    } else
                        cases2.put(c.Id, c);
                }
            } else if(c.Status == 'Closed'){cases.add(c);
                                           }
        }
        if(cases.size()>0){validateCaseAsset(cases);            
                          }else if(cases2.size()>0){updateCaseStatus(cases2, oldMap);
                                                   }
        
        if(TriggerUtility.tau.get('CaseServiceCode').isaccessible()){
            TriggerUtility.tau.get('CaseServiceCode').increment();
            updateWarrantyTotals(newMap.values());
        }
    }
    
    public static void updateWarrantyTotals(list<Case> cases)
    {    
        Set<String> CaseCurrencyIso= new set<string>();
        Map<id,case> caseMapBeforeUpdate=new Map<id,case>();
        Map<String,Decimal> conRatewithIso= new Map<string,Decimal>();
        // public static id caseID;
        //Reset to 0 in case there are no case service codes
        List<Id> cscMap = new List<Id>();
        for(Case_Service_Code__c csc : [select Id, Case__r.Id, Case__r.ParentId,Case__r.Parent.CurrencyIsoCode from Case_Service_Code__c where (Case__r.ParentId in :cases or Case__c in :cases) and WarrantyClassCode__c = null]){
            cscMap.add(csc.Case__r.Id);
            cscMap.add(csc.Case__r.ParentId);
        }
        
        for(Case cse:cases){
            cse.X3rd_Party_Parts_Amount_Approved__c=null;
            cse.X3rd_Party_Parts_Amount_Requested__c=null;
            cse.Additional_Materials_Amount_Approved__c=null;
            cse.Additional_Materials_Amount_Requested__c=null;
            cse.Daikin_Parts_Amount_Approved__c=null;
            cse.Daikin_Parts_Amount_Requested__c=null;
            cse.Labor_Amount_Approved__c=null;
            cse.Labor_Amount_Requested__c=null;
            cse.Hours_Approved__c=null;
            cse.Hours_Requested__c=null;
            cse.Warranty_Approved_Ttl__c=null;
            cse.Warranty_Requested_Ttl__c=null;
            cse.Concessions_Approved_Ttl__c=null;
            cse.Concessions_Requested_Ttl__c=null;
            cse.HasBlankClasses__c=cscMap.contains(cse.Id) || cscMap.contains(cse.ParentId);

        }     
        
        //update the cases with the sums of the codes and grap the parent cases to update
        Set<Id> pcases = new Set<Id>();
        Map<Id, Case> caseIds = new Map<Id, Case>(cases);
        //**********************************************************************************************************
        List<Schema.FieldSetMember> ListOfFields = Schema.SObjectType.Case_Service_Code__c.fieldSets.In_Line_Edit.getFields();
        System.debug('Field Set of Case'+ListOfFields);
        
        String childqueryforWarrantyClassType;
        String parentqueryforWarrantyClassType;
        String queryParent;
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : ListOfFields) {
            query += f.getFieldPath() + ', ';
        }
        queryParent = query + 'id,Case__r.parentid,WarrantyClassCode__r.Warranty_Class_Type__c FROM Case_Service_Code__c where Case__r.ParentId in :cases order by Case__r.parentid';
        query += 'Id,Case__c,Case__r.parentid,WarrantyClassCode__r.Warranty_Class_Type__c FROM Case_Service_Code__c where Case__c in :cases order by Case__c';
        
        List<Case_Service_Code__c> servicecodes=Database.query(query);
        List<Case_Service_Code__c> serviceCodeMasterCase=Database.query(queryParent);
        
        for(Case_Service_Code__c sc:servicecodes) //Sumup totals to child Case
        { 
            caseID = sc.Case__c; 
            case c=caseIds.get(sc.Case__c);
            if(caseID != checkrepeatId){
                rollupFirstServiceCodeToCase(c, sc);
                rolupwarrantyORConcessionTtl(c,sc);
            }
            
            //Check if the second serviceCode entered in loop belongs to same childcase
            else if(caseID == checkrepeatId){
                rollupRelatedServiceCodesToCase(c, sc);
                rolupwarrantyORConcessionTtl(c,sc);
                }
        }
        
        for(Case_Service_Code__c sc:serviceCodeMasterCase){ //Sumup totals to Parent Case
            caseID = sc.Case__r.parentid; 
            case c=caseIds.get(sc.Case__r.parentid);
            if(caseID != checkrepeatId){
                rollupFirstServiceCodeToCase(c, sc);
                rolupwarrantyORConcessionTtl(c,sc);
            }
            
           //Check if the second serviceCode entered in loop belongs to same ParentCase
            else if(caseID == checkrepeatId){
                rollupRelatedServiceCodesToCase(c, sc);
                rolupwarrantyORConcessionTtl(c,sc);
            }
        }
    }
    
    //Rollup first service code totals to child and Header Cases
    public static void rollupFirstServiceCodeToCase(Case c, Case_Service_Code__c sc){
        c.X3rd_Party_Parts_Amount_Approved__c=sc.X3rd_Party_Parts_Amount_Approved__c;
        c.X3rd_Party_Parts_Amount_Requested__c=sc.X3rd_Party_Parts_Amount_Requested__c;
        c.Additional_Materials_Amount_Approved__c=sc.Additional_Materials_Amount_Approved__c;
        c.Additional_Materials_Amount_Requested__c=sc.Additional_Materials_Amount_Requested__c;
        c.Daikin_Parts_Amount_Approved__c=sc.Daikin_Parts_Amount_Approved__c;
        c.Daikin_Parts_Amount_Requested__c=sc.Daikin_Parts_Amount_Requested__c;
        c.Labor_Amount_Approved__c=sc.Labor_Amount_Approved__c;
        c.Labor_Amount_Requested__c=sc.Labor_Amount_Requested__c;
        c.Hours_Approved__c=sc.Hours_Approved__c;
        c.Hours_Requested__c=sc.Hours_Requested__c;
        checkrepeatId = c.id; 
    }
    
    //Rollup second and more service code totals related to child and Header Cases
    public static void rollupRelatedServiceCodesToCase(Case c, Case_Service_Code__c sc){
        //3rd Party amount approved 
        if(c.X3rd_Party_Parts_Amount_Approved__c != null && sc.X3rd_Party_Parts_Amount_Approved__c != null)
            c.X3rd_Party_Parts_Amount_Approved__c=sc.X3rd_Party_Parts_Amount_Approved__c+c.X3rd_Party_Parts_Amount_Approved__c;
        else if (c.X3rd_Party_Parts_Amount_Approved__c == null && sc.X3rd_Party_Parts_Amount_Approved__c != null)
            c.X3rd_Party_Parts_Amount_Approved__c=sc.X3rd_Party_Parts_Amount_Approved__c;
        
        //3rd Party amount requested
        if(c.X3rd_Party_Parts_Amount_Requested__c != null && sc.X3rd_Party_Parts_Amount_Requested__c != null)
            c.X3rd_Party_Parts_Amount_Requested__c=sc.X3rd_Party_Parts_Amount_Requested__c+c.X3rd_Party_Parts_Amount_Requested__c;
        else if (c.X3rd_Party_Parts_Amount_Requested__c == null && sc.X3rd_Party_Parts_Amount_Requested__c != null)
            c.X3rd_Party_Parts_Amount_Requested__c=sc.X3rd_Party_Parts_Amount_Requested__c;
        
        //Additional materials amount approved
        if(c.Additional_Materials_Amount_Approved__c != null && sc.Additional_Materials_Amount_Approved__c != null)
            c.Additional_Materials_Amount_Approved__c=sc.Additional_Materials_Amount_Approved__c+c.Additional_Materials_Amount_Approved__c;
        else if (c.Additional_Materials_Amount_Approved__c == null && sc.Additional_Materials_Amount_Approved__c != null)
            c.Additional_Materials_Amount_Approved__c=sc.Additional_Materials_Amount_Approved__c;
        
        //Additional materials amount requested
        if(c.Additional_Materials_Amount_Requested__c != null && sc.Additional_Materials_Amount_Requested__c != null)
            c.Additional_Materials_Amount_Requested__c=sc.Additional_Materials_Amount_Requested__c+c.Additional_Materials_Amount_Requested__c;
        else if (c.Additional_Materials_Amount_Requested__c == null && sc.Additional_Materials_Amount_Requested__c != null)
            c.Additional_Materials_Amount_Requested__c=sc.Additional_Materials_Amount_Requested__c;
        
        //Dainkin Parts Amount approved        
        if(c.Daikin_Parts_Amount_Approved__c != null && sc.Daikin_Parts_Amount_Approved__c != null)
            c.Daikin_Parts_Amount_Approved__c=sc.Daikin_Parts_Amount_Approved__c+c.Daikin_Parts_Amount_Approved__c;
        else if (c.Daikin_Parts_Amount_Approved__c == null && sc.Daikin_Parts_Amount_Approved__c != null)
            c.Daikin_Parts_Amount_Approved__c=sc.Daikin_Parts_Amount_Approved__c;
        
        //Daikin parts amount requested
        if(c.Daikin_Parts_Amount_Requested__c != null && sc.Daikin_Parts_Amount_Requested__c != null)
            c.Daikin_Parts_Amount_Requested__c=sc.Daikin_Parts_Amount_Requested__c+c.Daikin_Parts_Amount_Requested__c;
        else if (c.Daikin_Parts_Amount_Requested__c == null && sc.Daikin_Parts_Amount_Requested__c != null)
            c.Daikin_Parts_Amount_Requested__c=sc.Daikin_Parts_Amount_Requested__c;
        
        //Labor Amount approved
        if(c.Labor_Amount_Approved__c != null && sc.Labor_Amount_Approved__c != null)
            c.Labor_Amount_Approved__c=sc.Labor_Amount_Approved__c+c.Labor_Amount_Approved__c;
        else if (c.Labor_Amount_Approved__c == null && sc.Labor_Amount_Approved__c != null)
            c.Labor_Amount_Approved__c=sc.Labor_Amount_Approved__c;
        
        //Labor amount requested
        if(c.Labor_Amount_Requested__c != null && sc.Labor_Amount_Requested__c != null)
            c.Labor_Amount_Requested__c=sc.Labor_Amount_Requested__c+c.Labor_Amount_Requested__c;
        else if (c.Labor_Amount_Requested__c == null && sc.Labor_Amount_Requested__c != null)
            c.Labor_Amount_Requested__c=sc.Labor_Amount_Requested__c;
        
        //Hours Approved
        if(c.Hours_Approved__c != null && sc.Hours_Approved__c != null)
            c.Hours_Approved__c=sc.Hours_Approved__c+c.Hours_Approved__c;
        else if (c.Hours_Approved__c == null && sc.Hours_Approved__c != null)
            c.Hours_Approved__c=sc.Hours_Approved__c;
        
        //Hours requested
        if(c.Hours_Requested__c != null && sc.Hours_Requested__c != null)
            c.Hours_Requested__c=sc.Hours_Requested__c+c.Hours_Requested__c;
        else if (c.Hours_Requested__c == null && sc.Hours_Requested__c != null)
            c.Hours_Requested__c=sc.Hours_Requested__c;
            }
    
    //Rollup Warranty AND Consession totals to child and Header Cases
    public static void rolupwarrantyORConcessionTtl(Case c, Case_Service_Code__c sc){
        Decimal existingApprovedTtl;
        Decimal existingRequetdTtl;
        if(sc.WarrantyClassCode__r.Warranty_Class_Type__c == 'Sales Concession'){
            existingApprovedTtl=(c.Concessions_Approved_Ttl__c ==null?0:c.Concessions_Approved_Ttl__c);
            existingRequetdTtl= (c.Concessions_Requested_Ttl__c ==null?0:c.Concessions_Requested_Ttl__c);
        }
        else{
            existingApprovedTtl=(c.Warranty_Approved_Ttl__c ==null?0:c.Warranty_Approved_Ttl__c);
            existingRequetdTtl= (c.Warranty_Requested_Ttl__c ==null?0:c.Warranty_Requested_Ttl__c);
        }

        Decimal approvedTotal=(sc.X3rd_Party_Parts_Amount_Approved__c == null?0:sc.X3rd_Party_Parts_Amount_Approved__c)+
                              (sc.Additional_Materials_Amount_Approved__c == null?0:sc.Additional_Materials_Amount_Approved__c)+
                              (sc.Daikin_Parts_Amount_Approved__c == null?0:sc.Daikin_Parts_Amount_Approved__c)+
                              (sc.Labor_Amount_Approved__c == null?0:sc.Labor_Amount_Approved__c)+
                              existingApprovedTtl;
        Decimal requestedTotal=(sc.X3rd_Party_Parts_Amount_Requested__c == null?0:sc.X3rd_Party_Parts_Amount_Requested__c)+
                               (sc.Additional_Materials_Amount_Requested__c==null?0:sc.Additional_Materials_Amount_Requested__c)+
                               (sc.Daikin_Parts_Amount_Requested__c == null?0:sc.Daikin_Parts_Amount_Requested__c)+
                               (sc.Labor_Amount_Requested__c == null?0:sc.Labor_Amount_Requested__c)+
                               existingRequetdTtl;
        if(sc.WarrantyClassCode__r.Warranty_Class_Type__c == 'Sales Concession'){
            c.Concessions_Approved_Ttl__c=approvedTotal;
            c.Concessions_Requested_Ttl__c=requestedTotal;
        }
        else{
            c.Warranty_Approved_Ttl__c=approvedTotal;
            c.Warranty_Requested_Ttl__c=requestedTotal;
        }
    }
    
    public static void validateCaseAsset(list<Case> cases)
    {
        /* if closing
query assets for failure cause
if there are any case assets with no failure Cause then throw an error
if no assets exist then move on.
*/
        set<Id> caseIds = new set<Id>();
        for(Case c : cases)
        {
            if(c.RecordType.Name!='Warranty' && c.Status == 'Closed')
                caseIds.add(c.Id);
        }
        if(caseIds.size()>0){
            map<Id, Integer> errorMap = new map<Id, integer>();
            
            for(AggregateResult ar : [Select Case__c, count(Id) cnt
                                      from Case_Asset__c 
                                      where Case__c in :caseIds
                                      and Failure_Cause__c = null and Case__r.RecordType.Name!='Warranty'
                                      group by Case__c
                                     ])
            {
                errorMap.put((String)ar.get('Case__c'), (Integer)ar.get('cnt'));
            }
            
            
            for(Case c : cases)
            {
                if(errorMap.containsKey(c.Id))
                    c.addError(CLOSE_WITHOUT_FAILURE_MESSAGE);
            }            
        }        
    }
    
    
    
    /***
*Created by: Solunus
*Created Date: 10/19/2018
*Last Updated Date: 10/29/2018
*Description : update Reject_Comments__c with comments when submit for approval status is rejected
***/
    public static void updateCaseStatus(map<Id,Case> newMap, map<Id,Case> oldMap){
        System.debug('Called');
        Map<String, String> caseProcessMap  = new Map<String, String>();
        
        Map<String, ProcessInstanceStep> approvalHistory  = new Map<String, ProcessInstanceStep>();
        
        List<ProcessInstanceStep> processSteps = [SELECT  Id,ProcessInstanceId,ProcessInstance.TargetObjectId, Comments, Systemmodstamp FROM ProcessInstanceStep where stepStatus ='Rejected'
                                                  AND Comments != null
                                                  AND ProcessInstance.TargetObjectId IN : newMap.keySet() order by CreatedDate ASC];
        
        system.debug('processSteps::'+processSteps);
        for(ProcessInstanceStep app : processSteps)
        {
            approvalHistory.put(app.ProcessInstanceId+'-'+app.ProcessInstance.TargetObjectId, app);    
        }
        
        for(Case c :newMap.values()){
            //if(c.Approval_Status__c == 'Warranty Rejected' && oldMap.get(c.id).Approval_Status__c != c.Approval_Status__c){
            /*if(c.Reason_for_Denial__c !=null && c.Reason_for_Denial__c != '')
c.Reason_for_Denial__c += ' | ';
else if(c.Reason_for_Denial__c == null)*/
            c.Reject_Comments__c = '';
            for(ProcessInstanceStep pi :processSteps){
                if(approvalHistory.containsKey(pi.ProcessInstanceId+'-'+c.id)){
                    //c.Reason_for_Denial__c += approvalHistory.get(pi.ProcessInstanceId+'-'+c.id).comments+' ';    
                    c.Reject_Comments__c += '"'+approvalHistory.get(pi.ProcessInstanceId+'-'+c.id).Systemmodstamp.format('MM/dd/YYYY') +' - '+approvalHistory.get(pi.ProcessInstanceId+'-'+c.id).Comments+'"'+' |';
                }  
                System.debug('c.Reject_Comments__c'+c.Reject_Comments__c);
            }
            c.Reject_Comments__c = c.Reject_Comments__c.removeEnd(' |');
            //}    
        }
    }
    
    public static void updateCaseServiceCodes(List<Case> caseList)
    {
        List<Case> cases = [select id,CurrencyIsoCode,(Select id,CurrencyIsoCode from Case_Service_Codes__r) from Case where Id IN :caseList AND Recordtype.DeveloperName='Warranty'];
        List<Case_Service_Code__c> updatecsCodes = new List<Case_Service_Code__c>();
        for(Case c : cases)
        {
            for(Case_Service_Code__c csCode : c.Case_Service_Codes__r)
            {
                if(csCode.CurrencyIsoCode != c.CurrencyIsoCode)
                {
                    csCode.CurrencyIsoCode = c.CurrencyIsoCode;
                    updatecsCodes.add(csCode);
                }
            }
        }
        
        if(updatecsCodes.size()>0)
        {
            update updatecsCodes;
        }
    }
    
    /***
*Created by: Solunus
*Created Date: 03/26/2019
*Last Updated Date: 04/03/2019
*Description : send 10k warranty email notification to users 
***/
    public static void sendEmailNotification(map<Id,Case> newMap, map<Id,Case> oldMap){
        CaseTriggerHandler.runonce=false; //To stop recursion - restricting to enter logic more than once in single transaction
        Id parentRecordID=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Warranty_Claim_Authorization').getRecordTypeId();     
        Id childRecordID=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Warranty').getRecordTypeId();     
        Decimal warrantyApprovedTtl = Decimal.valueOf(Label.Case_Min_Warranty_Approved_ttl);
        String vfTemplateName = Label.X10K_Warranty_Email_Template;
        
        set<id> parentCaseids=new set<id>();
        List<string> parentBusUnits=new List<string>();
        List<string> productClas=new List<string>();
        Map<id,case> parentCaseMap=new MAp<id,case>();
        Map<id,String> caseIdwithUsers= new Map<id,String>();
        Map<id,set<string>> casewithUserEmails= new Map<id,set<string>>();
        Map<String,PCL_Notification__c> pclMap=new Map<string,PCL_Notification__c>();
        List<String> usersToNotify= new List<String>();
        
        for(case cs:newMap.values()){ //Get parentcase ids to query child related fields
            parentCaseids.add(cs.id);
            parentBusUnits.add(cs.Business_Unit_Picklist__c);
        }
        Map<String,Case> childCaseMap=new Map<String,Case>();
        //Query Parent Cases and related childcases
        for(case pcCase:[select id,casenumber,Business_Unit_Picklist__c,(select id,parentid,parent.Business_Unit_Picklist__c,casenumber,asset.Product2.DW_Product_Class__c,assetid from cases where recordtypeid=:childRecordID) from case where id =:parentCaseids]){
            for(case cc:pcCase.cases)
            {
                childCaseMap.put(cc.asset.Product2.DW_Product_Class__c+cc.parent.Business_Unit_Picklist__c, cc); //Build child case and parent case values as key
                productClas.add(cc.asset.Product2.DW_Product_Class__c);
            }  
            parentCaseMap.put(pcCase.id,pcCase);
        }
        
        //Query PCL Notifications matching Business uint of Parent record and child-Asset-Product-DW product class
        for(PCL_Notification__c pcl:[select id,Name,Business_unit__c,Users_to_Notify__c 
                                     from PCL_Notification__c where Name IN :productClas 
                                     and Business_unit__c IN :parentBusUnits ]){
                                         pclMap.put(pcl.Name+pcl.Business_unit__c, pcl);}
        
        if(pclMap.size()>0){
            system.debug('PCL MAP '+pclMap);
            String pclUsers='';
            
            //Get the matching PCL records and add CaseParentID and emails from PCL notification to casewithUserEmails(MAP)
            for(case cldcas:childCaseMap.values()){
                string key=cldcas.asset.Product2.DW_Product_Class__c+cldcas.parent.Business_Unit_Picklist__c; //Build the parameters as key and get the matching PCL record
                if(pclMap.containskey(key) && pclMap.get(key).Users_to_Notify__c != null){// 
                    PCL_Notification__c pl=pclMap.get(key);
                    pclUsers=pclUsers+pl.Users_to_Notify__c+',';  //Contains  
                    caseIdwithUsers.put(cldcas.parentid, pl.Users_to_Notify__c);
                    LIst<string> userEmails=new list<string>();
                    userEmails=pl.Users_to_Notify__c.split(',');               
                    for(string s:userEmails){
                        if(casewithUserEmails.containskey(cldcas.parentid)){
                            casewithUserEmails.get(cldcas.parentid).add(s);    
                        }
                        else{
                            casewithUserEmails.put(cldcas.parentid, new set<String>{s});
                        }
                    }           
                }   
            }
            List<string> userToNotify=pclUsers.split(',');
            system.debug('userToNotify '+userToNotify);
            Map<String,id> userWithID=new Map<String,id>();
            for(User usr:[select id,name,email from user where email=:userToNotify]){
                userWithID.put(usr.email, usr.id);
            }
            system.debug('userWithID '+userWithID);
            //Add parentCaseID and users IDs to Map
            Map<id,set<id>> CaseidwithUsrIDs=new Map<id,set<id>>();
            for(case cldcss:childCaseMap.values()){
                if(casewithUserEmails.containskey(cldcss.ParentId)){
                    for(String email:casewithUserEmails.get(cldcss.ParentId)){
                        if(userWithID.containskey(email)){
                            id usrID=userWithID.get(email);
                            if(CaseidwithUsrIDs.containskey(cldcss.parentid)){
                                CaseidwithUsrIDs.get(cldcss.parentid).add(usrID);    
                            }
                            else{
                                CaseidwithUsrIDs.put(cldcss.parentid, new set<id>{usrID});
                            }
                        }
                    }
                }
            }
            //Get the Email template 
            Emailtemplate vftemplate = [select id,subject,body,HtmlValue from Emailtemplate 
                                        where name=:vfTemplateName limit 1];
            system.debug('Template '+vftemplate);
            
            if(vftemplate.id != null){
                Messaging.SingleEmailMessage[] messages = new Messaging.SingleEmailMessage[0];
                for(id pId:parentCaseMap.keyset()){ //Pass parentCaseIDs and assign emails to Uses IDs
                    if(CaseidwithUsrIDs.containsKey(pId)){
                        for(id usrId:CaseidwithUsrIDs.get(pId)){
                            Messaging.SingleEmailMessage m = new Messaging.SingleEmailMessage();
                            m.setTemplateId(vftemplate.id);
                            m.setTargetObjectId(usrId); 
                            m.setWhatId(pId);
                            m.setSaveAsActivity(false);
                            messages.add(m);
                        }                   
                    }
                }
                system.debug('messages.size() '+messages.size());
                if(messages.size()>0){ //Check if the list has values
                    try{
                        Messaging.SendEmailResult [] trs = Messaging.sendEmail(messages,false); 
                        for(Messaging.SendEmailResult res:trs){
                            if(!res.IsSuccess()){
                                system.debug('Error encountered '+res.errors);
                                // SendEmailError[] errArr = res.getErrors(); 
                            }}
                        
                        //Create Tasks on parent case - stating an email notification is sent to respective users
                        List<task> tskToInsert=new List<task>();
                        for(id pId:parentCaseMap.keyset()){
                            Task tsk=new Task();
                            tsk.Description='10K Warranty notification has been sent to User';
                            tsk.Subject='10K Warranty Notification';
                            tsk.Status='Completed';
                            tsk.Type='Email';
                            tsk.WhatId=pId;
                            tsk.ActivityDate=system.today();
                            tskToInsert.add(tsk);
                            system.debug('In TAsk creation');
                        } 
                        if(tskToInsert.size()>0)
                            insert tskToInsert; // INsert Tasks
                    }
                    catch (exception e){
                        system.debug('Exeption -'+e);
                    }
                }  
            }  
        }        
    }
}