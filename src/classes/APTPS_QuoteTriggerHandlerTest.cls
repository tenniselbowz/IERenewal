@isTest
public class APTPS_QuoteTriggerHandlerTest {
    @testSetup
    Static  void setup(){
        
       
        Id rta   = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('North America Proposal').getRecordTypeId();
        
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
        List<Product2> proList = new List<Product2>();
        Product2 p = new Product2(Name = 'Boilers',Product_Category__c='VRV', isActive = true);
        Product2 p1 = new Product2(Name = 'Air Handler',Product_Category__c='Air Handler', isActive = true);
        Product2 p2 = new Product2(Name = 'AC Chiller',Product_Category__c='AC Chiller', isActive = true);
        Product2 p3 = new Product2(Name = 'WC Chiller',Product_Category__c='WC Chiller', isActive = true);
        Product2 p4 = new Product2(Name = 'Split Systems',Product_Category__c='Split Systems', isActive = true);
        Product2 p5 = new Product2(Name = 'Sump Pumps',Product_Category__c='Sump Pumps', isActive = true);
        Product2 p6 = new Product2(Name = 'Pumps - Boiler Feedwater',Product_Category__c='VRV', isActive = true);
        Product2 p7 = new Product2(Name = 'Pumps',Product_Category__c='VRV', isActive = true);
        Product2 p8 = new Product2(Name = 'Pumps - Horizontal Split Case',Product_Category__c='VRV', isActive = true);
        
        proList.add(p);
        proList.add(p1);
        proList.add(p2);
        proList.add(p3);
        proList.add(p4);
        proList.add(p5);
        proList.add(p6);
        proList.add(p7);
        proList.add(p8);
        insert proList;
        
        Pricebook2 stdPriceBook = new Pricebook2(Id = standardPricebookId, IsActive = true);
        upsert stdPricebook;
        
        list<Apttus_Proposal__Proposal__c> quoteList = new list<Apttus_Proposal__Proposal__c>();
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
        q.Apttus_Proposal__Primary__c = true;
        q.Approval_Status__c = 'Mgmt Approved';
        q.RecordTypeId = rta;
        
        quoteList.add(q);
        //insert q;
        system.debug('quote1 is : '+ q);
        Apttus_Proposal__Proposal__c q3 =  new Apttus_Proposal__Proposal__c(
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
            Bulk_Exchange_Rate__c=12, 
            Brand__c= 'Daikin', 
            Quote_Presentation_Currency__c ='USD', 
            Apttus_Proposal__Primary_Contact__c = c.id);
        q3.Apttus_Proposal__Primary__c = true;
        q3.Approval_Status__c = 'Mgmt Approved';
        q3.RecordTypeId = rta;
        q3.Included_Line_Item_Categories__c = 'Customer Scope Description AC Chiller';
        
        quoteList.add(q3);
        
        Apttus_Proposal__Proposal__c q2 =  new Apttus_Proposal__Proposal__c(
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
        q2.Apttus_Proposal__Primary__c = true;
        q2.Approval_Status__c = 'Approved';
        q2.RecordTypeId = rta;
        //  insert q2;
        quoteList.add(q2);
        system.debug('quote2 is : '+ q2);
        
        Apttus_Proposal__Proposal__c q4 =  new Apttus_Proposal__Proposal__c(
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
            Bulk_Exchange_Rate__c=123, 
            Brand__c= 'Daikin', 
            Quote_Presentation_Currency__c ='USD', 
            Apttus_Proposal__Primary_Contact__c = c.id);
        q4.Apttus_Proposal__Primary__c = true;
        q4.Approval_Status__c = 'Mgmt Approved';
        q4.RecordTypeId = rta;
      
        
        quoteList.add(q4);
        
          
        Apttus_Proposal__Proposal__c q5 =  new Apttus_Proposal__Proposal__c(
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
            Bulk_Exchange_Rate__c=18, 
            Brand__c= 'Daikin', 
            Quote_Presentation_Currency__c ='USD', 
            
            Apttus_Proposal__Primary_Contact__c = c.id);
        q5.Apttus_Proposal__Primary__c = true;
        q5.Approval_Status__c = 'Mgmt Approved';
        q5.RecordTypeId = rta;
        quoteList.add(q5);
        insert  quoteList;
        
      
        
    }
    @isTest
    public static void unitTest()
    {
        test.startTest();
        Apttus_Proposal__Proposal__c q = [select id,Estimated_Close_Date__c,Apttus_QPConfig__ConfigurationFinalizedDate__c,
                                          Apttus_Proposal__Primary__c,Apttus_Proposal__Opportunity__c,RecordTypeId
                                          ,Apttus_Proposal__Approval_Stage__c from Apttus_Proposal__Proposal__c 
                                          where Apttus_Proposal__Primary__c=true limit 1];
        
        Apttus_Proposal__Proposal__c q2 = [select id,Estimated_Close_Date__c,Apttus_QPConfig__ConfigurationFinalizedDate__c,
                                           Apttus_Proposal__Primary__c,Apttus_Proposal__Opportunity__c,RecordTypeId
                                           ,Apttus_Proposal__Approval_Stage__c from Apttus_Proposal__Proposal__c 
                                           where Approval_Status__c='Approved' limit 1];
        
        
        List<Apttus_Proposal__Proposal__c> quoteList = new List<Apttus_Proposal__Proposal__c>();
      
        
        
    
        quoteList.add(q);
        quoteList.add(q2);
        APTPS_QuoteTriggerHandler.makeOnlyPrimaryQuote(quoteList);
        APTPS_QuoteTriggerHandler apquoteTrig = new APTPS_QuoteTriggerHandler();
      //  APTPS_QuoteTriggerHandler.createQuoteLineItems(quoteList);
        APTPS_QuoteTriggerHandler.primaryQuoteUtility(quoteList);
        APTPS_QuoteTriggerHandler.insertAtleastOnePrimaryProposal(quoteList);
        APTPS_QuoteTriggerHandler.deleteDocLineItemsOfAcceptedQuotes(quoteList);
        APTPS_QuoteTriggerHandler.setQuoteDefaults(quoteList);
        APTPS_QuoteTriggerHandler.deleteOppLinesWithoutDSTIds(quoteList);
        
        APTPS_QuoteTriggerHandler.createNewClausesFromQuotes(quoteList);
        APTPS_QuoteTriggerHandler.updateOpportunitiesWithPricebook(quoteList);
        // APTPS_QuoteTriggerHandler.synchronizeOpportunityLineItems(quoteList, oldQuoteMap);
        for(Apttus_Proposal__Proposal__c qq :quoteList)
        {
            qq.Bulk_Exchange_Rate__c = 2;
            qq.Apttus_Proposal__Primary__c = true;
            
        }
        update quoteList;
        test.stopTest();
    }

    
   @isTest
    public static void unitTest2()
    {
        
       // Id rta   = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('North America Proposal').getRecordTypeId();
       
        RecordTypes__mdt rta = [select id,RecordTypeId__c from RecordTypes__mdt where DeveloperName='North_America_RecordType'];
 
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
        List<Product2> proList = new List<Product2>();
        Product2 p = new Product2(Name = 'Boilers',Product_Category__c='VRV', isActive = true);
        Product2 p1 = new Product2(Name = 'Air Handler',Product_Category__c='Air Handler', isActive = true);
        Product2 p2 = new Product2(Name = 'AC Chiller',Product_Category__c='AC Chiller', isActive = true);
        Product2 p3 = new Product2(Name = 'WC Chiller',Product_Category__c='WC Chiller', isActive = true);
        Product2 p4 = new Product2(Name = 'Split Systems',Product_Category__c='Split Systems', isActive = true);
        Product2 p5 = new Product2(Name = 'Sump Pumps',Product_Category__c='Sump Pumps', isActive = true);
        Product2 p6 = new Product2(Name = 'Pumps - Boiler Feedwater',Product_Category__c='VRV', isActive = true);
        Product2 p7 = new Product2(Name = 'Pumps',Product_Category__c='VRV', isActive = true);
        Product2 p8 = new Product2(Name = 'Pumps - Horizontal Split Case',Product_Category__c='VRV', isActive = true);
        
        proList.add(p);
        proList.add(p1);
        proList.add(p2);
        proList.add(p3);
        proList.add(p4);
        proList.add(p5);
        proList.add(p6);
        proList.add(p7);
        proList.add(p8);
        insert proList;
        
        Pricebook2 stdPriceBook = new Pricebook2(Id = standardPricebookId, IsActive = true);
        upsert stdPricebook;
       
        Pricebookentry testPbe = new Pricebookentry();
        testPbe.Product2Id = p.Id;
        testPbe.Pricebook2Id = Test.getStandardPricebookId();
        testPbe.UnitPrice = 1;
        testPbe.IsActive = TRUE;
        insert testPbe;
        
        List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
        OpportunityLineItem oppLine11 = new OpportunityLineItem();
        oppLine11.OpportunityId = o.Id;
        oppLine11.APTPS_Product_Id__c = p.Id;
        oppLine11.DST_ID__c = 'DST_ID__c';
        oppLine11.Quantity = 22.00;
        oppLine11.TotalPrice = 440;
        oppLine11.PriceBookEntryId = testPbe.id;
        oppLine11.Product2Id = p.id;
        oppLine11.IsAccessory__c = false;
        
        
        OpportunityLineItem oppLineLA11 = new OpportunityLineItem();
        oppLineLA11.OpportunityId = o.Id;
        oppLineLA11.APTPS_Product_Id__c = p.Id;
        oppLineLA11.DST_ID__c = 'DST_ID__c';
        oppLineLA11.Quantity = 11.00;
        oppLineLA11.TotalPrice = 220;
        oppLineLA11.PriceBookEntryId = testpbe.id;
        oppLineLA11.Product2Id = p.id;
        oppLineLA11.IsAccessory__c = false;
        
        
        
        oppLineItems.add(oppLineLA11);
        oppLineItems.add(oppLine11);   
        insert oppLineItems;
        
      
        list<Apttus_Proposal__Proposal__c> quoteList = new list<Apttus_Proposal__Proposal__c>();
        Map<Id,Apttus_Proposal__Proposal__c> oldmap = new Map<Id,Apttus_Proposal__Proposal__c>();
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
        q.RecordTypeId = rta.RecordTypeId__c;
         insert q;
        
        oldmap.put(q.id,q);
        quoteList.add(q);
       
        system.debug('quote1 is : '+ q);
        Apttus_Proposal__Proposal__c q3 =  new Apttus_Proposal__Proposal__c(
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
            Bulk_Exchange_Rate__c=123, 
            Brand__c= 'Daikin', 
            Quote_Presentation_Currency__c ='USD', 
            Apttus_Proposal__Primary_Contact__c = c.id);
        q3.Apttus_Proposal__Primary__c = false;
        q3.Approval_Status__c = 'Approved';
        q3.RecordTypeId = rta.RecordTypeId__c;
       
       insert q3;
         oldmap.put(q3.id,q3);
       quoteList.add(q3);
     
         
        list<Apttus_Proposal__Proposal_Line_Item__c> lineitemList = new list<Apttus_Proposal__Proposal_Line_Item__c>();
        Apttus_Proposal__Proposal_Line_Item__c qli = new Apttus_Proposal__Proposal_Line_Item__c(
            Apttus_Proposal__Unit_Price__c =122, 
            Apttus_QPConfig__ClassificationHierarchy__c = 'Equipment Daikin | Service | AC Scroll | Chiller',
            Apttus_QPConfig__ItemSequence__c =1, Apttus_QPConfig__LineNumber__c =1, 
            Apttus_Proposal__Quantity__c =2, Apttus_Proposal__Proposal__c =q.id,  
            Apttus_QPConfig__LineStatus__c = 'New',
            Apttus_Proposal__Product__c = p.id,
            Apttus_QPConfig__LineType__c = 'Product/Service');
        // insert qli;
        lineitemList.add(qli);
        Apttus_Proposal__Proposal_Line_Item__c qli22 = new Apttus_Proposal__Proposal_Line_Item__c(
            Apttus_Proposal__Unit_Price__c =122, 
            Apttus_QPConfig__ClassificationHierarchy__c = 'Equipment Daikin | Service | RTU | Chiller',
            Apttus_QPConfig__ItemSequence__c =1, Apttus_QPConfig__LineNumber__c =1, 
            Apttus_Proposal__Quantity__c =2, Apttus_Proposal__Proposal__c =q3.id,  
            Apttus_QPConfig__LineStatus__c = 'New',
            Apttus_Proposal__Product__c = p.id,
            Apttus_QPConfig__LineType__c = 'Product/Service');
        
        lineitemList.add(qli22);
        
        Apttus_Proposal__Proposal_Line_Item__c qli44 = new Apttus_Proposal__Proposal_Line_Item__c(
            Apttus_Proposal__Unit_Price__c =122, 
            Apttus_QPConfig__ClassificationHierarchy__c = 'Equipment Daikin | Service | AC Scroll | Chiller',
            Apttus_QPConfig__ItemSequence__c =1, Apttus_QPConfig__LineNumber__c =1, 
            Apttus_Proposal__Quantity__c =2, Apttus_Proposal__Proposal__c =q3.id,  
            Apttus_QPConfig__LineStatus__c = 'New',
            Apttus_Proposal__Product__c = p.id,
            Apttus_QPConfig__LineType__c = 'Product/Service');
        
        lineitemList.add(qli44);
        
        Apttus_Proposal__Proposal_Line_Item__c qli2 = new Apttus_Proposal__Proposal_Line_Item__c(
            Apttus_Proposal__Unit_Price__c = 134, 
            Apttus_QPConfig__ClassificationHierarchy__c = 'Equipment Daikin | Chiller | WC Scroll | ACZ',
            Apttus_QPConfig__ItemSequence__c =2,
            Apttus_QPConfig__LineNumber__c =2, 
            Apttus_Proposal__Quantity__c =1,
            Apttus_Proposal__Proposal__c =q.id,  
            Apttus_QPConfig__LineStatus__c = 'New',
            Apttus_Proposal__Product__c = p.id,
            Apttus_QPConfig__LineType__c = 'Product/Service');
        
        //insert qli2;
        lineitemList.add(qli2);
        
        Apttus_Proposal__Proposal_Line_Item__c qli3 = new Apttus_Proposal__Proposal_Line_Item__c(
            Apttus_Proposal__Unit_Price__c =122, 
            Apttus_QPConfig__ClassificationHierarchy__c = 'Equipment Daikin | AAH | WC Scroll - Heat Recovery | DCG',
            Apttus_QPConfig__ItemSequence__c =3, 
            Apttus_QPConfig__LineNumber__c =3, 
            Apttus_Proposal__Quantity__c =2, 
            Apttus_Proposal__Proposal__c =q.id, 
            Apttus_QPConfig__LineStatus__c = 'New', 
            Apttus_QPConfig__LineType__c = 'Product/Service');
        qli3.Apttus_Proposal__Product__c = p.id;
        //insert qli3;
        lineitemList.add(qli3);
        //update qli3;
        system.debug('qli' +qli3); 
        
        Apttus_Proposal__Proposal_Line_Item__c qli4 = new Apttus_Proposal__Proposal_Line_Item__c(
            Apttus_Proposal__Unit_Price__c = 134, 
            Apttus_QPConfig__ClassificationHierarchy__c = 'Equipment Daikin | AAH | AHU | CAH',
            Apttus_QPConfig__ItemSequence__c =4, Apttus_QPConfig__LineNumber__c =4, 
            Apttus_Proposal__Quantity__c =1, Apttus_Proposal__Proposal__c =q3.id, 
            Apttus_QPConfig__LineStatus__c = 'New', Apttus_QPConfig__LineType__c = 'Product/Service',
            Apttus_Proposal__Product__c = p3.id);
        //insert qli4;
        lineitemList.add(qli4);
        Apttus_Proposal__Proposal_Line_Item__c qli14 = new Apttus_Proposal__Proposal_Line_Item__c(
            Apttus_Proposal__Unit_Price__c = 1341, 
            Apttus_QPConfig__ClassificationHierarchy__c = 'Equipment Daikin | AAH | Condensing Unit | CAH',
            Apttus_QPConfig__ItemSequence__c =4, 
            Apttus_QPConfig__LineNumber__c =4, 
            Apttus_Proposal__Quantity__c =1, 
            Apttus_Proposal__Proposal__c =q.id, 
            Apttus_QPConfig__LineStatus__c = 'New', 
            Apttus_QPConfig__LineType__c = 'Product/Service', 
            Apttus_Proposal__Product__c = p.id);
        //insert qli14;
        lineitemList.add(qli14);
        Apttus_Proposal__Proposal_Line_Item__c qli5 = new Apttus_Proposal__Proposal_Line_Item__c(
            Apttus_Proposal__Unit_Price__c =122, 
            Apttus_QPConfig__ClassificationHierarchy__c = 'Equipment Daikin | Chiller | WC Scroll | WGZ',
            Apttus_QPConfig__ItemSequence__c =5,
            Apttus_QPConfig__LineNumber__c =5, 
            Apttus_Proposal__Quantity__c =2, 
            Apttus_Proposal__Proposal__c =q3.id, 
            Apttus_QPConfig__LineStatus__c = 'New', 
            Apttus_QPConfig__LineType__c = 'Product/Service');
        
        //insert qli5;
        lineitemList.add(qli5);
        insert lineitemList;
        
        map<Id, Apttus_Proposal__Proposal__c> mapquoteList = new map<Id, Apttus_Proposal__Proposal__c>();
       
         test.startTest();
      //  APTPS_QuoteTriggerHandler.createQuoteLineItems(quoteList);
        APTPS_QuoteTriggerHandler.primaryQuoteUtility(quoteList);
        APTPS_QuoteTriggerHandler.setQuoteDefaults(quoteList) ;  
        APTPS_QuoteTriggerHandler.saveOppLineItems(oppLineItems);
        APTPS_QuoteTriggerHandler.deleteOppLineItems(oppLineItems);
        APTPS_QuoteTriggerHandler.makeOnlyPrimaryQuote(quoteList);
        APTPS_QuoteTriggerHandler.getMapOfOpptyWithLineItems(quoteList);
        APTPS_QuoteTriggerHandler.deleteDocLineItemsOfAcceptedQuotes(quoteList);
        APTPS_QuoteTriggerHandler.updateOpportunitiesWithPricebook(quoteList);
        APTPS_QuoteTriggerHandler.insertAtleastOnePrimaryProposal(quoteList);
        
        for(Apttus_Proposal__Proposal__c qq : quoteList)
        {
            
           
            qq.Apttus_QPConfig__ConfigurationFinalizedDate__c = system.today()+55;
           
            mapquoteList.put(qq.id,qq);
            
        }
        update quoteList;
         for(Apttus_Proposal__Proposal__c qq1 : quoteList)
        {
              qq1.Apttus_Proposal__Approval_Stage__c= 'Accepted';
        }
         update quoteList;
       // APTPS_QuoteTriggerHandler.updateOpptyListWithStandardPriceBook(oppList);
        //APTPS_QuoteTriggerHandler.concatenateTKClauses(quoteList, oldmap);
        APTPS_QuoteTriggerHandler.deleteOppLineItemsWithDST(quoteList, oldmap);
        APTPS_QuoteTriggerHandler.getQuotsForSyncOperation(quoteList, oldmap);
        APTPS_QuoteTriggerHandler.updateQuotesToNotPrimary(quoteList, oldmap);
        APTPS_QuoteTriggerHandler.syncOldQuotesIfOpportunitiesChanged(quoteList, oldMap);
        APTPS_QuoteTriggerHandler.synchronizeOpportunityLineItems(quoteList, oldMap);
        APTPS_QuoteTriggerHandler.updateAtleastOnePrimaryProposal(quoteList, oldmap);
        APTPS_QuoteTriggerHandler.concatenateTKClauses(mapquoteList, oldmap);
       // APTPS_QuoteTriggerHandler.syncQuotetoOpportunity(mapquoteList, oldmap);
        test.stopTest();
        
    }
       
    
}