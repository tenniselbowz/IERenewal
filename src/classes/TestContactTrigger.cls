/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestContactTrigger {

// NOTE: Need to use the @isTest(SeeAllData=true) annotation because the test needs access the Custom Settings: CountryCodes__c, StateCodes__c

    @isTest(SeeAllData=true) static void unitTest1() {
        // Create an Address, Account and Contact objects to test the Insert and Update triggers on the Contact

		//!!!!!!!!!!! Need to add this code snippet for AvaTax- AccountAddressTrigger to run successfully on Before Insert into the Account table !!!!!!!!!!!!!!!!!
    	AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c();
        ts1.AVA_SFCORE__Active_Setting__c = true;
        ts1.Name='Test Account';
        insert ts1;

		// ---------------------------------CREATE TEST DATA----------------------------
        // Create Address__c, Account, Account_Address__c records
        Account acctTemp = null;
        Address__c addrTemp = null;
        Account_Address__c acctAddrJunctionObj = null;
        
        addrTemp = new Address__c();
        addrTemp.Address_Line_1__c = 'Test Address Line 1';
        addrTemp.City__c = 'Minneapolis';
        addrTemp.Postal_Code__c = '55421';
        addrTemp.Country__c = 'United States';
        addrTemp.State_Province__c = 'Minnesota';
        insert addrTemp;
        
        acctTemp = new Account();
        acctTemp.Name = 'Account Test1';
        acctTemp.Type = 'Developer';
        acctTemp.Physical_Address__c = addrTemp.Id;
        acctTemp.IE_Sync_Status__c = 'Pending';
        insert acctTemp;
        
        acctAddrJunctionObj = new Account_Address__c();
        acctAddrJunctionObj.Account__c = acctTemp.Id;
        acctAddrJunctionObj.Address__c = addrTemp.Id;
        acctAddrJunctionObj.Active__c = true;
        acctAddrJunctionObj.Physical__c = true;
        insert acctAddrJunctionObj;

		//--------------------

		Account acctTemp4 = null;
        Address__c addrTemp4 = null;
        Account_Address__c acctAddrJunctionObj4 = null;
        
        addrTemp4 = new Address__c();
        addrTemp4.Address_Line_1__c = 'Test Address Line ZZZ';
        addrTemp4.City__c = 'Roseville';
        addrTemp4.Postal_Code__c = '55421';
        addrTemp4.Country__c = 'United States';
        addrTemp4.State_Province__c = 'Minnesota';
        insert addrTemp4;
        
        acctTemp4 = new Account();
        acctTemp4.Name = 'Account Test4';
        acctTemp4.Type = 'Developer';
        acctTemp4.Physical_Address__c = addrTemp4.Id;
        acctTemp4.IE_Sync_Status__c = 'Pending';
        insert acctTemp4;
        
        acctAddrJunctionObj4 = new Account_Address__c();
        acctAddrJunctionObj4.Account__c = acctTemp4.Id;
        acctAddrJunctionObj4.Address__c = addrTemp4.Id;
        acctAddrJunctionObj4.Active__c = true;
        acctAddrJunctionObj4.Physical__c = true;
        insert acctAddrJunctionObj4;

		//------------------

		RecordType recordTypeTemp = [SELECT Id FROM RecordType WHERE Name='Daikin Applied' AND SObjectType='Contact'];

        List<Contact> contactList = new List<Contact>();

		// Contact whose Account Address = its Primary Mailing Address
        Contact contactTemp1 = new Contact();
        contactTemp1.Eprise_Login_ID__c = 'RoesslKS1';
        contactTemp1.RecordTypeId = recordTypeTemp.Id;
        contactTemp1.AccountId = acctTemp.Id;
        contactTemp1.Status__c = 'Active';
        contactTemp1.Email = 'kent.roessler@daikinapplied.com';
        contactTemp1.FirstName = 'Kent1';
        contactTemp1.LastName = 'Roessler1';
        contactTemp1.IE_Sync_Status__c = 'Pending';
        contactTemp1.IE_Contact__c = true;
		contactTemp1.MailingStreet = 'Test Address Line 1';
		contactTemp1.MailingCity = 'Minneapolis';
		contactTemp1.MailingCountry = 'United States';
		contactTemp1.MailingState = 'Minnesota';
		contactTemp1.MailingPostalCode = '55421';
        // Create an address for this contact
        Address__c addrTemp1 = new Address__c();
        addrTemp1.Address_Line_1__c = 'Test Address Line 1';
        addrTemp1.City__c = 'Minneapolis';
        addrTemp1.Postal_Code__c = '55421';
        addrTemp1.Country__c = 'United States';
        addrTemp1.State_Province__c = 'Minnesota';
        insert addrTemp1;
        contactTemp1.Physical_Address__c = addrTemp1.Id;
		contactTemp1.Primary_Mailing_Address__c = addrTemp1.Id;
        contactList.add(contactTemp1);


		// Contact whose Account Address != its Primary Mailing Address
		Contact contactTemp2 = new Contact();
        contactTemp2.Eprise_Login_ID__c = 'RoesslKS2';
        contactTemp2.RecordTypeId = recordTypeTemp.Id;
        contactTemp2.AccountId = acctTemp.Id;
        contactTemp2.Status__c = 'Active';
        contactTemp2.Email = 'kent.roessler@daikinapplied.com';
        contactTemp2.FirstName = 'Kent2';
        contactTemp2.LastName = 'Roessler2';
        contactTemp2.IE_Sync_Status__c = 'Pending';
        contactTemp2.IE_Contact__c = true;
		contactTemp2.MailingStreet = 'Test Address Line 12';
		contactTemp2.MailingCity = 'Minneapolis';
		contactTemp2.MailingCountry = 'United States';
		contactTemp2.MailingState = 'Minnesota';
		contactTemp2.MailingPostalCode = '55418';
		contactTemp2.MailingCountryCode = 'US';
		contactTemp2.MailingStateCode = 'MN';
        // Create an address for this contact
        Address__c addrTemp2 = new Address__c();
        addrTemp2.Address_Line_1__c = 'Test Address Line 12';
        addrTemp2.City__c = 'Minneapolis';
        addrTemp2.Postal_Code__c = '55418';
        addrTemp2.Country__c = 'United States';
        addrTemp2.State_Province__c = 'Minnesota';
        insert addrTemp2;
        contactTemp2.Physical_Address__c = addrTemp2.Id;
		contactTemp2.Primary_Mailing_Address__c = addrTemp2.Id;
        contactList.add(contactTemp2);


		// Contact is NOT an IE Contact, set value for DTJobGUID__c field
        Contact contactTemp3 = new Contact();
		contactTemp3.Record_Usage__c = 'IE';
		contactTemp3.DTJobGUID__c = 'xxx';
        contactTemp3.Eprise_Login_ID__c = 'RoesslKS3';
        contactTemp3.RecordTypeId = recordTypeTemp.Id;
        contactTemp3.AccountId = acctTemp.Id;
        contactTemp3.Status__c = 'Active';
        contactTemp3.Email = 'kent.roessler@daikinapplied.com';
        contactTemp3.FirstName = 'Kent3';
        contactTemp3.LastName = 'Roessler3';
        contactTemp3.IE_Sync_Status__c = 'Pending';
        contactTemp3.IE_Contact__c = false;
		contactTemp3.MailingStreet = 'Test Address Line 1';
		contactTemp3.MailingCity = 'Minneapolis';
		contactTemp3.MailingCountry = 'United States';
		contactTemp3.MailingState = 'Minnesota';
		contactTemp3.MailingPostalCode = '55421';
        // Create an address for this contact
        Address__c addrTemp3 = new Address__c();
        addrTemp3.Address_Line_1__c = 'Test Address Line 1';
        addrTemp3.City__c = 'Minneapolis';
        addrTemp3.Postal_Code__c = '55421';
        addrTemp3.Country__c = 'United States';
        addrTemp3.State_Province__c = 'Minnesota';
        insert addrTemp3;
        contactTemp3.Physical_Address__c = addrTemp3.Id;
		contactTemp3.Primary_Mailing_Address__c = addrTemp3.Id;
        contactList.add(contactTemp3);


		insert contactList;

		// Update 3rd contact
		Contact ct3 = [SELECT Id, Type__c, Record_Usage__c, DTJobGUID__c  FROM Contact WHERE Id = :contactTemp3.Id];
		System.Debug('ct3.DTJobGUID__c='+ct3.DTJobGUID__c);
		ct3.Record_Usage__c = null;
		ct3.Type__c = 'Engineer';
		update ct3;


		// Update 2nd contact
		Contact ct2 = [SELECT Id, AccountId, Physical_Address__c, Primary_Mailing_Address__c  FROM Contact WHERE Id = :contactTemp2.Id];
		//set to a different account
		ct2.AccountId = acctTemp4.Id;
		ct2.MailingStreet = 'Test Address Line xx';
		ct2.MailingCity = 'Minneapolis';
		ct2.MailingCountry = 'United States';
		ct2.MailingState = 'Minnesota';
		ct2.MailingPostalCode = '55418';
		ct2.MailingCountryCode = 'US';
		ct2.MailingStateCode = 'MN';
		//create a new address for this contact
        Address__c addrTemp2_1 = new Address__c();
        addrTemp2_1.Address_Line_1__c = 'Test Address Line xx';
        addrTemp2_1.City__c = 'Minneapolis';
        addrTemp2_1.Postal_Code__c = '55418';
        addrTemp2_1.Country__c = 'United States';
        addrTemp2_1.State_Province__c = 'Minnesota';
        insert addrTemp2_1;
        ct2.Physical_Address__c = addrTemp2_1.Id;
		ct2.Primary_Mailing_Address__c = addrTemp2_1.Id;
		update ct2;


		// Assert Test Results
		Contact ct1 = [SELECT Id, IE_Sync_Status__c, Record_Usage__c from Contact Where Id = :contactTemp1.Id];
 		System.assertEquals('Pending', ct1.IE_Sync_Status__c);
		System.assertEquals('IE', ct1.Record_Usage__c);

		ct3 = [SELECT Id, DTJobGUID__c  FROM Contact WHERE Id = :contactTemp3.Id];
		System.Debug('ct3.DTJobGUID__c='+ct3.DTJobGUID__c);
		list<String> emptyList = new list<String>();
		System.assertEquals(''+emptyList, ct3.DTJobGUID__c);  // equivalent to System.assertEquals('()', ct3.DTJobGUID__c);

		ct2 = [SELECT Id, Physical_Address__c, Primary_Mailing_Address__c, MailingStreet  FROM Contact WHERE Id = :contactTemp2.Id];
		System.assertEquals('Test Address Line xx', ct2.MailingStreet);
    }
}