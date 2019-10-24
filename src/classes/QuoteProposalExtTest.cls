/*
* This test class is for testing creation of Quote/Proposal through Opportunity Validated Stage 
*/

@isTest
private class QuoteProposalExtTest{
    static testmethod void createQuote(){
        setup();
        Test.startTest();      
                QuoteProposalExt newQuoteProposalInsert = new QuoteProposalExt();
                newQuoteProposalInsert.quoteProposal.Clarifications__c = null;
                newQuoteProposalInsert.quoteProposal.Exclusions__c = null;
                PageReference pg = newQuoteProposalInsert.save();
                newQuoteProposalInsert.cancel();
        Test.stopTest();
        System.assertNotEquals(null, pg, 'There should not be any errors');
        List<Apttus_Proposal__Proposal__c> quoteList = [Select Id From Apttus_Proposal__Proposal__c];
        System.Assert(!quoteList.isEmpty(),'Quote should be created ');
    }
    
    static testmethod void createQuoteNULLException(){
        setup();
        Boolean expectedExceptionThrown;   
        Test.startTest(); 
            try{     
                QuoteProposalExt newQuoteProposalInsert;
                newQuoteProposalInsert.save();
            }
            catch(Exception e){
                expectedExceptionThrown =  e.getMessage().contains('Attempt to de-reference a null object') ? true : false;               
            }
        Test.stopTest();
        List<Apttus_Proposal__Proposal__c> quoteList = [Select Id From Apttus_Proposal__Proposal__c];
        System.Assert(quoteList.isEmpty(),'Quote should not be created');
        System.AssertEquals(expectedExceptionThrown, true);
    }
  
   @testSetup
    static void setup(){
        Account acc = TestDataFactory.createAccounts(1)[0];
        Contact contact = TestDataFactory.createContacts(1)[0];       
        Opportunity opp = TestDataFactory.createOpportunities(1)[0];
        opp.recordtypeId = [select Id from RecordType where Name = 'North America Apttus' and SobjectType = 'Opportunity'].id; 
        update opp; 
        PageReference pRef = Page.CreateNewValidateServiceProposal;
        pRef.getParameters().put('Id', opp.Id);
        Test.setCurrentPage(pRef);   
    } 
   
}