@isTest
public class QuoteSyncTriggerHnadlerTest {
    @testsetup
    Static  void setup(){
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
        //insert p;
        
        Product2 p1 = new Product2(Name = 'Air Handler',Product_Category__c='Air Handler', isActive = true);
        proList.add(p1);
        //insert p1;
        Product2 p2 = new Product2(Name = 'AC Chiller',Product_Category__c='AC Chiller', isActive = true);
        //insert p2;
        Product2 p3 = new Product2(Name = 'WC Chiller',Product_Category__c='WC Chiller', isActive = true);
        //insert p3;
        Product2 p4 = new Product2(Name = 'Split Systems',Product_Category__c='Split Systems', isActive = true);
        //insert p4;
        Product2 p5 = new Product2(Name = 'Sump Pumps',Product_Category__c='Sump Pumps', isActive = true);
        //insert p5;
        Product2 p6 = new Product2(Name = 'Test Product',Product_Category__c='VRV', isActive = true);
        //insert p6;
        proList.add(p2);
        proList.add(p3);
        proList.add(p4);
        proList.add(p5);
        proList.add(p6);
        insert proList;
        
        Pricebook2 stdPriceBook = new Pricebook2(Id = standardPricebookId, IsActive = true);
        upsert stdPricebook;


        //PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pb, Product2Id = p.Id, UnitPrice = 100, isActive = true);
        //insert pbe;
        
        //OpportunityLineItem oli = new OpportunityLineItem(Quantity = 1, Item_Number__c='1', Equipment_Gross_Margin__c=25, UnitPrice = 100, Multiplier_PAR__c=1, Exchange_Rate__c=1, PriceBookEntryId = pbe.Id, OpportunityId=o.Id );
        //insert oli;
        
        //OpportunityLineItem oli2 = new OpportunityLineItem(Quantity = 1, Item_Number__c='1', Equipment_Gross_Margin__c=25, UnitPrice = 123, Multiplier_PAR__c=1, Exchange_Rate__c=1, PriceBookEntryId = pbe.Id, OpportunityId=o.Id );
        //insert oli2;
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
        quoteList.add(q);
        //insert q;
        system.debug('quote1 is : '+ q);
        
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
      //  insert q2;
           quoteList.add(q2);
        system.debug('quote2 is : '+ q2);
        insert    quoteList;
        
        
        list<Apttus_Proposal__Proposal_Line_Item__c> lineitemList = new list<Apttus_Proposal__Proposal_Line_Item__c>();
        Apttus_Proposal__Proposal_Line_Item__c qli = new Apttus_Proposal__Proposal_Line_Item__c(
            Apttus_Proposal__Unit_Price__c =122, 
            Apttus_QPConfig__ClassificationHierarchy__c = 'Service | Maintenance | Chiller',
            Apttus_QPConfig__ItemSequence__c =1, Apttus_QPConfig__LineNumber__c =1, 
            Apttus_Proposal__Quantity__c =2, Apttus_Proposal__Proposal__c =q.id,  
            Apttus_QPConfig__LineStatus__c = 'New',
            Apttus_QPConfig__LineType__c = 'Product/Service');
        
          //  insert qli;
        lineitemList.add(qli);
       
        //qli.Apttus_Proposal__Product__c='01tC0000003epNN';
        //update qli;
        system.debug('qli' +qli);
        /*Apttus_Proposal__Proposal_Line_Item__c qli2 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Unit_Price__c = 134, Apttus_QPConfig__ClassificationHierarchy__c = 'Equipment Daikin | Chiller | AC Scroll | ACZ',Apttus_QPConfig__ItemSequence__c =2, Apttus_QPConfig__LineNumber__c =2, Apttus_Proposal__Quantity__c =1, Apttus_Proposal__Proposal__c =q.id,  Apttus_QPConfig__LineStatus__c = 'New', Apttus_QPConfig__LineType__c = 'Product/Service', Apttus_Proposal__Product__c='01tC0000003epPO');
        insert qli2;
        qli2.Apttus_Proposal__Unit_Price__c = 1340;
        update qli2;
        Apttus_Proposal__Proposal_Line_Item__c qli3 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Unit_Price__c =122, Apttus_QPConfig__ClassificationHierarchy__c = 'Equipment Daikin | Chiller | WC Scroll | WGZ',Apttus_QPConfig__ItemSequence__c =3, Apttus_QPConfig__LineNumber__c =3, Apttus_Proposal__Quantity__c =2, Apttus_Proposal__Proposal__c =q.id,  Apttus_QPConfig__LineStatus__c = 'New', Apttus_QPConfig__LineType__c = 'Product/Service', Apttus_Proposal__Product__c='01tC0000003epV0');
        insert qli3;
        update qli3;
        system.debug('qli' +qli3); */
        //Apttus_Proposal__Proposal_Line_Item__c qli4 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Unit_Price__c = 134, Apttus_QPConfig__ClassificationHierarchy__c = 'Equipment Daikin | AAH | AHU | CAH',Apttus_QPConfig__ItemSequence__c =4, Apttus_QPConfig__LineNumber__c =4, Apttus_Proposal__Quantity__c =1, Apttus_Proposal__Proposal__c =q2.id,  Apttus_QPConfig__LineStatus__c = 'New', Apttus_QPConfig__LineType__c = 'Product/Service');
        //insert qli4;
       // Apttus_Proposal__Proposal_Line_Item__c qli14 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Unit_Price__c = 1341, Apttus_QPConfig__ClassificationHierarchy__c = 'Equipment Daikin | AAH | AHU | CAH',Apttus_QPConfig__ItemSequence__c =4, Apttus_QPConfig__LineNumber__c =4, Apttus_Proposal__Quantity__c =1, Apttus_Proposal__Proposal__c =q.id,  Apttus_QPConfig__LineStatus__c = 'New', Apttus_QPConfig__LineType__c = 'Product/Service', Apttus_Proposal__Product__c='01tC0000003erpa');
        //insert qli14;
        Apttus_Proposal__Proposal_Line_Item__c qli5 = new Apttus_Proposal__Proposal_Line_Item__c(
            Apttus_Proposal__Unit_Price__c =122, 
            Apttus_QPConfig__ClassificationHierarchy__c = 'Equipment Daikin | Chiller | WC Scroll | WGZ',
            Apttus_QPConfig__ItemSequence__c =5,
            Apttus_QPConfig__LineNumber__c =5, 
            Apttus_Proposal__Quantity__c =2, 
            Apttus_Proposal__Proposal__c =q.id, 
            Apttus_QPConfig__LineStatus__c = 'New', 
            Apttus_QPConfig__LineType__c = 'Product/Service');
        
       // insert qli5;
       lineitemList.add(qli5);
     
        /*  Apttus_Proposal__Proposal_Line_Item__c qli6 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Unit_Price__c = 134, Apttus_QPConfig__ClassificationHierarchy__c = 'Equipment Daikin | Chiller | AC Scroll | ACZ',Apttus_QPConfig__ItemSequence__c =6, Apttus_QPConfig__LineNumber__c =6, Apttus_Proposal__Quantity__c =1, Apttus_Proposal__Proposal__c =q.id,  Apttus_QPConfig__LineStatus__c = 'New', Apttus_QPConfig__LineType__c = 'Product/Service', Apttus_Proposal__Product__c='01tC0000003epPO');
      lineitemList.add(qli6);
       //insert qli6;
        
        Apttus_Proposal__Proposal_Line_Item__c qli7 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Unit_Price__c = 134, Apttus_QPConfig__ClassificationHierarchy__c = 'Service | Maintenance | Chiller',Apttus_QPConfig__ItemSequence__c =7, Apttus_QPConfig__LineNumber__c =7, Apttus_Proposal__Quantity__c =1, Apttus_Proposal__Proposal__c =q2.id,  Apttus_QPConfig__LineStatus__c = 'New', Apttus_QPConfig__LineType__c = 'Product/Service', Apttus_Proposal__Product__c='01tL0000004R8DG');
        //insert qli7;
        lineitemList.add(qli7);
        Apttus_Proposal__Proposal_Line_Item__c qli8 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Unit_Price__c =122, Apttus_QPConfig__ClassificationHierarchy__c = 'Service | Maintenance | Chiller',Apttus_QPConfig__ItemSequence__c =8, Apttus_QPConfig__LineNumber__c =8, Apttus_Proposal__Quantity__c =2, Apttus_Proposal__Proposal__c =q.id,  Apttus_QPConfig__LineStatus__c = 'New', Apttus_QPConfig__LineType__c = 'Product/Service',  Apttus_Proposal__Product__c='01tL0000004R8DG');
        //insert qli8;
        lineitemList.add(qli8);
        system.debug('qli' +qli8);
        Apttus_Proposal__Proposal_Line_Item__c qli9 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Unit_Price__c = 134, Apttus_QPConfig__ClassificationHierarchy__c = 'Equipment Daikin | Chiller | AC Scroll | ACZ',Apttus_QPConfig__ItemSequence__c =9, Apttus_QPConfig__LineNumber__c =9, Apttus_Proposal__Quantity__c =1, Apttus_Proposal__Proposal__c =q2.id, Apttus_QPConfig__LineStatus__c = 'New', Apttus_QPConfig__LineType__c = 'Product/Service', Apttus_Proposal__Product__c='01tC0000003epPO');
        //insert qli9;
        lineitemList.add(qli9);
        
        
        Apttus_Proposal__Proposal_Line_Item__c qlip = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Unit_Price__c = 134, Apttus_QPConfig__ClassificationHierarchy__c = NULL,Apttus_QPConfig__ItemSequence__c =6, Apttus_QPConfig__LineNumber__c =6, Apttus_Proposal__Quantity__c =1, Apttus_Proposal__Proposal__c =q.id,  Apttus_QPConfig__LineStatus__c = 'New', Apttus_QPConfig__LineType__c = 'Product/Service', Apttus_Proposal__Product__c=p.id);
        //insert qlip;
        lineitemList.add(qlip);
        Apttus_Proposal__Proposal_Line_Item__c qlip1 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Unit_Price__c = 134, Apttus_QPConfig__ItemSequence__c =9, Apttus_QPConfig__ClassificationHierarchy__c = NULL, Apttus_QPConfig__LineNumber__c =9, Apttus_Proposal__Quantity__c =1, Apttus_Proposal__Proposal__c =q.id,  Apttus_QPConfig__LineStatus__c = 'New', Apttus_QPConfig__LineType__c = 'Product/Service', Apttus_Proposal__Product__c=p1.id);
        //insert qlip1;
        lineitemList.add(qlip1);
        Apttus_Proposal__Proposal_Line_Item__c qlip2 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Unit_Price__c = 134, Apttus_QPConfig__ItemSequence__c =7, Apttus_QPConfig__LineNumber__c =7, Apttus_Proposal__Quantity__c =1, Apttus_QPConfig__ClassificationHierarchy__c = NULL,Apttus_Proposal__Proposal__c =q.id,  Apttus_QPConfig__LineStatus__c = 'New', Apttus_QPConfig__LineType__c = 'Product/Service', Apttus_Proposal__Product__c=p2.Id);
        //insert qlip2;
        lineitemList.add(qlip2);
        Apttus_Proposal__Proposal_Line_Item__c qlip3 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Unit_Price__c =122, Apttus_QPConfig__ItemSequence__c =8, Apttus_QPConfig__LineNumber__c =8, Apttus_Proposal__Quantity__c =2, Apttus_QPConfig__ClassificationHierarchy__c = NULL,Apttus_Proposal__Proposal__c =q.id,  Apttus_QPConfig__LineStatus__c = 'New', Apttus_QPConfig__LineType__c = 'Product/Service',  Apttus_Proposal__Product__c=p3.id);
        //insert qlip3;
        lineitemList.add(qlip3);
        system.debug('qli' +qlip3);
        Apttus_Proposal__Proposal_Line_Item__c qlip4 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Unit_Price__c = 134, Apttus_QPConfig__ItemSequence__c =9, Apttus_QPConfig__LineNumber__c =9, Apttus_Proposal__Quantity__c =1, Apttus_QPConfig__ClassificationHierarchy__c = NULL,Apttus_Proposal__Proposal__c =q.id,  Apttus_QPConfig__LineStatus__c = 'New', Apttus_QPConfig__LineType__c = 'Product/Service', Apttus_Proposal__Product__c=p4.Id);
        //insert qlip4;
        lineitemList.add(qlip4);
        Apttus_Proposal__Proposal_Line_Item__c qlip5 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Unit_Price__c =122, Apttus_QPConfig__ItemSequence__c =8, Apttus_QPConfig__LineNumber__c =8, Apttus_Proposal__Quantity__c =2, Apttus_QPConfig__ClassificationHierarchy__c = NULL,Apttus_Proposal__Proposal__c =q.id,  Apttus_QPConfig__LineStatus__c = 'New', Apttus_QPConfig__LineType__c = 'Product/Service',  Apttus_Proposal__Product__c=p5.id);
        insert qlip5;
         lineitemList.add(qlip5);
        system.debug('qli' +qlip5);*/
        insert lineitemList;
    }
    Static testMethod void myUnitTest(){
       // RecordType oppRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'North_America' AND SobjectType = 'Opportunity'][0];
       // RecordType naRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'North_America_Proposal' AND SobjectType = 'Apttus_Proposal__Proposal__c'][0];
       // RecordType laRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Latin_America_Proposal' AND SobjectType = 'Apttus_Proposal__Proposal__c'][0];
        
        
        //OpportunityLineItem oL = new OpportunityLineItem();
        //Pricebook2 pb = [select Id from Pricebook2 where PriceBook2.Name = 'Standard Price Book'];
		

        
        
        //Id  standardPricebookId =Test.getStandardPricebookId();
        //O.Pricebook2Id = standardPricebookId;
        //custom price book
        
        
        /*for(Apttus_Proposal__Proposal_Line_Item__c lI : [SELECT Id FROM Apttus_Proposal__Proposal_Line_Item__c WHERE Apttus_Proposal__Proposal__c = :q.id]){
            system.debug('Quote Line Items: ' +lI);
        }*/
        test.startTest();
        Apttus_Proposal__Proposal__c q = [select id,Estimated_Close_Date__c,Apttus_QPConfig__ConfigurationFinalizedDate__c 
                                          from  Apttus_Proposal__Proposal__c where Approval_Status__c = 'Mgmt Approved' 
                                         limit 1];
        q.Estimated_Close_Date__c= system.today()+100;
        q.Apttus_QPConfig__ConfigurationFinalizedDate__c = system.today();
        update q;
        Apttus_Proposal__Proposal__c q2 = [select id,Estimated_Close_Date__c,Apttus_QPConfig__ConfigurationFinalizedDate__c 
                                          from  Apttus_Proposal__Proposal__c where Approval_Status__c = 'Approved' 
                                         limit 1];
        q2.Estimated_Close_Date__c= system.today()+90;
        update q2; 

        
        
       
        
        
        opportunity o = [select id,Synced_Quote_Proposal__c from opportunity limit 1];
        o.Synced_Quote_Proposal__c = q2.id;
        update o;
        q.Estimated_Close_Date__c= Date.newInstance(2016, 07, 07);
        
        update q;
        q.Estimated_Close_Date__c= Date.newInstance(2016, 06, 06);
        
        update q;
        system.debug('quote1 is : '+ q);
        system.debug('quote2 is : '+ q2);
        delete q;   
        q2.Estimated_Close_Date__c= Date.newInstance(2016, 07, 07);
        
        update q2;
        q2.Estimated_Close_Date__c= Date.newInstance(2016, 06, 06);
        
        update q2;
        system.debug('quote2 is : '+ q2);
       delete q2;
        test.stopTest();
        
    }
}