public class ApttusQuoteProposalHandler {
    
    public static void HandleBeforeInsert(List<Apttus_Proposal__Proposal__c> quoteList)
    {
        ApttusQuoteProposalServices.setQuoteDefaults(quoteList);
        ApttusQuoteProposalServices.setTotalNetPriceInWords(quoteList);
        ApttusQuoteProposalServices.makeOnlyPrimaryQuote(quoteList);
    }
    
    public static void HandleBeforeUpdate(List<Apttus_Proposal__Proposal__c> quoteList)
    {
        ApttusQuoteProposalServices.setTotalNetPriceInWords(quoteList);
        /*for(Apttus_Proposal__Proposal__c p : quoteList){
              if(p.Apttus_Proposal__Approval_Stage__c=='Generated')
                  p.Approval_Status__c=null;
        }*/        
    }
    
    public static void HandleAfterUpdate(List<Apttus_Proposal__Proposal__c> quoteList,Map<Id, Apttus_Proposal__Proposal__c> oldQuoteMap)
    {
        ApttusQuoteProposalServices.synchronizeOpportunityLineItems(quoteList,oldQuoteMap);
        ApttusQuoteProposalServices.makeOnlyPrimaryQuote(quoteList);
        
    }
    
}