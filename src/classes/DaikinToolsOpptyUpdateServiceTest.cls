@isTest
private class DaikinToolsOpptyUpdateServiceTest
{
    public static final Integer NUM_SIZE_PRICE_LIST = 3;
    private static List<Apttus_Config2__PriceList__c> testPriceList;
    public static Integer NUM_OPPTIES = 10;
    public static String DT_STATUS = 'Test Status';
    public static String DAIKIN_TOOLS_SOURCE = 'Daikin Tools';
    public static Integer SALES_ORDER_NUMBER = 12345;
    public static String PURCHASE_ORDER_NUM = 'TestPO Num';
    public static String PAR_NUMBER = '54321';
    public static final String OPS_SOURCE = 'OPS';
    public static DaikinToolsOpptyUpdateService.OpportunityUpdateRequest testRequest ;
    public static Long counter = 0;
    public static Apttus_Proposal__Proposal__c quote;
    public static Pricebookentry testPbe_quote;
    
    public static Id naRecordType{
        get{
            if(naRecordType == null){
                naRecordType = [Select id from RecordType Where SobjectType ='Opportunity' AND DeveloperName =: 'North_America' limit 1].id;
            }
            return naRecordType;
        }set;
    }
    
    
    public static void setup(){
        testPriceList = new List<Apttus_Config2__PriceList__c>();
        
        for(Integer i = 0; i < NUM_SIZE_PRICE_LIST; i++)
        {
            testPriceList.add(new Apttus_Config2__PriceList__c(Name='PL-' + i));
        }
        
        insert testPriceList;
    }
    
    public static void setupForQuote(boolean doUpdate){
        //DPL Added Ava sfcore stuff
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;
        
        Account testAccount = (Account) SObjectFactory.create(Account.SobjectType);//DPL Changed to this other method because doesnt fail flow
        //Account testAccount = TestingUtils.createAccounts( 1, 'Test Account', true )[0];
        Contact testContact = Testingutils.createContacts( 1, testAccount.id, true)[0];
        
        Opportunity parentOpp = (Opportunity) SObjectFactory.create(Opportunity.SobjectType, new Map<Schema.SobjectField, Object>{Opportunity.accountId =>testAccount.id, Opportunity.RecordTypeId => naRecordType, Opportunity.StageName  => 'No Bid'});//DPL Changed to this other method because doesnt fail flow
        //Opportunity parentOpp = TestingUtils.createOpportunities( 1, testAccount.Id, false )[0];
        //parentOpp.recordTypeId = naRecordType;
 
 
        Product2 testProd = new Product2( Name = 'Test Prod' );
        insert testProd;

        testPbe_quote = new Pricebookentry();

        testPbe_quote.Product2Id = testProd.Id;
        testPbe_quote.Pricebook2Id = Test.getStandardPricebookId();
        testPbe_quote.UnitPrice = 1;
        testPbe_quote.IsActive = TRUE;

        insert testPbe_quote;
        
        
        Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c (name = 'testlist');
        insert pricelist;
        
        quote = new Apttus_Proposal__Proposal__c(); 
        
        quote.Apttus_Proposal__Account__c = testAccount.id;
        quote.Apttus_Proposal__Primary_Contact__c = testContact.id;
        quote.Apttus_QPConfig__PriceListId__c = pricelist.id;
        quote.Apttus_Proposal__Opportunity__c = parentOpp.id;
        quote.Quote_Document_Date__c = Date.today();
        quote.Expiration_Date__c = Date.today();
        quote.Brand__c = 'test';
        quote.Quote_Document_Title__c = 'test';
        insert quote;
        
        if(doUpdate)
        {
            //We need to update the proposal again because Accepting a proposal is not allowed on insert.
            quote.Apttus_Proposal__Approval_Stage__c ='Accepted';
            update quote;
        }
        
    }
    
    public static void setupForPost(){
        PreventDeleteHandler.byPassTrigger = true;
        
        Account testAccount = TestingUtils.createAccounts( 1, 'Test Account', true )[0];

        testRequest = new DaikinToolsOpptyUpdateService.OpportunityUpdateRequest();
        testRequest.Source = DAIKIN_TOOLS_SOURCE;
        testRequest.Opportunities = new List<DaikinToolsOpptyUpdateService.Request_Opportunity>();

        List<Opportunity> testOpportunities = TestingUtils.createOpportunities( NUM_OPPTIES, testAccount.Id, false );
        counter = System.now().getTime();

        for( Opportunity anOpportunity : testOpportunities )
        {
            anOpportunity.DST_ID__c = '' + counter++;
            anOpportunity.Bypass__c = TRUE;
            anOpportunity.PriceBook2Id = null;
            anOpportunity.recordTypeId = naRecordType;
        }
        insert testOpportunities;

        for( Opportunity anOpportunity : testOpportunities )
        {
            DaikinToolsOpptyUpdateService.Request_Opportunity newOpportunity = new DaikinToolsOpptyUpdateService.Request_Opportunity();
            newOpportunity.CustomerPurchaseOrderNumber = PURCHASE_ORDER_NUM;
            newOpportunity.JobGuid = anOpportunity.DST_ID__c;
            newOpportunity.SFDCID = anOpportunity.Id;
            newOpportunity.OrderStatus = DT_STATUS;
            newOpportunity.SalesOrderNumber = SALES_ORDER_NUMBER;
            newOpportunity.PARNumber = PAR_NUMBER;
            newOpportunity.Addresses = new List<DaikinToolsOpptyUpdateService.Request_OpportunityAddress>{ DaikinToolsTestingUtils.createTestAddress( DaikinToolsTestingUtils.TEST_ADDRESS_TYPE_END ) };
            newOpportunity.SalesPeople = new List<DaikinToolsOpptyUpdateService.Request_OpportunitySalesPerson>{ DaikinToolsTestingUtils.createTestSalesPerson( DaikinToolsTestingUtils.TEST_SALESPERSON_INSIDE_TYPE ), DaikinToolsTestingUtils.createTestSalesPerson( DaikinToolsTestingUtils.TEST_SALESPERSON_OUTSIDE_TYPE )  };
            newOpportunity.Items = new List<DaikinToolsOpptyUpdateService.Request_OpportunityItem>{ DaikinToolsTestingUtils.createTestOLI(counter) };
            testRequest.Opportunities.add( newOpportunity );
            counter++;
        }
    }
    
    
    static testMethod void testDoPost()
    {   
        setup();
        setupForPost();

        RestContext.request = new System.RestRequest();
        RestContext.request.requestBody = Blob.valueOf( JSON.serialize(testRequest) );

        Test.startTest();

            DaikinToolsOpptyUpdateService.DEFAULT_PRICEBOOK_ID = Test.getStandardPricebookId();
            RestContext.response = new System.RestResponse();
            DaikinToolsOpptyUpdateService.doPost();

        Test.stopTest();

        List<Opportunity> updatedOpportunities = [ SELECT Id, PriceBook2Id, DST_ID__c, SO_Number__c, PAR_Number__c,
                                                   DT_Order_Status__c, DT_END_Address_Contact__c,
                                                   DT_END_Address_ID__c, DT_END_Address_Line_1__c, DT_END_Address_Line_2__c,
                                                   DT_END_Address_Line_3__c, DT_END_Address_Line_4__c, DT_END_Address_Name__c,
                                                   DT_END_Address_Phone__c, DT_END_Address_Special_Delivery_Comments__c,
                                                   DT_END_Address_Validated__c, DT_END_City__c, DT_END_Contact_Email_Address__c,
                                                   DT_END_Country__c, DT_END_County__c, DT_END_Fax__c, DT_END_Hours_Before__c, DT_END_Postal_Code__c,
                                                   DT_END_State__c, DT_IS_First_Name__c, DT_IS_Last_Name__c, DT_IS_ID__c, DT_OSP_First_Name__c,
                                                   DT_OSP_Last_Name__c, DT_OSP_ID__c, CustomerPurchaseOrderNumber__c,
                                                    (SELECT DST_ID__c, OpportunityId, IsAlternate__c, DT_Parent_ID__c, Quantity, TotalPrice, List_Price__c,
                                                            TAG__c, DT_App_Key__c, DT_Format_Number__c, DT_Item_Status__c, Custom_Description__c,
                                                            Discount__c, NetPrice__c, UnitPrice, PricebookEntryId, DT_Code_Item__c, DT_InputsAndOutputs__c,
                                                            Item_Number__c, DT_PCL__c, Multiplier_PAR__c, Is_Priced__c, Is_Stock__c,
                                                            Is_Quick_Ship__c, Is_Not_Found__c, Is_Outside_Vendor__c, Requested_Ship_Date__c
                                                            FROM OpportunityLineItems )
                                                   FROM Opportunity ];

        //System.assert(false, [SELECT Id, OpportunityId FROM OpportunityLineItem ]); 

        System.assertEquals( NUM_OPPTIES, updatedOpportunities.size(), 'There should be as many opportunities retrieved as were created' );

        for( Opportunity anOpportunity : updatedOpportunities )
        {
            System.assertNotEquals( null, anOpportunity.DST_ID__c, 'When passed through a post call the external id should still exist' );
            System.assertEquals( DT_STATUS, anOpportunity.DT_Order_Status__c, 'When passed through a Post call the Order Status should be updated' );
            System.assertEquals( SALES_ORDER_NUMBER, anOpportunity.SO_Number__c, 'When passed through a Post call the SO Number should be updated' );
            System.assertEquals( Decimal.valueOf(PAR_NUMBER), anOpportunity.PAR_Number__c, 'When passed through a Post call the PAR Number should be updated' );
            System.assertEquals( DaikinToolsOpptyUpdateService.DEFAULT_PRICEBOOK_ID, anOpportunity.PriceBook2Id, 'When passed through a Post call the PricebookID should be set if it is not' );
            System.assertEquals( PURCHASE_ORDER_NUM, anOpportunity.CustomerPurchaseOrderNumber__c, 'When passed through a post call the Customer Purchase Order Number should be updated');

            //Testing the address info
            System.assertEquals( DaikinToolsTestingUtils.TEST_CONTACT, anOpportunity.DT_END_Address_Contact__c, 'The address contact should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_ADDRESS_ID, anOpportunity.DT_END_Address_ID__c, 'The address id should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_ADDRESS_LINE_1, anOpportunity.DT_END_Address_Line_1__c, 'The address line 1 should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_ADDRESS_LINE_2, anOpportunity.DT_END_Address_Line_2__c, 'The address line2 should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_ADDRESS_LINE_3, anOpportunity.DT_END_Address_Line_3__c, 'The address line 3 should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_ADDRESS_LINE_4, anOpportunity.DT_END_Address_Line_4__c, 'The address line 4 should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_NAME, anOpportunity.DT_END_Address_Name__c, 'The address name should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_PHONE, anOpportunity.DT_END_Address_Phone__c, 'The address phone should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_SPECIAL_DELIVERY_COMMENTS, anOpportunity.DT_END_Address_Special_Delivery_Comments__c, 'The address spec deliv should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_VALIDATED, anOpportunity.DT_END_Address_Validated__c, 'The address validated should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_CITY, anOpportunity.DT_END_City__c, 'The address city should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_EMAILADDRESS, anOpportunity.DT_END_Contact_Email_Address__c, 'The address email add should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_COUNTRY, anOpportunity.DT_END_Country__c, 'The address country should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_COUNTY, anOpportunity.DT_END_County__c, 'The address county should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_FAX, anOpportunity.DT_END_Fax__c, 'The address fax should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_HOURS_BEFORE, anOpportunity.DT_END_Hours_Before__c, 'The address hours before should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_POSTAL_CODE, anOpportunity.DT_END_Postal_Code__c, 'The address postal code should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_STATE, anOpportunity.DT_END_State__c, 'The address state should be correctly set' );

            //Testing the salesperson info
            System.assertEquals( DaikinToolsTestingUtils.TEST_SALESPERSON_INSIDE_FNAME, anOpportunity.DT_IS_First_Name__c, 'The inside firstname should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_SALESPERSON_INSIDE_LNAME, anOpportunity.DT_IS_Last_Name__c, 'The inside lastname should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_SALESPERSON_INSIDE_ID, anOpportunity.DT_IS_ID__c, 'The inside Id should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_SALESPERSON_OUTSIDE_FNAME, anOpportunity.DT_OSP_First_Name__c, 'The outside firstname  should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_SALESPERSON_OUTSIDE_LNAME, anOpportunity.DT_OSP_Last_Name__c, 'The outside lastname should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_SALESPERSON_OUTSIDE_ID, anOpportunity.DT_OSP_ID__c, 'The outside Id should be correctly set' );

            //OLI assertions
            System.assertEquals( 1, anOpportunity.opportunityLineItems.size(), 'There should be one line item');

            for( OpportunityLineItem olifound : anOpportunity.opportunityLineItems )
            {
                System.assertNotEquals( null, olifound.DST_ID__c, 'The oli guid should be correctly set' );
                System.assertEquals( false, olifound.IsAlternate__c, 'The oli alternate flag should be correctly set' );
                System.assertEquals( DaikinToolsTestingUtils.TEST_OLI_PARENT_GUID, olifound.DT_Parent_ID__c, 'The oli parent guid should be correctly set' );
                System.assertEquals( DaikinToolsTestingUtils.TEST_OLI_QUANTITY, olifound.Quantity, 'The oli qty should be correctly set' );
                System.assertEquals( DaikinToolsTestingUtils.TEST_OLI_LIST_PRICE, olifound.List_Price__c, 'The oli list price should be correctly set' );
                System.assertEquals( DaikinToolsTestingUtils.TEST_OLI_BASE_TAG, olifound.TAG__c, 'The oli tag should be correctly set' );
                System.assertEquals( DaikinToolsTestingUtils.TEST_OLI_APP_KEY, olifound.DT_App_Key__c, 'The oli app key should be correctly set' );
                System.assertEquals( DaikinToolsTestingUtils.TEST_OLI_FORMAT_NUMBER, olifound.DT_Format_Number__c, 'The oli format should be correctly set' );

                System.assertEquals( DaikinToolsTestingUtils.TEST_OLI_ITEM_NUMBER, olifound.Item_Number__c, 'The oli item number should be correctly set' );
                System.assertEquals( DaikinToolsTestingUtils.TEST_OLI_DT_PCL, olifound.DT_PCL__c, 'The oli DT PCL should be correctly set' );
                System.assertEquals( DaikinToolsTestingUtils.TEST_OLI_MULT_PAR, olifound.Multiplier_PAR__c, 'The oli Multiplier PAR should be correctly set' );
                System.assertEquals( DaikinToolsTestingUtils.TEST_OLI_IS_PRICED, olifound.Is_Priced__c, 'The is Priced checkbox should be correctly set' );
                System.assertEquals( DaikinToolsTestingUtils.TEST_OLI_IS_STOCK, olifound.Is_Stock__c, 'The is Stocked checkbox should be correctly set' );
                System.assertEquals( DaikinToolsTestingUtils.TEST_OLI_IS_QUICK_SHIP, olifound.Is_Quick_Ship__c, 'The is Quick Ship checkbox should be correctly set' );
                System.assertEquals( DaikinToolsTestingUtils.TEST_OLI_IS_NOT_FOUND, olifound.Is_Not_Found__c, 'The is Not Found checkbox should be correctly set' );
                System.assertEquals( DaikinToolsTestingUtils.TEST_OLI_IS_OUTSIDE_VENDOR, olifound.Is_Outside_Vendor__c, 'The is Outside Vendor checkbox should be correctly set' );
                System.assertEquals( DaikinToolsOpptyUpdateService.convertStringToDate(DaikinToolsTestingUtils.TEST_OLI_REQ_SHIP_DATE), olifound.Requested_Ship_Date__c, 'The is Requested Ship Date checkbox should be correctly set' );

                System.assertEquals( DaikinToolsTestingUtils.TEST_OLI_ITEM_STATUS, olifound.DT_Item_Status__c, 'The oli status should be correctly set' );
                System.assertEquals( DaikinToolsTestingUtils.TEST_OLI_MODEL_DESC, olifound.Custom_Description__c, 'The oli desc should be correctly set' );
                System.assertEquals( DaikinToolsTestingUtils.TEST_OLI_QTY_DISC_FACT, olifound.Discount__c, 'The oli discount factor should be correctly set' );
                System.assertEquals( DaikinToolsTestingUtils.TEST_OLI_NET_PRICE, olifound.NetPrice__c, 'The oli net price should be correctly set' );
                System.assertNotEquals( null, olifound.PricebookEntryId, 'The oli guid should be correctly set' );

                System.assertNotEquals( null, olifound.DT_Code_Item__c, 'The code item cannot be null' );
                System.assert(olifound.DT_Code_Item__c.contains(String.valueOf(DaikinToolsTestingUtils.TEST_OLI_CODE_ITEMS_ITEM)), 'The code item is missing item');
                System.assert(olifound.DT_Code_Item__c.contains(DaikinToolsTestingUtils.TEST_OLI_CODE_ITEMS_DESCRIPTION), 'The code item is missing description');
                System.assert(olifound.DT_Code_Item__c.contains(DaikinToolsTestingUtils.TEST_OLI_CODE_ITEMS_VALUE), 'The code item is missing item value');
                System.assert(olifound.DT_Code_Item__c.contains(DaikinToolsTestingUtils.TEST_OLI_CODE_ITEMS_VAL_DESCRIP), 'The code item is missing item description');
                System.assert(olifound.DT_Code_Item__c.contains(String.valueOf(DaikinToolsTestingUtils.TEST_OLI_CODE_ITEMS_LIST_PRICE)), 'The code item is missing list price');
                System.assert(olifound.DT_Code_Item__c.contains(String.valueOf(DaikinToolsTestingUtils.TEST_OLI_CODE_ITEMS_IS_SPECIAL)), 'The code item is missing is special value');
                System.assert(olifound.DT_Code_Item__c.contains(DaikinToolsTestingUtils.TEST_OLI_CODE_ITEMS_SPECIAL_TEXT), 'The code item is missing special text');

                System.assertNotEquals( null, olifound.DT_InputsAndOutputs__c, 'The input and output item cannot be null' );
                System.assert(olifound.DT_InputsAndOutputs__c.contains(DaikinToolsTestingUtils.TEST_REQ_OPP_PROPERTY_NAME), 'The inputs and outputs is missing the property name');
                System.assert(olifound.DT_InputsAndOutputs__c.contains(DaikinToolsTestingUtils.TEST_REQ_OPP_PROPERTY_VALUE), 'The inputs and outputs is missing the property value');
                System.assert(olifound.DT_InputsAndOutputs__c.contains(DaikinToolsTestingUtils.TEST_REQ_OPP_PROPERTY_DESCRIPTION), 'The inputs and outputs is missing the property description');

                System.assert(olifound.DT_InputsAndOutputs__c.contains(DaikinToolsTestingUtils.TEST_OPP_COMPONENT_PROP_NAME), 'The inputs and outputs is missing the component property name');
                System.assert(olifound.DT_InputsAndOutputs__c.contains(DaikinToolsTestingUtils.TEST_OPP_COMPONENT_PROP_VALUE), 'The inputs and outputs is missing the component property value');
                System.assert(olifound.DT_InputsAndOutputs__c.contains(DaikinToolsTestingUtils.TEST_OPP_COMPONENT_PROP_DESCRIP), 'The inputs and outputs is missing the component property description');
                System.assert(olifound.DT_InputsAndOutputs__c.contains(String.valueOf(DaikinToolsTestingUtils.TEST_OPP_COMPONENT_ID)), 'The inputs and outputs is missing the component property Id');
                System.assert(olifound.DT_InputsAndOutputs__c.contains(String.valueOf(DaikinToolsTestingUtils.TEST_OPP_COMPONENT_TYPE)), 'The inputs and outputs is missing the component property type');

            }
        }
        
        List<Apttus_Config2__PriceListItem__c> listOfPriceListItems = [SELECT Id, Apttus_Config2__ProductId__c, Apttus_Config2__PriceListId__c 
                                                                    FROM Apttus_Config2__PriceListItem__c];
        List<Product2> listOfProducts = [SELECT Id FROM Product2];
        
        System.assertNotEquals(null, listOfPriceListItems, 'We expect there to be a price list item for every price list and product.');
        System.assertEquals(listOfProducts.size() * NUM_SIZE_PRICE_LIST, listOfPriceListItems.size(), 'We expect the number of price line items will equal to the number of products times price list');
    }
    
     static testMethod void testDoPost_WithAccessories()
    {   
        setup();
        setupForPost();
        DaikinToolsOpptyUpdateService.Request_OpportunityAccessory accessory;
        accessory = new DaikinToolsOpptyUpdateService.Request_OpportunityAccessory();
        accessory.ListPrice = 100;
        accessory.itemNumber = 'acc10';
        accessory.partNumber = 'acc10';
        accessory.description = 'Accessory Description';
        accessory.quantity = 1;
        accessory.guid = ''+ (counter++); 
        
        testRequest.Opportunities[0].items[0].Accessories = new List<DaikinToolsOpptyUpdateService.Request_OpportunityAccessory>{accessory};
        
        RestContext.request = new System.RestRequest();
        RestContext.request.requestBody = Blob.valueOf( JSON.serialize(testRequest) );

        Test.startTest();

            DaikinToolsOpptyUpdateService.DEFAULT_PRICEBOOK_ID = Test.getStandardPricebookId();
            RestContext.response = new System.RestResponse();
            DaikinToolsOpptyUpdateService.doPost();

        Test.stopTest();
        
        Set<String> expectedModelNumbers = new Set<String>{accessory.partNumber, testRequest.Opportunities[0].items[0].modelNumber};
        Set<String> expectedGuids = new Set<String>{accessory.guid, testRequest.Opportunities[0].items[0].guid};
        
        List<Opportunity> updatedOpportunities = [ SELECT Id,
                                                    (SELECT DST_ID__c, Product2id, Misc_Add_On_One_Amount__c, Misc_Add_On_One_Type__c
                                                            FROM OpportunityLineItems Order by Misc_Add_On_One_Amount__c DESC NULLS LAST)
                                                   FROM Opportunity ];
        List<Product2> products = [Select id, productcode from Product2];
        
        System.assertEquals( NUM_OPPTIES, updatedOpportunities.size(), 'There should be as many opportunities retrieved as were created.' );
        List<OpportunityLineItem> lineItems = updatedOpportunities[0].OpportunityLineItems; 
        
        System.assertEquals(2, lineItems.size(), 'Two line Item');
        System.assertEquals(expectedModelNumbers, Pluck.strings('productcode', products), 'An incorrect product code was inserted into our products.');
        System.assertEquals(expectedGuids, Pluck.strings('DST_ID__c', lineItems), 'An incorrect Daikin ID was inserted into our line items.' );
        
        System.AssertEquals(100, lineItems[0].Misc_Add_On_One_Amount__c );
        System.AssertEquals('Part', lineItems[0].Misc_Add_On_One_Type__c );
        System.AssertEquals(null, lineItems[1].Misc_Add_On_One_Amount__c );
        System.AssertEquals(null, lineItems[1].Misc_Add_On_One_Type__c );
        
    }
    
  //  static testMethod void testDoPost_RemoveDST()
  //  {   
  //      //setup();
  //      setupForPost();
  //      setupForQuote(false);
        
  //      /*DaikinToolsOpptyUpdateService.Request_OpportunityAccessory accessory;
  //      accessory = new DaikinToolsOpptyUpdateService.Request_OpportunityAccessory();
  //      accessory.ListPrice = 100;
  //      accessory.itemNumber = 'acc10';
  //      accessory.partNumber = 'acc10';
  //      accessory.description = 'Accessory Description';
  //      accessory.quantity = 1;
  //      accessory.guid = ''+ (counter++); 
  //      */
        
  //      Opportunity opp = [SELECT Id, Name FROM Opportunity LIMIT 1];
  //      opp.Synced_Quote_Proposal__c = quote.id;
  //      opp.RecordType = [SELECT Id FROM RecordType WHERE DeveloperName NOT IN : DaikinToolsOpptyValidationService.LATIN_AM_RECORD_TYPE ][0];
  //      update opp;
        
  //      OpportunityLineItem olisForOppty = Testingutils.createOpportunityLineItems (1, opp.Id, testPbe_quote.Id, false)[0];
  //      olisForOppty.DST_ID__c = '12345';
  //      insert olisForOppty;
        
  //      //testRequest.Opportunities[0].items[0].Accessories = new List<DaikinToolsOpptyUpdateService.Request_OpportunityAccessory>{accessory};
        
  //      RestContext.request = new System.RestRequest();
  //      RestContext.request.requestBody = Blob.valueOf( JSON.serialize(testRequest) );

  //      Test.startTest();

  //          DaikinToolsOpptyUpdateService.DEFAULT_PRICEBOOK_ID = Test.getStandardPricebookId();
  //          RestContext.response = new System.RestResponse();
  //          DaikinToolsOpptyUpdateService.doPost();

  //      Test.stopTest();
        
        
  //      List<Opportunity> updatedOpportunities = [ SELECT Id,
  //                                                  (SELECT DST_ID__c, Product2id, Misc_Add_On_One_Amount__c, Misc_Add_On_One_Type__c
  //                                                          FROM OpportunityLineItems WHERE DST_ID__C = null)
  //                                                 FROM Opportunity WHERE Id =: opp.Id];
  //      List<Product2> products = [Select id, productcode from Product2];
        
  //      System.assertEquals( 1, updatedOpportunities.size(), 'There should be one opportunity retrieved.' );
        
  //      List<OpportunityLineItem> lineItems = updatedOpportunities[0].OpportunityLineItems; 
  //      System.assertEquals(1, lineItems.size(), 'We expect only one line item to be returned.');
  //      System.assertEquals(NULL, lineItems[0].DST_ID__c, 'We expect the id to be nulled out.');
        
  //  }

  //  static testMethod void testDoPost_Header_Level()
  //  {   
  //    PreventDeleteHandler.byPassTrigger = true;
        
  //    NUM_OPPTIES = 1;
  //    counter = 5;
        
  //      setup();
  //      setupForPost();
  //      setupForQuote(true);
                
  //      DaikinToolsOpptyUpdateService.Request_OpportunityAccessory accessory;
  //      accessory = new DaikinToolsOpptyUpdateService.Request_OpportunityAccessory();
  //      accessory.ListPrice = 100;
  //      accessory.itemNumber = 'acc10';
  //      accessory.partNumber = 'acc10';
  //      accessory.description = 'Accessory Description';
  //      accessory.quantity = 1;
  //      accessory.guid = ''+ (counter++); 
  //      newOpportunity.Items = new List<DaikinToolsOpptyUpdateService.Request_OpportunityItem>{ DaikinToolsTestingUtils.createTestOLI(counter), DaikinToolsTestingUtils.createTestOLI(++counter) };
        
        
  //      Opportunity opp = [SELECT Id, Name FROM Opportunity LIMIT 1];
  //      opp.Synced_Quote_Proposal__c = quote.id;
  //      opp.Do_Not_Sync_Line_Items__c = false;
  //      opp.Linked_to_DT__c = false;
  //      update opp;
        
  //      List<OpportunityLineItem> olisForOppty = Testingutils.createOpportunityLineItems (5, opp.Id, testPbe_quote.Id, false);
  //      UnitTest.addData(olisForOppty).tag('OLIs').assign('Quantity', 5);
  //      insert olisForOppty;
        
  //      for(OpportunityLineItem oli : olisForOppty)
  //        System.debug('Olis!!: ' + oli);
                
  //      RestContext.request = new System.RestRequest();
  //      RestContext.request.requestBody = Blob.valueOf( JSON.serialize(testRequest) );

  //      Test.startTest();

  //          DaikinToolsOpptyUpdateService.DEFAULT_PRICEBOOK_ID = Test.getStandardPricebookId();
  //          RestContext.response = new System.RestResponse();
  //          DaikinToolsOpptyUpdateService.doPost();

  //      Test.stopTest();
        
        
  //      List<Opportunity> updatedOpportunities = [ SELECT Id, Do_Not_Sync_Line_Items__c, Linked_to_DT__c,
  //                                                  (SELECT DST_ID__c, Product2id, Misc_Add_On_One_Amount__c, Quantity, Misc_Add_On_One_Type__c
  //                                                          FROM OpportunityLineItems)
  //                                                 FROM Opportunity WHERE Id =: opp.Id];
  //      List<Product2> products = [Select id, productcode from Product2];
        
  //      System.assertEquals( 1, updatedOpportunities.size(), 'There should be one opportunity retrieved.' );
        
  //      List<OpportunityLineItem> lineItems = updatedOpportunities[0].OpportunityLineItems; 
  //      //System.assertEquals(olisForOppty.size(), lineItems.size(), 'We expect the same number of line items to be returned.');
  //      for(OpportunityLineItem oli : lineItems)
  //        System.assertEquals( 5, oli.Quantity, 'We expect the olis quantity to be not be synced.');
        //System.assertEquals(true, updatedOpportunities[0].Do_Not_Sync_Line_Items__c, 'We expect the Do Not Sync boolean to be set to true.');
        //System.assertEquals(true, updatedOpportunities[0].Linked_to_DT__c, 'We expect the Opp to be now be linked.');   
  //  }
    
    static testMethod void testDoPost_SourceOPS()
    {
        setup();
        setupForQuote(false);
        
        PreventDeleteHandler.byPassTrigger = true;
  
        Account testAccount = TestingUtils.createAccounts( 1, 'Test Account', true )[0];
        
        testRequest = new DaikinToolsOpptyUpdateService.OpportunityUpdateRequest();
        testRequest.Source = OPS_SOURCE;
        testRequest.Opportunities = new List<DaikinToolsOpptyUpdateService.Request_Opportunity>();

        List<Opportunity> testOpportunities = TestingUtils.createOpportunities( NUM_OPPTIES, testAccount.Id, false );
        counter = System.now().getTime();
        Integer halfCounter = 0;
        for( Opportunity anOpportunity : testOpportunities )
        {
            anOpportunity.DST_ID__c = '' + counter++;
            anOpportunity.Bypass__c = TRUE;
            anOpportunity.PriceBook2Id = null;
            anOpportunity.recordTypeId = naRecordType;
            
            if(halfCounter >= testOpportunities.size() / 2)
            {
                anOpportunity.Synced_Quote_Proposal__c = quote.id;
            }
            halfCounter++;
        }
        
        insert testOpportunities;

        for( Opportunity anOpportunity : testOpportunities )
        {
            DaikinToolsOpptyUpdateService.Request_Opportunity newOpportunity = new DaikinToolsOpptyUpdateService.Request_Opportunity();
            newOpportunity.CustomerPurchaseOrderNumber = PURCHASE_ORDER_NUM;
            newOpportunity.JobGuid = anOpportunity.DST_ID__c;
            newOpportunity.SFDCID = anOpportunity.Id;
            newOpportunity.OrderStatus = DT_STATUS;
            newOpportunity.SalesOrderNumber = SALES_ORDER_NUMBER;
            newOpportunity.Addresses = new List<DaikinToolsOpptyUpdateService.Request_OpportunityAddress>{ DaikinToolsTestingUtils.createTestAddress( DaikinToolsTestingUtils.TEST_ADDRESS_TYPE_END ) };
            newOpportunity.SalesPeople = new List<DaikinToolsOpptyUpdateService.Request_OpportunitySalesPerson>{ DaikinToolsTestingUtils.createTestSalesPerson( DaikinToolsTestingUtils.TEST_SALESPERSON_INSIDE_TYPE ), DaikinToolsTestingUtils.createTestSalesPerson( DaikinToolsTestingUtils.TEST_SALESPERSON_OUTSIDE_TYPE )  };
            newOpportunity.Items = new List<DaikinToolsOpptyUpdateService.Request_OpportunityItem>{ DaikinToolsTestingUtils.createTestOLI(counter) };
            
            testRequest.Opportunities.add( newOpportunity );
            
            counter++;
        }

        RestContext.request = new System.RestRequest();
        RestContext.request.requestBody = Blob.valueOf( JSON.serialize(testRequest) );

        Test.startTest();

            DaikinToolsOpptyUpdateService.DEFAULT_PRICEBOOK_ID = Test.getStandardPricebookId();
            RestContext.response = new System.RestResponse();
            DaikinToolsOpptyUpdateService.doPost();

        Test.stopTest();

        List<Opportunity> updatedOpportunities = [ SELECT Id, PriceBook2Id, DST_ID__c, SO_Number__c,
                                                   DT_Order_Status__c, DT_END_Address_Contact__c,
                                                   DT_END_Address_ID__c, DT_END_Address_Line_1__c, DT_END_Address_Line_2__c,
                                                   DT_END_Address_Line_3__c, DT_END_Address_Line_4__c, DT_END_Address_Name__c,
                                                   DT_END_Address_Phone__c, DT_END_Address_Special_Delivery_Comments__c,
                                                   DT_END_Address_Validated__c, DT_END_City__c, DT_END_Contact_Email_Address__c,
                                                   DT_END_Country__c, DT_END_County__c, DT_END_Fax__c, DT_END_Hours_Before__c, DT_END_Postal_Code__c,
                                                   DT_END_State__c, DT_IS_First_Name__c, DT_IS_Last_Name__c, DT_IS_ID__c, DT_OSP_First_Name__c,
                                                   DT_OSP_Last_Name__c, DT_OSP_ID__c, CustomerPurchaseOrderNumber__c,
                                                    (SELECT DST_ID__c, OpportunityId, IsAlternate__c, DT_Parent_ID__c, Quantity, TotalPrice, List_Price__c,
                                                            TAG__c, DT_App_Key__c, DT_Format_Number__c, DT_Item_Status__c, Custom_Description__c,
                                                            Discount__c, NetPrice__c, UnitPrice, PricebookEntryId, DT_Code_Item__c, DT_InputsAndOutputs__c,
                                                            Item_Number__c, DT_PCL__c, Multiplier_PAR__c, Is_Priced__c, Is_Stock__c,
                                                            Is_Quick_Ship__c, Is_Not_Found__c, Is_Outside_Vendor__c, Requested_Ship_Date__c
                                                            FROM OpportunityLineItems )
                                                   FROM Opportunity WHERE Id IN :testOpportunities];

        System.assertEquals( NUM_OPPTIES, updatedOpportunities.size(), 'There should be as many opportunities retrieved as were created' );

        for( Opportunity anOpportunity : updatedOpportunities )
        {
            System.assertNotEquals( null, anOpportunity.DST_ID__c, 'When passed through a post call the external id should still exist' );
            
            System.assertEquals( DT_STATUS, anOpportunity.DT_Order_Status__c, 'When passed through a Post call the Order Status should be updated' );
            System.assertEquals( SALES_ORDER_NUMBER, anOpportunity.SO_Number__c, 'When passed through a Post call the SO Number should be updated' );
            System.assertEquals( DaikinToolsOpptyUpdateService.DEFAULT_PRICEBOOK_ID, anOpportunity.PriceBook2Id, 'When passed through a Post call the PricebookID should be set if it is not' );
            System.assertEquals( PURCHASE_ORDER_NUM, anOpportunity.CustomerPurchaseOrderNumber__c, 'When passed through a post call the Customer Purchase Order Number should be updated');

            //Testing the address info
            System.assertEquals( DaikinToolsTestingUtils.TEST_CONTACT, anOpportunity.DT_END_Address_Contact__c, 'The address contact should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_ADDRESS_ID, anOpportunity.DT_END_Address_ID__c, 'The address id should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_ADDRESS_LINE_1, anOpportunity.DT_END_Address_Line_1__c, 'The address line 1 should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_ADDRESS_LINE_2, anOpportunity.DT_END_Address_Line_2__c, 'The address line2 should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_ADDRESS_LINE_3, anOpportunity.DT_END_Address_Line_3__c, 'The address line 3 should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_ADDRESS_LINE_4, anOpportunity.DT_END_Address_Line_4__c, 'The address line 4 should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_NAME, anOpportunity.DT_END_Address_Name__c, 'The address name should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_PHONE, anOpportunity.DT_END_Address_Phone__c, 'The address phone should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_SPECIAL_DELIVERY_COMMENTS, anOpportunity.DT_END_Address_Special_Delivery_Comments__c, 'The address spec deliv should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_VALIDATED, anOpportunity.DT_END_Address_Validated__c, 'The address validated should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_CITY, anOpportunity.DT_END_City__c, 'The address city should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_EMAILADDRESS, anOpportunity.DT_END_Contact_Email_Address__c, 'The address email add should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_COUNTRY, anOpportunity.DT_END_Country__c, 'The address country should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_COUNTY, anOpportunity.DT_END_County__c, 'The address county should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_FAX, anOpportunity.DT_END_Fax__c, 'The address fax should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_HOURS_BEFORE, anOpportunity.DT_END_Hours_Before__c, 'The address hours before should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_POSTAL_CODE, anOpportunity.DT_END_Postal_Code__c, 'The address postal code should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_STATE, anOpportunity.DT_END_State__c, 'The address state should be correctly set' );

            //Testing the salesperson info
            System.assertEquals( DaikinToolsTestingUtils.TEST_SALESPERSON_INSIDE_FNAME, anOpportunity.DT_IS_First_Name__c, 'The inside firstname should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_SALESPERSON_INSIDE_LNAME, anOpportunity.DT_IS_Last_Name__c, 'The inside lastname should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_SALESPERSON_INSIDE_ID, anOpportunity.DT_IS_ID__c, 'The inside Id should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_SALESPERSON_OUTSIDE_FNAME, anOpportunity.DT_OSP_First_Name__c, 'The outside firstname  should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_SALESPERSON_OUTSIDE_LNAME, anOpportunity.DT_OSP_Last_Name__c, 'The outside lastname should be correctly set' );
            System.assertEquals( DaikinToolsTestingUtils.TEST_SALESPERSON_OUTSIDE_ID, anOpportunity.DT_OSP_ID__c, 'The outside Id should be correctly set' );

            //OLI assertions
            System.assertEquals( 1, anOpportunity.opportunityLineItems.size(), 'There should be one line item');

            for( OpportunityLineItem olifound : anOpportunity.opportunityLineItems )
            {
                System.assertNotEquals( null, olifound.DST_ID__c, 'The oli guid should be correctly set' );
                System.assertEquals( DaikinToolsTestingUtils.TEST_OLI_PARENT_GUID, olifound.DT_Parent_ID__c, 'The oli parent guid should be correctly set' );
                System.assertEquals( DaikinToolsTestingUtils.TEST_OLI_QUANTITY, olifound.Quantity, 'The oli qty should be correctly set' );
                //System.assertEquals( DaikinToolsTestingUtils.TEST_OLI_LIST_PRICE, olifound.TotalPrice, 'The oli total price should be correctly set' );
                System.assertEquals( DaikinToolsTestingUtils.TEST_OLI_LIST_PRICE, olifound.List_Price__c, 'The oli list price should be correctly set' );
                System.assertEquals( DaikinToolsTestingUtils.TEST_OLI_BASE_TAG, olifound.TAG__c, 'The oli tag should be correctly set' );
                System.assertEquals( DaikinToolsTestingUtils.TEST_OLI_APP_KEY, olifound.DT_App_Key__c, 'The oli app key should be correctly set' );
                System.assertEquals( DaikinToolsTestingUtils.TEST_OLI_FORMAT_NUMBER, olifound.DT_Format_Number__c, 'The oli format should be correctly set' );

                //added
                System.assertEquals( DaikinToolsTestingUtils.TEST_OLI_ITEM_NUMBER, olifound.Item_Number__c, 'The oli item number should be correctly set' );
                System.assertEquals( DaikinToolsTestingUtils.TEST_OLI_DT_PCL, olifound.DT_PCL__c, 'The oli DT PCL should be correctly set' );
                System.assertEquals( DaikinToolsTestingUtils.TEST_OLI_MULT_PAR, olifound.Multiplier_PAR__c, 'The oli Multiplier PAR should be correctly set' );
                System.assertEquals( DaikinToolsTestingUtils.TEST_OLI_IS_PRICED, olifound.Is_Priced__c, 'The is Priced checkbox should be correctly set' );
                System.assertEquals( DaikinToolsTestingUtils.TEST_OLI_IS_STOCK, olifound.Is_Stock__c, 'The is Stocked checkbox should be correctly set' );
                System.assertEquals( DaikinToolsTestingUtils.TEST_OLI_IS_QUICK_SHIP, olifound.Is_Quick_Ship__c, 'The is Quick Ship checkbox should be correctly set' );
                System.assertEquals( DaikinToolsTestingUtils.TEST_OLI_IS_NOT_FOUND, olifound.Is_Not_Found__c, 'The is Not Found checkbox should be correctly set' );
                System.assertEquals( DaikinToolsTestingUtils.TEST_OLI_IS_OUTSIDE_VENDOR, olifound.Is_Outside_Vendor__c, 'The is Outside Vendor checkbox should be correctly set' );
                System.assertEquals( DaikinToolsOpptyUpdateService.convertStringToDate(DaikinToolsTestingUtils.TEST_OLI_REQ_SHIP_DATE), olifound.Requested_Ship_Date__c, 'The is Requested Ship Date checkbox should be correctly set' );

                System.assertEquals( DaikinToolsTestingUtils.TEST_OLI_ITEM_STATUS, olifound.DT_Item_Status__c, 'The oli status should be correctly set' );
                System.assertEquals( DaikinToolsTestingUtils.TEST_OLI_MODEL_DESC, olifound.Custom_Description__c, 'The oli desc should be correctly set' );
                System.assertEquals( DaikinToolsTestingUtils.TEST_OLI_QTY_DISC_FACT, olifound.Discount__c, 'The oli discount factor should be correctly set' );
                System.assertEquals( DaikinToolsTestingUtils.TEST_OLI_NET_PRICE, olifound.NetPrice__c, 'The oli net price should be correctly set' );
             //   System.assertEquals( DaikinToolsTestingUtils.TEST_OLI_NET_PRICE, olifound.UnitPrice, 'The oli unit price should be correectly set as equal to net price' );
                System.assertNotEquals( null, olifound.PricebookEntryId, 'The oli guid should be correctly set' );

                System.assertNotEquals( null, olifound.DT_Code_Item__c, 'The code item cannot be null' );
                System.assert(olifound.DT_Code_Item__c.contains(String.valueOf(DaikinToolsTestingUtils.TEST_OLI_CODE_ITEMS_ITEM)), 'The code item is missing item');
                System.assert(olifound.DT_Code_Item__c.contains(DaikinToolsTestingUtils.TEST_OLI_CODE_ITEMS_DESCRIPTION), 'The code item is missing description');
                System.assert(olifound.DT_Code_Item__c.contains(DaikinToolsTestingUtils.TEST_OLI_CODE_ITEMS_VALUE), 'The code item is missing item value');
                System.assert(olifound.DT_Code_Item__c.contains(DaikinToolsTestingUtils.TEST_OLI_CODE_ITEMS_VAL_DESCRIP), 'The code item is missing item description');
                System.assert(olifound.DT_Code_Item__c.contains(String.valueOf(DaikinToolsTestingUtils.TEST_OLI_CODE_ITEMS_LIST_PRICE)), 'The code item is missing list price');
                System.assert(olifound.DT_Code_Item__c.contains(String.valueOf(DaikinToolsTestingUtils.TEST_OLI_CODE_ITEMS_IS_SPECIAL)), 'The code item is missing is special value');
                System.assert(olifound.DT_Code_Item__c.contains(DaikinToolsTestingUtils.TEST_OLI_CODE_ITEMS_SPECIAL_TEXT), 'The code item is missing special text');

                System.assertNotEquals( null, olifound.DT_InputsAndOutputs__c, 'The input and output item cannot be null' );
                System.assert(olifound.DT_InputsAndOutputs__c.contains(DaikinToolsTestingUtils.TEST_REQ_OPP_PROPERTY_NAME), 'The inputs and outputs is missing the property name');
                System.assert(olifound.DT_InputsAndOutputs__c.contains(DaikinToolsTestingUtils.TEST_REQ_OPP_PROPERTY_VALUE), 'The inputs and outputs is missing the property value');
                System.assert(olifound.DT_InputsAndOutputs__c.contains(DaikinToolsTestingUtils.TEST_REQ_OPP_PROPERTY_DESCRIPTION), 'The inputs and outputs is missing the property description');

                System.assert(olifound.DT_InputsAndOutputs__c.contains(DaikinToolsTestingUtils.TEST_OPP_COMPONENT_PROP_NAME), 'The inputs and outputs is missing the component property name');
                System.assert(olifound.DT_InputsAndOutputs__c.contains(DaikinToolsTestingUtils.TEST_OPP_COMPONENT_PROP_VALUE), 'The inputs and outputs is missing the component property value');
                System.assert(olifound.DT_InputsAndOutputs__c.contains(DaikinToolsTestingUtils.TEST_OPP_COMPONENT_PROP_DESCRIP), 'The inputs and outputs is missing the component property description');
                System.assert(olifound.DT_InputsAndOutputs__c.contains(String.valueOf(DaikinToolsTestingUtils.TEST_OPP_COMPONENT_ID)), 'The inputs and outputs is missing the component property Id');
                System.assert(olifound.DT_InputsAndOutputs__c.contains(String.valueOf(DaikinToolsTestingUtils.TEST_OPP_COMPONENT_TYPE)), 'The inputs and outputs is missing the component property type');

            }
            
        }
    }

    static testMethod void testDoPostMissingModelNumber()
    {
        setup();
        Account testAccount = TestingUtils.createAccounts( 1, 'Test Account', true )[0];

        testRequest = new DaikinToolsOpptyUpdateService.OpportunityUpdateRequest();
        testRequest.Source = DAIKIN_TOOLS_SOURCE;
        testRequest.Opportunities = new List<DaikinToolsOpptyUpdateService.Request_Opportunity>();

        List<Opportunity> testOpportunities = TestingUtils.createOpportunities( NUM_OPPTIES, testAccount.Id, false );
        counter = System.now().getTime();

        for( Opportunity anOpportunity : testOpportunities )
        {
            anOpportunity.DST_ID__c = '' + counter++;
            anOpportunity.Bypass__c = TRUE;
            anOpportunity.PriceBook2Id = null;
            anOpportunity.recordTypeId = naRecordType;
        }
        insert testOpportunities;

        for( Opportunity anOpportunity : testOpportunities )
        {
            DaikinToolsOpptyUpdateService.Request_Opportunity newOpportunity = new DaikinToolsOpptyUpdateService.Request_Opportunity();
            newOpportunity.JobGuid = anOpportunity.DST_ID__c;
            newOpportunity.SFDCID = anOpportunity.Id;
            newOpportunity.OrderStatus = DT_STATUS;
            newOpportunity.SalesOrderNumber = SALES_ORDER_NUMBER;
            newOpportunity.Addresses = new List<DaikinToolsOpptyUpdateService.Request_OpportunityAddress>{ DaikinToolsTestingUtils.createTestAddress( DaikinToolsTestingUtils.TEST_ADDRESS_TYPE_END ) };
            newOpportunity.SalesPeople = new List<DaikinToolsOpptyUpdateService.Request_OpportunitySalesPerson>{ DaikinToolsTestingUtils.createTestSalesPerson( DaikinToolsTestingUtils.TEST_SALESPERSON_INSIDE_TYPE ), DaikinToolsTestingUtils.createTestSalesPerson( DaikinToolsTestingUtils.TEST_SALESPERSON_OUTSIDE_TYPE )  };

            DaikinToolsOpptyUpdateService.Request_OpportunityItem opItem = DaikinToolsTestingUtils.createTestOLI(counter);
            opItem.ModelNumber = '';

            newOpportunity.Items = new List<DaikinToolsOpptyUpdateService.Request_OpportunityItem>{ opItem };
            testRequest.Opportunities.add( newOpportunity );
            counter++;
        }

        RestContext.request = new System.RestRequest();
        String totalRequest = JSON.serialize(testRequest);
        RestContext.request.requestBody = Blob.valueOf( totalRequest );

        Test.startTest();

            DaikinToolsOpptyUpdateService.DEFAULT_PRICEBOOK_ID = Test.getStandardPricebookId();
            RestContext.response = new System.RestResponse();
            DaikinToolsOpptyUpdateService.doPost();

        Test.stopTest();


        List<Integration_Error__c> errors = [SELECT Id, Direction__c, Error_Description__c,
                                                    Integration_Object__c, Integration_Point__c,
                                                    Request_Data__c
                                            FROM Integration_Error__c ];

        //We expect an error for the pricebook, the product and the 10 olis - total 12
        System.assertEquals( NUM_OPPTIES + 2, errors.size(), 'Missing model numbers should cause an error on oli creation and product and pricebook creation');

        for( Integration_Error__c err : errors )
        {
            System.assertEquals( DaikinToolsOpptyUpdateService.ERROR_DIRECTION, err.Direction__c, 'The error direction should be correctly captured');
            System.assertEquals( DAIKIN_TOOLS_SOURCE, err.Integration_Point__c, 'The error integration point should be correctly captured');
            //System.assertEquals( totalRequest, err.Request_Data__c, 'The error request should be correctly captured');
        }

        List<Opportunity> updatedOpportunities = [ SELECT Id,
                                                    (SELECT DST_ID__c
                                                            FROM OpportunityLineItems )
                                                   FROM Opportunity ];

        System.assertEquals( NUM_OPPTIES, updatedOpportunities.size(), 'There should be as many opportunities retrieved as were created' );

        for( Opportunity anOpportunity : updatedOpportunities )
        {
            //OLI assertions
            System.assertEquals( 0, anOpportunity.opportunityLineItems.size(), 'There should not be any line items');
        }
        
        List<Apttus_Config2__PriceListItem__c> listOfPriceListItems = [SELECT Id, Apttus_Config2__ProductId__c, Apttus_Config2__PriceListId__c 
                                                                    FROM Apttus_Config2__PriceListItem__c];
        List<Product2> listOfProducts = [SELECT Id FROM Product2];
        
        System.assertNotEquals(null, listOfPriceListItems, 'We expect there to be a price list item for every price list and product.');
        System.assertEquals(listOfProducts.size() * NUM_SIZE_PRICE_LIST, listOfPriceListItems.size(), 'We expect the number of price line items will equal to the number of products times price list');
    }

    static testMethod void testDoPostDeleteMissingLineItems()
    {
        
        final Integer NUM_OLIS_PER = 7;

        Account testAccount = TestingUtils.createAccounts( 1, 'Test Account', true )[0];

        testRequest = new DaikinToolsOpptyUpdateService.OpportunityUpdateRequest();
        testRequest.Source = DAIKIN_TOOLS_SOURCE;
        testRequest.Opportunities = new List<DaikinToolsOpptyUpdateService.Request_Opportunity>();

        List<Opportunity> testOpportunities = TestingUtils.createOpportunities( NUM_OPPTIES, testAccount.Id, false );
        counter = System.now().getTime();

        Product2 testProd = new Product2( Name = 'Test Prod' );
        insert testProd;
        
        for( Opportunity anOpportunity : testOpportunities )
        {
            anOpportunity.DST_ID__c = '' + counter++;
            anOpportunity.Bypass__c = TRUE;
            anOpportunity.PriceBook2Id = Test.getStandardPricebookId();
            anOpportunity.recordTypeId = naRecordType;
        }
        insert testOpportunities;

        Pricebookentry testPbe = new Pricebookentry();

        testPbe.Product2Id = testProd.Id;
        testPbe.Pricebook2Id = Test.getStandardPricebookId();
        testPbe.UnitPrice = 1;
        testPbe.IsActive = TRUE;

        insert testPbe;

        List<OpportunityLineItem> testOlis = new List<OpportunityLineItem>();
        Set<String> olisGuidsToRemain = new Set<String>();
        
        for( Opportunity anOpportunity : testOpportunities )
        {
            DaikinToolsOpptyUpdateService.Request_Opportunity newOpportunity = new DaikinToolsOpptyUpdateService.Request_Opportunity();
            newOpportunity.JobGuid = anOpportunity.DST_ID__c;
            newOpportunity.SFDCID = anOpportunity.Id;
            newOpportunity.OrderStatus = DT_STATUS;
            newOpportunity.SalesOrderNumber = SALES_ORDER_NUMBER;
            newOpportunity.Addresses = new List<DaikinToolsOpptyUpdateService.Request_OpportunityAddress>{ DaikinToolsTestingUtils.createTestAddress( DaikinToolsTestingUtils.TEST_ADDRESS_TYPE_END ) };
            newOpportunity.SalesPeople = new List<DaikinToolsOpptyUpdateService.Request_OpportunitySalesPerson>{ DaikinToolsTestingUtils.createTestSalesPerson( DaikinToolsTestingUtils.TEST_SALESPERSON_INSIDE_TYPE ), DaikinToolsTestingUtils.createTestSalesPerson( DaikinToolsTestingUtils.TEST_SALESPERSON_OUTSIDE_TYPE )  };
            newOpportunity.Items = new List<DaikinToolsOpptyUpdateService.Request_OpportunityItem>{ DaikinToolsTestingUtils.createTestOLI(counter), DaikinToolsTestingUtils.createTestOLI(++counter) };

            List<OpportunityLineItem>olisForOppty = Testingutils.createOpportunityLineItems (NUM_OLIS_PER, anOpportunity.Id, testPbe.Id, false);
            for(OpportunityLineItem oli : olisForOppty){
                oli.DST_ID__c = ''+ (counter-1); 
            }

            olisForOppty[0].DST_ID__c = '' + counter;
            olisGuidsToRemain.add( '' + (counter - 1) );
            olisGuidsToRemain.add( '' + counter );

            testOlis.addAll( olisForOppty );

            testRequest.Opportunities.add( newOpportunity );
            counter++;
        }
        insert testOlis;

        RestContext.request = new System.RestRequest();
        RestContext.request.requestBody = Blob.valueOf( JSON.serialize(testRequest) );

        Test.startTest();

            DaikinToolsOpptyUpdateService.DEFAULT_PRICEBOOK_ID = Test.getStandardPricebookId();
            RestContext.response = new System.RestResponse();
            DaikinToolsOpptyUpdateService.doPost();

        Test.stopTest();

        List<Opportunity> updatedOpportunities = [ SELECT Id,
                                                    (SELECT DST_ID__c, OpportunityId
                                                            FROM OpportunityLineItems )
                                                   FROM Opportunity ];

        System.assertEquals( NUM_OPPTIES, updatedOpportunities.size(), 'There should be as many opportunities retrieved as were created' );
        Set<String> actualOliIGUIDS = new Set<String>();

        for( Opportunity anOpportunity : updatedOpportunities )
        {
            System.assertEquals( 2, anOpportunity.opportunityLineItems.size(), 'There should be two line items');
            actualOliIGUIDS.add( anOpportunity.opportunityLineItems[0].DST_ID__c);
            actualOliIGUIDS.add( anOpportunity.opportunityLineItems[1].DST_ID__c);
        }

        System.assertEquals( olisGuidsToRemain, actualOliIGUIDS, 'The expected Olis should remain and all others should be deleted');

    }

    static testMethod void testDoPostDontDeleteMissingLineItems()
    {

        final Integer NUM_OLIS_PER = 7;

        Account testAccount = TestingUtils.createAccounts( 1, 'Test Account', true )[0];

        testRequest = new DaikinToolsOpptyUpdateService.OpportunityUpdateRequest();
        testRequest.Source = OPS_SOURCE;
        testRequest.Opportunities = new List<DaikinToolsOpptyUpdateService.Request_Opportunity>();

        List<Opportunity> testOpportunities = TestingUtils.createOpportunities( NUM_OPPTIES, testAccount.Id, false );
        counter = System.now().getTime();

        Product2 testProd = new Product2( Name = 'Test Prod' );
        insert testProd;
        
        
        for( Opportunity anOpportunity : testOpportunities )
        {
            anOpportunity.recordTypeId = naRecordType;
            anOpportunity.DST_ID__c = '' + counter++;
            anOpportunity.Bypass__c = TRUE;
            anOpportunity.PriceBook2Id = Test.getStandardPricebookId();
        }
        insert testOpportunities;

        Pricebookentry testPbe = new Pricebookentry();

        testPbe.Product2Id = testProd.Id;
        testPbe.Pricebook2Id = Test.getStandardPricebookId();
        testPbe.UnitPrice = 1;
        testPbe.IsActive = TRUE;

        insert testPbe;

        List<OpportunityLineItem> testOlis = new List<OpportunityLineItem>();
        
        for( Opportunity anOpportunity : testOpportunities )
        {
            DaikinToolsOpptyUpdateService.Request_Opportunity newOpportunity = new DaikinToolsOpptyUpdateService.Request_Opportunity();
            newOpportunity.JobGuid = anOpportunity.DST_ID__c;
            newOpportunity.SFDCID = anOpportunity.Id;
            newOpportunity.OrderStatus = DT_STATUS;
            newOpportunity.SalesOrderNumber = SALES_ORDER_NUMBER;
            newOpportunity.Addresses = new List<DaikinToolsOpptyUpdateService.Request_OpportunityAddress>{ DaikinToolsTestingUtils.createTestAddress( DaikinToolsTestingUtils.TEST_ADDRESS_TYPE_END ) };
            newOpportunity.SalesPeople = new List<DaikinToolsOpptyUpdateService.Request_OpportunitySalesPerson>{ DaikinToolsTestingUtils.createTestSalesPerson( DaikinToolsTestingUtils.TEST_SALESPERSON_INSIDE_TYPE ), DaikinToolsTestingUtils.createTestSalesPerson( DaikinToolsTestingUtils.TEST_SALESPERSON_OUTSIDE_TYPE )  };
            newOpportunity.Items = new List<DaikinToolsOpptyUpdateService.Request_OpportunityItem>{ DaikinToolsTestingUtils.createTestOLI(counter) };

            List<OpportunityLineItem>olisForOppty = Testingutils.createOpportunityLineItems (NUM_OLIS_PER, anOpportunity.Id, testPbe.Id, false);
            olisForOppty[0].DST_ID__c = '' + counter;

            testOlis.addAll( olisForOppty );

            testRequest.Opportunities.add( newOpportunity );
            counter++;
        }

        insert testOlis;

        RestContext.request = new System.RestRequest();
        RestContext.request.requestBody = Blob.valueOf( JSON.serialize(testRequest) );

        Test.startTest();

            DaikinToolsOpptyUpdateService.DEFAULT_PRICEBOOK_ID = Test.getStandardPricebookId();
            RestContext.response = new System.RestResponse();
            DaikinToolsOpptyUpdateService.doPost();

        Test.stopTest();

        List<Opportunity> updatedOpportunities = [ SELECT Id,
                                                    (SELECT DST_ID__c, OpportunityId
                                                            FROM OpportunityLineItems )
                                                   FROM Opportunity ];

        System.assertEquals( NUM_OPPTIES, updatedOpportunities.size(), 'There should be as many opportunities retrieved as were created' );

        for( Opportunity anOpportunity : updatedOpportunities )
        {
            System.assertEquals( NUM_OLIS_PER, anOpportunity.opportunityLineItems.size(), 'There should be one line item');
        }
    }

 
    static testMethod void testDoPostChangedModelNumber()
    {
      
        final String OLD_PRODUCT_CODE = '56789';
        final String NEW_PRODUCT_CODE = '98765';
        final String TEST_OLI_DSTID = '000009';

        Account testAccount = TestingUtils.createAccounts( 1, 'Test Account', true )[0];

        testRequest = new DaikinToolsOpptyUpdateService.OpportunityUpdateRequest();
        testRequest.Source = DAIKIN_TOOLS_SOURCE;
        testRequest.Opportunities = new List<DaikinToolsOpptyUpdateService.Request_Opportunity>();

        //insert old product code / model number
        Product2 testProd = TestingUtils.createProduct('Test Prod', new Map<String,Object>{'ProductCode' => OLD_PRODUCT_CODE} , true);
        Pricebookentry testPbe = TestingUtils.createPriceBookEntry(testProd.Id, 1, new Map<String, Object>{} ,true);
        
        
        
        Opportunity testOpportunity = TestingUtils.createOpportunities( 1, testAccount.Id, false )[0];
        counter = System.now().getTime();
        
        testOpportunity.recordTypeId = naRecordType;
        testOpportunity.DST_ID__c = '' + counter++;
        testOpportunity.Bypass__c = TRUE;
        testOpportunity.PriceBook2Id = Test.getStandardPricebookId();
        insert testOpportunity;

        OpportunityLineItem testOLI = TestingUtils.createOpportunityLineItems(1, testOpportunity.Id, testPbe.Id, false)[0];
        testOLI.DST_ID__c = TEST_OLI_DSTID;
        insert testOLI;

        // lets build the request
        DaikinToolsOpptyUpdateService.Request_Opportunity newOpportunity = new DaikinToolsOpptyUpdateService.Request_Opportunity();
        newOpportunity.JobGuid = testOpportunity.DST_ID__c;
        newOpportunity.SFDCID = testOpportunity.Id;

        DaikinToolsOpptyUpdateService.Request_OpportunityItem newOLI = DaikinToolsTestingUtils.createTestOLI(counter);
        newOLI.Guid = TEST_OLI_DSTID;
        newOLI.ModelNumber = NEW_PRODUCT_CODE;

        newOpportunity.Items = new List<DaikinToolsOpptyUpdateService.Request_OpportunityItem>{ newOLI };
        testRequest.Opportunities.add(newOpportunity);

        RestContext.request = new System.RestRequest();
        RestContext.request.requestBody = Blob.valueOf( JSON.serialize(testRequest) );

        Test.startTest();
            DaikinToolsOpptyUpdateService.DEFAULT_PRICEBOOK_ID = Test.getStandardPricebookId();
            RestContext.response = new System.RestResponse();
            DaikinToolsOpptyUpdateService.doPost();
        Test.stopTest();

        System.assert(ApexPages.getMessages().isEmpty(), 'Errors: '+ApexPages.getMessages());
        List<OpportunityLineItem> updatedOLI = [SELECT Id, DST_ID__c, PricebookEntry.Product2.ProductCode FROM OpportunityLineItem ];

       // List<Product2> allProducts = [SELECT Id, ProductCode FROM Product2];
       // System.debug('all products --> '+ allProducts);

        List<Product2> updatedProduct = [SELECT Id, ProductCode FROM Product2 WHERE Id != : testProd.Id];
        List<PricebookEntry> updatedPBE = [SELECT Id FROM PricebookEntry WHERE Id != : testPbe.Id AND Product2Id = : updatedProduct[0].ID];



        System.assertEquals(1, updatedOLI.size(), 'We should expect 1 OLI to have been created');
        System.assertEquals(TEST_OLI_DSTID, updatedOLI[0].DST_ID__c, 'The DST_ID__c should not change after the request is sent');
        System.assertEquals(NEW_PRODUCT_CODE, updatedOLI[0].PricebookEntry.Product2.ProductCode, 'The product code should have been updated to the new model number');

        System.assertEquals(1, updatedProduct.size(), 'We should expect 1 Product to have been created');
        System.assertEquals(NEW_PRODUCT_CODE, updatedProduct[0].ProductCode, 'The Product Code should have been updated to the new model number');

        System.assertEquals(1, updatedPBE.size(), 'We should expect 1 PBE to have been created');

    }

    static testMethod void testDoDelete()
    { /*
        final Integer NUM_OPPTIES = 10;
        final Integer NUM_OLIS_PER = 1;

        Account testAccount = TestingUtils.createAccounts( 1, 'Test Account', true )[0];

        DaikinToolsOpptyUpdateService.OpportunityUpdateRequest testRequest = new DaikinToolsOpptyUpdateService.OpportunityUpdateRequest();
        testRequest.Opportunities = new List<DaikinToolsOpptyUpdateService.Request_Opportunity>();

        //add fields to delete to the field set
        DaikinToolsOpptyUpdateService.fieldsToDeleteFromOppty.add('DST_ID__c');
        DaikinToolsOpptyUpdateService.fieldsToDeleteFromOppty.add('CustomerPurchaseOrderNumber__c');

        List<Opportunity> testOpportunities = TestingUtils.createOpportunities( NUM_OPPTIES, testAccount.Id, false );
        counter = System.now().getTime();

        Product2 testProd = new Product2( Name = 'Test Prod' );
        insert testProd;

        Pricebookentry testPbe = new Pricebookentry();

        testPbe.Product2Id = testProd.Id;
        testPbe.Pricebook2Id = Test.getStandardPricebookId();
        testPbe.UnitPrice = 1;
        testPbe.IsActive = TRUE;

        insert testPbe;

        List<OpportunityLineItem> testOlis = new List<OpportunityLineItem>();

        for( Opportunity anOpportunity : testOpportunities )
        {
            anOpportunity.DST_ID__c = '' + counter++;
            anOpportunity.Bypass__c = TRUE;
            anOpportunity.CustomerPurchaseOrderNumber__c = 'Test PO Num';
        }

        insert testOpportunities;


        for( Opportunity anOpportunity : testOpportunities )
        {
            DaikinToolsOpptyUpdateService.Request_Opportunity newOpportunity = new DaikinToolsOpptyUpdateService.Request_Opportunity();
            newOpportunity.JobGuid = anOpportunity.DST_ID__c;
            newOpportunity.SFDCID = anOpportunity.Id;
            testRequest.Opportunities.add( newOpportunity );

            List<OpportunityLineItem> olisForOppty = Testingutils.createOpportunityLineItems (NUM_OLIS_PER, anOpportunity.Id, testPbe.Id, false);
            testOlis.addAll( olisForOppty );
        }

        insert testOlis;

        RestContext.request = new System.RestRequest();
        RestContext.request.requestBody = Blob.valueOf( JSON.serialize(testRequest) );

        Test.startTest();

            RestContext.response = new System.RestResponse();
            DaikinToolsOpptyUpdateService.doDelete();

        Test.stopTest();

        List<Opportunity> updatedOpportunities = [ SELECT Id, DST_ID__c, CustomerPurchaseOrderNumber__c FROM Opportunity ];
        System.assertEquals( NUM_OPPTIES, updatedOpportunities.size(), 'There should be as many opportunities retrieved as were created' );
        for( Opportunity anOpportunity : updatedOpportunities )
        {
            System.assertEquals( null, anOpportunity.DST_ID__c, 'When passed through a Delete call the external id should have been deleted' );
            System.assertEquals( null, anOpportunity.CustomerPurchaseOrderNumber__c, 'When passed through a Delete call, all fields in Fields To Delete Field Set should be cleared out.');
        }

        List<OpportunityLineItem> updatedOLIs = [ SELECT Id, DST_ID__c FROM OpportunityLineItem ];
        System.assertEquals( NUM_OPPTIES * NUM_OLIS_PER, updatedOLIs.size(), 'There should be as many olis retrieved as were created' );
        for( OpportunityLineItem anOLI : updatedOLIs )
        {
            System.assertEquals( null, anOLI.DST_ID__c, 'When passed through a Delete call the external id should have been deleted' );
        } */
    }

    static testMethod void testDoDelete_SyncedQuoteFound()
    {
        final Integer NUM_OPPORTUNITIES = 1;
        final Integer NUM_OLIS_PER = 1;

        Account testAccount = TestingUtils.createAccounts( 1, 'Test Account', true )[0];
        Contact testContact = Testingutils.createContacts( 1, testAccount.id, true)[0];
        
        testRequest = new DaikinToolsOpptyUpdateService.OpportunityUpdateRequest();
        testRequest.Opportunities = new List<DaikinToolsOpptyUpdateService.Request_Opportunity>();

        //add fields to delete to the field set
        DaikinToolsOpptyUpdateService.fieldsToDeleteFromOppty.add('DST_ID__c');
        DaikinToolsOpptyUpdateService.fieldsToDeleteFromOppty.add('CustomerPurchaseOrderNumber__c');
        
        Opportunity parentOpp = TestingUtils.createOpportunities( 1, testAccount.Id, false )[0];
        parentOpp.StageName = 'Develop Customer Solution/In Design';
        insert parentOpp;
        
        List<Opportunity> testOpportunities = TestingUtils.createOpportunities( NUM_OPPORTUNITIES, testAccount.Id, false );
        
        
        counter = System.now().getTime();

        Product2 testProd = new Product2( Name = 'Test Prod' );
        insert testProd;

        Pricebookentry testPbe = new Pricebookentry();

        testPbe.Product2Id = testProd.Id;
        testPbe.Pricebook2Id = Test.getStandardPricebookId();
        testPbe.UnitPrice = 1;
        testPbe.IsActive = TRUE;

        insert testPbe;
        
        
        Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c (name = 'testlist');
        insert pricelist;
        
        List<OpportunityLineItem> testOlis = new List<OpportunityLineItem>();
        Apttus_Proposal__Proposal__c prop = new Apttus_Proposal__Proposal__c();
        
        prop.Apttus_Proposal__Account__c = testAccount.id;
        prop.Apttus_Proposal__Primary_Contact__c = testContact.id;
        prop.Apttus_QPConfig__PriceListId__c = pricelist.id;
        prop.Apttus_Proposal__Opportunity__c = parentOpp.id;
        prop.Quote_Document_Date__c = Date.today();
        prop.Expiration_Date__c = Date.today();
        prop.Brand__c = 'test';
        prop.Quote_Document_Title__c = 'test';
        insert prop;
        
        //We need to update the proposal again because Accepting a proposal is not allowed on insert.
        prop.Apttus_Proposal__Approval_Stage__c ='Accepted';
        update prop;
        
        for( Opportunity anOpportunity : testOpportunities )
        {
            anOpportunity.DST_ID__c = '' + counter++;
            anOpportunity.Bypass__c = TRUE;
            anOpportunity.CustomerPurchaseOrderNumber__c = 'Test PO Num';
            anOpportunity.Synced_Quote_Proposal__c = prop.id;
            anOpportunity.recordTypeId = naRecordType;
        }

        insert testOpportunities;

        for( Opportunity anOpportunity : testOpportunities )
        {
            DaikinToolsOpptyUpdateService.Request_Opportunity newOpportunity = new DaikinToolsOpptyUpdateService.Request_Opportunity();
            newOpportunity.JobGuid = anOpportunity.DST_ID__c;
            newOpportunity.SFDCID = anOpportunity.Id;
            testRequest.Opportunities.add( newOpportunity );

            List<OpportunityLineItem> olisForOppty = Testingutils.createOpportunityLineItems (NUM_OLIS_PER, anOpportunity.Id, testPbe.Id, false);
            for(OpportunityLineItem oli : olisForOppty){
                oli.DST_ID__c = ''+ counter++;
            }
            testOlis.addAll( olisForOppty );
        }

        insert testOlis;

        RestContext.request = new System.RestRequest();
        RestContext.request.requestBody = Blob.valueOf( JSON.serialize(testRequest) );

        Test.startTest();

            RestContext.response = new System.RestResponse();
            DaikinToolsOpptyUpdateService.doDelete();

        Test.stopTest();

        List<Opportunity> updatedOpportunities = [ SELECT Id, DST_ID__c, CustomerPurchaseOrderNumber__c FROM Opportunity where ID !=: parentOpp.id ];
        System.assertEquals( NUM_OPPORTUNITIES, updatedOpportunities.size(), 'There should be as many opportunities retrieved as were created' );
        for( Opportunity anOpportunity : updatedOpportunities )
        {
            System.assertNotEquals( null, anOpportunity.DST_ID__c, 'When passed through a Delete call, but the Opp is synced to a quote, the external id should have not be deleted' );
            System.assertNotEquals( null, anOpportunity.CustomerPurchaseOrderNumber__c, 'When passed through a Delete call, but the Opp is synced to a quote, all fields in Fields To Delete Field Set should not be cleared out.');
        }

        List<OpportunityLineItem> updatedOLIs = [ SELECT Id, DST_ID__c FROM OpportunityLineItem ];
        System.assertEquals( NUM_OPPORTUNITIES * NUM_OLIS_PER, updatedOLIs.size(), 'There should be as many olis retrieved as were created' );
        for( OpportunityLineItem anOLI : updatedOLIs )
        {
            System.assertNotEquals( null, anOLI.DST_ID__c, 'When passed through a Delete call, but the Opp is synced with a quote, the external id should not have been deleted' );
        }
    }
    
    public static testMethod void testCreatePriceItems()
    {
        setup();
        
        final Integer NUM_SIZE_PRODUCT = 2;
        List<Product2> listOfProduct = TestingUtils.createProducts(NUM_SIZE_PRODUCT, 'Test Prod', new Map<String,Object>{'ProductCode' => '233445'} , true);
        
        Test.startTest();
            DaikinToolsOpptyUpdateService.createPriceItems(listOfProduct, null, null, null);
        Test.stopTest();
        
        Set<Id> productsId = Pluck.ids(listOfProduct);
        Set<Id> priceListId = Pluck.ids(testPriceList);
        
        List<Apttus_Config2__PriceListItem__c> listOfPriceListItems = [SELECT Id, Apttus_Config2__ProductId__c, Apttus_Config2__PriceListId__c, Apttus_Config2__ListPrice__c, Apttus_Config2__Active__c
                                                                    FROM Apttus_Config2__PriceListItem__c
                                                                    WHERE Apttus_Config2__ProductId__c =: productsId];
        
        System.assertEquals(NUM_SIZE_PRODUCT * NUM_SIZE_PRICE_LIST, listOfPriceListItems.size(), 'We expect there to be a price list item for every price list and product.');
        
        for( Apttus_Config2__PriceListItem__c aPriceListItem: listOfPriceListItems )
        {
            System.assert(productsId.contains(aPriceListItem.Apttus_Config2__ProductId__c), 'We expect that the productId is in the priceListItem' );
            System.assert(priceListId.contains(aPriceListItem.Apttus_Config2__PriceListId__c), 'We expect that the price list id is in the priceListItem' );
            System.assertEquals(0, aPriceListItem.Apttus_Config2__ListPrice__c, 'We expect the ListPrice to be 0 on creation.');
            System.assertEquals(TRUE, aPriceListItem.Apttus_Config2__Active__c, 'We expect the Active Status to be true.');
        
        }
    }
    
}