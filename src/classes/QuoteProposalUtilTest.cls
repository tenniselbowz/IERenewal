@isTest
private class QuoteProposalUtilTest {
    
    @isTest static void submitFroCreditPreApproval() {
        User currentUser = [SELECT Id, ManagerId, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, ProfileId, LanguageLocaleKey
                          FROM User 
                          WHERE Id = :System.UserInfo.getUserId() Limit 1];

        User newUser = new User(FirstName = 'Tom', UserName = 'Tomorrow@gmail.com', LastName = 'Morrow', CommunityNickname = 'TM', 
            TimeZoneSidKey = currentUser.TimeZoneSidKey, LocaleSidKey = currentUser.LocaleSidKey, EmailEncodingKey = currentUser.EmailEncodingKey, ProfileId = currentUser.ProfileId, LanguageLocaleKey = currentUser.LanguageLocaleKey
            , Email = 'Tomorrow@bluewolfgroup.com', Alias = 'Tommy');
        insert newUser;
        currentUser.DM_District_Manager__c = newUser.Id;
        update currentUser;
        System.runAs(currentUser) {
            //DPL to fix flow errors
            Apttus_Proposal__Proposal__c quoteProposal = TestDataFactory.createApttusProposal(1, True)[0];
            //Apttus_Proposal__Proposal__c quoteProposal = new Apttus_Proposal__Proposal__c();
            //quoteProposal.Credit_Pre_Approval_Required__c = True;
            //insert quoteProposal;
            
            Boolean result = QuoteProposalUtil.submitForCreditPreApproval(new List<Id>{quoteProposal.Id})[0];
            System.assert(result, 'This should have no errors');
        }
    
    }
}