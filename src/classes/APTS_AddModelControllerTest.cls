/*************************************************************
@Name: APTS_AddModelControllerTest
@Author: Hardik Shah
@CreateDate: 18/01/2016
@Description: Controller to save MA Model Data Enter by User
@UsedBy: Test Class for APTS_AddModelController
@ModifiedBy: NA
@ModifiedDate: NA
@ChangeDescription: 
PS: @ModifiedBy and @ChangeDescription can be repeated multiple time, based on number of changes made to the original process.
******************************************************************/

@isTest (seeAllData=false)
public class APTS_AddModelControllerTest {

    static testmethod void testAvaTaxForApex() { 
    
            AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
            ts1.AVA_SFCORE__Active_Setting__c = true; 
            ts1.Name='Test Account';
            insert ts1;
            
            Account accnt = getAccount('TestAccount1');
            insert accnt;
            
            Opportunity opp =  getOpportunity('TestOpportunity', accnt);
            insert opp;

            Apttus_Config2__PriceList__c priceList = getPriceList('TestPriceList');
            insert priceList;
            
            Apttus_Proposal__Proposal__c proposal = getQuoteHeader('TestProposal', accnt.Id, opp.Id, priceList.Id);
            insert proposal;
            
            PageReference pageRef1 = Page.APTS_AddModels;
            pageRef1.getParameters().put('retId',  proposal.id); 
            Test.setCurrentPage(pageRef1);
            
            MA_Model__c oMAModel = new MA_Model__c();
            oMAModel.Proposal__c = proposal.id;
            oMAModel.Equipment_Group__c = 'EG';
            oMAModel.Equipment_Type__c = 'ET';
            oMAModel.Serial__c = 'S1';
            oMAModel.Model__c = 'M1';
            
            APTS_AddModelController oModelController = New APTS_AddModelController ();
            oModelController.listMAModelsWrapper = new List<MA_Model__c>();
            oModelController.listMAModelsWrapper.add(oMAModel);
           
            oModelController.saveMAModles();
            oModelController.getMAModelsList();
            oModelController.AddRow();
            oModelController.removeRow();

}



 private static Account getAccount(String name) {
            
            Account acc = new Account();
            acc.name = name;
            acc.BillingStreet = '1400 Fashion Island Blvd';
            acc.BillingCity = 'San Mateo';
            acc.BillingState = 'California';
            acc.BillingCountry = 'United States';
            acc.BillingCountryCode='US';
            acc.BillingStatecode='CA';
            acc.BillingPostalCode = '94404';
            acc.phone='1234';
            acc.ShippingStreet = '1400 Fashion Island Blvd';
            acc.ShippingCity = 'San Mateo';
            acc.ShippingState = 'California';
            acc.ShippingCountry = 'United States';
            acc.ShippingCountryCode='US';
            acc.shippingstatecode='CA';
            acc.ShippingPostalCode = '94404';
    
            return acc;
        }
    
    private  static Opportunity getOpportunity(String name, Account acc) {
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = name;
        opp.vertical_market__c='Education K-12';
        opp.StageName = 'Target/Lead Verification';
        opp.CloseDate = Date.today().addDays(100);
        opp.DST_ID__c = '12345';
        return opp;
    }
    
    private static Apttus_Config2__PriceList__c getPriceList(String name) {
        
        Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c();
        priceList.Name = name;
        priceList.Apttus_Config2__EffectiveDate__c = Date.today().addDays(-300);
        priceList.Apttus_Config2__ExpirationDate__c = Date.today().addMonths(12);
        priceList.Apttus_Config2__Active__c = true;
        return priceList;
    }
    
    public static Apttus_Proposal__Proposal__c getQuoteHeader(String proposalName,ID accountID,ID opportunityId,ID priceListId) {
        ID rtID = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Proposal').getRecordTypeID();
        Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c();
        proposal.Apttus_Proposal__Proposal_Name__c = proposalName;
        proposal.Apttus_Proposal__Opportunity__c = opportunityId;
        proposal.RecordTypeId = rtID;
        proposal.Apttus_Proposal__Account__c = accountID;
        proposal.Apttus_Proposal__Presented_Date__c = date.today();//date.parse('03/12/2015');
        proposal.Apttus_Proposal__ExpectedStartDate__c = date.today();//date.parse('1/1/2015');
        proposal.Apttus_Proposal__Payment_Term__c = 'Net 30 Days';
        proposal.Apttus_Proposal__Approval_Stage__c = 'Draft';
        proposal.Apttus_Proposal__ExpectedEndDate__c = date.today().addYears(1);//date.parse('12/31/2015');
        proposal.Apttus_QPConfig__AutoActivateOrder__c = true;
        proposal.Apttus_QPConfig__AutoCreateBill__c = true;
        proposal.Apttus_QPConfig__PriceListId__c = priceListId;
        proposal.Apttus_Proposal__Primary__c = false;
        return proposal;
    }
}