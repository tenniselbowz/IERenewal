/************************************
Created by    : Solunus
Created date  :  2/8/2019
Functionality : Custom cloning of Case (Record type : Warranty claim authorization) with making 
                one field(PGM Approver) as blank. 
  
 ****************************************/


public class CustomCloneWarrantyClaimController 
{
    //added an instance varaible for the standard controller
    private ApexPages.StandardController controller {get; set;}
    
    private Case caseObj {get;set;}
    
    public Case caserecord{set;get;}
    
    public Case stdCase {set;get;}
    
    public CustomCloneWarrantyClaimController(ApexPages.StandardController controller)
    {
        //initialize the stanrdard controller
        this.controller = controller;
        // load the current record
        stdCase = (Case)controller.getRecord();
        this.caserecord = getcaseFieldValues();
        caserecord.Status = 'new';
        caserecord.Subject = '';
        caserecord.Date_of_Failure__c = null;
        caserecord.Date_Received__c = null;
        
    }
    
    
    public PageReference saveCase()
    {
        Case newCaseRec = caserecord.clone(true);
        newCaseRec.Status = 'new';
        newCaseRec.OwnerId = userinfo.getUserId();
        newCaseRec.id=null;
        try
        {
            insert newCaseRec;
            System.debug('New Case :::'+newCaseRec);
        }
        Catch(Exception e)
        {
            Apexpages.addMessages(e);
            return null;
        }
        
        PageReference pageref=new PageReference('/' +newCaseRec.Id); 
        return pageref;
    }
    
   /* public PageReference cancel()
    {
        PageReference p = new PageReference('/'+stdCase.Id);
       // p.setRedirect(true);
        return p;
    }*/
    
    public PageReference saveAndNewCase(){
        
       Case newCaseRec = caserecord.clone(true);
        newCaseRec.Status = 'new';
        newCaseRec.OwnerId = userinfo.getUserId();
        newCaseRec.id=null;
        try
        {
            insert newCaseRec;
        }
        catch(Exception e)
        {
            apexPages.addMessages(e);
            return null;
        }
        PageReference pageRef ;
        if(newCaseRec.id != null){
            pageRef = new PageReference('/setup/ui/recordtypeselect.jsp?ent=Case&retURL=/500/o&save_new_url=/500/e?retURL=/500/o');
        }
        return pageRef;
    }
    
    public PageReference saveAndClose()
    {
        
       Case newCaseRec = caserecord.clone(true);
        newCaseRec.Status = 'new';
        newCaseRec.OwnerId = userinfo.getUserId();
        newCaseRec.id=null;
        try
        {
            insert newCaseRec;
        }
        Catch(Exception e)
        {
            apexPages.addMessages(e);
            return null;
        }
        
        PageReference pageRef ;
        if(newCaseRec.id != null){
            pageRef = new PageReference('/'+newCaseRec.id+'/s?retURL=/'+newCaseRec.id);
        }
        return pageRef;    
    }
    
    
    public  List<Schema.FieldSetMember> getFields()
    {
        List<String> fields = new List<String>();
        // field set name : Clone_Field_Mapping_on_WCA
        List<Schema.FieldSetMember> ListOfFields = Schema.SObjectType.Case.fieldSets.Clone_Field_Mapping_on_WCA.getFields();
        System.debug('Field Set of Case'+ListOfFields);
        
        for(Schema.FieldSetMember f : ListOfFields)
        {
            fields.add(f.getFieldPath());
        }
        
        return ListOfFields;
    }
    
    public Case getcaseFieldValues() 
    {
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : this.getFields()) {
            query += f.getFieldPath() + ', ';
        }
        string caseId=stdCase.id;
        query += 'Id FROM Case where id= :caseId';
        return Database.query(query);
    }
}