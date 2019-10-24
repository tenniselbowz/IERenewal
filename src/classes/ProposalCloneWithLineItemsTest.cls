@isTest
public class ProposalCloneWithLineItemsTest {
	Static testMethod void myUnitTest(){
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;
        
    	Apttus_Proposal__Proposal__c qApttusProposal = TestDataFactory.createApttusProposal(1)[0];
        ProposalCloneWithLineItems newClone = new ProposalCloneWithLineItems(new ApexPages.StandardController(qApttusProposal));
        newClone.clones();
    }
}