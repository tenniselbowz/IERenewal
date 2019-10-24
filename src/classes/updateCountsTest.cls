@isTest
public class updateCountsTest {
    @isTest
    public static void unitTest()
    {
       //list<RecordTypes__mdt> rta = [select id,RecordTypeId__c from RecordTypes__mdt where DeveloperName='North_America_Proposal'];//North_America_RecordType
 
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;
        
        Account a = new Account (Name = 'Test Account');
        insert a;
        
        contact c = new contact (Firstname = 'FirstName', LastName = 'LastName', email = 'test@test.com', phone ='123', AccountId = a.id);
        insert c;
      
        Date d1 = Date.today();
        Opportunity o = new Opportunity (Name = 'Test Opp', AccountId=a.id, closedate=d1, stagename='Target/Lead Verification', Local_Currency__c = 'USD', Estimated_Shipping_Date__c =d1.addDays(1), Line_of_Business__c ='Equipment Only', Vertical_Market__c = 'Airports & Transportation', Region_Territory__c ='DALA', Opportunity_Country__c= 'Dominica', Opportunity_City__c='Roseau');
        Id  standardPricebookId =Test.getStandardPricebookId();
        o.Pricebook2Id = standardPricebookId;
        insert o;  
        
        Apttus_Proposal__Proposal__c q =  new Apttus_Proposal__Proposal__c(
            Apttus_Proposal__Account__c = a.id, 
            Apttus_QPConfig__ConfigurationFinalizedDate__c = Date.newInstance(2016, 06, 06), 
            Estimated_Close_Date__c= Date.newInstance(2016, 06, 06),
            Quote_Document_Date__c= Date.newInstance(2016, 06, 06), 
            T_C_Country__c= 'USA', 
            Emergency_Service_Level__c ='24 x 7 incl holidays',
            Document_Presentation_Language__c= 'English',
            Local_Currency__c = 'USD', 
            Apttus_QPConfig__BillToAccountId__c = a.id, 
            Apttus_Proposal__Opportunity__c = o.id, 
            Bulk_Exchange_Rate__c=125.03, 
            Brand__c= 'Daikin', 
            Quote_Presentation_Currency__c ='USD', 
            Apttus_Proposal__Primary_Contact__c = c.id);
        q.Apttus_Proposal__Primary__c = false;
        q.Approval_Status__c = 'Approved';
        q.RecordTypeId = '012C0000000GTQR';//rta[0].RecordTypeId__c;
        insert q;
        
        Customer_Documents__c cd = new Customer_Documents__c();
        cd.Document_Type__c = 'Customer PO';
        cd.Quote_Proposal__c = q.id;
        insert cd;
        
        cd.Document_Type__c = 'Customer Signature';
        update cd;
        
        delete cd;
    }

}