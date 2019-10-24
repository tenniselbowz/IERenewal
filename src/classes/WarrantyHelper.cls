global class WarrantyHelper implements Database.Batchable<sObject>  {

    private Boolean evenly = false;
    private Case_Service_Code__c csc;
    
    public WarrantyHelper(Case_Service_Code__c csc, Boolean evenly){
        this.csc = csc;
        this.evenly = evenly;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([select Id from Case where ParentId=:csc.Case__r.ParentId and Id!=:csc.Case__c]);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Case> tcs = (List<Case>)scope;

        List<Case_Service_Code__c> cscs = new List<Case_Service_Code__c>();
        for(Case cs :tcs){
            Case_Service_Code__c c = csc.clone();
            c.Case__c = cs.Id;
            c.X3rd_Party_Parts_Amount_Approved__c=csc.X3rd_Party_Parts_Amount_Approved__c;
            c.Additional_Materials_Amount_Approved__c=csc.Additional_Materials_Amount_Approved__c;
            c.Daikin_Parts_Amount_Approved__c=csc.Daikin_Parts_Amount_Approved__c;
            c.Hours_Approved__c=csc.Hours_Approved__c;
            c.Labor_Amount_Approved__c=csc.Labor_Amount_Approved__c;
            
            c.X3rd_Party_Parts_Amount_Requested__c=csc.X3rd_Party_Parts_Amount_Requested__c;
            c.Additional_Materials_Amount_Requested__c=csc.Additional_Materials_Amount_Requested__c;
            c.Daikin_Parts_Amount_Requested__c=csc.Daikin_Parts_Amount_Requested__c;
            c.Hours_Requested__c=csc.Hours_Requested__c;
            c.Labor_Amount_Requested__c=csc.Labor_Amount_Requested__c;

            cscs.add(c);
        }
        insert cscs;
    }
    
    global void finish(Database.BatchableContext BC){
    }
    
    private static Decimal divideValue(Decimal val, Integer count){
        if(val == null)
            val = 0;
        if(val>0 && count>0){
            val /= count;
        }

        return val;
    }
    webservice static Integer associateCaseServiceCodes(String cscId, Boolean evenly){
        Case_Service_Code__c csc = [Select Id, Case__c, Case__r.ParentId
                                    ,X3rd_Party_Parts_Amount_Approved__c, Additional_Materials_Amount_Approved__c, Daikin_Parts_Amount_Approved__c, Hours_Approved__c, Labor_Amount_Approved__c
                                    ,X3rd_Party_Parts_Amount_Requested__c, Additional_Materials_Amount_Requested__c, Daikin_Parts_Amount_Requested__c, Hours_Requested__c, Labor_Amount_Requested__c
                                    , Description__c, MajorCode__c, ModeCode__c, SpecificCode__c, TypeCode__c, UnitCode__c, WarrantyClassCode__c, Responsibility__c 
                                    from Case_Service_Code__c where Id=:cscId];
        
        Integer origcount = Database.countQuery('select count() from Case where ParentId=\''+csc.Case__r.ParentId+'\' and Id!=\''+csc.Case__c+'\'');
        if(origcount>0){
            Integer count = origcount;
            if(evenly)
                count++;
            else
                count = 0;
            csc.X3rd_Party_Parts_Amount_Approved__c=divideValue(csc.X3rd_Party_Parts_Amount_Approved__c, count);
            csc.Additional_Materials_Amount_Approved__c=divideValue(csc.Additional_Materials_Amount_Approved__c, count);
            csc.Daikin_Parts_Amount_Approved__c=divideValue(csc.Daikin_Parts_Amount_Approved__c, count);
            csc.Hours_Approved__c=divideValue(csc.Hours_Approved__c, count);
            csc.Labor_Amount_Approved__c=divideValue(csc.Labor_Amount_Approved__c, count);
            
            csc.X3rd_Party_Parts_Amount_Requested__c=divideValue(csc.X3rd_Party_Parts_Amount_Requested__c, count);
            csc.Additional_Materials_Amount_Requested__c=divideValue(csc.Additional_Materials_Amount_Requested__c, count);
            csc.Daikin_Parts_Amount_Requested__c=divideValue(csc.Daikin_Parts_Amount_Requested__c, count);
            csc.Hours_Requested__c=divideValue(csc.Hours_Requested__c, count);
            csc.Labor_Amount_Requested__c=divideValue(csc.Labor_Amount_Requested__c, count);
                            
            update csc;
            Database.executeBatch(new WarrantyHelper(csc, evenly));
        }
        return origcount;        
    }

    webservice static Integer associateOrderAssets(String caseId){
        List<Case> cases = new List<Case>();
        
        List<Case> pcases = [Select Id, Order__r.Id, RecordTypeId, AccountId, ContactId, Origin, Priority, Date_of_Failure__c, Date_Received__c, Subject, Case_Category__c, Type, Status, Reason_For_Authorization_Request__c, Pay_To__c/*, Business_Unit_Multi__c*/ from Case where /*Case_Category__c='WAR' and*/ ParentId = null and Order__r.Id != null and Id=:caseId];
        if(pcases!=null && pcases.size()==1){
            Case pcase = pcases[0];
            if(pcase != null){
                List<Id> ids = new List<Id>();
                List<Case> tcs = [select AssetId from Case where AssetId != null and ParentId=:pcase.Id];
                if(tcs != null && tcs.size()>0){
                    for(Case cs :tcs){
                        ids.add(cs.AssetId);
                    }
                }
                //if(pcase.Business_Unit_Multi__c != null){
                    //String[] BUs = pcase.Business_Unit_Multi__c.split(';');
                    //if(BUs != null){
                        List<Asset> assets = [select Id, Order__r.Id from Asset where Order__r.Id=:pcase.Order__r.Id /*and (Product2.DW_Product_Business_Unit__c != null and Product2.DW_Product_Business_Unit__c in :BUs)*/ and Id not in :ids];
                        if(assets!=null && assets.size()>0){
                            for(Asset a :assets){
                                Case c = pcase.clone();
                                c.ParentId = pcase.Id;
                                c.AssetId = a.Id;
                                c.Status = pcase.Status;//'New';
                                c.Case_Category__c = 'Claim';
                                c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Warranty').getRecordTypeId();//'0122F0000008acg';
                                cases.add(c);
                            }
                        }
                    //}    
                //}
            }
        }        
        Integer count = cases.size();
        if(count>0)
            insert cases;
        return count;
    }
    
}