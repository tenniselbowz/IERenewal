/*
*This is a controller class used to fetch details from opportunity into Quote/Proposal object after validating opportunity stage
*/

public with sharing class QuoteProposalExt{

    public Apttus_Proposal__Proposal__c quoteProposal{get; set;}
   // public static List<Schema.PicklistEntry> allValues {get;set;}
    public Id oppId{get; set;}
    
    //Constructor to create Quote/Proposal     
    public QuoteProposalExt() {       
        oppId = ApexPages.currentPage().getParameters().get('Id');        
        Opportunity opp = [SELECT Id, AccountId, OwnerId, Name, Line_of_Business__c, CloseDate FROM Opportunity WHERE Id =: oppId Limit 1];
        if (opp != NULL){
            quoteProposal = new Apttus_Proposal__Proposal__c(
                    Apttus_Proposal__Opportunity__c = opp.Id, Apttus_Proposal__Account__c = opp.AccountId, OwnerId = opp.OwnerId, 
                    Apttus_Proposal__Proposal_Name__c = opp.Name, Line_of_Business__c = opp.Line_of_Business__c, Estimated_Close_Date__c = opp.CloseDate
                );
        } 
               
        quoteProposal.Clarifications__c= selectMultiSelectedClarifications();
        quoteProposal.Exclusions__c=selectMultiSelectedExclusions();
    
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
    
    //save method to save data for Quote/proposal
    public PageReference save(){
        try {
            insert quoteProposal;
            PageReference pr = new PageReference('/'+quoteProposal.Id);
            pr.setRedirect(true);
            return pr;
        }
        catch (DmlException ex) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,'Error creating/updating record ' + ex.getMessage()));
            return null;
        }
    }
    
    //cancel method to redirect back to opportunity 
    public PageReference cancel(){
        PageReference pr = new PageReference('/'+ oppId);
        pr.setRedirect(true);
        return pr;
    }
}