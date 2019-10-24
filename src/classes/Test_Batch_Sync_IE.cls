/**
 * 
 */
@isTest
private class Test_Batch_Sync_IE { 

    static testMethod void testSyncUnits() {
        //!!!!!!!!!!! Need to add this code snippet for AvaTax- AccountAddressTrigger to run successfully on Before Insert into the Account table !!!!!!!!!!!!!!!!!
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;


		// Create Order__c and Product2 records
        Order__c orderTemp1 = null;
        orderTemp1 = new Order__c();
        orderTemp1.Job_Name__c = 'Test Order Job Name 1';
        orderTemp1.Order_Type_ID__c = 'Domestic';
        orderTemp1.Order_Entry_Date__c = Date.today();
        orderTemp1.SO_Number__c = 'SO #999';
        insert orderTemp1;

        Product2 prodTemp1 = null;
        prodTemp1 = new Product2();
        prodTemp1.Name = 'Test Prod1';
        prodTemp1.Vendor_Supplier__c = 'Test Vendor1';
        prodTemp1.IsActive = true;
        prodTemp1.Description = 'Test Description1';
        prodTemp1.DW_PCL_Description__c = 'Test DW PCL Description1';
        prodTemp1.Apttus_Product__c = true;
        prodTemp1.Product_Category__c = 'Test Category1';
        prodTemp1.ProductCode = 'DPS015A';
        insert prodTemp1;

        Product2 prodTemp2 = null;
        prodTemp2 = new Product2();
        prodTemp2.Name = 'Test Prod2';
        prodTemp2.Vendor_Supplier__c = 'Test Vendor2';
        prodTemp2.IsActive = true;
        prodTemp2.Description = 'Test Description2';
        prodTemp2.DW_PCL_Description__c = 'Test DW PCL Description2';
        prodTemp2.Apttus_Product__c = true;
        prodTemp2.Product_Category__c = 'Test Category2';
        prodTemp2.ProductCode = 'DPS015A';
        insert prodTemp2;

        Product2 prodTemp3 = null;
        prodTemp3 = new Product2();
        prodTemp3.Name = 'Intelligent Equipment Gateway';
        prodTemp3.Vendor_Supplier__c = 'Test Vendor3';
        prodTemp3.IsActive = true;
        prodTemp3.Description = 'Test Description3';
        prodTemp3.DW_PCL_Description__c = 'Test DW PCL Description3';
        prodTemp3.Apttus_Product__c = true;
        prodTemp3.Product_Category__c = 'Test Category3';
        insert prodTemp3;

        Product2 prodTemp4 = null;
        prodTemp4 = new Product2();
        prodTemp4.Name = 'Intelligent Equipment Energy Management Module';
        prodTemp4.Vendor_Supplier__c = 'Test Vendor4';
        prodTemp4.IsActive = true;
        prodTemp4.Description = 'Test Description4';
        prodTemp4.DW_PCL_Description__c = 'Test DW PCL Description4';
        prodTemp4.Apttus_Product__c = true;
        prodTemp4.Product_Category__c = 'Test Category4';
        insert prodTemp4;


		//Create Address
        Address__c addr = new Address__c(Address_Line_1__c = 'x1'
                                        ,Address_Line_2__c = 'x2'
                                        ,Address_Line_3__c = 'x3'
                                        ,Address_Line_4__c = 'x4'
                                        ,City__c = 'New York'
                                        ,State_Province__c = 'New York'
                                        ,Country__c = 'United States'
                                        //,State_Province__c = 'NY'
                                        ,Postal_Code__c = '11111'
                                        ,IE_ID__c  = 'x'
                                        ,IE_Address__c = true
                                        ,IE_Updated_Date__c = System.Now());
        
        insert addr;

        // Create Test Account
        Account a = new Account(Name = 'Test'
                              , IE_Sync_Status__c = 'Pending'
                              , IE_ID__c = '123'
                              , IE_Account__c = true
							  , Physical_Address__c = addr.Id
                              );
        insert a;

        map<String, Id> RecordTypeNameMap = new map<String, Id>();
        for(RecordType rt : [Select Name, SobjectType, Id 
                               from RecordType 
                              where Name in ('TRC', 'Address', 'SFDC Integration' )])
        {
            RecordTypeNameMap.put(rt.Name+'-'+rt.SobjectType, rt.Id);
        }
        
        IE_Service_Configuration__c ie = new IE_Service_Configuration__c();
        ie.Account_RecordType__c = RecordTypeNameMap.get('TRC-Account');
        ie.Address_RecordType__c = RecordTypeNameMap.get('Address-Address__c');
        ie.Contact_RecordType__c = RecordTypeNameMap.get('SFDC Integration-Contact');
        ie.Unit_Record_Type__c = '';
        ie.DaikinAccountId__c = a.Id;
        ie.endpoint__c = 'http://daikin-iep-service-qa.cloudapp.net/SalesforceIntegration.svc';
        ie.IndividualService__c = '/Individual';
        ie.OrganizationService__c = '/Organization';
        ie.username__c = 'xxx';
        ie.password__c = 'yyy';
        ie.SubscriptionService__c = '/Subscription';
        ie.UnitService__c = '/Unit';
        
        insert ie;
        
        List<IE_Integration_Field_Set__c> fieldList = new List<IE_Integration_Field_Set__c>{new IE_Integration_Field_Set__c(Name='Account', Field_List__c=('Record_Usage__c'))
                                                                                           ,new IE_Integration_Field_Set__c(Name='Contact', Field_List__c=('Record_Usage__c'))
                                                                                           ,new IE_Integration_Field_Set__c(Name='Address__c', Field_List__c=('Record_Usage__c'))};
        
        insert fieldList;
        
        // Create Test Account 2
        Account a2 = new Account(Name = 'Test2'
                              , IE_Sync_Status__c = 'Pending'
                              , IE_Account__c = true
							  , Physical_Address__c = addr.Id
                              );
        insert a2;
        
        // Create Assets
        Asset asset = new Asset(Name = 'test'
                              , AccountId = a.Id
							  , Asset_Address__c = addr.Id
                              , SerialNumber='123Test'
                              , Code_String_Breakdown__c = '[{"code_sequence":"1","code_value":"W","code_description":"Product Category; WATER SOURCE HEAT PUMP"},{"code_sequence":"2","code_value":"CCH","code_description":"Unit Type; CEILING MTD./STANDARD RANGE"},{"code_sequence":"3","code_value":"2","code_description":"Design series; 2ND DESIGN"},{"code_sequence":"4","code_value":"030","code_description":"Unit Size; 30,000 BTUH NOMINAL COOLING"},{"code_sequence":"5","code_value":"E","code_description":"Controls; DDC LESS BOARD"},{"code_sequence":"6","code_value":"K","code_description":"Voltage; 460/60/3"},{"code_sequence":"7","code_value":"Y","code_description":"Cabinet Height; NONE"},{"code_sequence":"8","code_value":"R","code_description":"Return Air; RIGHT HAND RETURN AIR"},{"code_sequence":"9","code_value":"S","code_description":"Discharge Air; STRAIGHT DISCHARGE"},{"code_sequence":"10","code_value":"01","code_description":"Blower Motor; STANDARD"},{"code_sequence":"11","code_value":"YY","code_description":"Disch. Grille/Cab. Type; NONE"},{"code_sequence":"12","code_value":"A","code_description":"Construction Type; STANDARD"},{"code_sequence":"13","code_value":"C","code_description":"Water-Refrig Ht Exch Constr; Copper Inner/Steel Outer Tubes"},{"code_sequence":"14","code_value":"Y","code_description":"Heating Options; NONE"},{"code_sequence":"15","code_value":"YY","code_description":"Dehumidification; NONE"},{"code_sequence":"16","code_value":"Y","code_description":"Piping Hand; NONE"},{"code_sequence":"17","code_value":"YYY","code_description":"Thermostat Control; NONE"},{"code_sequence":"18","code_value":"YYY","code_description":"Night Control; NONE"},{"code_sequence":"19","code_value":"YYY","code_description":"Desuperheater; NONE"},{"code_sequence":"20","code_value":"A","code_description":"Refrigerant; 410A"},{"code_sequence":"21","code_value":"Y","code_description":"Power Connection; NONE"},{"code_sequence":"22","code_value":"YYY","code_description":"Cabinet Electrical; NONE"},{"code_sequence":"23","code_value":"Y","code_description":"Water Flow Control; NONE"},{"code_sequence":"24","code_value":"Y","code_description":"Color; NONE"},{"code_sequence":"25","code_value":"Y","code_description":"Outside Air; NONE"},{"code_sequence":"26","code_value":"C","code_description":"Agency Listing; ETL, CETL, ARI, MEA"},{"code_sequence":"27","code_value":"1","code_description":"Packaging; STANDARD"},{"code_sequence":"28","code_value":"Y","code_description":"Ext. Warranty; NONE"},{"code_sequence":"29","code_value":"2","code_description":"Product Style; Style 2"}]'
                              , Tag__c = 'x'
                              //, Device_ID__c = '111.222.333.444'
                              , SIM_Card_ICCID__c = '11111'
                              , Format_Number__c = '22222'
                              , Commissioned__c = false
                              , IE_ID__c = null
                              , IE_Sync_Status__c = 'Pending'
                              , IE_Asset__c = true
							  , Product2Id = prodTemp1.Id
							  , Order__c = orderTemp1.Id
							  //, LastModifiedDate = System.today()
                              );
        insert asset;
        
        Asset asset1 = new Asset(Name = 'test1'
                              , AccountId = a.Id
							  , Asset_Address__c = addr.Id
                              , SerialNumber='123Test1'
                              , Code_String_Breakdown__c = '[{"code_sequence":"1","code_value":"W","code_description":"Product Category; WATER SOURCE HEAT PUMP"},{"code_sequence":"2","code_value":"CCH","code_description":"Unit Type; CEILING MTD./STANDARD RANGE"},{"code_sequence":"3","code_value":"2","code_description":"Design series; 2ND DESIGN"},{"code_sequence":"4","code_value":"030","code_description":"Unit Size; 30,000 BTUH NOMINAL COOLING"},{"code_sequence":"5","code_value":"E","code_description":"Controls; DDC LESS BOARD"},{"code_sequence":"6","code_value":"K","code_description":"Voltage; 460/60/3"},{"code_sequence":"7","code_value":"Y","code_description":"Cabinet Height; NONE"},{"code_sequence":"8","code_value":"R","code_description":"Return Air; RIGHT HAND RETURN AIR"},{"code_sequence":"9","code_value":"S","code_description":"Discharge Air; STRAIGHT DISCHARGE"},{"code_sequence":"10","code_value":"01","code_description":"Blower Motor; STANDARD"},{"code_sequence":"11","code_value":"YY","code_description":"Disch. Grille/Cab. Type; NONE"},{"code_sequence":"12","code_value":"A","code_description":"Construction Type; STANDARD"},{"code_sequence":"13","code_value":"C","code_description":"Water-Refrig Ht Exch Constr; Copper Inner/Steel Outer Tubes"},{"code_sequence":"14","code_value":"Y","code_description":"Heating Options; NONE"},{"code_sequence":"15","code_value":"YY","code_description":"Dehumidification; NONE"},{"code_sequence":"16","code_value":"Y","code_description":"Piping Hand; NONE"},{"code_sequence":"17","code_value":"YYY","code_description":"Thermostat Control; NONE"},{"code_sequence":"18","code_value":"YYY","code_description":"Night Control; NONE"},{"code_sequence":"19","code_value":"YYY","code_description":"Desuperheater; NONE"},{"code_sequence":"20","code_value":"A","code_description":"Refrigerant; 410A"},{"code_sequence":"21","code_value":"Y","code_description":"Power Connection; NONE"},{"code_sequence":"22","code_value":"YYY","code_description":"Cabinet Electrical; NONE"},{"code_sequence":"23","code_value":"Y","code_description":"Water Flow Control; NONE"},{"code_sequence":"24","code_value":"Y","code_description":"Color; NONE"},{"code_sequence":"25","code_value":"Y","code_description":"Outside Air; NONE"},{"code_sequence":"26","code_value":"C","code_description":"Agency Listing; ETL, CETL, ARI, MEA"},{"code_sequence":"27","code_value":"1","code_description":"Packaging; STANDARD"},{"code_sequence":"28","code_value":"Y","code_description":"Ext. Warranty; NONE"},{"code_sequence":"29","code_value":"2","code_description":"Product Style; Style 2"}]'
                              , Tag__c = 'x'
                              //, Device_ID__c = '111.222.333.444'
                              , SIM_Card_ICCID__c = '11111'
                              , Format_Number__c = '22222'
                              , Commissioned__c = false
                              , IE_ID__c = '123'
                              , IE_Sync_Status__c = 'Pending'
                              , IE_Asset__c = true
							  , Product2Id = prodTemp2.Id
							  , Order__c = orderTemp1.Id
							  //, LastModifiedDate = System.today()
							  );
        insert asset1;

        
        
        //Create Asset Address
        Asset_Address__c aa = new Asset_Address__c(Asset__c = asset.Id
                                                  ,Address__c = addr.Id
                                                  ,Building_Identifier__c = '123');
        insert aa;
        
        Asset_Address__c aa2 = new Asset_Address__c(Asset__c = asset1.Id
                                                  ,Address__c = addr.Id
                                                  ,Building_Identifier__c = '123');
        insert aa2;


		// Create Related Asset Records for each Parent Asset
        Asset relatedAsset1 = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = a.Id, SerialNumber = 'PO112711-2-075', Parent_Asset__c = asset.Id);
        relatedAsset1.Product2Id = prodTemp3.Id;
        relatedAsset1.SIM_Card_Active__c = true;
        relatedAsset1.SIM_Card_ICCID__c = '89011704258018735310';
		relatedAsset1.MAC_Address__c = 'abc123';
        insert relatedAsset1;

        Asset relatedAsset2 = new Asset(Name = 'Intelligent Equipment Energy Management Module', AccountId = a.Id, SerialNumber = 'MESF04115', Parent_Asset__c = asset.Id);
        relatedAsset2.Product2Id = prodTemp4.Id;
        relatedAsset2.SIM_Card_Active__c = true;
        insert relatedAsset2;

        Asset relatedAsset3 = new Asset(Name = 'Intelligent Equipment Gateway', AccountId = a.Id, SerialNumber = 'PO112711-2-075', Parent_Asset__c = asset1.Id);
        relatedAsset3.Product2Id = prodTemp3.Id;
        relatedAsset3.SIM_Card_Active__c = true;
        relatedAsset3.SIM_Card_ICCID__c = 'some text89011704258018735310some text';
		relatedAsset3.MAC_Address__c = 'xyz123';
        insert relatedAsset3;

        Asset relatedAsset4 = new Asset(Name = 'Intelligent Equipment Energy Management Module', AccountId = a.Id, SerialNumber = 'MESF04115', Parent_Asset__c = asset1.Id);
        relatedAsset4.Product2Id = prodTemp4.Id;
        relatedAsset4.SIM_Card_Active__c = true;
        insert relatedAsset4;



		// Create Account Address
        Account_Address__c aa1 = new Account_Address__c(Account__c = a.Id
                                                       ,Address__c = addr.Id
                                                       ,Primary_Mail_To__c = true);
        insert aa1;
        

        // Create Subscriptions
        Subscription__c sub = new Subscription__c(Type__c = 'CustomRead'
                                                , Start_Date__c = System.today()
                                                , End_Date__c = System.today() + 1
                                                , Buyer_ID__c = a.Id
                                                , Asset__c = asset1.Id
                                                , IE_ID__c = '123'
                                                , IE_Updated_Date__c = System.now()
                                                , IE_Sync_Status__c = 'Pending'
                                                , IE_Subscription__c = true);
        insert sub;
        
        Subscription__c sub2 = new Subscription__c(Type__c = 'TechReadWrite'
                                                , Start_Date__c = System.today()
                                                , End_Date__c = System.today() + 1
                                                , Buyer_ID__c = a.Id
                                                , Asset__c = asset1.Id
                                                , IE_ID__c = null
                                                , IE_Updated_Date__c = System.now()
                                                , IE_Sync_Status__c = 'Pending'
                                                , IE_Subscription__c = true);
        insert sub2;
        
        
		Test.startTest(); // moved this here to start another context since we were running into soql query linit exception
        
		// Add 11 contacts to test the code that breaks it up into multiple chunks to process
        Contact c1 = new Contact(FirstName = 'x'
                              , LastName = 'y'
                              , Middle_Name__c = 'z'
                              , Email = 'tester@daikintest.com'
                              , Phone = '3334445555'
                              , MobilePhone = '4445556666'
                              , IE_Username__c = 'tester@daikintest.com'
                              , IE_Accessed__c = true
                              , IE_Inactive__c = false
                              , IE_Updated_Date__c = null
                              , IE_ID__c = null
                              , IE_Contact__c = true
                              , IE_Sync_Status__c = 'Pending');
        insert c1;
        
        Contact_Address__c ca1 = new Contact_Address__c(Contact__c = c1.Id
                                                    ,Address__c = addr.Id
                                                    ,Primary_Mail_To__c = true);
        insert ca1;
        
        Contact_Subscription__c cs1 = new Contact_Subscription__c(Contact__c = c1.Id
                                                                 ,Subscription__c = sub.Id
                                                                 ,Asset__c = asset1.Id 
                                                                 ,Role__c = 'TechnicianAdministrator');
        insert cs1;
        

        Contact c2 = new Contact(FirstName = 'x'
                              , LastName = 'y'
                              , Middle_Name__c = 'z'
                              , Email = 'tester@daikintest.com'
                              , Phone = '3334445555'
                              , MobilePhone = '4445556666'
                              , IE_Username__c = 'tester@daikintest.com'
                              , IE_Accessed__c = true
                              , IE_Inactive__c = false
                              , IE_Updated_Date__c = System.now()
                              , IE_ID__c = '123456'
                              , IE_Contact__c = true
                              , IE_Sync_Status__c = 'Pending');
        insert c2;

        Contact_Address__c ca2 = new Contact_Address__c(Contact__c = c2.Id
                                                        ,Address__c = addr.Id
                                                        ,Primary_Mail_To__c = true);
        insert ca2;
        
        Contact_Subscription__c cs2 = new Contact_Subscription__c(Contact__c = c2.Id
                                                                 ,Subscription__c = sub.Id
                                                                 ,Asset__c = asset1.Id
                                                                 ,Role__c = 'Customer');
        insert cs2;


        Contact c3 = new Contact(FirstName = 'x'
                              , LastName = 'y'
                              , Middle_Name__c = 'z'
                              , Email = 'tester@daikintest.com'
                              , Phone = '3334445555'
                              , MobilePhone = '4445556666'
                              , IE_Username__c = 'tester@daikintest.com'
                              , IE_Accessed__c = true
                              , IE_Inactive__c = false
                              , IE_Updated_Date__c = System.now()
                              , IE_ID__c = '123456'
                              , IE_Contact__c = true
                              , IE_Sync_Status__c = 'Pending');
        insert c3;

        Contact_Address__c ca3 = new Contact_Address__c(Contact__c = c3.Id
                                                        ,Address__c = addr.Id
                                                        ,Primary_Mail_To__c = true);
        //insert ca3;
        
        Contact_Subscription__c cs3 = new Contact_Subscription__c(Contact__c = c3.Id
                                                                 ,Subscription__c = sub.Id
                                                                 ,Asset__c = asset1.Id
                                                                 ,Role__c = 'Customer');
        insert cs3;


        Contact c4 = new Contact(FirstName = 'x'
                              , LastName = 'y'
                              , Middle_Name__c = 'z'
                              , Email = 'tester@daikintest.com'
                              , Phone = '3334445555'
                              , MobilePhone = '4445556666'
                              , IE_Username__c = 'tester@daikintest.com'
                              , IE_Accessed__c = true
                              , IE_Inactive__c = false
                              , IE_Updated_Date__c = System.now()
                              , IE_ID__c = '123456'
                              , IE_Contact__c = true
                              , IE_Sync_Status__c = 'Pending');
        insert c4;

        Contact_Address__c ca4 = new Contact_Address__c(Contact__c = c4.Id
                                                        ,Address__c = addr.Id
                                                        ,Primary_Mail_To__c = true);
        //insert ca4;
        
        Contact_Subscription__c cs4 = new Contact_Subscription__c(Contact__c = c4.Id
                                                                 ,Subscription__c = sub.Id
                                                                 ,Asset__c = asset1.Id
                                                                 ,Role__c = 'Customer');
        insert cs4;


        Contact c5 = new Contact(FirstName = 'x'
                              , LastName = 'y'
                              , Middle_Name__c = 'z'
                              , Email = 'tester@daikintest.com'
                              , Phone = '3334445555'
                              , MobilePhone = '4445556666'
                              , IE_Username__c = 'tester@daikintest.com'
                              , IE_Accessed__c = true
                              , IE_Inactive__c = false
                              , IE_Updated_Date__c = System.now()
                              , IE_ID__c = '123456'
                              , IE_Contact__c = true
                              , IE_Sync_Status__c = 'Pending');
        insert c5;

        Contact_Address__c ca5 = new Contact_Address__c(Contact__c = c5.Id
                                                        ,Address__c = addr.Id
                                                        ,Primary_Mail_To__c = true);
        //insert ca5;
        
        Contact_Subscription__c cs5 = new Contact_Subscription__c(Contact__c = c5.Id
                                                                 ,Subscription__c = sub.Id
                                                                 ,Asset__c = asset1.Id
                                                                 ,Role__c = 'Customer');
        insert cs5;


        Contact c6 = new Contact(FirstName = 'x'
                              , LastName = 'y'
                              , Middle_Name__c = 'z'
                              , Email = 'tester@daikintest.com'
                              , Phone = '3334445555'
                              , MobilePhone = '4445556666'
                              , IE_Username__c = 'tester@daikintest.com'
                              , IE_Accessed__c = true
                              , IE_Inactive__c = false
                              , IE_Updated_Date__c = System.now()
                              , IE_ID__c = '123456'
                              , IE_Contact__c = true
                              , IE_Sync_Status__c = 'Pending');
        insert c6;

        Contact_Address__c ca6 = new Contact_Address__c(Contact__c = c6.Id
                                                        ,Address__c = addr.Id
                                                        ,Primary_Mail_To__c = true);
        //insert ca6;
        
        Contact_Subscription__c cs6 = new Contact_Subscription__c(Contact__c = c6.Id
                                                                 ,Subscription__c = sub.Id
                                                                 ,Asset__c = asset1.Id
                                                                 ,Role__c = 'Customer');
        insert cs6;


        Contact c7 = new Contact(FirstName = 'x'
                              , LastName = 'y'
                              , Middle_Name__c = 'z'
                              , Email = 'tester@daikintest.com'
                              , Phone = '3334445555'
                              , MobilePhone = '4445556666'
                              , IE_Username__c = 'tester@daikintest.com'
                              , IE_Accessed__c = true
                              , IE_Inactive__c = false
                              , IE_Updated_Date__c = System.now()
                              , IE_ID__c = '123456'
                              , IE_Contact__c = true
                              , IE_Sync_Status__c = 'Pending');
        insert c7;

        Contact_Address__c ca7 = new Contact_Address__c(Contact__c = c7.Id
                                                        ,Address__c = addr.Id
                                                        ,Primary_Mail_To__c = true);
        //insert ca7;
        
        Contact_Subscription__c cs7 = new Contact_Subscription__c(Contact__c = c7.Id
                                                                 ,Subscription__c = sub.Id
                                                                 ,Asset__c = asset1.Id
                                                                 ,Role__c = 'Customer');
        insert cs7;


        Contact c8 = new Contact(FirstName = 'x'
                              , LastName = 'y'
                              , Middle_Name__c = 'z'
                              , Email = 'tester@daikintest.com'
                              , Phone = '3334445555'
                              , MobilePhone = '4445556666'
                              , IE_Username__c = 'tester@daikintest.com'
                              , IE_Accessed__c = true
                              , IE_Inactive__c = false
                              , IE_Updated_Date__c = System.now()
                              , IE_ID__c = '123456'
                              , IE_Contact__c = true
                              , IE_Sync_Status__c = 'Pending');
        insert c8;

        Contact_Address__c ca8 = new Contact_Address__c(Contact__c = c8.Id
                                                        ,Address__c = addr.Id
                                                        ,Primary_Mail_To__c = true);
        //insert ca8;
        
        Contact_Subscription__c cs8 = new Contact_Subscription__c(Contact__c = c8.Id
                                                                 ,Subscription__c = sub.Id
                                                                 ,Asset__c = asset1.Id
                                                                 ,Role__c = 'Customer');
        insert cs8;


        Contact c9 = new Contact(FirstName = 'x'
                              , LastName = 'y'
                              , Middle_Name__c = 'z'
                              , Email = 'tester@daikintest.com'
                              , Phone = '3334445555'
                              , MobilePhone = '4445556666'
                              , IE_Username__c = 'tester@daikintest.com'
                              , IE_Accessed__c = true
                              , IE_Inactive__c = false
                              , IE_Updated_Date__c = System.now()
                              , IE_ID__c = '123456'
                              , IE_Contact__c = true
                              , IE_Sync_Status__c = 'Pending');
        insert c9;

        Contact_Address__c ca9 = new Contact_Address__c(Contact__c = c9.Id
                                                        ,Address__c = addr.Id
                                                        ,Primary_Mail_To__c = true);
        //insert ca9;
        
        Contact_Subscription__c cs9 = new Contact_Subscription__c(Contact__c = c9.Id
                                                                 ,Subscription__c = sub.Id
                                                                 ,Asset__c = asset1.Id
                                                                 ,Role__c = 'Customer');
        insert cs9;


        Contact c10 = new Contact(FirstName = 'x'
                              , LastName = 'y'
                              , Middle_Name__c = 'z'
                              , Email = 'tester@daikintest.com'
                              , Phone = '3334445555'
                              , MobilePhone = '4445556666'
                              , IE_Username__c = 'tester@daikintest.com'
                              , IE_Accessed__c = true
                              , IE_Inactive__c = false
                              , IE_Updated_Date__c = System.now()
                              , IE_ID__c = '123456'
                              , IE_Contact__c = true
                              , IE_Sync_Status__c = 'Pending');
        insert c10;

        Contact_Address__c ca10 = new Contact_Address__c(Contact__c = c10.Id
                                                        ,Address__c = addr.Id
                                                        ,Primary_Mail_To__c = true);
        //insert ca10;
        
        Contact_Subscription__c cs10 = new Contact_Subscription__c(Contact__c = c10.Id
                                                                 ,Subscription__c = sub.Id
                                                                 ,Asset__c = asset1.Id
                                                                 ,Role__c = 'Customer');
        insert cs10;


        Contact c11 = new Contact(FirstName = 'x'
                              , LastName = 'y'
                              , Middle_Name__c = 'z'
                              , Email = 'tester@daikintest.com'
                              , Phone = '3334445555'
                              , MobilePhone = '4445556666'
                              , IE_Username__c = 'tester@daikintest.com'
                              , IE_Accessed__c = true
                              , IE_Inactive__c = false
                              , IE_Updated_Date__c = System.now()
                              , IE_ID__c = '123456'
                              , IE_Contact__c = true
                              , IE_Sync_Status__c = 'Pending');
        insert c11;

        Contact_Address__c ca11 = new Contact_Address__c(Contact__c = c11.Id
                                                        ,Address__c = addr.Id
                                                        ,Primary_Mail_To__c = true);
        //insert ca11;
        
        Contact_Subscription__c cs11 = new Contact_Subscription__c(Contact__c = c11.Id
                                                                 ,Subscription__c = sub.Id
                                                                 ,Asset__c = asset1.Id
                                                                 ,Role__c = 'Customer');
        insert cs11;
		
        

        //Test.startTest();
        Database.ExecuteBatch(new Batch_Sync_IE_Unit('Pending'));
        Test.stopTest();
        
    }


    static testMethod void testSyncUnits_fail() {
        // Create Asset
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;

		//Create Address
        Address__c addr = new Address__c(Address_Line_1__c = 'x1'
                                        ,Address_Line_2__c = 'x2'
                                        ,Address_Line_3__c = 'x3'
                                        ,Address_Line_4__c = 'x4'
                                        ,City__c = 'New York'
                                        ,State_Province__c = 'New York'
                                        ,Country__c = 'United States'
                                        //,State_Province__c = 'NY'
                                        ,Postal_Code__c = '11111'
                                        ,IE_ID__c  = 'x'
                                        ,IE_Address__c = true
                                        ,IE_Updated_Date__c = System.Now());
        
        insert addr;


		// Create Accounts
        Account a = new Account(Name = 'Test'
                              , IE_Sync_Status__c = 'Pending'
                              , IE_ID__c = '123'
                              , IE_Account__c = true
							  , Physical_Address__c = addr.Id
                              );
        insert a;

        map<String, Id> RecordTypeNameMap = new map<String, Id>();
        for(RecordType rt : [Select Name, SobjectType, Id 
                               from RecordType 
                              where Name in ('TRC', 'Address', 'SFDC Integration' )])
        {
            RecordTypeNameMap.put(rt.Name+'-'+rt.SobjectType, rt.Id);
        }
        
        IE_Service_Configuration__c ie = new IE_Service_Configuration__c();
        ie.Account_RecordType__c = RecordTypeNameMap.get('TRC-Account');
        ie.Address_RecordType__c = RecordTypeNameMap.get('Address-Address__c');
        ie.Contact_RecordType__c = RecordTypeNameMap.get('SFDC Integration-Contact');
        ie.Unit_Record_Type__c = '';
        ie.DaikinAccountId__c = a.Id;
        ie.endpoint__c = 'http://daikin-iep-service-qa.cloudapp.net/SalesforceIntegration.svc';
        ie.IndividualService__c = '/Individual';
        ie.OrganizationService__c = '/Organization';
        ie.username__c = 'xxx';
        ie.password__c = 'yyy';
        ie.SubscriptionService__c = '/Subscription';
        ie.UnitService__c = '/Unit';
        
        insert ie;
        
        List<IE_Integration_Field_Set__c> fieldList = new List<IE_Integration_Field_Set__c>{new IE_Integration_Field_Set__c(Name='Account', Field_List__c=('Record_Usage__c'))
                                                                                           ,new IE_Integration_Field_Set__c(Name='Contact', Field_List__c=('Record_Usage__c'))
                                                                                           ,new IE_Integration_Field_Set__c(Name='Address__c', Field_List__c=('Record_Usage__c'))};
        
        insert fieldList;
        
        Account a2 = new Account(Name = 'Test2'
                              , IE_Sync_Status__c = 'Pending'
                              , IE_Account__c = true
							  , Physical_Address__c = addr.Id
                              );
        insert a2;
        

		// Create Assets
        Asset asset = new Asset(Name = 'test'
                              , AccountId = a.Id
							  , Asset_Address__c = addr.Id
                              , SerialNumber='123Test'
                              , Code_String_Breakdown__c = '[{"code_sequence":"1","code_value":"W","code_description":"Product Category; WATER SOURCE HEAT PUMP"},{"code_sequence":"2","code_value":"CCH","code_description":"Unit Type; CEILING MTD./STANDARD RANGE"},{"code_sequence":"3","code_value":"2","code_description":"Design series; 2ND DESIGN"},{"code_sequence":"4","code_value":"030","code_description":"Unit Size; 30,000 BTUH NOMINAL COOLING"},{"code_sequence":"5","code_value":"E","code_description":"Controls; DDC LESS BOARD"},{"code_sequence":"6","code_value":"K","code_description":"Voltage; 460/60/3"},{"code_sequence":"7","code_value":"Y","code_description":"Cabinet Height; NONE"},{"code_sequence":"8","code_value":"R","code_description":"Return Air; RIGHT HAND RETURN AIR"},{"code_sequence":"9","code_value":"S","code_description":"Discharge Air; STRAIGHT DISCHARGE"},{"code_sequence":"10","code_value":"01","code_description":"Blower Motor; STANDARD"},{"code_sequence":"11","code_value":"YY","code_description":"Disch. Grille/Cab. Type; NONE"},{"code_sequence":"12","code_value":"A","code_description":"Construction Type; STANDARD"},{"code_sequence":"13","code_value":"C","code_description":"Water-Refrig Ht Exch Constr; Copper Inner/Steel Outer Tubes"},{"code_sequence":"14","code_value":"Y","code_description":"Heating Options; NONE"},{"code_sequence":"15","code_value":"YY","code_description":"Dehumidification; NONE"},{"code_sequence":"16","code_value":"Y","code_description":"Piping Hand; NONE"},{"code_sequence":"17","code_value":"YYY","code_description":"Thermostat Control; NONE"},{"code_sequence":"18","code_value":"YYY","code_description":"Night Control; NONE"},{"code_sequence":"19","code_value":"YYY","code_description":"Desuperheater; NONE"},{"code_sequence":"20","code_value":"A","code_description":"Refrigerant; 410A"},{"code_sequence":"21","code_value":"Y","code_description":"Power Connection; NONE"},{"code_sequence":"22","code_value":"YYY","code_description":"Cabinet Electrical; NONE"},{"code_sequence":"23","code_value":"Y","code_description":"Water Flow Control; NONE"},{"code_sequence":"24","code_value":"Y","code_description":"Color; NONE"},{"code_sequence":"25","code_value":"Y","code_description":"Outside Air; NONE"},{"code_sequence":"26","code_value":"C","code_description":"Agency Listing; ETL, CETL, ARI, MEA"},{"code_sequence":"27","code_value":"1","code_description":"Packaging; STANDARD"},{"code_sequence":"28","code_value":"Y","code_description":"Ext. Warranty; NONE"},{"code_sequence":"29","code_value":"2","code_description":"Product Style; Style 2"}]'
                              , Tag__c = 'x'
                              //, Device_ID__c = '111.222.333.444'
                              , SIM_Card_ICCID__c = '11111'
                              , Format_Number__c = '22222'
                              , Commissioned__c = false
                              , IE_ID__c = null
                              , IE_Sync_Status__c = 'Pending'
                              , IE_Asset__c = true
                              );
        insert asset;
        
        Asset asset1 = new Asset(Name = 'test'
                              , AccountId = a.Id
							  , Asset_Address__c = addr.Id
                              , SerialNumber='123Test1'
                              , Code_String_Breakdown__c = '[{"code_sequence":"1","code_value":"W","code_description":"Product Category; WATER SOURCE HEAT PUMP"},{"code_sequence":"2","code_value":"CCH","code_description":"Unit Type; CEILING MTD./STANDARD RANGE"},{"code_sequence":"3","code_value":"2","code_description":"Design series; 2ND DESIGN"},{"code_sequence":"4","code_value":"030","code_description":"Unit Size; 30,000 BTUH NOMINAL COOLING"},{"code_sequence":"5","code_value":"E","code_description":"Controls; DDC LESS BOARD"},{"code_sequence":"6","code_value":"K","code_description":"Voltage; 460/60/3"},{"code_sequence":"7","code_value":"Y","code_description":"Cabinet Height; NONE"},{"code_sequence":"8","code_value":"R","code_description":"Return Air; RIGHT HAND RETURN AIR"},{"code_sequence":"9","code_value":"S","code_description":"Discharge Air; STRAIGHT DISCHARGE"},{"code_sequence":"10","code_value":"01","code_description":"Blower Motor; STANDARD"},{"code_sequence":"11","code_value":"YY","code_description":"Disch. Grille/Cab. Type; NONE"},{"code_sequence":"12","code_value":"A","code_description":"Construction Type; STANDARD"},{"code_sequence":"13","code_value":"C","code_description":"Water-Refrig Ht Exch Constr; Copper Inner/Steel Outer Tubes"},{"code_sequence":"14","code_value":"Y","code_description":"Heating Options; NONE"},{"code_sequence":"15","code_value":"YY","code_description":"Dehumidification; NONE"},{"code_sequence":"16","code_value":"Y","code_description":"Piping Hand; NONE"},{"code_sequence":"17","code_value":"YYY","code_description":"Thermostat Control; NONE"},{"code_sequence":"18","code_value":"YYY","code_description":"Night Control; NONE"},{"code_sequence":"19","code_value":"YYY","code_description":"Desuperheater; NONE"},{"code_sequence":"20","code_value":"A","code_description":"Refrigerant; 410A"},{"code_sequence":"21","code_value":"Y","code_description":"Power Connection; NONE"},{"code_sequence":"22","code_value":"YYY","code_description":"Cabinet Electrical; NONE"},{"code_sequence":"23","code_value":"Y","code_description":"Water Flow Control; NONE"},{"code_sequence":"24","code_value":"Y","code_description":"Color; NONE"},{"code_sequence":"25","code_value":"Y","code_description":"Outside Air; NONE"},{"code_sequence":"26","code_value":"C","code_description":"Agency Listing; ETL, CETL, ARI, MEA"},{"code_sequence":"27","code_value":"1","code_description":"Packaging; STANDARD"},{"code_sequence":"28","code_value":"Y","code_description":"Ext. Warranty; NONE"},{"code_sequence":"29","code_value":"2","code_description":"Product Style; Style 2"}]'
                              , Tag__c = 'x'
                              //, Device_ID__c = '111.222.333.444'
                              , SIM_Card_ICCID__c = '11111'
                              , Format_Number__c = '22222'
                              , Commissioned__c = false
                              , IE_ID__c = '123'
                              , IE_Sync_Status__c = 'Pending'
                              , IE_Asset__c = true);
        insert asset1;
        

        
        //Create Asset Address
        Asset_Address__c aa = new Asset_Address__c(Asset__c = asset.Id
                                                  ,Address__c = addr.Id
                                                  ,Building_Identifier__c = '123');
        insert aa;
        
        Asset_Address__c aa2 = new Asset_Address__c(Asset__c = asset1.Id
                                                  ,Address__c = addr.Id
                                                  ,Building_Identifier__c = '123');
        insert aa2;


		Account_Address__c aa1 = new Account_Address__c(Account__c = a.Id
                                                       ,Address__c = addr.Id
                                                       ,Primary_Mail_To__c = true);
        insert aa1;

        
		// Create subscriptions
        Subscription__c sub = new Subscription__c(Type__c = 'CustomRead'
                                                , Start_Date__c = System.today()
                                                , End_Date__c = System.today() + 1
                                                , Buyer_ID__c = a.Id
                                                , Asset__c = asset1.Id
                                                , IE_ID__c = '123'
                                                , IE_Updated_Date__c = System.now()
                                                , IE_Sync_Status__c = 'Pending'
                                                , IE_Subscription__c = true);
        insert sub;
        
        Subscription__c sub2 = new Subscription__c(Type__c = 'TechReadWrite'
                                                , Start_Date__c = System.today()
                                                , End_Date__c = System.today() + 1
                                                , Buyer_ID__c = a.Id
                                                , Asset__c = asset1.Id
                                                , IE_ID__c = null
                                                , IE_Updated_Date__c = System.now()
                                                , IE_Sync_Status__c = 'Pending'
                                                , IE_Subscription__c = true);
        insert sub2;
        
		// Create Contacts
        Contact c = new Contact(FirstName = 'x'
                              , LastName = 'y'
                              , Middle_Name__c = 'z'
                              , Email = 'tester@daikintest.com'
                              , Phone = '3334445555'
                              , MobilePhone = '4445556666'
                              , IE_Username__c = 'tester@daikintest.com'
                              , IE_Accessed__c = true
                              , IE_Inactive__c = false
                              , IE_Updated_Date__c = null
                              , IE_ID__c = null
                              , IE_Contact__c = true
                              , IE_Sync_Status__c = 'Pending');
        insert c;
        
        Contact_Address__c ca1 = new Contact_Address__c(Contact__c = c.Id
                                                    ,Address__c = addr.Id
                                                    ,Primary_Mail_To__c = true);
        insert ca1;
        
        Contact_Subscription__c cs1 = new Contact_Subscription__c(Contact__c = c.Id
                                                                 ,Subscription__c = sub.Id
                                                                 ,Asset__c = asset1.Id 
                                                                 ,Role__c = 'Customer');
        insert cs1;
        
        Contact c2 = new Contact(FirstName = 'x'
                              , LastName = 'y'
                              , Middle_Name__c = 'z'
                              , Email = 'tester@daikintest.com'
                              , Phone = '3334445555'
                              , MobilePhone = '4445556666'
                              , IE_Username__c = 'tester@daikintest.com'
                              , IE_Accessed__c = true
                              , IE_Inactive__c = false
                              , IE_Updated_Date__c = System.now()
                              , IE_ID__c = '123456'
                              , IE_Contact__c = true
                              , IE_Sync_Status__c = 'Pending');
        insert c2;
        
        Contact_Subscription__c cs2 = new Contact_Subscription__c(Contact__c = c2.Id
                                                                 ,Subscription__c = sub.Id
                                                                 ,Asset__c = asset1.Id
                                                                 ,Role__c = 'Customer');
        insert cs2;
        
        Contact_Address__c ca2 = new Contact_Address__c(Contact__c = c2.Id
                                                        ,Address__c = addr.Id
                                                        ,Primary_Mail_To__c = true);
        insert ca2;
        
        
        
        Test.startTest();
        // Force an unsuccessful http response status code
        Batch_Sync_IE_Individual.crash_TestByResponseStatusCode = true;
        Batch_Sync_IE_Subscription.crash_TestByResponseStatusCode = true;
		Batch_Sync_IE_Unit.crash_TestByResponseStatusCode = true;
		Batch_Sync_IE_Organization.crash_TestByResponseStatusCode = true;

        Database.ExecuteBatch(new Batch_Sync_IE_Unit('Pending'));
        Test.stopTest();
        
    }


	static testMethod void testSyncUnits_MissingAssetAddress() {
        // Create Asset
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;

		//Create Address
        Address__c addr = new Address__c(Address_Line_1__c = 'x1'
                                        ,Address_Line_2__c = 'x2'
                                        ,Address_Line_3__c = 'x3'
                                        ,Address_Line_4__c = 'x4'
                                        ,City__c = 'New York'
                                        ,State_Province__c = 'New York'
                                        ,Country__c = 'United States'
                                        //,State_Province__c = 'NY'
                                        ,Postal_Code__c = '11111'
                                        ,IE_ID__c  = 'x'
                                        ,IE_Address__c = true
                                        ,IE_Updated_Date__c = System.Now());
        
        insert addr;


		// Create Accounts
        Account a = new Account(Name = 'Test'
                              , IE_Sync_Status__c = 'Pending'
                              , IE_ID__c = '123'
                              , IE_Account__c = true
							  , Physical_Address__c = addr.Id
                              );
        insert a;

        map<String, Id> RecordTypeNameMap = new map<String, Id>();
        for(RecordType rt : [Select Name, SobjectType, Id 
                               from RecordType 
                              where Name in ('TRC', 'Address', 'SFDC Integration' )])
        {
            RecordTypeNameMap.put(rt.Name+'-'+rt.SobjectType, rt.Id);
        }
        
        IE_Service_Configuration__c ie = new IE_Service_Configuration__c();
        ie.Account_RecordType__c = RecordTypeNameMap.get('TRC-Account');
        ie.Address_RecordType__c = RecordTypeNameMap.get('Address-Address__c');
        ie.Contact_RecordType__c = RecordTypeNameMap.get('SFDC Integration-Contact');
        ie.Unit_Record_Type__c = '';
        ie.DaikinAccountId__c = a.Id;
        ie.endpoint__c = 'http://daikin-iep-service-qa.cloudapp.net/SalesforceIntegration.svc';
        ie.IndividualService__c = '/Individual';
        ie.OrganizationService__c = '/Organization';
        ie.username__c = 'xxx';
        ie.password__c = 'yyy';
        ie.SubscriptionService__c = '/Subscription';
        ie.UnitService__c = '/Unit';
        
        insert ie;
        
        List<IE_Integration_Field_Set__c> fieldList = new List<IE_Integration_Field_Set__c>{new IE_Integration_Field_Set__c(Name='Account', Field_List__c=('Record_Usage__c'))
                                                                                           ,new IE_Integration_Field_Set__c(Name='Contact', Field_List__c=('Record_Usage__c'))
                                                                                           ,new IE_Integration_Field_Set__c(Name='Address__c', Field_List__c=('Record_Usage__c'))};
        
        insert fieldList;
        
        Account a2 = new Account(Name = 'Test2'
                              , IE_Sync_Status__c = 'Pending'
                              , IE_Account__c = true
							  , Physical_Address__c = addr.Id
                              );
        insert a2;
        

		// Create Assets
        
        Asset asset1 = new Asset(Name = 'test'
                              , AccountId = a.Id
							  //, Asset_Address__c = addr.Id
                              , SerialNumber='123Test1'
                              , Code_String_Breakdown__c = '[{"code_sequence":"1","code_value":"W","code_description":"Product Category; WATER SOURCE HEAT PUMP"},{"code_sequence":"2","code_value":"CCH","code_description":"Unit Type; CEILING MTD./STANDARD RANGE"},{"code_sequence":"3","code_value":"2","code_description":"Design series; 2ND DESIGN"},{"code_sequence":"4","code_value":"030","code_description":"Unit Size; 30,000 BTUH NOMINAL COOLING"},{"code_sequence":"5","code_value":"E","code_description":"Controls; DDC LESS BOARD"},{"code_sequence":"6","code_value":"K","code_description":"Voltage; 460/60/3"},{"code_sequence":"7","code_value":"Y","code_description":"Cabinet Height; NONE"},{"code_sequence":"8","code_value":"R","code_description":"Return Air; RIGHT HAND RETURN AIR"},{"code_sequence":"9","code_value":"S","code_description":"Discharge Air; STRAIGHT DISCHARGE"},{"code_sequence":"10","code_value":"01","code_description":"Blower Motor; STANDARD"},{"code_sequence":"11","code_value":"YY","code_description":"Disch. Grille/Cab. Type; NONE"},{"code_sequence":"12","code_value":"A","code_description":"Construction Type; STANDARD"},{"code_sequence":"13","code_value":"C","code_description":"Water-Refrig Ht Exch Constr; Copper Inner/Steel Outer Tubes"},{"code_sequence":"14","code_value":"Y","code_description":"Heating Options; NONE"},{"code_sequence":"15","code_value":"YY","code_description":"Dehumidification; NONE"},{"code_sequence":"16","code_value":"Y","code_description":"Piping Hand; NONE"},{"code_sequence":"17","code_value":"YYY","code_description":"Thermostat Control; NONE"},{"code_sequence":"18","code_value":"YYY","code_description":"Night Control; NONE"},{"code_sequence":"19","code_value":"YYY","code_description":"Desuperheater; NONE"},{"code_sequence":"20","code_value":"A","code_description":"Refrigerant; 410A"},{"code_sequence":"21","code_value":"Y","code_description":"Power Connection; NONE"},{"code_sequence":"22","code_value":"YYY","code_description":"Cabinet Electrical; NONE"},{"code_sequence":"23","code_value":"Y","code_description":"Water Flow Control; NONE"},{"code_sequence":"24","code_value":"Y","code_description":"Color; NONE"},{"code_sequence":"25","code_value":"Y","code_description":"Outside Air; NONE"},{"code_sequence":"26","code_value":"C","code_description":"Agency Listing; ETL, CETL, ARI, MEA"},{"code_sequence":"27","code_value":"1","code_description":"Packaging; STANDARD"},{"code_sequence":"28","code_value":"Y","code_description":"Ext. Warranty; NONE"},{"code_sequence":"29","code_value":"2","code_description":"Product Style; Style 2"}]'
                              , Tag__c = 'x'
                              //, Device_ID__c = '111.222.333.444'
                              , SIM_Card_ICCID__c = '11111'
                              , Format_Number__c = '22222'
                              , Commissioned__c = false
                              , IE_ID__c = '123'
                              , IE_Sync_Status__c = 'Pending'
                              , IE_Asset__c = true);
        insert asset1;
        

        


		Account_Address__c aa1 = new Account_Address__c(Account__c = a.Id
                                                       ,Address__c = addr.Id
                                                       ,Primary_Mail_To__c = true);
        insert aa1;

        
		// Create subscriptions
        Subscription__c sub = new Subscription__c(Type__c = 'CustomRead'
                                                , Start_Date__c = System.today()
                                                , End_Date__c = System.today() + 1
                                                , Buyer_ID__c = a.Id
                                                , Asset__c = asset1.Id
                                                , IE_ID__c = '123'
                                                , IE_Updated_Date__c = System.now()
                                                , IE_Sync_Status__c = 'Pending'
                                                , IE_Subscription__c = true);
        insert sub;
        
        Subscription__c sub2 = new Subscription__c(Type__c = 'TechReadWrite'
                                                , Start_Date__c = System.today()
                                                , End_Date__c = System.today() + 1
                                                , Buyer_ID__c = a.Id
                                                , Asset__c = asset1.Id
                                                , IE_ID__c = null
                                                , IE_Updated_Date__c = System.now()
                                                , IE_Sync_Status__c = 'Pending'
                                                , IE_Subscription__c = true);
        insert sub2;
        
		// Create Contacts
        Contact c = new Contact(FirstName = 'x'
                              , LastName = 'y'
                              , Middle_Name__c = 'z'
                              , Email = 'tester@daikintest.com'
                              , Phone = '3334445555'
                              , MobilePhone = '4445556666'
                              , IE_Username__c = 'tester@daikintest.com'
                              , IE_Accessed__c = true
                              , IE_Inactive__c = false
                              , IE_Updated_Date__c = null
                              , IE_ID__c = null
                              , IE_Contact__c = true
                              , IE_Sync_Status__c = 'Pending');
        insert c;
        
        Contact_Address__c ca1 = new Contact_Address__c(Contact__c = c.Id
                                                    ,Address__c = addr.Id
                                                    ,Primary_Mail_To__c = true);
        insert ca1;
        
        Contact_Subscription__c cs1 = new Contact_Subscription__c(Contact__c = c.Id
                                                                 ,Subscription__c = sub.Id
                                                                 ,Asset__c = asset1.Id 
                                                                 ,Role__c = 'Customer');
        insert cs1;
        
        Contact c2 = new Contact(FirstName = 'x'
                              , LastName = 'y'
                              , Middle_Name__c = 'z'
                              , Email = 'tester@daikintest.com'
                              , Phone = '3334445555'
                              , MobilePhone = '4445556666'
                              , IE_Username__c = 'tester@daikintest.com'
                              , IE_Accessed__c = true
                              , IE_Inactive__c = false
                              , IE_Updated_Date__c = System.now()
                              , IE_ID__c = '123456'
                              , IE_Contact__c = true
                              , IE_Sync_Status__c = 'Pending');
        insert c2;
        
        Contact_Subscription__c cs2 = new Contact_Subscription__c(Contact__c = c2.Id
                                                                 ,Subscription__c = sub.Id
                                                                 ,Asset__c = asset1.Id
                                                                 ,Role__c = 'Customer');
        insert cs2;
        
        Contact_Address__c ca2 = new Contact_Address__c(Contact__c = c2.Id
                                                        ,Address__c = addr.Id
                                                        ,Primary_Mail_To__c = true);
        insert ca2;
        
        
        
        Test.startTest();
        Database.ExecuteBatch(new Batch_Sync_IE_Unit('Pending'));
        Test.stopTest();
        
    }



	static testMethod void testSyncUnits_OtherConstructor() {
        // Create Asset
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;

        Test.startTest();
		Date lastUpdatedDate = date.newInstance(1960, 1, 1);
		//calls the other constructor but no assets will be processed
        Database.ExecuteBatch(new Batch_Sync_IE_Unit('Pending', lastUpdatedDate));
        Test.stopTest();
        
    }


    
    static testmethod void testBatch_Sync_IE_Unit_Schedular(){    
      Test.startTest(); 
      //defien the CRON Expression
      String CRON_EXP;
      CRON_EXP = '0 0 2 * * ?';
      Batch_Sync_IE_Unit_Schedular s = new Batch_Sync_IE_Unit_Schedular();
      SchedulableContext sc;
      s.execute(sc);
      System.schedule('test-Batch_Sync_IE_Unit_Schedular', CRON_EXP, s);
      Test.stopTest();
   }
}