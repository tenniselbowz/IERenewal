/* NOTE:  This unit test uses the Static resource file to load case test data.
* Name of file is CaseStaticRecords2 and it is a csv file for Case records.
* User must set the CreatedDate field of the last 2 entries to yesterday depending on the day you actually run the test.
*/

@isTest
public class TRC_Dashboard_Data_Test {
    static testmethod void unitTest(){
        
        
        Test.startTest();
     
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c();
        ts1.AVA_SFCORE__Active_Setting__c = true;
        ts1.Name='Test Account';
        insert ts1;

        Address__c address = new Address__c(Address_Line_1__c='13600 Industrial Park Blvd.', City__c='Plymouth', Country__c='United States', State_Province__c='Minnesota', Postal_Code__c='55418');
        Insert address;
        
        Account account = new Account(Name='TEST', Type='Other', Physical_Address__c=address.Id);
        Insert account;
        
        Contact contact = new Contact(LastName='TEST', Email='test@test.com', Account=account);
        Insert contact;
        
		DateTime yesterday = datetime.newInstance(datetime.now().year(), datetime.now().month(), datetime.now().day()-1);

        Case cs = new case (Origin='Phone', Status = 'Working', Priority= 'Low', Reason = 'Equipment Performance Issue', Subject='TRC', RecordTypeID='012C0000000Hqlk'/*TRC*/, Date_Time_Re_Opened__c = yesterday, Contact=contact);
        case css = cs.clone();
        Insert cs;
        insert css;
        cs.Status = 'Closed';
        cs.Resolution_Type__c = 'Answered Question';
        cs.Resolution_Description__c = 'Resolution Description';

        update cs;

		Case cs2 = new case (Origin='Phone', Status = 'Working', Priority= 'Low', Reason = 'Equipment Performance Issue', Subject='TRC - AAH', RecordTypeID='012C0000000HoMR'/*TRC - AAH*/, Date_Time_Re_Opened__c = yesterday, Contact=contact);
		insert cs2;

		cs2.Status = 'Closed';
        cs2.Resolution_Type__c = 'Answered Question';
        cs2.Resolution_Description__c = 'Resolution Description';

        update cs2; // Need to do an update after changing the status to Closed because inserting a case record automatically sets the status to Working.

        final String staticResourceName = 'CaseStaticRecords2';
        final Case[] testCases = (Case[]) Test.loadData(Case.sObjectType, staticResourceName);
        List<Case> ccc = [SELECT Id, Status, CreatedDate, ClosedDate From Case];
		System.debug('Loaded Case test data:');
		for(Case c : ccc) {
			System.debug(c);
		}

        /*TRC_Dashboard_Data TRCCase = new TRC_Dashboard_Data();
        TRCCase.getTRCResults();*/
        
        TRC_Dashboard_Data_Retrieval sch1 = new TRC_Dashboard_Data_Retrieval();
        String sch = '0 0 18 * * ?';
        system.schedule('TRC_Dashboard_Data', sch, sch1); 
        
        Test.stopTest(); 
        
        //update testCases;
        
        
      
    }
}