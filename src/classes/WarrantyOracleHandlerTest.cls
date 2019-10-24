@isTest 
global class WarrantyOracleHandlerTest implements HttpCalloutMock{    

    Integer statusCode = 200;
    String responseBody='{"status": "S", "message": "Updated instance detail(s)", "order_lines": [ { "order_number": 260563, "serial_number": "SLPU164700925", "status": "S" }], "orders": [ { "order_info": { "operating_unit": "MCQUAY US OU", "order_number": 260563, "order_source": "ORM", "source_order_number": "OPS103396", "ordered_date": "17-Oct-2016", "job_name": "RMC WSHP - 101716", "customer_name": "NE ALABAMA REG MEDICAL CENTER", "customer_number": 317151 }, "lines": [ { "line_info": { "source_line_number": "00100", "line_number": 100.1, "ordered_item": "E026056300100", "model": "WCCH4024", "pcl": "0084", "shipped_quantity": 1, "serial_number": "SLPU164700925", "ship_date": "30-Nov-2016", "ship_to_address1": "RMC LOADING DOCK", "ship_to_address2": "400 EAST 10TH STREET", "ship_to_city": "Anniston", "ship_to_state": "AL", "ship_to_postal_code": 36207, "status": "ACTIVE", "startup_date":"30-Nov-2016" }, "warranties": [ { "warranty_item": "-A S P&L", "warranty_desc": "AUB - STD. PARTS & LABOR (ENTIRE UNIT)", "warranty_item_type": "WAR", "warranty_type": "PARTS AND LABOR", "warranty_subtype": "ENTIRE UNIT", "warranty_start_date": "30-Nov-2016", "warranty_end_date": "30-May-2018", "warranty_status": "EXPIRED" } ] }, { "line_info": { "source_line_number": "00200", "line_number": 200.1, "ordered_item": "E026056300200", "model": "WCCH5030", "pcl": "0084", "shipped_quantity": 1, "serial_number": "SLPU164700877", "ship_date": "29-Nov-2016", "ship_to_address1": "RMC LOADING DOCK", "ship_to_address2": "400 EAST 10TH STREET", "ship_to_city": "Anniston", "ship_to_state": "AL", "ship_to_postal_code": 36207, "status": "ACTIVE" }, "warranties": [ { "warranty_item": "-A S P&L", "warranty_desc": "AUB - STD. PARTS & LABOR (ENTIRE UNIT)", "warranty_item_type": "WAR", "warranty_type": "PARTS AND LABOR", "warranty_subtype": "ENTIRE UNIT", "warranty_start_date": "29-Nov-2016", "warranty_end_date": "28-May-2018", "warranty_status": "EXPIRED" } ] }, { "line_info": { "source_line_number": "00300", "line_number": 300.1, "ordered_item": 669808800, "model": 669808800, "pcl": "0084", "shipped_quantity": 1, "serial_number": "SLPU163600288", "ship_date": "18-Oct-2016", "ship_to_address1": "RMC LOADING DOCK", "ship_to_address2": "400 EAST 10TH STREET", "ship_to_city": "Anniston", "ship_to_state": "AL", "ship_to_postal_code": 36207, "status": "ACTIVE" }, "warranties": [ { "warranty_item": "-A S P&L", "warranty_desc": "AUB - STD. PARTS & LABOR (ENTIRE UNIT)", "warranty_item_type": "WAR", "warranty_type": "PARTS AND LABOR", "warranty_subtype": "ENTIRE UNIT", "warranty_start_date": "18-Oct-2016", "warranty_end_date": "17-Apr-2018", "warranty_status": "EXPIRED" }, { "warranty_item": "-A 4X P&L", "warranty_desc": "AUB - EXT 4 YRS PARTS & LABOR", "warranty_item_type": "EXTWAR", "warranty_type": "PARTS AND LABOR", "warranty_subtype": "ENTIRE UNIT", "warranty_start_date": "18-Apr-2018", "warranty_end_date": "16-Apr-2022", "warranty_status": "ACTIVE" } ] } ] } ]}';
    //String responseBody='{"status": "S", "orders": [ { "order_info": { "operating_unit": "MCQUAY US OU", "order_number": 260563, "order_source": "ORM", "source_order_number": "OPS103396", "ordered_date": "17-Oct-2016", "job_name": "RMC WSHP - 101716", "customer_name": "NE ALABAMA REG MEDICAL CENTER", "customer_number": 317151 }, "lines": [ { "line_info": { "source_line_number": "00100", "line_number": 100.1, "ordered_item": "E026056300100", "model": "WCCH4024", "pcl": "0084", "shipped_quantity": 1, "serial_number": "SLPU164700925", "ship_date": "30-Nov-2016", "ship_to_address1": "RMC LOADING DOCK", "ship_to_address2": "400 EAST 10TH STREET", "ship_to_city": "Anniston", "ship_to_state": "AL", "ship_to_postal_code": 36207, "status": "ACTIVE" }, "warranties": [ { "warranty_item": "-A S P&L", "warranty_desc": "AUB - STD. PARTS & LABOR (ENTIRE UNIT)", "warranty_item_type": "WAR", "warranty_type": "PARTS AND LABOR", "warranty_subtype": "ENTIRE UNIT", "warranty_start_date": "30-Nov-2016", "warranty_end_date": "30-May-2018", "warranty_status": "EXPIRED" } ] }, { "line_info": { "source_line_number": "00200", "line_number": 200.1, "ordered_item": "E026056300200", "model": "WCCH5030", "pcl": "0084", "shipped_quantity": 1, "serial_number": "SLPU164700877", "ship_date": "29-Nov-2016", "ship_to_address1": "RMC LOADING DOCK", "ship_to_address2": "400 EAST 10TH STREET", "ship_to_city": "Anniston", "ship_to_state": "AL", "ship_to_postal_code": 36207, "status": "ACTIVE" }, "warranties": [ { "warranty_item": "-A S P&L", "warranty_desc": "AUB - STD. PARTS & LABOR (ENTIRE UNIT)", "warranty_item_type": "WAR", "warranty_type": "PARTS AND LABOR", "warranty_subtype": "ENTIRE UNIT", "warranty_start_date": "29-Nov-2016", "warranty_end_date": "28-May-2018", "warranty_status": "EXPIRED" } ] }, { "line_info": { "source_line_number": "00300", "line_number": 300.1, "ordered_item": 669808800, "model": 669808800, "pcl": "0084", "shipped_quantity": 1, "serial_number": "SLPU163600288", "ship_date": "18-Oct-2016", "ship_to_address1": "RMC LOADING DOCK", "ship_to_address2": "400 EAST 10TH STREET", "ship_to_city": "Anniston", "ship_to_state": "AL", "ship_to_postal_code": 36207, "status": "ACTIVE" }, "warranties": [ { "warranty_item": "-A S P&L", "warranty_desc": "AUB - STD. PARTS & LABOR (ENTIRE UNIT)", "warranty_item_type": "WAR", "warranty_type": "PARTS AND LABOR", "warranty_subtype": "ENTIRE UNIT", "warranty_start_date": "18-Oct-2016", "warranty_end_date": "17-Apr-2018", "warranty_status": "EXPIRED" }, { "warranty_item": "-A 4X P&L", "warranty_desc": "AUB - EXT 4 YRS PARTS & LABOR", "warranty_item_type": "EXTWAR", "warranty_type": "PARTS AND LABOR", "warranty_subtype": "ENTIRE UNIT", "warranty_start_date": "18-Apr-2018", "warranty_end_date": "16-Apr-2022", "warranty_status": "ACTIVE" } ] } ] } ]}';
    //String responseBody='{"status": "S", "message": "Updated instance detail(s)", "order_lines": [ { "order_number": 152331, "serial_number": "AUBU092300949", "status": "S" }, { "order_number": 152331, "serial_number": "AUBU092300950", "status": "S" } ]}';
    //String responseBody = '{"warranty_items":[{"Description":"TEST"}]}';
    
    public WarrantyOracleHandlerTest(){
    }
    
    public WarrantyOracleHandlerTest(String responseBody){
        this.responseBody = responseBody;
    }

    public WarrantyOracleHandlerTest(Integer statusCode, String responseBody){
        this.statusCode = statusCode;
        this.responseBody=responseBody;
    }
    
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        res.setBody(responseBody);
        res.setStatusCode(statusCode);
        if(statusCode>=300)
            res.setStatus(responseBody);
        System.assertNotEquals(0, statusCode);
        return res;
    }
    
    @TestSetup
    private static void loadTestWar(){
        Oracle_Warranty_REST_Services_Config__c serviceConfig = new Oracle_Warranty_REST_Services_Config__c();
        serviceConfig.Active__c=true;
        insert serviceConfig;
        
            AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c();
            ts1.AVA_SFCORE__Active_Setting__c = true;
            ts1.Name='Test Account';
            insert ts1;
            
            Address__c address = new Address__c();
            address.Address_Line_1__c = 'TEST';
            address.City__c = 'Minneapolis';
            address.Postal_Code__c = '55421';
            address.Country__c = 'United States';
            address.State_Province__c = 'Minnesota';
            insert address;
    
            Account a = new Account();
            a.Name = 'TEST';
            a.Type = 'Developer';
            a.Physical_Address__c = address.Id;
            insert a;
            
            Account_Address__c aa = new Account_Address__c();
            aa.Account__c = a.Id;
            aa.Address__c = address.Id;
            aa.Active__c = true;
            aa.Physical__c = true;
            insert aa;
            
            Contact c = new Contact();
            c.AccountId = a.Id;
            c.LastName = 'TEST';
            c.Email = 'test@test.com';
            insert c;
            
            Product2 p = new Product2();
            p.Name = 'TEST';
            p.IsActive = true;
            p.ProductCode = 'TEST';
            p.DW_Product_Business_Unit__c = 'Applied Air Handler';
            p.Product_Group__c = 'IE Gateway';            
            insert p;
            
            Order__c order = new Order__c();
            order.SO_Number__c='260563';
            insert order;
            
            Asset passet = new Asset();
            passet.Name = 'TEST';
            passet.SerialNumber = 'SLPU164700925';
            passet.Product2Id = p.Id;
            passet.AccountId = a.Id;
            passet.ContactId = c.Id;
            passet.Order__c = order.Id;
            passet.Warehouse_ID__c = 'TEST';
            insert passet;
            
            Asset asset = passet.clone();
            asset.Parent_Asset__c = passet.Id;
            insert asset;

            Case war = new Case();
            war.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Warranty Claim Authorization').getRecordTypeId();
            war.Subject = 'TEST';
            war.Origin = 'Email';
            war.AccountId = a.Id;
            war.ContactId = c.Id;
            war.Date_of_Failure__c = System.today();
            war.Date_Received__c = System.today();
            war.Reason_for_Authorization_Request__c = 'TEST';
            war.Case_Category__c = 'Claim';
            war.Business_Unit_Picklist__c = 'AAH';
            war.AssetId = asset.Id;
            war.Order__c = order.Id;
            insert war;
    }
    
    private static Case getTestWar(){
        return [select Id, Subject, Origin, AccountId, ContactId, Date_of_Failure__c, Date_Received__c, Reason_for_Authorization_Request__c, Business_Unit_Picklist__c, AssetId, Order__c from Case Limit 1];
    }
    private static Asset getTestAsset(String aId){
        return [select Id, Startup_Date__c, Warranty_Items__c, Warehouse_ID__c, SO_Number__c, SerialNumber, Actual_Warranty_Start_Date__c, Actual_Warranty_End_Date__c from Asset where Id=:aId];
    }
    
    static testMethod void AssetUpdateTriggerTest() {
        Case war = getTestWar();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WarrantyOracleHandlerTest());        
            Asset a = getTestAsset(war.AssetId);
            a.Startup_Date__c=Date.today();
            update a;
        Test.stopTest();

        a = getTestAsset(war.AssetId);
        System.assertNotEquals(Null, a.Warranty_Items__c);
    }
    
    static testMethod void AssetUpdateTriggerTest2() {
        Case war = getTestWar();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WarrantyOracleHandlerTest());        
            Asset a = getTestAsset(war.AssetId);
            a.Startup_Date__c = null;
            a.Warranty_Items__c = null;
            update a;
        Test.stopTest();
        a = getTestAsset(war.AssetId);
        System.assertNotEquals(Null, a.Startup_Date__c);
    }
    static testMethod void CaseAssetInsertTriggerTest() {
        Case war = getTestWar();
        Case_Asset__c ca = new Case_Asset__c();
        ca.Case__c=war.Id;        
        ca.Asset__c=war.AssetId;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WarrantyOracleHandlerTest('{"warranty_items":[{"Description":"TEST"}]}'));        
            insert ca;
        Test.stopTest();
        Asset a = getTestAsset(ca.Asset__c);
        System.assertNotEquals(null, a.Warranty_Items__c);
    }
    static testMethod void CaseInsertAssetLookupTriggerTest() {
        Case war = getTestWar();
        Case c = war.clone();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WarrantyOracleHandlerTest('{"warranty_items":[{"Description":"TEST"}]}'));        
            insert c;
        Test.stopTest();
        Asset a = getTestAsset(c.AssetId);
        System.assertNotEquals(null, a.Warranty_Items__c);
    }
    static testMethod void ControllerTestAsset(){
        Case war = getTestWar();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WarrantyOracleHandlerTest());        
            Asset a = getTestAsset(war.AssetId);
            a.Startup_Date__c=Date.today();
            update a;
        Test.stopTest();
        a = getTestAsset(war.AssetId);
        WarrantyOracleController controller = new WarrantyOracleController(new ApexPages.StandardController(a));
        controller.getWarrantyInfo();
        List<WarrantyOracleController.WarrantyItem> itms = controller.getItems();
        System.assertNotEquals(0, itms.size());
    }
    static testMethod void ControllerTestCase(){
        Case war = getTestWar();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WarrantyOracleHandlerTest());        
            Asset a = getTestAsset(war.AssetId);
            a.Startup_Date__c=Date.today();
            update a;
        Test.stopTest();
        WarrantyOracleController controller = new WarrantyOracleController(new ApexPages.StandardController(war));
        controller.getWarrantyInfo();
        List<WarrantyOracleController.WarrantyItem> itms = controller.getItems();
        System.assertNotEquals(0, itms.size());
    }/*
    static testMethod void AssetTriggerHandlerCodeCoverageTest(){
        Case war = getTestWar();
        Asset a = getTestAsset(war.AssetId);
        a.Record_Usage__c='IE';
        a.IE_Updated_Date__c=System.today().addDays(-365);
        a.IE_Asset__c=true;
        a.IE_Sync_Status__c='Processed';
        a.Name='Intelligent Equipment Gateway';
        a.Status='Obsolete';
        a.GWotGo__c=false;
        update a;
        try{
            delete a;
        } catch(Exception e){
            System.assertNotEquals(null, a.Id);
        }
        a.Record_Usage__c='DCW';
        
        try{
            update a;
        } catch(Exception e){
            System.assertEquals(null, a.IE_Updated_Date__c);
        }
    }
    static testMethod void CaseTriggerCodeCoverageTest(){
        Case war = getTestWar();
        war.Description = 'TEST';
        update war;
        
        Case_Service_Code__c csc = new Case_Service_Code__c();
        csc.Case__c=war.Id;
        insert csc;
        
        delete war;
        System.assertEquals(0, [select Id from Case_Service_Code__c].size());        
    }*/
}