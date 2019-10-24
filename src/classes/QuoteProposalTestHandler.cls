public class QuoteProposalTestHandler 
{
    public static boolean flag=true;
    
    public static void UpdateOpportunityRollup(map<Id, Apttus_Proposal__Proposal__c> quoteList, map<Id, Apttus_Proposal__Proposal__c> oldQuoteMap)
    {
        Map<Id, Apttus_Proposal__Proposal__c> quoteMap = new Map<Id, Apttus_Proposal__Proposal__c>(
            [SELECT Id, owner.name FROM Apttus_Proposal__Proposal__c
             WHERE Id IN :quoteList.keySet()]);
        system.debug('quoteMap:'+quoteMap);
        List<Apttus_Proposal__Proposal__c> updateQuotes = new List<Apttus_Proposal__Proposal__c> ();
        system.debug('updateQuotes:::'+quoteMap);
        for(Apttus_Proposal__Proposal__c q: quoteList.values())
        {
            system.debug('quoteMap.get(q.id).owner.name'+quoteMap.get(q.id).owner.name);
            if(quoteList.get(q.Id).Approval_Action__c != oldQuoteMap.get(q.Id).Approval_Action__c)
            {
                q.Credit_Approved__c = (q.Credit_Approved__c == null)?0:q.Credit_Approved__c;
                q.Credit_Rejected__c = (q.Credit_Rejected__c == null)?0:q.Credit_Rejected__c;
                
                
                if(q.Apttus_Proposal__Primary__c)
                {
                    if(q.Apttus_Proposal__Approval_Stage__c ==  'Credit Approval Requested'){
                        q.Credit_Status__c = 'Pending';    
                    }else{
                        q.Credit_Status__c =  q.Approval_Status__c;        
                    }
                    
                    
                }
                
                if(q.Approval_Action__c == 'Approved' )
                {
                    system.debug('q.Approval_Status__c::'+q.Approval_Status__c);
                    q.Credit_Approved__c += 1;    
                    system.debug('q.Credit_Approved__c:::'+q.Credit_Approved__c);
                }
                else if(q.Approval_Action__c == 'Rejected')
                {
                    q.Credit_Rejected__c += 1;    
                }
                updateQuotes.add(q);
                
            }
        }
        if(updateQuotes.size()>0){
            flag = false;
            
        }
    }
}