public class CloneWarningExt {
    public Id recId;
    public String sObjectType;
    public Boolean showQuote {get;set;}
    public Boolean showWarning {get;set;}
    public Apttus_Proposal__Proposal__c cloneQuote {get;set;}
    private CloneSObject cloneObject;
    public String parentSObjectType;
    private SObject recordToClone;
    public final String CLONE_REDIRECT_URL = '/apex/QuoteProposal?Id=';

    public static Map<String, List<Custom_Clone_System_Fields__mdt>> systemFields = GroupBy.strings('Object_Name__c', [SELECT Is_Lookup__c, Field_Api__c, Location__c, Object_Name__c, Type__c, Value__c, Copy_Clone__c FROM Custom_Clone_System_Fields__mdt]);
    public static Map<String, List<Clone_Field_Set_To_Clone__mdt>> cloneFieldSets = GroupBy.strings('Object_Name__c', [SELECT Field_Set_Name__c, Object_Name__c FROM Clone_Field_Set_To_Clone__mdt]);
    public static Map<String, List<Custom_Clone_Child_Object__mdt>> cloneChildObjects = GroupBy.strings('Object_Name__c', [SELECT Required_Fields__c, User_Lookup_Field__c, Copy_User_Field__c, Child_Field_on_Parent__c, Child_Object_Api__c, Parent_Lookup_Field__c, Object_Name__c FROM Custom_Clone_Child_Object__mdt]);
    
    public CloneWarningExt(ApexPages.StandardController stdController) {
        showQuote = false;
        showWarning = true;
        recId = stdController.getId();
        recordToClone = stdController.getRecord();
        sObjectType = stdController.getRecord().getSObjectType().getDescribe().getName(); 
    }
    public PageReference cancel() {
        if(parentSObjectType == 'Opportunity') {
            if(cloneObject.cloneObject.get('Apttus_Proposal__Opportunity__c') != null){
                Opportunity parentOpp = new Opportunity(Id = (Id)cloneObject.cloneObject.get('Apttus_Proposal__Opportunity__c'));
                try {
                    delete parentOpp;
                }
                catch (DmlException dmlE){
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An Error Occured While Deleting Opportunity: ' + dmlE.getMessage()));
                    return null;
                }
            }
            else {
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Clone Opportunity To Delete'));
                return null;
            }
        }
        return new PageReference('/' + recId);
    }
    public void cloneSobject() {
        showQuote = true;
        showWarning = false;
        Boolean isSuccessful = true;
        parentSObjectType = sObjectType;
        if(sObjectType == 'Opportunity') {
            //clone Opportunity and save
            List<Apttus_Proposal__Proposal__c> primaryQuote = [SELECT Id FROM Apttus_Proposal__Proposal__c WHERE Apttus_Proposal__Opportunity__c =: recId AND Apttus_Proposal__Primary__c = true Limit 1];
            if(primaryQuote.isEmpty()) {
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Primary Quote Related to Opportunity'));
                return;
            }
            cloneObject = new CloneSobject(recordToClone, sobjectType, cloneFieldSets.get(sobjectType)[0].Field_Set_Name__c, systemFields.get(sobjectType), cloneChildObjects.get(sObjectType));
            cloneObject.runFullClone();
            isSuccessful = cloneObject.saveCloneObject();
            if(!isSuccessful)return;
            isSuccessful = cloneObject.cloneAndSaveChildObjects();
            if(!isSuccessful)return;

            Id oppId = cloneObject.cloneObject.Id;
            recId = primaryQuote[0].Id;
            sObjectType = primaryQuote.getSObjectType().getDescribe().getName();
            //call create here
            Apttus_Proposal__Proposal__c newProp = new Apttus_Proposal__Proposal__c();
            newProp = Apttus_QPConfig.QPConfigWebService.cloneProposal(recId);
            cloneObject = new CloneSobject(primaryQuote[0], sObjectType, cloneFieldSets.get(sobjectType)[0].Field_Set_Name__c, systemFields.get(sobjectType), cloneChildObjects.get(sObjectType));
            cloneObject.cloneObject = newProp;
            cloneObject.runFullClone();
            cloneObject.cloneObject.put('Apttus_Proposal__Opportunity__c', oppId);
            cloneQuote = (Apttus_Proposal__Proposal__c) cloneObject.cloneObject;
            
            cloneQuote .Clarifications__c= selectMultiSelectedClarifications();
            cloneQuote .Exclusions__c=selectMultiSelectedExclusions();
            
            cloneQuote.Quote_Document_Date__c = system.today();
            cloneQuote.Internal_Team_Notes__c = Null;
            cloneQuote.SV_Order_Number__c = Null;
        }
        else {
            //call create here
            Apttus_Proposal__Proposal__c newProp = new Apttus_Proposal__Proposal__c();
            newProp = Apttus_QPConfig.QPConfigWebService.cloneProposal(recordToClone.Id);
            cloneObject = new CloneSobject(recordToClone, sobjectType, cloneFieldSets.get(sobjectType)[0].Field_Set_Name__c, systemFields.get(sobjectType), cloneChildObjects.get(sObjectType));
            cloneObject.cloneObject = newProp;
            cloneObject.runFullClone();
            cloneQuote = (Apttus_Proposal__Proposal__c) cloneObject.cloneObject;
            
            cloneQuote .Clarifications__c= selectMultiSelectedClarifications();
            cloneQuote .Exclusions__c=selectMultiSelectedExclusions();
            
        }
    }
    
    public string selectMultiSelectedClarifications()
    {
     
     List<String> lstPickvals=new List<String>();
     Schema.DescribeFieldResult fieldResult = Apttus_Proposal__Proposal__c.Clarifications__c.getDescribe();
     List<Schema.PicklistEntry> allValues  = fieldResult.getPicklistValues();
      for (Schema.PicklistEntry a : allValues) 
      { 
      lstPickvals.add(a.getValue());
       }
   
       if (lstPickvals==null)return null;
       return String.join(lstPickvals, ';');
   
     }
     
       public string selectMultiSelectedExclusions()
    {
     
     List<String> lstPickvals=new List<String>();
     Schema.DescribeFieldResult fieldResult = Apttus_Proposal__Proposal__c.Exclusions__c.getDescribe();
     List<Schema.PicklistEntry> allValues  = fieldResult.getPicklistValues();
      for (Schema.PicklistEntry a : allValues) 
      { 
      lstPickvals.add(a.getValue());
       }
   
       if (lstPickvals==null)return null;
       return String.join(lstPickvals, ';');
   
     }

    public PageReference saveQuoteClone() {
        Boolean isSuccessful = true;
        isSuccessful = cloneObject.saveCloneObject();
        if(!isSuccessful)return null;
        isSuccessful = cloneObject.cloneAndSaveChildObjects();
        if(!isSuccessful)return null;
        return new PageReference('/'+cloneObject.cloneObject.Id);
    }
}