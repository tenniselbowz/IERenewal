@isTest (seeAllData=false)
public class APTS_AvalaraTaxIntegrationTest {

       static testmethod void testAvaTaxForApex() { 
       
            AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
            ts1.AVA_SFCORE__Active_Setting__c = true; 
            ts1.Name='Test Account';
            insert ts1;

            Account accnt = getAccount('TestAccount12345678901234567890123456789012345678901234567890');//test for accounts > 50 characters
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
            
            //Do Pricing
            Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO pricingRequest = new Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO();
            pricingRequest.CartId = cartResult.CartId;
            pricingRequest.LineNumber = bunleResponse.LineNumber;
            Apttus_CPQApi.CPQWebService.computeNetPriceForBundle(pricingRequest);
            
            //Finalize the cart
            Apttus_CPQApi.CPQ.FinalizeCartRequestDO finReq = new Apttus_CPQApi.CPQ.FinalizeCartRequestDO();
            finReq.CartId = cartResult.CartId;
            Apttus_CPQApi.CPQ.FinalizeCartResponseDO finRes = Apttus_CPQApi.CPQWebService.finalizeCart(finReq);
            
            List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList = [select Id,Apttus_QPConfig__StartDate__c,Apttus_QPConfig__EndDate__c from Apttus_Proposal__Proposal_Line_Item__c where Apttus_Proposal__Proposal__c=:proposal.id];
            //System.assertEquals(true, (proposalLineItemList[0].Apttus_QPConfig__StartDate__c!=null && proposalLineItemList[0].Apttus_QPConfig__EndDate__c!=null));
            Apttus_Proposal__Proposal_Line_Item__c appli = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = proposal.Id, Apttus_QPConfig__ChargeType__c = 'Initial License Fee', Apttus_QPConfig__BasePrice__c = 100.00,Apttus_QPConfig__NetPrice__c=100,Apttus_QPConfig__Quantity2__c=2,Apttus_QPConfig__ConfigurationId__c=productConfig.id);
            insert appli;            

            TaxConnectorConfig__c taxConfig= new TaxConnectorConfig__c();
            taxConfig.Name = 'Avalara';
            taxConfig.UserName__c= '1100116219';
            taxConfig.AllowableTaxCountries__c= 'United States';
            taxConfig.Address1__c= '13600 Industrial Park Boulevard';
            taxConfig.CompanyCode__c= 'Daikin-Apttus';
            taxConfig.City__c= 'Plymouth';
            taxConfig.EnableAddressValidation__c= true;
            taxConfig.EnableAvaTax__c= true;
            taxConfig.PostalCode__c='55441' ;
            taxConfig.Password__c = '93CB48F4DB2CF18A';
            taxConfig.EndPoint__c = '';
            taxConfig.StateCode__c = 'MN';
            taxConfig.EnableDocumentCommit__c = true;
            insert taxConfig; 
            
            
            PageReference pageRef = Page.APTS_CalculateTaxFromQuote;
            pageRef.getParameters().put('Id',  proposal.id  ); 
            Test.setCurrentPage(pageRef); 
            APTS_QuoteSupport quoteSupport = New APTS_QuoteSupport ();
            quoteSupport.computeTax(); 

            
            TaxCustomClass taxCustomSo = New TaxCustomClass();
            TaxCustomClass taxCustomSo2 = New TaxCustomClass('batchCode','locatioNcode','customerCode','taxExemptionNumber','docCode','lineNumber','itemCode','itemDescription','resultCode','origcode',Date.today());
            TaxCustomClass taxCustomSo3 = New TaxCustomClass(taxCustomSo2);
            AvalaraTaxCallback.computeTax(new Apttus_Config2.CustomClass.TaxInput());
            AvalaraTaxCallback.computeTaxMultiple(new List<Apttus_Config2.CustomClass.TaxInput>{new Apttus_Config2.CustomClass.TaxInput()});
            AvalaraTaxCallback.computeTaxAndCommit(new List<Apttus_Config2.CustomClass.TaxInput>{new Apttus_Config2.CustomClass.TaxInput()});
            AvalaraTaxCallback.cancelTax(new List<Apttus_Config2.CustomClass.TaxInput>{new Apttus_Config2.CustomClass.TaxInput()});            
            AvalaraTaxCallback.ping();
            AvalaraTaxCallback.validateAddress(proposal.id, new Apttus_Config2.CustomClass.Address(), 'addressType', false);
            }
            
            
            
        static testmethod void testAvaTaxForApex1() { 

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
                                   
            Apttus_Config2__ClassificationName__c clsfcName = new Apttus_Config2__ClassificationName__c();
            clsfcName.Name = 'LP Spain';
            clsfcName.Apttus_Config2__Active__c = true;
            clsfcName.Apttus_Config2__HierarchyLabel__c = 'Service';
            clsfcName.Apttus_Config2__Type__c = 'Offering';
            insert clsfcName;
            
            Apttus_Config2__ClassificationHierarchy__c clsfHrchy = new Apttus_Config2__ClassificationHierarchy__c();
            clsfHrchy.Name = 'LP Spain';
            clsfHrchy.Apttus_Config2__HierarchyId__c =clsfcName.id;
            clsfHrchy.Apttus_Config2__Label__c = 'Offering';
            clsfHrchy.Apttus_Config2__Left__c = 1;
            clsfHrchy.Apttus_Config2__Level__c = 0;
            insert clsfHrchy;
                                  
            //Create cart
            Apttus_CPQApi.CPQ.CreateCartRequestDO cartRequest = new Apttus_CPQApi.CPQ.CreateCartRequestDO();   
            cartRequest.QuoteId = proposal.id ;        
            Apttus_CPQApi.CPQ.CreateCartResponseDO cartResult = Apttus_CPQApi.CPQWebService.createCart(cartRequest);
                        
            Apttus_Config2__ProductConfiguration__c prod = new Apttus_Config2__ProductConfiguration__c(Id = cartResult.CartId);
            prod.Apttus_Config2__BusinessObjectId__c = proposal.id;
            prod.Apttus_Config2__BusinessObjectType__c = 'Proposal';
            prod.Apttus_Config2__SummaryGroupType__c = 'Product';
            update prod;
                               
            //Add Products to cart
            Apttus_CPQApi.CPQ.AddBundleRequestDO bundleRequest = new Apttus_CPQApi.CPQ.AddBundleRequestDO();
            bundleRequest.CartId = prod.id;
            bundleRequest.SelectedBundle = new Apttus_CPQApi.CPQ.SelectedBundleDO();
            bundleRequest.SelectedBundle.SelectedProduct = new Apttus_CPQApi.CPQ.SelectedProductDO();
            bundleRequest.SelectedBundle.SelectedProduct.ProductId = product.Id;
            bundleRequest.SelectedBundle.SelectedProduct.Quantity = 1;
            Apttus_CPQApi.CPQ.AddBundleResponseDO bunleResponse = Apttus_CPQApi.CPQWebService.addBundle(bundleRequest);
                                    
            List<Apttus_Config2__LineItem__c> lineItemList = [select Id, Apttus_Config2__TaxInclusive__c,
                                                                Apttus_Config2__ConfigurationId__r.Apttus_Config2__BusinessObjectType__c,
                                                                Apttus_Config2__LineStatus__c,Apttus_Config2__ClassificationId__c,
                                                                Apttus_Config2__LineType__c
                                                                from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c=:prod.id];
            System.assertEquals(true, lineItemList.size()>0);
                          
            //Do Pricing
            Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO pricingRequest = new Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO();
            pricingRequest.CartId = cartResult.CartId;
            pricingRequest.LineNumber = bunleResponse.LineNumber;
            Apttus_CPQApi.CPQWebService.computeNetPriceForBundle(pricingRequest);
            
            Apttus_CpqApi.CPQ.UpdatePriceRequestDO req = new Apttus_CpqApi.CPQ.UpdatePriceRequestDO();
            req.CartId = prod.Id;
            Apttus_CpqApi.CPQ.UpdatePriceResponseDO result = Apttus_CpqApi.CPQWebService.updatePriceForCart(req); 
            
            List<Apttus_Config2__SummaryGroup__c> listSummaryGroup = [SELECT Id, Name, Apttus_Config2__ClassificationId__c, Apttus_Config2__LineType__c
                                                                      FROM Apttus_Config2__SummaryGroup__c];
            
            for(Apttus_Config2__SummaryGroup__c oSummary : listSummaryGroup) {
                
                if(oSummary.Name.equals('TestProduct')){
                    oSummary.Apttus_Config2__ClassificationId__c = clsfHrchy.id;
                } 
            }
            
            update listSummaryGroup;
            //Finalize the cart
            Apttus_CPQApi.CPQ.FinalizeCartRequestDO finReq = new Apttus_CPQApi.CPQ.FinalizeCartRequestDO();
            finReq.CartId = cartResult.CartId;
            Apttus_CPQApi.CPQ.FinalizeCartResponseDO finRes = Apttus_CPQApi.CPQWebService.finalizeCart(finReq);
            
        
            TaxConnectorConfig__c taxConfig= new TaxConnectorConfig__c();
            taxConfig.Name = 'Avalara';
            taxConfig.UserName__c= '1100116219';
            taxConfig.AllowableTaxCountries__c= 'United States';
            taxConfig.Address1__c= '13600 Industrial Park Boulevard';
            taxConfig.CompanyCode__c= 'Daikin-Apttus';
            taxConfig.City__c= 'Plymouth';
            taxConfig.EnableAddressValidation__c= true;
            taxConfig.EnableAvaTax__c= true;
            taxConfig.PostalCode__c='55441' ;
            taxConfig.Password__c = '93CB48F4DB2CF18A';
            taxConfig.EndPoint__c = '';
            taxConfig.StateCode__c = 'MN';
            taxConfig.EnableDocumentCommit__c = true;
            insert taxConfig; 
            
            
            // updated by Hardik Shah - Start
            PageReference pageRef1 = Page.APTS_CalculateTaxForLineItem;
            pageRef1.getParameters().put('Id',  prod.id ); 
            Test.setCurrentPage(pageRef1); 
            APTS_CalculateTaxOnLineItem calculateTaxOnLineItem = New APTS_CalculateTaxOnLineItem ();
            calculateTaxOnLineItem.computeTax();
            calculateTaxOnLineItem.cancel();
            // finish
            
            TaxCustomClass taxCustomSo = New TaxCustomClass();
            TaxCustomClass taxCustomSo2 = New TaxCustomClass('batchCode','locatioNcode','customerCode','taxExemptionNumber','docCode','lineNumber','itemCode','itemDescription','resultCode','origcode',Date.today());
            TaxCustomClass taxCustomSo3 = New TaxCustomClass(taxCustomSo2);
            AvalaraTaxCallback.computeTax(new Apttus_Config2.CustomClass.TaxInput());
            AvalaraTaxCallback.computeTaxMultiple(new List<Apttus_Config2.CustomClass.TaxInput>{new Apttus_Config2.CustomClass.TaxInput()});
            AvalaraTaxCallback.computeTaxAndCommit(new List<Apttus_Config2.CustomClass.TaxInput>{new Apttus_Config2.CustomClass.TaxInput()});
            AvalaraTaxCallback.cancelTax(new List<Apttus_Config2.CustomClass.TaxInput>{new Apttus_Config2.CustomClass.TaxInput()});            
            AvalaraTaxCallback.ping();
            AvalaraTaxCallback.validateAddress(proposal.id, new Apttus_Config2.CustomClass.Address(), 'addressType', false);
                     
            }
 
 
 
     public static Account getAccount(String name) {
            
            AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
            ts1.AVA_SFCORE__Active_Setting__c = true; 
            ts1.Name='Test Account';
            insert ts1;

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