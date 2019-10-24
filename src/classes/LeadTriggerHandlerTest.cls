@isTest
public class LeadTriggerHandlerTest {
	Static testMethod void myUnitTest(){
		AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;
    	
		// creating a lead by calling Test Data factory.
		Lead lead = TestDataFactory.createLeads(1)[0];
		              

		Database.LeadConvert lc = new database.LeadConvert();
		lc.setLeadId(lead.id);
		lc.setDoNotCreateOpportunity(false);
        //LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
		//lc.setConvertedStatus(convertStatus.MasterLabel);
		
		lc.setConvertedStatus('Qualified');
		Database.LeadConvertResult lcr;

		System.runAs(TestingUtils.ADMIN_USER){
			lcr = Database.convertLead(lc);  // Converts a lead into an account and contact, as well as (optionally) an opportunity
		}
		
		System.assert(lcr.isSuccess());

    }
}