/* 
    Class : APTPS_DaikinPricingCallbackTest
    Description : This class covers APTPS_DaikinPricingCallback custom pricing code.
    Author : Parth Sevak , @Apttus            
*/
@isTest
private class APTPS_DaikinPricingCallbackTest {

    private static final String LINE_TYPE_PRODUCT_SERVICE = 'Product/Service';
    private static final String LINE_TYPE_OPTION = 'Option';
    private static final String LINE_STATUS_NEW = 'New';
    private static final String PRICE_TYPE_RECURRING = 'Recurring';
    private static final String CHARGE_TYPE_OVERAGE = 'Overage';
    private static final String CHARGE_TYPE_INCLUDED_UNITS = 'Included Units';
    private static final String CHARGE_TYPE_COMMIT = 'Commit';
    private static final String CHARGE_TYPE_INCLUDED = 'Included';
    private static final String LINE_STATUS_CANCELLED = 'Cancelled';
    
    static testMethod void testCustomPricingLogic() {
        //create config custom class properties
        Apttus_Config2__ConfigCustomClasses__c configCustomClassesProperty = new Apttus_Config2__ConfigCustomClasses__c();
        configCustomClassesProperty.Name = 'Config Custom Classes';
        configCustomClassesProperty.Apttus_Config2__PricingCallbackClass__c = 'APTPS_DaikinPricingCallback';
        insert configCustomClassesProperty;
        
        //create Config LineItem Custom Fields properties
        Apttus_Config2__ConfigLineItemCustomFields__c configLineItemCustomFields = new Apttus_Config2__ConfigLineItemCustomFields__c();
        configLineItemCustomFields.Name = 'System Properties';
        configLineItemCustomFields.Apttus_Config2__CustomFieldNames__c = 'Apttus_Config2__ProductId__r.APTS_WRC_Percentage__c,Apttus_Config2__ProductId__r.APTS_WRC_Product__c,Apttus_Config2__ClassificationId__r.Name';
        configLineItemCustomFields.Apttus_Config2__CustomFieldNames2__c = 'APTPS_Cost__c,APTS_Option_Price__c,APTS_Roll_up_of_Total_Hours__c,Total_of_Hours__c';
        configLineItemCustomFields.Apttus_Config2__CustomFieldNames4__c = 'APTPS_Selling_Price__c,APTPS_Margin_Dollar__c,APTPS_Margin_Percentage__c,APTPS_Margin_Percentage_Previous__c';
        configLineItemCustomFields.Apttus_Config2__CustomFieldNames5__c = 'APTS_Product_Attribute_RollUp__c,Apttus_Config2__BaseExtendedCost__c,Estimated_Tax__c, Apttus_Config2__OptionId__r.APTS_Daikin_Pricing__c, Apttus_Config2__ProductId__r.APTS_Daikin_Pricing__c, Apttus_Config2__ProductId__r.APTS_ApplyOptionPrice__c, ';
        insert configLineItemCustomFields;
        
        APTPS_Bundle_Products_With_Option_Price__c bundleCS = new APTPS_Bundle_Products_With_Option_Price__c();
        bundleCS.Name = 'Equipment & Tasking';
        insert bundleCS;
        
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;


        //Create Accounts
        Account account = new Account(Name = 'APTPS TST Account 1',BillingStreet='Street1', BillingCity = 'City', BillingCountry ='United States', BillingState = 'Minnesota', BillingPostalCode = '55447');
        insert account;
        
        Contact contact = APTPS_DaikinTestDataUtility.getContact(account);
        insert contact;
        
        //create Opportunity
        Opportunity opportunity = APTPS_DaikinTestDataUtility.getOpp(account);
        insert opportunity;
        
        //create price list
        Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c(Name = 'APTPS TST PriceList 1', Apttus_Config2__Active__c = true);
        insert priceList;
        
        //Create Product
        list<Product2> productsList = new list<Product2>();
        Product2 product1 = new product2(Name = 'Service Technician', ProductCode = 'ATP 0001', Apttus_Config2__ConfigurationType__c = 'Standalone', IsActive = true,APTS_Daikin_Pricing__c = True); 
        productsList.add(product1);
        
        Product2 product21 = new product2(Name = 'Personnel Vehicle Mileage/Mile', ProductCode = 'ATP 0002', Apttus_Config2__ConfigurationType__c = 'Standalone', IsActive = true); 
        productsList.add(product21);
        
        Product2 product3 = new product2(Name = 'Cab', ProductCode = 'ATP 0003', Apttus_Config2__ConfigurationType__c = 'Standalone', IsActive = true, APTS_WRC_Product__c = 'Warranty (Parts & Material)'); 
        productsList.add(product3);
        
        Product2 product4 = new product2(Name = 'Equipment & Tasking', ProductCode = 'ATP 0004', Apttus_Config2__ConfigurationType__c = 'Bundle', IsActive = true,Apttus_Config2__HasOptions__c = true, APTS_WRC_Product__c = null); 
        productsList.add(product4);
        
        insert productsList;
        
                
        //create price list items
        list<Apttus_Config2__PriceListItem__c> priceListItems = new list<Apttus_Config2__PriceListItem__c>();
        Apttus_Config2__PriceListItem__c priceListItem1 = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 1000, Apttus_Config2__ProductId__c = product1.Id, Apttus_Config2__ChargeType__c = 'Standard Price');
        priceListItems.add(priceListItem1);
        
        Apttus_Config2__PriceListItem__c priceListItem2 = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 1000, Apttus_Config2__ProductId__c = product21.Id, Apttus_Config2__ChargeType__c = 'Subscription Fee');
        priceListItems.add(priceListItem2);
        
        Apttus_Config2__PriceListItem__c priceListItem3 = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 1000, Apttus_Config2__ProductId__c = product3.Id, Apttus_Config2__ChargeType__c = 'Subscription Fee');
        priceListItems.add(priceListItem3);
        
        Apttus_Config2__PriceListItem__c priceListItem4 = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 1000, Apttus_Config2__ProductId__c = product4.Id, Apttus_Config2__ChargeType__c = 'Subscription Fee');
        priceListItems.add(priceListItem4);
        insert priceListItems;
        
        //create quote/proposal
        Apttus_Proposal__Proposal__c quote = APTPS_DaikinTestDataUtility.getQuote(account, contact, opportunity, priceList);
        insert quote;
        
        //create product configuration
        Apttus_Config2__ProductConfiguration__c configuration = new Apttus_Config2__ProductConfiguration__c(Name = 'APTpS TST Configuration 1', Apttus_Config2__AccountId__c = account.Id, Apttus_Config2__PriceListId__c = priceList.Id, Apttus_QPConfig__Proposald__c = quote.Id, Apttus_Config2__Status__c = LINE_STATUS_NEW, Apttus_Config2__VersionNumber__c = 1, Apttus_Config2__EffectivePriceListId__c = priceList.Id);
        insert configuration;
        
        //create line items
        list<Apttus_Config2__LineItem__c> lineItemsList = new list<Apttus_Config2__LineItem__c>();
        
        product1 = [Select Id from Product2 where Name = 'Service Technician' limit 1]; 
        Apttus_Config2__LineItem__c lineItem1 = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = configuration.Id, 
            Apttus_Config2__LineType__c = LINE_TYPE_PRODUCT_SERVICE, Apttus_Config2__LineStatus__c = LINE_STATUS_NEW, Apttus_Config2__ProductId__c = product1.Id, 
            Apttus_Config2__BasePrice__c = 1000, APTPS_Cost__c = 500, APTPS_Margin_Percentage__c = 10, 
            Apttus_Config2__ChargeType__c = 'One Time Fee', Apttus_Config2__Quantity__c = 1, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1, 
            Apttus_Config2__PrimaryLineNumber__c = 1);
        lineItemsList.add(lineItem1);
        
        product21 = [Select Id from Product2 where Name = 'Personnel Vehicle Mileage/Mile' limit 1]; 
        Apttus_Config2__LineItem__c lineItem2 = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = configuration.Id, 
            Apttus_Config2__LineType__c = LINE_TYPE_OPTION, Apttus_Config2__ParentBundleNumber__c = 1, Apttus_Config2__LineStatus__c = LINE_STATUS_NEW, 
            Apttus_Config2__ProductId__c = product21.Id, Apttus_Config2__BasePrice__c = 1000,
            APTPS_Cost__c = null, APTPS_Selling_Price__c = 600, Apttus_Config2__ChargeType__c = 'One Time Fee', 
            Apttus_Config2__Quantity__c = 60, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1, Apttus_Config2__PrimaryLineNumber__c = 2, 
            Apttus_Config2__PriceType__c = PRICE_TYPE_RECURRING);
        lineItemsList.add(lineItem2);
        
        product3 = [Select Id from Product2 where Name = 'Cab' limit 1]; 
        Apttus_Config2__LineItem__c lineItem3 = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = configuration.Id, 
            Apttus_Config2__LineType__c = 'Product/Service', Apttus_Config2__ParentBundleNumber__c = 1, Apttus_Config2__LineStatus__c = LINE_STATUS_NEW, 
            Apttus_Config2__ProductId__c = product3.Id, Apttus_Config2__BasePrice__c = 1000,
            APTPS_Cost__c = 900, APTPS_Selling_Price__c = 1500, Apttus_Config2__ChargeType__c = 'One Time Fee', 
            Apttus_Config2__Quantity__c = 1, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1, Apttus_Config2__PrimaryLineNumber__c = 3, 
            Apttus_Config2__PriceType__c = 'One Time', Apttus_Config2__AdjustmentType__c = 'Discount Amount', Apttus_Config2__AdjustedPrice__c = 10, Apttus_Config2__NetPrice__c = 1490);
        lineItemsList.add(lineItem3);
        
        
        Product2 prd2 = new product2(Name = 'APTS TST Product 222', ProductCode = 'ATP1 0002', Apttus_Config2__ConfigurationType__c = 'Standalone', IsActive = true); 
        insert prd2;
        
        Apttus_Config2__LineItem__c lineItemSO6= new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = configuration.Id, 
            Apttus_Config2__LineType__c = LINE_TYPE_PRODUCT_SERVICE
                                                           , Apttus_Config2__LineStatus__c = 'New', Apttus_Config2__PriceMethod__c = 'Per Unit'
                                                           , Apttus_Config2__ProductId__c = product3.Id, Apttus_Config2__Frequency__c = 'One Time'
                                                           , Apttus_Config2__BasePrice__c = 1000
                                                           , Apttus_Config2__Term__c = 1
                                                           , APTPS_Cost__c = 900, APTPS_Margin_Percentage__c = 10
                                                           , Apttus_Config2__ChargeType__c = 'Standard Price'
                                                           , Apttus_Config2__Quantity__c = 1, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1
                                                           , Apttus_Config2__PrimaryLineNumber__c = 1, Apttus_Config2__SellingFrequency__c = 'One Time'
                                                           , Apttus_Config2__PriceType__c = 'One Time', Apttus_Config2__TotalQuantity__c = 1, Apttus_Config2__SellingTerm__c = 1);
        insert lineItemSO6;
       
        product4 = [Select Id from Product2 where Name = 'Equipment & Tasking' limit 1]; 
        Apttus_Config2__LineItem__c lineItem4 = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = configuration.Id, 
            Apttus_Config2__LineType__c = 'Product/Service', Apttus_Config2__LineStatus__c = LINE_STATUS_NEW, 
            Apttus_Config2__ProductId__c = product4.Id, Apttus_Config2__BasePrice__c = 1000,
            APTPS_Cost__c = 900, APTPS_Selling_Price__c = 1500, Apttus_Config2__ChargeType__c = 'One Time Fee', 
            Apttus_Config2__Quantity__c = 1, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1, Apttus_Config2__PrimaryLineNumber__c = 4, 
            Apttus_Config2__PriceType__c = PRICE_TYPE_RECURRING, APTPS_Selling_Price_Previous__c = 1500);
        lineItemsList.add(lineItem4);
        
        Apttus_Config2__LineItem__c lineItem5 = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = configuration.Id, 
            Apttus_Config2__LineType__c = 'Option', Apttus_Config2__ParentBundleNumber__c = 1, Apttus_Config2__LineStatus__c = LINE_STATUS_NEW, 
            Apttus_Config2__ProductId__c = product4.Id, Apttus_Config2__BasePrice__c = 1000,
            APTPS_Cost__c = 900, APTPS_Selling_Price__c = 1500.00, Apttus_Config2__ChargeType__c = 'One Time Fee', 
            Apttus_Config2__Quantity__c = 1, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1, Apttus_Config2__PrimaryLineNumber__c = 5, 
            Apttus_Config2__PriceType__c = PRICE_TYPE_RECURRING, Apttus_Config2__NetPrice__c = 1490,
            Apttus_Config2__AdjustmentType__c = 'Discount Amount', Apttus_Config2__AdjustmentAmount__c = 10, APTPS_Margin_Percentage__c = 100, 
            Apttus_Config2__AdjustedPrice__c = 10);
        lineItemsList.add(lineItem5);
        
        insert lineItemsList;
        
        test.startTest();
        APTPS_DaikinPricingCallback callBackPricingObj = new APTPS_DaikinPricingCallback();
        callBackPricingObj.setMode(Apttus_Config2.CustomClass.PricingMode.ADJUSTMENT);
        
        Boolean result = Apttus_Config2.PricingWebService.computeBasePriceForItemColl(configuration.Id, 1);
        system.assert(result);
        
        test.stopTest();
    }
    
    static testMethod void testCustomPricingLogic1(){
        
            //create config custom class properties
            Apttus_Config2__ConfigCustomClasses__c configCustomClassesProperty = new Apttus_Config2__ConfigCustomClasses__c();
            configCustomClassesProperty.Name = 'Config Custom Classes';
            configCustomClassesProperty.Apttus_Config2__PricingCallbackClass__c = 'APTPS_DaikinPricingCallback';
            insert configCustomClassesProperty;
            
        //create Config LineItem Custom Fields properties
        Apttus_Config2__ConfigLineItemCustomFields__c configLineItemCustomFields = new Apttus_Config2__ConfigLineItemCustomFields__c();
        configLineItemCustomFields.Name = 'System Properties';
        configLineItemCustomFields.Apttus_Config2__CustomFieldNames__c = 'Apttus_Config2__ProductId__r.APTS_WRC_Percentage__c,Apttus_Config2__ProductId__r.APTS_WRC_Product__c,Apttus_Config2__ClassificationId__r.Name';
        configLineItemCustomFields.Apttus_Config2__CustomFieldNames2__c = 'APTPS_Cost__c,APTS_Option_Price__c,APTS_Roll_up_of_Total_Hours__c,Total_of_Hours__c';
        configLineItemCustomFields.Apttus_Config2__CustomFieldNames4__c = 'APTPS_Selling_Price__c,APTPS_Margin_Dollar__c,APTPS_Margin_Percentage__c,APTPS_Margin_Percentage_Previous__c';
        configLineItemCustomFields.Apttus_Config2__CustomFieldNames5__c = 'APTS_Product_Attribute_RollUp__c,Apttus_Config2__BaseExtendedCost__c,Estimated_Tax__c, Apttus_Config2__ProductId__r.APTS_Daikin_Pricing__c, Apttus_Config2__OptionId__r.APTS_Daikin_Pricing__c, Apttus_Config2__ProductId__r.APTS_ApplyOptionPrice__c';
        insert configLineItemCustomFields;
            
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
            
            String standardPricebookId =Test.getStandardPricebookId();
        
            Pricebook2 stdPriceBook = new Pricebook2(Id = standardPricebookId, IsActive = true);
            upsert stdPricebook;
        
            Id stndrdPBId = APTPS_DaikinTestDataUtility.getStandardPricebookId();
            Pricebook2 customPriceBook = new Pricebook2(Name = 'Custom Price Book', Description = 'Price Book', IsActive = true);
            insert customPriceBook;
            
            Product2 product = getProduct('TestProduct','PROD1');
            insert product;
            
            Apttus_Config2__PriceListItem__c priceListItem = getPriceListItem(priceList.Id, product.Id,null, 'Subscription Fee', 'Recurring', 'Per Unit', 'Monthly',1000);
            insert priceListItem;
            
            Contact cont = new Contact();
            cont.AccountId = accnt.ID;
            cont.FirstName = 'Diego';
            cont.LastName = 'Francis'; 
            cont.phone='1234';
            insert cont;  
            
            Apttus_Proposal__Proposal__c proposal = getQuoteHeader('TestProposal', accnt.Id, opp.Id, priceList.Id);
            insert proposal;    
            
            Apttus_Config2__ProductConfiguration__c  productConfig = getProductConfiguration('abc',1,proposal.id,'Proposal','Category',priceList.id);
            insert productConfig ;
            
            //Create cart
            Apttus_CPQApi.CPQ.CreateCartRequestDO cartRequest = new Apttus_CPQApi.CPQ.CreateCartRequestDO();   
            cartRequest.QuoteId = proposal.id ;        
            Apttus_CPQApi.CPQ.CreateCartResponseDO cartResult = Apttus_CPQApi.CPQWebService.createCart(cartRequest);
                    
            //Add Products to cart
            Apttus_CPQApi.CPQ.AddBundleRequestDO bundleRequest = new Apttus_CPQApi.CPQ.AddBundleRequestDO();
            bundleRequest.CartId = cartResult.CartId;
            bundleRequest.SelectedBundle = new Apttus_CPQApi.CPQ.SelectedBundleDO();
            bundleRequest.SelectedBundle.SelectedProduct = new Apttus_CPQApi.CPQ.SelectedProductDO();
            bundleRequest.SelectedBundle.SelectedProduct.ProductId = product.Id;
            bundleRequest.SelectedBundle.SelectedProduct.Quantity = 1;
            Apttus_CPQApi.CPQ.AddBundleResponseDO bunleResponse = Apttus_CPQApi.CPQWebService.addBundle(bundleRequest);
            
            List<Apttus_Config2__LineItem__c> lineItemList = [select Id from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c=:cartResult.CartId];
            System.assertEquals(true, lineItemList.size()>0);
            
            APTPS_DaikinPricingCallback callBackPricingObj = new APTPS_DaikinPricingCallback();
            callBackPricingObj.setMode(Apttus_Config2.CustomClass.PricingMode.ADJUSTMENT);
            //Do Pricing
            Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO pricingRequest = new Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO();
            pricingRequest.CartId = cartResult.CartId;
            pricingRequest.LineNumber = bunleResponse.LineNumber;
            Apttus_CPQApi.CPQWebService.computeNetPriceForBundle(pricingRequest);
            
            //Finalize the cart
            Apttus_CPQApi.CPQ.FinalizeCartRequestDO finReq = new Apttus_CPQApi.CPQ.FinalizeCartRequestDO();
            finReq.CartId = cartResult.CartId;
            Apttus_CPQApi.CPQ.FinalizeCartResponseDO finRes = Apttus_CPQApi.CPQWebService.finalizeCart(finReq);
            
           
    }
    
    
    
      public static Account getAccount(String name) {
            
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
    
    public static Opportunity getOpportunity(String name, Account acc) {
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = name;
        opp.vertical_market__c='Education K-12';
        opp.StageName = 'Target/Lead Verification';
        opp.CloseDate = Date.today().addDays(100);
        opp.DST_ID__c = '12345';
        return opp;
    }
    
    public static Apttus_Config2__PriceList__c getPriceList(String name) {
        
        Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c();
        priceList.Name = name;
        priceList.Apttus_Config2__EffectiveDate__c = Date.today().addDays(-300);
        priceList.Apttus_Config2__ExpirationDate__c = Date.today().addMonths(12);
        priceList.Apttus_Config2__Active__c = true;
        return priceList;
    }
    
    public static Product2 getProduct(String name,String code) {
        
       // ID rtID = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Software').getRecordTypeID();
        Product2 product = new Product2(Name=name);
        //product.RecordTypeId = rtID;
        product.ProductCode = code;
        product.Use_Tax_Applicable__c= true;
        product.Apttus_Config2__ConfigurationType__c = 'Standalone';
        product.IsActive = true;
        product.Use_Model_Materials_for_Tax__c = true;
        product.APTS_Daikin_Pricing__c = False ;
        return product; 
    }
    
    public static Apttus_Config2__PriceListItem__c getPriceListItem(Id priceListId, Id productId,Id taxCodeId,String chargeType,String priceType,String priceMethod,String Frequency,Decimal listPrice) {
        
        Apttus_Config2__PriceListItem__c priceListItem = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceListId);
        priceListItem.Apttus_Config2__ProductId__c = productId;
        priceListItem.Apttus_Config2__ChargeType__c = chargeType;
        priceListItem.Apttus_Config2__PriceType__c = priceType;
        priceListItem.Apttus_Config2__PriceMethod__c = priceMethod;
        priceListItem.Apttus_Config2__ListPrice__c = listPrice;
        priceListItem.Apttus_Config2__EffectiveDate__c = Date.today().addDays(-100);
        priceListItem.Apttus_Config2__ExpirationDate__c = Date.today().addDays(365);
        priceListItem.Apttus_Config2__Frequency__c = Frequency;
        priceListItem.Apttus_Config2__Taxable__c = true;
        priceListItem.Apttus_Config2__TaxInclusive__c = false;

        return priceListItem;
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
       // proposal.Start_Date__c = date.today();//date.parse('1/1/2015');
        //proposal.End_Date__c = date.today().addYears(1);//date.parse('1/1/2015');
        proposal.Apttus_Proposal__Payment_Term__c = 'Net 30 Days';
        proposal.Apttus_Proposal__Approval_Stage__c = 'Draft';
        proposal.Apttus_Proposal__ExpectedEndDate__c = date.today().addYears(1);//date.parse('12/31/2015');
        proposal.Apttus_QPConfig__AutoActivateOrder__c = true;
        proposal.Apttus_QPConfig__AutoCreateBill__c = true;
        proposal.Apttus_QPConfig__PriceListId__c = priceListId;
        proposal.Apttus_Proposal__Primary__c = false;
        //proposal.Apttus_QPConfig__PaymentTermId__c = paymentTermID;
//        proposal.Apttus_QPConfig__BillingPreferenceId__c = billingPrefereneID;
        return proposal;
    }
    
    public static Apttus_Config2__ProductConfiguration__c getProductConfiguration(String configName,
                                                                                  Integer versionNbr,
                                                                                  ID bObjectId,
                                                                                  String bObjectType,
                                                                                  String groupType,
                                                                                  ID priceListId
                                                                                  ){
        
        Apttus_Config2__ProductConfiguration__c configSO = new Apttus_Config2__ProductConfiguration__c(Name = configName, OwnerId = UserInfo.getUserId());
        configSO.Apttus_Config2__VersionNumber__c = versionNbr;
        configSO.Apttus_Config2__SummaryGroupType__c = groupType;
        configSO.Apttus_Config2__BusinessObjectId__c = bObjectId;
        configSO.Apttus_Config2__BusinessObjectType__c = bObjectType;
        configSO.Apttus_QPConfig__Proposald__c = bObjectId;
        configSO.Apttus_Config2__PriceListId__c = priceListId;
        //configSO.Apttus_Config2__AncestorId__c = ancestorId;
        configSO.Apttus_Config2__Status__c = 'Finalized';
        configSO.Apttus_Config2__IsTransient__c = true;
        configSO.Apttus_Config2__FinalizedDate__c = dateTime.now();
        configSO.Apttus_Config2__EffectiveDate__c = datetime.now(); 
        configSO.Apttus_Config2__Description__c = 'testdesc';
        //insert configSO;
        return configSO;
    }

}