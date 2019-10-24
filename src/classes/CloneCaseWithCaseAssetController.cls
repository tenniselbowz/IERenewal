public class CloneCaseWithCaseAssetController {
   
    private Id caseId;
    public  Case c;
    private ApexPages.StandardController sc;
    public CloneCaseWithCaseAssetController(ApexPages.StandardController stdController) {
        caseId = ApexPages.currentPage().getParameters().get('id');
        c = (case)stdController.getRecord();
        c.status = 'New';
        c.Resolution_Type__c = null;
        c.Resolution_Description__c = null;
        c.Monitoring__c = null;
		c.Original_Inquiry_Date_Time__c = null;
        this.sc = stdController;
    }
    
    public String save(){
        try{
            PageReference pageRef = sc.save();
        }catch(Exception e){
            System.debug('Error: '+e);
        }
        
        String newCaseId = sc.getId();
        
        //create dynamic query and get all the fields of Case Asset Object from Custom setting
        String query = 'Select ';        
        for(CaseAssetFields__c str : CaseAssetFields__c.getAll().values()){  
            query += str.API__c + ', ' ;
        }
        query +=  'Id from Case_Asset__C where Case__c =: caseId';
        
        List<Case_Asset__c> caseAssetList = Database.query(query);
        
        if(!caseAssetList.isEmpty()){
            List<Case_Asset__c> newCaseAssetList = new List<Case_Asset__c>();
            for(Case_Asset__c caseAsset : caseAssetList){
                Case_Asset__c caseAssetObj = new Case_Asset__C();
                caseAssetObj.Case__c = newCaseId;
                for(CaseAssetFields__c str : CaseAssetFields__c.getAll().values()){      
                    caseAssetObj.put(str.API__c,caseAsset.get(str.API__c));          
                }
                newCaseAssetList.add(caseAssetObj);
            }
            
            if(!newCaseAssetList.isEmpty()){
                Database.SaveResult[] result = Database.insert(newCaseAssetList,false);
                for (Database.SaveResult sr : result) {
                    if (sr.isSuccess()) {
                        System.debug('Successfully inserted Case Asset. Case Asset ID: ' + sr.getId());
                    }
                    else {
                        for(Database.Error err : sr.getErrors()) {
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Case Asset fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }           
        }
        return newCaseId;
    }
    
    public PageReference saveCase(){
        String newCaseId = save();
        if(newCaseId!=null){
            Case c = [select id,status from case where id = :newCaseId limit 1];
            c.status = 'New';
            c.Number_of_Tasks__c = 0;
            c.Number_of_Events__c = 0;
            update c;
        }
        PageReference pageRef ;
        if(newCaseId != null){
            pageRef = new PageReference('/'+newCaseId);
        }
        return pageRef;
    }
    
    public PageReference saveAndNewCase(){
        String newCaseId = save();
        PageReference pageRef ;
        if(caseId != null){
            pageRef = new PageReference('/setup/ui/recordtypeselect.jsp?ent=Case&retURL=/500/o&save_new_url=/500/e?retURL=/500/o');
        }
        return pageRef;
    }
    
    public PageReference saveAndClose(){
        String newCaseId = save();
        PageReference pageRef ;
        if(newCaseId != null){
            pageRef = new PageReference('/'+newCaseId+'/s?retURL=/'+newCaseId);
        }
        return pageRef;    
    }
}