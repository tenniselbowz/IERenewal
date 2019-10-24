@isTest
public class CreateNewServiceProposalControllerTest {
    static testmethod void runTest(){
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;
        Account a = TestDataFactory.createAccounts(1)[0];
        Contact c = TestDataFactory.createContacts(1)[0];
        
        Opportunity o = TestDataFactory.createOpportunities(1)[0];
        o.recordtypeId = [select Id from RecordType where Name = 'North America Apttus' and SobjectType = 'Opportunity'].id; 
        update o;
        
        Apttus_Config2__PriceList__c pb = new Apttus_Config2__PriceList__c(Name= 'Test Pricebook', Apttus_Config2__Active__c=TRUE);
        insert pb;
        Apttus_Proposal__Proposal__c newProposal = new Apttus_Proposal__Proposal__c();
        newProposal.Apttus_Proposal__Primary_Contact__c = c.id;
        newProposal.Apttus_QPConfig__PriceListId__c = pb.Id; 
        newProposal.Quote_Document_Date__c = date.Today(); 
        newProposal.Expiration_Date__c = date.Today()+1;
        newProposal.Brand__c = 'Daikin'; 
        newProposal.Quote_Document_Title__c = 'QUOTE';
        newProposal.Document_Presentation_Language__c = 'English'; 
        newProposal.Quote_Presentation_Currency__c ='USD';
        newProposal.Estimated_Close_Date__c = date.Today()+2;
        newProposal.Term_in_Years__c = '2';
        newProposal.RecordTypeId = [select Id from RecordType where Name = 'North America Proposal' and SobjectType = 'Apttus_Proposal__Proposal__c'].id;
        
        PageReference pRef = Page.CreateNewServiceProposal;

        pRef.getParameters().put('retURL', o.Id);

        Test.setCurrentPage(pRef);

         
        Test.startTest();
        
        CreateNewServiceProposalController newProposalInsert = new CreateNewServiceProposalController(new ApexPages.StandardController(newProposal));        

        Test.stopTest();
    }
}