@isTest
public class QuoteProposalTriggerHandlerTest {
    @testsetup
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
        Product2 p = new Product2(Name = 'Boilers',Product_Category__c='Customer Scope Description Boiler', isActive = true);
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
        q.Apttus_Proposal__Primary__c = false;
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
        q3.Apttus_Proposal__Primary__c = false;
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
   public static void updateAuthorizationTest()
    {
        List<Apttus_Proposal__Proposal__c> quoteList = new List<Apttus_Proposal__Proposal__c>([select id,Estimated_Close_Date__c,Apttus_QPConfig__ConfigurationFinalizedDate__c,Apttus_Proposal__Opportunity__c,
                                          RecordTypeId,Apttus_Proposal__Primary__c,Apttus_Proposal__Approval_Stage__c
                                          from  Apttus_Proposal__Proposal__c where Approval_Status__c = 'Approved']);
        
        if(!quoteList.isEmpty() &&quoteList.size() > 0)
        {
            Id user1 = userinfo.getUserId();
            Approval.ProcessSubmitRequest req1 =  new Approval.ProcessSubmitRequest();
           //req1.setProcessDefinitionNameOrId('Credit Approval Process');
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(quoteList[0].id);
            // Submit on behalf of a specific submitter
            req1.setSubmitterId(user1); 
            // Submit the record to specific process and skip the criteria evaluation
            // req1.setProcessDefinitionNameOrId('Update Opportunity Stage to Closed Won');
          //  req1.setSkipEntryCriteria(true);
            // Submit the approval request for the account
            Approval.ProcessResult result = Approval.process(req1);   
            
            // Verify the result
        System.assert(result.isSuccess());
        System.assertEquals('Approved', result.getInstanceStatus(), 'Instance Status'+result.getInstanceStatus());
        }
    }
     
   /* public static void updateAuthorizationTest2()
    {
        List<Apttus_Proposal__Proposal__c> quoteList = new List<Apttus_Proposal__Proposal__c>([select id,Estimated_Close_Date__c,Apttus_QPConfig__ConfigurationFinalizedDate__c,Apttus_Proposal__Opportunity__c,
                                          RecordTypeId,Apttus_Proposal__Primary__c,Apttus_Proposal__Approval_Stage__c
                                          from  Apttus_Proposal__Proposal__c where Approval_Status__c = 'Approved']);
        
        if(!quoteList.isEmpty() &&quoteList.size() > 0)
        {         
              Id user1 = userinfo.getUserId();
            Approval.ProcessSubmitRequest req2 =  new Approval.ProcessSubmitRequest();
            req2.setProcessDefinitionNameOrId('DM_Auto_Approval');
            req2.setComments('Submitting request for approval.');
            req2.setObjectId(quoteList[0].id);
            req2.setSubmitterId(user1); 
             req2.setSkipEntryCriteria(true);
            Approval.ProcessResult result2 = Approval.process(req2); 
        } 
    }
   public static void updateAuthorizationTest3()
    {
        List<Apttus_Proposal__Proposal__c> quoteList = new List<Apttus_Proposal__Proposal__c>([select id,Estimated_Close_Date__c,Apttus_QPConfig__ConfigurationFinalizedDate__c,Apttus_Proposal__Opportunity__c,
                                          RecordTypeId,Apttus_Proposal__Primary__c,Apttus_Proposal__Approval_Stage__c
                                          from  Apttus_Proposal__Proposal__c where Approval_Status__c = 'Approved']);
        
        if(!quoteList.isEmpty() &&quoteList.size() > 0)
        {       
               Id user1 = userinfo.getUserId();
            Approval.ProcessSubmitRequest req3 =  new Approval.ProcessSubmitRequest();
            req3.setProcessDefinitionNameOrId('NA_Quote_DM_Auto_Approval_Solunus_v3');
            req3.setComments('Submitting request for approval.');
            req3.setObjectId(quoteList[0].id);
            req3.setSubmitterId(user1); 
            Approval.ProcessResult result3 = Approval.process(req3);  
        }
    }
   public static void updateAuthorizationTest4()
    {
        List<Apttus_Proposal__Proposal__c> quoteList = new List<Apttus_Proposal__Proposal__c>([select id,Estimated_Close_Date__c,Apttus_QPConfig__ConfigurationFinalizedDate__c,Apttus_Proposal__Opportunity__c,
                                          RecordTypeId,Apttus_Proposal__Primary__c,Apttus_Proposal__Approval_Stage__c
                                          from  Apttus_Proposal__Proposal__c where Approval_Status__c = 'Approved']);
        
        if(!quoteList.isEmpty() &&quoteList.size() > 0)
        {          
               Id user1 = userinfo.getUserId();
            Approval.ProcessSubmitRequest req4 =  new Approval.ProcessSubmitRequest();
            req4.setProcessDefinitionNameOrId('Bluewolf_NA_Quote_Approval_Process_R12_7');
            req4.setComments('Submitting request for approval.');
            req4.setObjectId(quoteList[0].id);
            req4.setSubmitterId(user1); 
            Approval.ProcessResult result4 = Approval.process(req4);  
        }
    }
     public static void updateAuthorizationTest5()
    {
        List<Apttus_Proposal__Proposal__c> quoteList = new List<Apttus_Proposal__Proposal__c>([select id,Estimated_Close_Date__c,Apttus_QPConfig__ConfigurationFinalizedDate__c,Apttus_Proposal__Opportunity__c,
                                          RecordTypeId,Apttus_Proposal__Primary__c,Apttus_Proposal__Approval_Stage__c
                                          from  Apttus_Proposal__Proposal__c where Approval_Status__c = 'Approved']);
        
        if(!quoteList.isEmpty() &&quoteList.size() > 0)
        {      
               Id user1 = userinfo.getUserId();
           Approval.ProcessSubmitRequest req5 =  new Approval.ProcessSubmitRequest();
            req5.setProcessDefinitionNameOrId('Credit_Approval_Process');
            req5.setComments('Submitting request for approval.');
            req5.setObjectId(quoteList[0].id);
            req5.setSubmitterId(user1); 
            Approval.ProcessResult result5 = Approval.process(req5);  
        }  
       
    }  
*/
   
    @isTest
    public static void concatenateTKClausesTest()
    {
        
        test.startTest();
        Apttus_Proposal__Proposal__c q = [select id,Estimated_Close_Date__c,Apttus_QPConfig__ConfigurationFinalizedDate__c,Apttus_Proposal__Opportunity__c
                                          ,RecordTypeId,Apttus_Proposal__Primary__c,Apttus_Proposal__Approval_Stage__c
                                          from  Apttus_Proposal__Proposal__c where Approval_Status__c = 'Mgmt Approved' 
                                          limit 1];
        Apttus_Proposal__Proposal__c q2 = [select id,Estimated_Close_Date__c,Apttus_QPConfig__ConfigurationFinalizedDate__c,Apttus_Proposal__Opportunity__c,
                                           RecordTypeId,Apttus_Proposal__Primary__c,Apttus_Proposal__Approval_Stage__c
                                           from  Apttus_Proposal__Proposal__c where Approval_Status__c = 'Approved' 
                                           limit 1];
        Apttus_Proposal__Proposal__c q3 = [select id,Estimated_Close_Date__c,Apttus_QPConfig__ConfigurationFinalizedDate__c,Apttus_Proposal__Opportunity__c,
                                           RecordTypeId,Apttus_Proposal__Primary__c,Apttus_Proposal__Approval_Stage__c,Included_Line_Item_Categories__c
                                           from  Apttus_Proposal__Proposal__c where Approval_Status__c = 'Mgmt Approved' and Bulk_Exchange_Rate__c=12
                                           limit 1];
        
        List<Apttus_Proposal__Proposal__c> quoteList = new List<Apttus_Proposal__Proposal__c>();
        quoteList.add(q);
        quoteList.add(q2);
        quoteList.add(q3);
        
        Product2 p = new Product2(Name = 'Boilers',Product_Category__c='VRV', isActive = true);
        insert p;
        
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
        insert qli2;
        
        q.Apttus_QPConfig__ConfigurationFinalizedDate__c = system.today()+55;
        // update q;
        
        Apttus_Proposal__Proposal_Line_Item__c qli22 = new Apttus_Proposal__Proposal_Line_Item__c(
            Apttus_Proposal__Unit_Price__c = 134, 
            Apttus_QPConfig__ClassificationHierarchy__c = 'Equipment Daikin | Chiller | RTU | ACZ',
            Apttus_QPConfig__ItemSequence__c =2,
            Apttus_QPConfig__LineNumber__c =2, 
            Apttus_Proposal__Quantity__c =1,
            Apttus_Proposal__Proposal__c =q2.id,  
            Apttus_QPConfig__LineStatus__c = 'New',
            Apttus_Proposal__Product__c = p.id,
            Apttus_QPConfig__LineType__c = 'Product/Service');
        insert qli22;
        q2.Apttus_QPConfig__ConfigurationFinalizedDate__c = system.today()+55;
        // update q2;
        
        Apttus_Proposal__Proposal_Line_Item__c qli222 = new Apttus_Proposal__Proposal_Line_Item__c(
            Apttus_Proposal__Unit_Price__c = 134, 
            Apttus_QPConfig__ClassificationHierarchy__c = 'Equipment Daikin | Chiller | AHU | ACZ',
            Apttus_QPConfig__ItemSequence__c =2,
            Apttus_QPConfig__LineNumber__c =2, 
            Apttus_Proposal__Quantity__c =1,
            Apttus_Proposal__Proposal__c =q3.id,  
            Apttus_QPConfig__LineStatus__c = 'New',
            Apttus_Proposal__Product__c = p.id,
            Apttus_QPConfig__LineType__c = 'Product/Service');
        insert qli222;
        
        q3.Apttus_QPConfig__ConfigurationFinalizedDate__c = system.today()+55;
        // update q3;
        
        Apttus_Proposal__Proposal_Line_Item__c qli2222 = new Apttus_Proposal__Proposal_Line_Item__c(
            Apttus_Proposal__Unit_Price__c = 134, 
            Apttus_QPConfig__ClassificationHierarchy__c = 'Equipment Daikin | Chiller | Split system AH | ACZ',
            Apttus_QPConfig__ItemSequence__c =2,
            Apttus_QPConfig__LineNumber__c =2, 
            Apttus_Proposal__Quantity__c =1,
            Apttus_Proposal__Proposal__c =q3.id,  
            Apttus_QPConfig__LineStatus__c = 'New',
            Apttus_Proposal__Product__c = p.id,
            Apttus_QPConfig__LineType__c = 'Product/Service');
        insert qli2222;
        for(Apttus_Proposal__Proposal__c qq: quoteList)
        {
            qq.Apttus_QPConfig__ConfigurationFinalizedDate__c = system.today()+55;
        }
         update quoteList;
        
        test.stopTest();
        
    }
    
    @isTest
    public static void concatenateTKClausesTest1()
    {
        Apttus_Proposal__Proposal__c q = [select id,Estimated_Close_Date__c,Apttus_QPConfig__ConfigurationFinalizedDate__c,Apttus_Proposal__Opportunity__c
                                          ,RecordTypeId,Apttus_Proposal__Primary__c,Apttus_Proposal__Approval_Stage__c
                                          from  Apttus_Proposal__Proposal__c where Approval_Status__c = 'Mgmt Approved' 
                                          limit 1];
        
        Product2 p = [select id from Product2 where Name='Boilers' AND Product_Category__c='Customer Scope Description Boiler' limit 1];
        
        
        Apttus_Proposal__Proposal_Line_Item__c qli2 = new Apttus_Proposal__Proposal_Line_Item__c(
            Apttus_Proposal__Unit_Price__c = 134, 
            Apttus_QPConfig__ClassificationHierarchy__c = 'Equipment Daikin | Chiller | AC Scroll | ACZ',
            Apttus_QPConfig__ItemSequence__c =2,
            Apttus_QPConfig__LineNumber__c =2, 
            Apttus_Proposal__Quantity__c =1,
            Apttus_Proposal__Proposal__c =q.id,  
            Apttus_QPConfig__LineStatus__c = 'New',
            Apttus_Proposal__Product__c = p.id,
            Apttus_QPConfig__LineType__c = 'Product/Service');
        insert qli2;
        
        q.Apttus_QPConfig__ConfigurationFinalizedDate__c = system.today()+55;
        update q;
    }
    @isTest
    public static void concatenateTKClausesTest2()
    {
        Apttus_Proposal__Proposal__c q = [select id,Estimated_Close_Date__c,Apttus_QPConfig__ConfigurationFinalizedDate__c,Apttus_Proposal__Opportunity__c
                                          ,RecordTypeId
                                          from  Apttus_Proposal__Proposal__c where Approval_Status__c = 'Mgmt Approved' and Bulk_Exchange_Rate__c=12
                                          limit 1];
        
        Product2 p = new Product2(Name = 'Boilers',Product_Category__c='VRV', isActive = true);
        
        Apttus_Proposal__Proposal_Line_Item__c qli2 = new Apttus_Proposal__Proposal_Line_Item__c(
            Apttus_Proposal__Unit_Price__c = 134, 
            Apttus_QPConfig__ClassificationHierarchy__c = 'Equipment Daikin | Chiller | Split system AH | ACZ',
            Apttus_QPConfig__ItemSequence__c =2,
            Apttus_QPConfig__LineNumber__c =2, 
            Apttus_Proposal__Quantity__c =1,
            Apttus_Proposal__Proposal__c =q.id,  
            Apttus_QPConfig__LineStatus__c = 'New',
            Apttus_Proposal__Product__c = p.id,
            Apttus_QPConfig__LineType__c = 'Product/Service');
        insert qli2;
        
        q.Apttus_QPConfig__ConfigurationFinalizedDate__c = system.today()+55;
        update q;
        
        
        
        
    }
    @isTest
    public static void concatenateTKClausesTest3()
    {
        Apttus_Proposal__Proposal__c q = [select id,Estimated_Close_Date__c,Apttus_QPConfig__ConfigurationFinalizedDate__c,Apttus_Proposal__Opportunity__c
                                          ,RecordTypeId
                                          from  Apttus_Proposal__Proposal__c where Approval_Status__c = 'Mgmt Approved' and Bulk_Exchange_Rate__c=12
                                          limit 1];
        
        Apttus_Proposal__Proposal__c q2 = [select id,Estimated_Close_Date__c,Apttus_QPConfig__ConfigurationFinalizedDate__c,Apttus_Proposal__Opportunity__c,
                                           RecordTypeId,Apttus_Proposal__Primary__c,Apttus_Proposal__Approval_Stage__c
                                           from  Apttus_Proposal__Proposal__c where Approval_Status__c = 'Approved' 
                                           limit 1];
        Apttus_Proposal__Proposal__c q3 = [select id,Estimated_Close_Date__c,Apttus_QPConfig__ConfigurationFinalizedDate__c,Apttus_Proposal__Opportunity__c,
                                           RecordTypeId,Apttus_Proposal__Primary__c,Apttus_Proposal__Approval_Stage__c,Included_Line_Item_Categories__c
                                           from  Apttus_Proposal__Proposal__c where Approval_Status__c = 'Mgmt Approved' and Bulk_Exchange_Rate__c=123
                                           limit 1];
        
        Product2 p = new Product2(Name = 'Boilers',Product_Category__c='VRV', isActive = true);
        
        List<Product2> proList = new List<Product2>();
        Product2 p1 = new Product2(Name = 'Air Handler',Product_Category__c='Air Handler', isActive = true);
        Product2 p2 = new Product2(Name = 'AC Chiller',Product_Category__c='AC Chiller', isActive = true);
        Product2 p3 = new Product2(Name = 'WC Chiller',Product_Category__c='WC Chiller', isActive = true);
        Product2 p4 = new Product2(Name = 'Split Systems',Product_Category__c='Split Systems', isActive = true);
        Product2 p5 = new Product2(Name = 'Sump Pumps',Product_Category__c='Sump Pumps', isActive = true);
         Product2 p6 = new Product2(Name = 'Boilers',Product_Category__c='Customer Scope Description Boiler', isActive = true);
       
        proList.add(p);
        proList.add(p1);
        proList.add(p2);
        proList.add(p3);
        proList.add(p4);
        proList.add(p5);
         proList.add(p6);
        insert proList;
        test.startTest();
        Apttus_Proposal__Proposal_Line_Item__c qli2 = new Apttus_Proposal__Proposal_Line_Item__c(
            Apttus_Proposal__Unit_Price__c = 134, 
            Apttus_QPConfig__ClassificationHierarchy__c = 'AC Scroll',
            Apttus_QPConfig__ItemSequence__c =2,
            Apttus_QPConfig__LineNumber__c =2, 
            Apttus_Proposal__Quantity__c =1,
            Apttus_Proposal__Proposal__c =q.id,  
            Apttus_QPConfig__LineStatus__c = 'New',
            Apttus_Proposal__Product__c = p.id,
            Apttus_QPConfig__LineType__c = 'Product/Service');
        insert qli2;
        
        q.Apttus_QPConfig__ConfigurationFinalizedDate__c = system.today()+55;
        update q;
        Apttus_Proposal__Proposal_Line_Item__c qli20 = new Apttus_Proposal__Proposal_Line_Item__c(
            Apttus_Proposal__Unit_Price__c = 134, 
            Apttus_QPConfig__ClassificationHierarchy__c = 'AC Scroll',
            Apttus_QPConfig__ItemSequence__c =2,
            Apttus_QPConfig__LineNumber__c =2, 
            Apttus_Proposal__Quantity__c =1,
            Apttus_Proposal__Proposal__c =q2.id,  
            Apttus_QPConfig__LineStatus__c = 'New',
            Apttus_Proposal__Product__c = p1.id,
            Apttus_QPConfig__LineType__c = 'Product/Service');
        insert qli20;
        
        q2.Apttus_QPConfig__ConfigurationFinalizedDate__c = system.today()+55;
        update q2;
        Apttus_Proposal__Proposal_Line_Item__c qli21 = new Apttus_Proposal__Proposal_Line_Item__c(
            Apttus_Proposal__Unit_Price__c = 134, 
            Apttus_QPConfig__ClassificationHierarchy__c = 'AC Scroll',
            Apttus_QPConfig__ItemSequence__c =2,
            Apttus_QPConfig__LineNumber__c =2, 
            Apttus_Proposal__Quantity__c =1,
            Apttus_Proposal__Proposal__c =q3.id,  
            Apttus_QPConfig__LineStatus__c = 'New',
            Apttus_Proposal__Product__c = p2.id,
            Apttus_QPConfig__LineType__c = 'Product/Service');
        insert qli21;
        
        List<Apttus_Proposal__Proposal__c> quoteList = new List<Apttus_Proposal__Proposal__c>();
        quoteList.add(q);
        quoteList.add(q2);
        quoteList.add(q3);
        for(Apttus_Proposal__Proposal__c qq : quoteList)
        {
       	 qq.Apttus_QPConfig__ConfigurationFinalizedDate__c = system.today()+55;
       // update q3;
        }
        update quoteList;
        test.stopTest();
    }
    @isTest
    public static void concatenateTKClausesTest4()
    {
        Apttus_Proposal__Proposal__c q = [select id,Estimated_Close_Date__c,Apttus_QPConfig__ConfigurationFinalizedDate__c,Apttus_Proposal__Opportunity__c
                                          ,RecordTypeId
                                          from  Apttus_Proposal__Proposal__c where Approval_Status__c = 'Mgmt Approved' and Bulk_Exchange_Rate__c=12
                                          limit 1];
        
        Apttus_Proposal__Proposal__c q2 = [select id,Estimated_Close_Date__c,Apttus_QPConfig__ConfigurationFinalizedDate__c,Apttus_Proposal__Opportunity__c,
                                           RecordTypeId,Apttus_Proposal__Primary__c,Apttus_Proposal__Approval_Stage__c
                                           from  Apttus_Proposal__Proposal__c where Approval_Status__c = 'Approved' 
                                           limit 1];
        Apttus_Proposal__Proposal__c q3 = [select id,Estimated_Close_Date__c,Apttus_QPConfig__ConfigurationFinalizedDate__c,Apttus_Proposal__Opportunity__c,
                                           RecordTypeId,Apttus_Proposal__Primary__c,Apttus_Proposal__Approval_Stage__c,Included_Line_Item_Categories__c
                                           from  Apttus_Proposal__Proposal__c where Approval_Status__c = 'Mgmt Approved' and Bulk_Exchange_Rate__c=123
                                           limit 1];
        
        
        List<Product2> proList = new List<Product2>();
        
        Product2 p3 = new Product2(Name = 'WC Chiller',Product_Category__c='WC Chiller', isActive = true);
        Product2 p4 = new Product2(Name = 'Split Systems',Product_Category__c='Split Systems', isActive = true);
        Product2 p5 = new Product2(Name = 'Sump Pumps',Product_Category__c='Sump Pumps', isActive = true);
        
        proList.add(p3);
        proList.add(p4);
        proList.add(p5);
        insert proList;
        test.startTest();
        Apttus_Proposal__Proposal_Line_Item__c qli2 = new Apttus_Proposal__Proposal_Line_Item__c(
            Apttus_Proposal__Unit_Price__c = 134, 
            Apttus_QPConfig__ClassificationHierarchy__c = 'AC Scroll',
            Apttus_QPConfig__ItemSequence__c =2,
            Apttus_QPConfig__LineNumber__c =2, 
            Apttus_Proposal__Quantity__c =1,
            Apttus_Proposal__Proposal__c =q.id,  
            Apttus_QPConfig__LineStatus__c = 'New',
            Apttus_Proposal__Product__c = p3.id,
            Apttus_QPConfig__LineType__c = 'Product/Service');
        insert qli2;
        
        q.Apttus_QPConfig__ConfigurationFinalizedDate__c = system.today()+55;
        update q;
        Apttus_Proposal__Proposal_Line_Item__c qli20 = new Apttus_Proposal__Proposal_Line_Item__c(
            Apttus_Proposal__Unit_Price__c = 134, 
            Apttus_QPConfig__ClassificationHierarchy__c = 'AC Scroll',
            Apttus_QPConfig__ItemSequence__c =2,
            Apttus_QPConfig__LineNumber__c =2, 
            Apttus_Proposal__Quantity__c =1,
            Apttus_Proposal__Proposal__c =q2.id,  
            Apttus_QPConfig__LineStatus__c = 'New',
            Apttus_Proposal__Product__c = p4.id,
            Apttus_QPConfig__LineType__c = 'Product/Service');
        insert qli20;
        
        q2.Apttus_QPConfig__ConfigurationFinalizedDate__c = system.today()+55;
        update q2;
        Apttus_Proposal__Proposal_Line_Item__c qli21 = new Apttus_Proposal__Proposal_Line_Item__c(
            Apttus_Proposal__Unit_Price__c = 134, 
            Apttus_QPConfig__ClassificationHierarchy__c = 'AC Scroll',
            Apttus_QPConfig__ItemSequence__c =2,
            Apttus_QPConfig__LineNumber__c =2, 
            Apttus_Proposal__Quantity__c =1,
            Apttus_Proposal__Proposal__c =q3.id,  
            Apttus_QPConfig__LineStatus__c = 'New',
            Apttus_Proposal__Product__c = p5.id,
            Apttus_QPConfig__LineType__c = 'Product/Service');
        insert qli21;
        
        q3.Apttus_QPConfig__ConfigurationFinalizedDate__c = system.today()+55;
        update q3;
        test.stopTest();
    }
    @isTest
    public static void concatenateTKClausesTest5()
    {
        Apttus_Proposal__Proposal__c q = [select id,Estimated_Close_Date__c,Apttus_QPConfig__ConfigurationFinalizedDate__c,Apttus_Proposal__Opportunity__c
                                          ,RecordTypeId,Apttus_Proposal__Primary__c,Apttus_Proposal__Approval_Stage__c,Included_Line_Item_Categories__c
                                          from  Apttus_Proposal__Proposal__c where Approval_Status__c = 'Mgmt Approved' and Bulk_Exchange_Rate__c=18
                                          limit 1];
        System.debug('Quote proposal::'+q);
        
        Product2 p = new Product2(Name = 'AC Chiller',Product_Category__c='AC Chiller', isActive = true);
        insert p;
        
        Apttus_Proposal__Proposal_Line_Item__c qli2 = new Apttus_Proposal__Proposal_Line_Item__c(
            Apttus_Proposal__Unit_Price__c = 134, 
            Apttus_QPConfig__ClassificationHierarchy__c = 'Equipment Daikin | Chiller | Chiller ',
            Apttus_QPConfig__ItemSequence__c =2,
            Apttus_QPConfig__LineNumber__c =2, 
            Apttus_Proposal__Quantity__c =1,
            Apttus_Proposal__Proposal__c =q.id,  
            Apttus_QPConfig__LineStatus__c = 'New',
            Apttus_Proposal__Product__c = p.id,
            Apttus_QPConfig__LineType__c = 'Product/Service');
        insert qli2;
        
        q.Apttus_QPConfig__ConfigurationFinalizedDate__c = system.today()+55;
        q.Included_Line_Item_Categories__c = 'Customer Scope Description AC Chiller';
        
        update q;
    }
   
    @isTest
    public static void unitTest2()
    {
       
        Product2 p = new Product2(Name = 'Boilers',Product_Category__c='VRV', isActive = true);
        Product2 p1 = new Product2(Name = 'Air Handler',Product_Category__c='Air Handler', isActive = true);
        Product2 p2 = new Product2(Name = 'AC Chiller',Product_Category__c='AC Chiller', isActive = true);
        Product2 p3 = new Product2(Name = 'WC Chiller',Product_Category__c='WC Chiller', isActive = true);
       List<Product2> proList = new List<Product2>();
        proList.add(p);
        proList.add(p1);
        proList.add(p2);
        proList.add(p3);
        
        insert ProList;
        
        Id rta = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('North America Proposal').getRecordTypeId();
        
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
        String  standardPricebookId =Test.getStandardPricebookId();
        o.Pricebook2Id = standardPricebookId;
        insert o;  
        
        
        
        
        
        test.startTest();
        list<Apttus_Proposal__Proposal__c> quoteList = new list<Apttus_Proposal__Proposal__c>();
        Apttus_Proposal__Proposal__c q =  new Apttus_Proposal__Proposal__c(
            Apttus_Proposal__Account__c = a.id, 
            Apttus_QPConfig__ConfigurationFinalizedDate__c = system.today()+6, 
            Estimated_Close_Date__c= system.today()+3,
            Quote_Document_Date__c= system.today()+5, 
            T_C_Country__c= 'USA', 
            Emergency_Service_Level__c ='24 x 7 incl holidays',
            Document_Presentation_Language__c= 'English',
            Local_Currency__c = 'USD', 
            Apttus_QPConfig__BillToAccountId__c = a.id, 
            Apttus_Proposal__Opportunity__c = o.id, 
            Bulk_Exchange_Rate__c=125.03, 
            Brand__c= 'Daikin', 
            Apttus_Proposal__Approval_Stage__c = 'Generated',
            Quote_Presentation_Currency__c ='USD', 
            Apttus_Proposal__Primary_Contact__c = c.id);
        q.Apttus_Proposal__Primary__c = false;
        q.Approval_Status__c = 'Approved';
        q.RecordTypeId = rta;
        insert q;
        
        
        
        quoteList.add(q);
        Apttus_Proposal__Proposal__c q2 =  new Apttus_Proposal__Proposal__c(
            Apttus_Proposal__Account__c = a.id, 
            Apttus_QPConfig__ConfigurationFinalizedDate__c =System.today()+20,  
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
            Apttus_Proposal__Approval_Stage__c = 'Draft',
            Line_of_Business__c = 'parts only',
            Quote_Presentation_Currency__c ='USD', 
            Apttus_Proposal__Primary_Contact__c = c.id);
        q2.Apttus_Proposal__Primary__c = false;
        q2.Approval_Status__c = 'Approved';
        q2.RecordTypeId = rta;
        insert q2;
         
        list<Apttus_Proposal__Proposal_Line_Item__c> lineitemList = new list<Apttus_Proposal__Proposal_Line_Item__c>();
        Apttus_Proposal__Proposal_Line_Item__c qli = new Apttus_Proposal__Proposal_Line_Item__c(
            Apttus_Proposal__Unit_Price__c =122, 
            Apttus_QPConfig__ClassificationHierarchy__c = 'Equipment Daikin',
            Apttus_QPConfig__ItemSequence__c =1, Apttus_QPConfig__LineNumber__c =1, 
            Apttus_Proposal__Quantity__c =2, Apttus_Proposal__Proposal__c =q.id,  
            Apttus_QPConfig__LineStatus__c = 'New',
            Apttus_Proposal__Product__c = p2.id,
            Apttus_QPConfig__LineType__c = 'Product/Service');
        // insert qli;
        lineitemList.add(qli);
        Apttus_Proposal__Proposal_Line_Item__c qli22 = new Apttus_Proposal__Proposal_Line_Item__c(
            Apttus_Proposal__Unit_Price__c =122, 
            Apttus_QPConfig__ClassificationHierarchy__c = 'Equipment Daikin | Service | Service | Chiller',
            Apttus_QPConfig__ItemSequence__c =1, Apttus_QPConfig__LineNumber__c =1, 
            Apttus_Proposal__Quantity__c =2, Apttus_Proposal__Proposal__c =q2.id,  
            Apttus_QPConfig__LineStatus__c = 'New',
            Apttus_Proposal__Product__c = p1.id,
            Apttus_QPConfig__LineType__c = 'Product/Service');
        
        lineitemList.add(qli22);
        
        Apttus_Proposal__Proposal_Line_Item__c qli44 = new Apttus_Proposal__Proposal_Line_Item__c(
            Apttus_Proposal__Unit_Price__c =122, 
            Apttus_QPConfig__ClassificationHierarchy__c = 'Equipment Daikin | Service | WC Scroll | Chiller',
            Apttus_QPConfig__ItemSequence__c =1, Apttus_QPConfig__LineNumber__c =1, 
            Apttus_Proposal__Quantity__c =2, Apttus_Proposal__Proposal__c =q2.id,  
            Apttus_QPConfig__LineStatus__c = 'New',
            Apttus_Proposal__Product__c = p.id,
            Apttus_QPConfig__LineType__c = 'Product/Service');
        
        lineitemList.add(qli44);
        
        Apttus_Proposal__Proposal_Line_Item__c qli2 = new Apttus_Proposal__Proposal_Line_Item__c(
            Apttus_Proposal__Unit_Price__c = 134, 
            Apttus_QPConfig__ClassificationHierarchy__c = 'Equipment Daikin | Chiller | WC Chiller | ACZ',
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
            Apttus_QPConfig__ClassificationHierarchy__c = 'Equipment Daikin | AAH | Split system AH | DCG',
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
            Apttus_Proposal__Quantity__c =1, Apttus_Proposal__Proposal__c =q2.id, 
            Apttus_QPConfig__LineStatus__c = 'New', Apttus_QPConfig__LineType__c = 'Product/Service',
            Apttus_Proposal__Product__c = p3.id);
        //insert qli4;
        lineitemList.add(qli4);
        Apttus_Proposal__Proposal_Line_Item__c qli14 = new Apttus_Proposal__Proposal_Line_Item__c(
            Apttus_Proposal__Unit_Price__c = 1341, 
            Apttus_QPConfig__ClassificationHierarchy__c = 'Equipment Daikin | AAH | RTU | CAH',
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
            Apttus_Proposal__Proposal__c =q.id, 
            Apttus_QPConfig__LineStatus__c = 'New', 
            Apttus_QPConfig__LineType__c = 'Product/Service');
        
        //insert qli5;
        lineitemList.add(qli5);
        insert lineitemList;
        
        quoteList.add(q2);
      
        
        for(Apttus_Proposal__Proposal__c qq : quoteList)
        {
            qq.Apttus_QPConfig__ConfigurationFinalizedDate__c = system.today()+55;
        }
       
        update quoteList;
        test.stopTest();
        
    }    
    
}