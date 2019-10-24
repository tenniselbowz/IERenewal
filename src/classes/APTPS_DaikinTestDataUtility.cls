@isTest
/*
    Class : APTPS_DaikinTestDataUtility
    Description : This class contains blue print of required test data. 
*/
public class APTPS_DaikinTestDataUtility {
    
    public static List<Account> accountListNA;
    public static List<Account> accountListLA;
    public static List<Contact> contacts;
    public static List<Opportunity> oppListNA;
    public static List<Opportunity> oppListLA;
    public static List<Apttus_Proposal__Proposal__c> quoteListNA;
    public static List<Apttus_Proposal__Proposal__c> quoteListLA;
    //
    public static List<Product2> standaloneProductList;
    public static List<Product2> bundleProductList;
    
    //public static List<Apttus_Config2__PriceList__c> priceList; //active
    public static List<Apttus_Config2__PriceListItem__c> priceListItemList; //associated with Price list and Product
    
    public static Product2 getProduct(String productName) {
        return new Product2(Name = productName, Vendor_Supplier__c = 'Test Vendor', IsActive = true, Description = 'Test Description', Apttus_Product__c = true,
         Product_Category__c = 'Test Category');
    }
    
    public static Id getStandardPricebookId() {
        return Test.getStandardPricebookId();
    } 
    
    public static PricebookEntry getPBEntry(Id productId, Id priceBookId, Boolean useStandardPrice) {
        return new PricebookEntry(Product2Id = productId, Pricebook2Id = pricebookId, IsActive = true, UnitPrice = 10, UseStandardPrice = useStandardPrice);
    }
    
    public static Account getAccount(String accName) {
        return new Account(Name = accName);
    }
    
    public static Contact getContact(Account account) {
        return new Contact(FirstName = 'Test Account', LastName = 'NA-1', AccountId = account.Id, Email = 'psevak@apttus.com', Phone = '123456789');
    }
    
    public static Opportunity getOpp(Account account) {
        return new Opportunity(Name = 'Test Opp NA-1', AccountId = account.Id, Line_of_Business__c = 'Rental Chillers', Vertical_Market__c = 'Manufacturing Facilities and Warehouses',
            Opp_City__c = 'Ahmedabad', Opp_State__c = 'Gujarat', CloseDate = System.Today() + 30, NextStep = 'Close', StageName = 'A-Purchase order received', Probability = 25, Bypass__c = true);
    }
    
    public static OpportunityLineItem getOppLineItem(Id oppId, Id pbEntryId) {
        OpportunityLineItem oppLineItem = new OpportunityLineItem(OpportunityId = oppId);
        oppLineItem.TAG__c = 'Tag'; oppLineItem.PriceBookEntryId = pbEntryId;
        oppLineItem.UnitPrice = 10; oppLineItem.Multiplier_PAR__c = 1; oppLineItem.Quantity = 1;
        return oppLineItem;
    }
    
    public static Apttus_Config2__PriceList__c getPriceList(String name) {
        return new Apttus_Config2__PriceList__c(Name = name, Apttus_Config2__Active__c = true);
    }
    
    public static APTPS_Configurable_Variables__c getNorthAmericaQuoteCS() {
        APTPS_Configurable_Variables__c northAmericaQuoteCS = new APTPS_Configurable_Variables__c();
        northAmericaQuoteCS.Name = 'North_America_Quote_Price_List';
        northAmericaQuoteCS.APTPS_Variable_Value__c = 'USD Price List';
        return northAmericaQuoteCS;
    }
    
    public static Apttus_Proposal__Proposal__c getQuote(Account account, Contact contact, Opportunity opportunity, Apttus_Config2__PriceList__c priceList) {
        return new Apttus_Proposal__Proposal__c(Apttus_Proposal__Proposal_Name__c = 'Test Quote NA-1', Apttus_Proposal__Account__c = account.Id, 
            Apttus_Proposal__Opportunity__c = opportunity.Id, Apttus_QPConfig__PriceListId__c = priceList.Id,
            Apttus_Proposal__Primary_Contact__c = contact.Id, Local_Currency__c = 'USD',Bulk_Exchange_Rate__c = 1,
            Estimated_Close_Date__c = System.today() + 30, Quote_Document_Date__c = System.today(), T_C_Country__c = 'USA',
            Brand__c = 'Daikin', Maintenance_Type__c = 'Inspection', Term_in_Years__c = '1', 
            Payments__c = 'In Advance', MA_Term_Expiration_Date__c = System.today() + 60, Payments_will_be_made__c = 'Year');//DPL added these to get tests to pass... must be set to MA which requires these.
    }
    
    
     public static List<Product2> getProductList(){
       
        List<Product2> ProductList = New list<Product2>();
        Product2 Product_1 = new Product2();
        Product_1.Name ='Test - Voice and Data';
        Product_1.ProductCode = 'V0001';
        Product_1.Family ='Smartshare';        
        
        ProductList.add(Product_1);
       
       
        Product2 Product_2 = new Product2();
        Product_2.Name ='Test - Voice and Data (Unlimited)';
        Product_2.ProductCode = 'V0002';
        Product_2.Family ='Smartshare';        
        
        ProductList.add(Product_2);
       
        Product2 Product_3 = new Product2();
        Product_3.Name ='Test -Ultra $119 (incl. GST)';
        Product_3.ProductCode = 'V0003';
        Product_3.Family ='Mobile Plan';        
        
        ProductList.add(Product_3);
       
        Product2 Product_4 = new Product2();
        Product_4.Name ='Test -Ultra $79 (incl. GST)';
        Product_4.ProductCode = 'V0004';
        Product_4.Family ='Mobile Plan';        
        
        ProductList.add(Product_4);       
        
        Return ProductList;
    }
    
    public static List<Apttus_Config2__PriceListItem__c> CreatePLI(List<Product2> products, Apttus_Config2__PriceList__c pl)
    {
        List<Apttus_Config2__PriceListItem__c> listPLI = new List<Apttus_Config2__PriceListItem__c>();
        for(Product2 pro:products)
        {
            Apttus_Config2__PriceListItem__c PLI = new Apttus_Config2__PriceListItem__c();
            PLI.Apttus_Config2__PriceListId__c = pl.Id;
            PLI.Apttus_Config2__ChargeType__c = 'Monthly Account Fee';
            PLI.Apttus_Config2__ProductId__c = pro.Id;
            PLI.Apttus_Config2__Active__c = True;
            PLI.Apttus_Config2__ListPrice__c = 25;
            PLI.Apttus_Config2__PriceType__c = 'Recurring';
            PLI.Apttus_Config2__Frequency__c = 'Monthly';
            PLI.Apttus_Config2__PriceMethod__c = 'Per Unit';
            PLI.Apttus_Config2__PriceUom__c = 'Month';
            listPLI.Add(PLI);
        }
        return listPLI;
    }
    
     public static Apttus_Config2__ProductConfiguration__c GetConfiguration(Apttus_Proposal__Proposal__c prop, Apttus_Config2__PriceList__c pl)
    {
        // Create Configuration and Get details
        Apttus_Config2__ProductConfiguration__c myConfigSO = new Apttus_Config2__ProductConfiguration__c();
        myConfigSO.Name = 'Test - Configu';
        myConfigSO.Apttus_Config2__BusinessObjectType__c = 'Proposal';
        myConfigSO.Apttus_Config2__SummaryGroupType__c = 'Category';
        myConfigSO.Apttus_Config2__BusinessObjectId__c = prop.Id;
        myConfigSO.Apttus_QPConfig__Proposald__c = prop.Id;
        myConfigSO.Apttus_Config2__AccountId__c = prop.Apttus_Proposal__Account__c;
        myConfigSO.Apttus_Config2__PriceListId__c = pl.Id;
        myConfigSO.Apttus_Config2__Status__c = 'Saved';
        return myConfigSO;
    }
    
    public static List<Apttus_Config2__LineItem__c> GetLineItem(List<Product2> products, List<Apttus_Config2__PriceListItem__c> plis, Apttus_Config2__ProductConfiguration__c configu)
    {
        List<Apttus_Config2__LineItem__c> listLineItem = new List<Apttus_Config2__LineItem__c>();
        Apttus_Config2__LineItem__c lItem;
        Integer count = 1;
        for(Product2 prod: products){
            Apttus_Config2__PriceListItem__c pPLI;
            for(Apttus_Config2__PriceListItem__c pli: plis){
                if(pli.Apttus_Config2__ProductId__c == prod.Id){
                    pPLI = new Apttus_Config2__PriceListItem__c();
                    pPLI = pli;
                    break;
                }                
            }
            
            lItem = new Apttus_Config2__LineItem__c();
            lItem.Apttus_Config2__ConfigurationId__c = configu.Id;
            lItem.Apttus_Config2__LineNumber__c = count;
            lItem.Apttus_Config2__IsPrimaryLine__c = True;
            lItem.Apttus_Config2__PrimaryLineNumber__c = count;
            lItem.Apttus_Config2__ItemSequence__c = count;
            lItem.Apttus_Config2__LineType__c = 'Product/Service';
            lItem.Apttus_Config2__ProductId__c = prod.Id;
            lItem.Apttus_Config2__Quantity__c = 25;
            lItem.Apttus_Config2__Uom__c = pPLI.Apttus_Config2__PriceUom__c;
            lItem.Apttus_Config2__Term__c = 1;
            lItem.Apttus_Config2__LineStatus__c = 'New';
            lItem.Apttus_Config2__PriceListId__c = pPLI.Apttus_Config2__PriceListId__c;
            lItem.Apttus_Config2__PriceListItemId__c = pPLI.Id;
            lItem.Apttus_Config2__PriceType__c = pPLI.Apttus_Config2__PriceType__c;
            lItem.Apttus_Config2__PriceMethod__c = pPLI.Apttus_Config2__PriceMethod__c;
            lItem.Apttus_Config2__ChargeType__c = pPLI.Apttus_Config2__ChargeType__c;
            lItem.Apttus_Config2__Frequency__c = pPLI.Apttus_Config2__Frequency__c;
            lItem.Apttus_Config2__ListPrice__c = pPLI.Apttus_Config2__ListPrice__c;
            lItem.Apttus_Config2__BasePrice__c = pPLI.Apttus_Config2__ListPrice__c;
            listLineItem.add(lItem);
            count++;
        }
        return listLineItem;
    }
}