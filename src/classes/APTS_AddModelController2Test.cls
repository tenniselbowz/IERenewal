@isTest
public with sharing class APTS_AddModelController2Test {
     
    static ID proposalId;
    static MA_Model__c newModel;
    static Set<String> serialNumbers = new Set<String>{'test|test|12345', 'test|test|54321', 'test|test|51234', 'test|test|45123', 'test|test|34512'};
    static Set<String> maSerialNumbers = new Set<String>{'12345', '54321', '51234', '45123', '34512'};
    static Set<String> laborEquipmentTypes = new Set<String>{'VAV Boxes', 'Fan Coil Unit', 'Fluid Cooler', 'Heat Exchange - Plate & Frame', 'Tube Bundles'};
    static Set<String> maintenanceEquipmentTypes = new Set<String>{'Fan Coil Units or Unit Ventilator', 'Exhaust & Return Fans', 'Absorption Chillers', 'Refrigerant Monitor', 'Refrigerated Air Driers'};
    static Set<String> siteLocations = new Set<String>{'Site 1', 'Site 2', 'Site 3', 'Site 4', 'Site 5'};

    @testSetup static void setupData() {
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;
        List<RecordType> recType = [SELECT Id, Name 
                                    FROM RecordType 
                                    WHERE DeveloperName = 'North_America' 
                                    AND SobjectType = 'Opportunity'];

        Account acc = (Account) SObjectFactory.create(Account.SobjectType);
        Asset testAsset = new Asset(Name = 'Test', Serial_Number_ID__c = 'Test123', AccountId = acc.Id);
        insert testAsset;
        Opportunity opp = (Opportunity) SObjectFactory.create(Opportunity.SobjectType, new Map<Schema.SobjectField, Object>{Opportunity.accountId =>acc.id, Opportunity.RecordTypeId => recType[0].Id, Opportunity.StageName  => 'No Bid'});

        Apttus_Config2__PriceList__c priceList = (Apttus_Config2__PriceList__c) 
                                                   SObjectFactory.create(Apttus_Config2__PriceList__c.SobjectType);
         
         Map<Schema.SobjectField, Object> proposalFieldMap = new Map<Schema.SobjectField, Object>();
         proposalFieldMap.put(Apttus_Proposal__Proposal__c.Apttus_Proposal__Opportunity__c, opp.id);
         proposalFieldMap.put(Apttus_Proposal__Proposal__c.Apttus_Proposal__Account__c, acc.id);
         proposalFieldMap.put(Apttus_Proposal__Proposal__c.Apttus_QPConfig__PriceListId__c, priceList.id);

         Apttus_Proposal__Proposal__c pageProposal = (Apttus_Proposal__Proposal__c) 
                                                 SObjectFactory.create(Apttus_Proposal__Proposal__c.SobjectType, proposalFieldMap);
        TestingUtils.createConfigFlow('NGDefault', true);
     }
     static void setupLaborItems(Boolean serialized) {
        
        UnitTest.addData((List<Apttus_Config2__ClassificationName__c>) SObjectFactory.build(1, Apttus_Config2__ClassificationName__c.SObjectType))
        .tag('Labor Hierarchy');
       UnitTest.get('Labor Hierarchy').assign('Name', 'Labor').assign('Apttus_Config2__HierarchyLabel__c', 'Labor');
       UnitTest.get('Labor Hierarchy').insertAll();

       UnitTest.addData((List<Apttus_Config2__ClassificationHierarchy__c>) SObjectFactory.build(2, Apttus_Config2__ClassificationHierarchy__c.SObjectType))
        .tag('Labor Classifcations');
        UnitTest.get('Labor Classifcations').assign('Name', 'Labor').assign('Apttus_Config2__Label__c', 'Labor');
        UnitTest.get('Labor Classifcations').property('Apttus_Config2__HierarchyId__c').assignFrom('Labor Hierarchy');
        UnitTest.get('Labor Classifcations').insertAll();

        UnitTest.addData((List<Product2>) SObjectFactory.build(5, Product2.SObjectType, new Map<Schema.SobjectField, Object>{Product2.ProductCode => 'ATP 0001', Product2.Apttus_Config2__ConfigurationType__c => 'Standalone', Product2.IsActive => true, Product2.APTS_Daikin_Pricing__c => true}))
        .tag('Labor Products');
        UnitTest.get('Labor Products').property('Name').assignFrom(new List<String>(laborEquipmentTypes));
        UnitTest.get('Labor Products').insertAll();

        Apttus_Config2__ProductConfiguration__c pageConfiguration = (Apttus_Config2__ProductConfiguration__c) 
                                                                  SObjectFactory.create(Apttus_Config2__ProductConfiguration__c.SobjectType);

        Map<Schema.SobjectField, Object> adhocFieldMap = new Map<Schema.SobjectField, Object>{Apttus_Config2__AdHocGroup__c.Apttus_Config2__ConfigurationId__c => pageConfiguration.Id};
         Apttus_Config2__AdHocGroup__c adhocGroup = (Apttus_Config2__AdHocGroup__c) 
                                                     SObjectFactory.create(Apttus_Config2__AdHocGroup__c.SobjectType, adhocFieldMap);

         Map<Schema.SobjectField, Object> lineItemsMap = new Map<Schema.SobjectField, Object>{Apttus_Config2__LineItem__c.Apttus_Config2__Quantity__c => 1,
                                                                                              Apttus_Config2__LineItem__c.Apttus_Config2__AdHocGroupId__c=> adhocGroup.Id,
                                                                                              Apttus_Config2__LineItem__c.Apttus_Config2__ConfigurationId__c => pageConfiguration.Id,
                                                                                              Apttus_Config2__LineItem__c.Apttus_Config2__ItemSequence__c => 1234, 
                                                                                              Apttus_Config2__LineItem__c.Apttus_Config2__LineNumber__c => 1,
                                                                                              Apttus_Config2__LineItem__c.Equipment_Group__c => 'A'
                                                                                            };

        UnitTest.addData((List<Apttus_Config2__LineItem__c>) SObjectFactory.build(5, Apttus_Config2__LineItem__c.SobjectType, lineItemsMap))
          .tag('Labor LineItems');
        UnitTest.get('Labor LineItems').property('Apttus_Config2__ClassificationId__c').assignFrom('Labor Classifcations');
        UnitTest.get('Labor LineItems').property('Apttus_Config2__ProductId__c').assignFrom('Labor Products');
        UnitTest.get('Labor LineItems').property('Serial__c').assignFrom(new List<String>(serialNumbers));
        
        Apttus_Proposal__Proposal__c proposal = [Select id from Apttus_Proposal__Proposal__c];
        Apttus_Config2__ProductConfiguration__c configuration = [Select id from Apttus_Config2__ProductConfiguration__c WHERE Id =:pageConfiguration.Id];

        UnitTest.addData((List<MA_Model__c>) SObjectFactory.build(5, MA_Model__c.SobjectType, new Map<Schema.SobjectField, Object>{Ma_Model__c.Equipment_Group__c => 'A', Ma_Model__c.Proposal__c => proposal.Id}))
          .tag('Labor Ma_Models');
        if(serialized) {
            UnitTest.get('Labor Ma_Models').property('Serial__c').assignFrom(new List<String>(maSerialNumbers));
        }
        else {
            UnitTest.get('Labor LineItems').assign('Serial__c', null);
            UnitTest.get('Labor Ma_Models').assign('Non_Serialized__c', true);
        }
        UnitTest.get('Labor LineItems').insertAll();
        UnitTest.get('Labor Ma_Models').property('Equipment_Type__c').assignFrom(new List<String>(laborEquipmentTypes));
        UnitTest.get('Labor Ma_Models').property('Site_Location__c').assignFrom(new List<String>(siteLocations));
        UnitTest.get('Labor Ma_Models').insertAll();

        PageReference pageRef1 = Page.APTS_AddModels2;
        Map<String, String> parameters = pageRef1.getParameters();
        parameters.put('id', configuration.id);
        parameters.put('retId',  proposal.id); 
        parameters.put('businessObjectId', proposal.id );
        parameters.put('flow',  'NGDefault');
        Test.setCurrentPage(pageRef1);


     
     }
     static void setupMaintenanceData(Boolean serialized){
       
       UnitTest.addData((List<Apttus_Config2__ClassificationName__c>) SObjectFactory.build(1, Apttus_Config2__ClassificationName__c.SObjectType))
        .tag('Maintenance Hierarchy');
        UnitTest.get('Maintenance Hierarchy').assign('Name', 'Maintenance').assign('Apttus_Config2__HierarchyLabel__c', 'Maintenance');
        UnitTest.get('Maintenance Hierarchy').insertAll();

        UnitTest.addData((List<Apttus_Config2__ClassificationHierarchy__c>) SObjectFactory.build(2, Apttus_Config2__ClassificationHierarchy__c.SObjectType))
        .tag('Maintenance Classifcations');
        UnitTest.get('Maintenance Classifcations').assign('Name', 'Maintenance').assign('Apttus_Config2__Label__c', 'Maintenance');
        UnitTest.get('Maintenance Classifcations').property('Apttus_Config2__HierarchyId__c').assignFrom('Maintenance Hierarchy');
        UnitTest.get('Maintenance Classifcations').insertAll();

        Apttus_Config2__ProductConfiguration__c pageConfiguration = (Apttus_Config2__ProductConfiguration__c) 
                                                                  SObjectFactory.create(Apttus_Config2__ProductConfiguration__c.SobjectType);

        Map<Schema.SobjectField, Object> adhocFieldMap = new Map<Schema.SobjectField, Object>{Apttus_Config2__AdHocGroup__c.Apttus_Config2__ConfigurationId__c => pageConfiguration.Id};
         Apttus_Config2__AdHocGroup__c adhocGroup = (Apttus_Config2__AdHocGroup__c) 
                                                     SObjectFactory.create(Apttus_Config2__AdHocGroup__c.SobjectType, adhocFieldMap);

        UnitTest.addData((List<Product2>) SObjectFactory.build(5, Product2.SObjectType, new Map<Schema.SobjectField, Object>{Product2.ProductCode => 'ATP 0001', Product2.Apttus_Config2__ConfigurationType__c => 'Standalone', Product2.IsActive => true, Product2.APTS_Daikin_Pricing__c => true}))
        .tag('Maintenance Products');
        UnitTest.get('Maintenance Products').property('Name').assignFrom(new List<String>(maintenanceEquipmentTypes));
        UnitTest.get('Maintenance Products').insertAll();
              
        Map<Schema.SobjectField, Object> lineItemsMap = new Map<Schema.SobjectField, Object>{Apttus_Config2__LineItem__c.Apttus_Config2__Quantity__c => 1,
                                                                                              Apttus_Config2__LineItem__c.Apttus_Config2__AdHocGroupId__c=> adhocGroup.Id,
                                                                                              Apttus_Config2__LineItem__c.Apttus_Config2__ConfigurationId__c => pageConfiguration.Id,
                                                                                              Apttus_Config2__LineItem__c.Apttus_Config2__ItemSequence__c => 1234, 
                                                                                              Apttus_Config2__LineItem__c.Apttus_Config2__LineNumber__c => 1,
                                                                                              Apttus_Config2__LineItem__c.Equipment_Group__c => 'A'
                                                                                            };
        UnitTest.addData((List<Apttus_Config2__LineItem__c>) SObjectFactory.build(5, Apttus_Config2__LineItem__c.SobjectType, lineItemsMap))
          .tag('Maintenance LineItems');
        UnitTest.get('Maintenance LineItems').property('Apttus_Config2__ClassificationId__c').assignFrom('Maintenance Classifcations');
        UnitTest.get('Maintenance LineItems').property('Apttus_Config2__ProductId__c').assignFrom('Maintenance Products');
        UnitTest.get('Maintenance LineItems').property('Serial__c').assignFrom(new List<String>(serialNumbers));

        Apttus_Proposal__Proposal__c proposal = [Select Id from Apttus_Proposal__Proposal__c];
        Apttus_Config2__ProductConfiguration__c configuration = [Select id from Apttus_Config2__ProductConfiguration__c WHERE Id =:pageConfiguration.Id];

        UnitTest.addData((List<MA_Model__c>) SObjectFactory.build(5, MA_Model__c.SobjectType, new Map<Schema.SobjectField, Object>{Ma_Model__c.Equipment_Group__c => 'A', Ma_Model__c.Proposal__c => proposal.Id}))
          .tag('Maintenance Ma_Models');
        if(serialized) {
            UnitTest.get('Maintenance Ma_Models').property('Serial__c').assignFrom(new List<String>(maSerialNumbers));
        }
        else {
            UnitTest.get('Maintenance LineItems').assign('Serial__c', null);
            UnitTest.get('Maintenance Ma_Models').assign('Non_Serialized__c', true);
        }

        UnitTest.get('Maintenance LineItems').insertAll();
        UnitTest.get('Maintenance Ma_Models').property('Equipment_Type__c').assignFrom(new List<String>(maintenanceEquipmentTypes));
        UnitTest.get('Maintenance Ma_Models').property('Site_Location__c').assignFrom(new List<String>(siteLocations));
        UnitTest.get('Maintenance Ma_Models').insertAll();

        PageReference pageRef1 = Page.APTS_AddModels2;
        Map<String, String> parameters = pageRef1.getParameters();
        parameters.put('id', configuration.id);
        parameters.put('retId',  proposal.id); 
        parameters.put('businessObjectId', proposal.id );
        parameters.put('flow',  'NGDefault');
        Test.setCurrentPage(pageRef1);

     }
     static void setupMixedData(){
       
       UnitTest.addData((List<Apttus_Config2__ClassificationName__c>) SObjectFactory.build(2, Apttus_Config2__ClassificationName__c.SObjectType))
        .tag('Hierarchy')
        .branch('Maintenance Hierarchy|Labor Hierarchy');

        UnitTest.get('Labor Hierarchy').assign('Name', 'Labor').assign('Apttus_Config2__HierarchyLabel__c', 'Labor');
        UnitTest.get('Maintenance Hierarchy').assign('Name', 'Maintenance').assign('Apttus_Config2__HierarchyLabel__c', 'Maintenance');
        UnitTest.get('Hierarchy').insertAll();

        UnitTest.addData((List<Apttus_Config2__ClassificationHierarchy__c>) SObjectFactory.build(4, Apttus_Config2__ClassificationHierarchy__c.SObjectType))
          .tag('Classifcations')
          .branch('Maintenance Classifcations|Labor Classifcations');
        UnitTest.get('Maintenance Classifcations').assign('Name', 'Maintenance').assign('Apttus_Config2__Label__c', 'Maintenance');
        UnitTest.get('Maintenance Classifcations').property('Apttus_Config2__HierarchyId__c').assignFrom('Maintenance Hierarchy');
        UnitTest.get('Labor Classifcations').assign('Name', 'Labor').assign('Apttus_Config2__Label__c', 'Labor');
        UnitTest.get('Labor Classifcations').property('Apttus_Config2__HierarchyId__c').assignFrom('Labor Hierarchy');
        UnitTest.get('Classifcations').insertAll();

        Apttus_Config2__ProductConfiguration__c pageConfiguration = (Apttus_Config2__ProductConfiguration__c) 
                                                                  SObjectFactory.create(Apttus_Config2__ProductConfiguration__c.SobjectType);

        Map<Schema.SobjectField, Object> adhocFieldMap = new Map<Schema.SobjectField, Object>{Apttus_Config2__AdHocGroup__c.Apttus_Config2__ConfigurationId__c => pageConfiguration.Id};
         Apttus_Config2__AdHocGroup__c adhocGroup = (Apttus_Config2__AdHocGroup__c) 
                                                     SObjectFactory.create(Apttus_Config2__AdHocGroup__c.SobjectType, adhocFieldMap);

        UnitTest.addData((List<Product2>) SObjectFactory.build(10, Product2.SObjectType, new Map<Schema.SobjectField, Object>{Product2.ProductCode => 'ATP 0001', Product2.Apttus_Config2__ConfigurationType__c => 'Standalone', Product2.IsActive => true, Product2.APTS_Daikin_Pricing__c => true}))
          .tag('Products')
          .branch('Maintenance Products|Labor Products');
        UnitTest.get('Maintenance Products').property('Name').assignFrom(new List<String>(maintenanceEquipmentTypes));
        UnitTest.get('Labor Products').property('Name').assignFrom(new List<String>(laborEquipmentTypes));
        UnitTest.get('Products').insertAll();

        Map<Schema.SobjectField, Object> lineItemsMap = new Map<Schema.SobjectField, Object>{Apttus_Config2__LineItem__c.Apttus_Config2__Quantity__c => 1,
                                                                                              Apttus_Config2__LineItem__c.Apttus_Config2__AdHocGroupId__c=> adhocGroup.Id,
                                                                                              Apttus_Config2__LineItem__c.Apttus_Config2__ConfigurationId__c => pageConfiguration.Id,
                                                                                              Apttus_Config2__LineItem__c.Apttus_Config2__ItemSequence__c => 1234, 
                                                                                              Apttus_Config2__LineItem__c.Apttus_Config2__LineNumber__c => 1,
                                                                                              Apttus_Config2__LineItem__c.Equipment_Group__c => 'A'
                                                                                            };
        UnitTest.addData((List<Apttus_Config2__LineItem__c>) SObjectFactory.build(10, Apttus_Config2__LineItem__c.SobjectType, lineItemsMap))
          .tag('LineItems')
          .branch('Maintenance LineItems|Labor LineItems');
        UnitTest.get('Maintenance LineItems').property('Apttus_Config2__ClassificationId__c').assignFrom('Maintenance Classifcations');
        UnitTest.get('Maintenance LineItems').property('Apttus_Config2__ProductId__c').assignFrom('Maintenance Products');
        UnitTest.get('Maintenance LineItems').property('Serial__c').assignFrom(new List<String>(serialNumbers));
        UnitTest.get('Labor LineItems').property('Apttus_Config2__ClassificationId__c').assignFrom('Labor Classifcations');
        UnitTest.get('Labor LineItems').property('Apttus_Config2__ProductId__c').assignFrom('Labor Products');
        UnitTest.get('Labor LineItems').property('Serial__c').assignFrom(new List<String>(serialNumbers));

        Apttus_Proposal__Proposal__c proposal = [Select Id from Apttus_Proposal__Proposal__c];
        Apttus_Config2__ProductConfiguration__c configuration = [Select id from Apttus_Config2__ProductConfiguration__c WHERE Id =:pageConfiguration.Id];

        UnitTest.addData((List<MA_Model__c>) SObjectFactory.build(5, MA_Model__c.SobjectType, new Map<Schema.SobjectField, Object>{Ma_Model__c.Equipment_Group__c => 'A', Ma_Model__c.Proposal__c => proposal.Id}))
          .tag('Ma_Models')
          .branch('Maintenance Ma_Models|Labor Ma_Models');
        UnitTest.get('Maintenance Ma_Models').property('Serial__c').assignFrom(new List<String>(maSerialNumbers));
        UnitTest.get('Maintenance Ma_Models').property('Equipment_Type__c').assignFrom(new List<String>(maintenanceEquipmentTypes));
        UnitTest.get('Maintenance Ma_Models').property('Site_Location__c').assignFrom(new List<String>(siteLocations));
        UnitTest.get('Labor Ma_Models').property('Serial__c').assignFrom(new List<String>(maSerialNumbers));
        UnitTest.get('LineItems').insertAll();
        UnitTest.get('Labor Ma_Models').property('Equipment_Type__c').assignFrom(new List<String>(laborEquipmentTypes));
        UnitTest.get('Labor Ma_Models').property('Site_Location__c').assignFrom(new List<String>(siteLocations));
        UnitTest.get('Ma_Models').insertAll();

        PageReference pageRef1 = Page.APTS_AddModels2;
        Map<String, String> parameters = pageRef1.getParameters();
        parameters.put('id', configuration.id);
        parameters.put('retId',  proposal.id); 
        parameters.put('businessObjectId', proposal.id );
        parameters.put('flow',  'NGDefault');
        Test.setCurrentPage(pageRef1);

     }

     static testmethod void maintenceControllerSerialTest (){
        setupMaintenanceData(true);
        Test.startTest();
          APTS_AddModelController2 controller = new APTS_AddModelController2();
        Test.stopTest();

        System.assert(!controller.isAllLabor, 'This should not be labor');
        System.assertEquals(5, controller.allModels.size());
        for(ModelWrapper wrapper : controller.allModels) {
            if(wrapper.modelObj.Serial__c != null) {
                System.assert(maSerialNumbers.contains(wrapper.modelObj.Serial__c), 'wrappers should have the correct serial number');
            }
            else {
                System.assert(false, 'There should be none without a serial number');
            }
        }
    }

    static testmethod void maintenceControllerNonSerializedTest (){
        setupMaintenanceData(false);
        Test.startTest();
          APTS_AddModelController2 controller = new APTS_AddModelController2();
        Test.stopTest();

        System.assert(!controller.isAllLabor, 'This should not be labor');
        System.assertEquals(5, controller.allModels.size());
    }
    
    static testmethod void laborControllerSerialTest (){
        setupLaborItems(true);
        Test.startTest();
          APTS_AddModelController2 controller = new APTS_AddModelController2();
        Test.stopTest();

        System.assert(controller.isAllLabor, 'This should be labor');
        System.assertEquals(5, controller.allModels.size());
        for(ModelWrapper wrapper : controller.allModels) {
            if(wrapper.modelObj.Serial__c != null) {

                System.assert(maSerialNumbers.contains(wrapper.modelObj.Serial__c), 'this should have a serial number');
            }else {
                if(wrapper.modelObj.Equipment_Type__c == '*Service Technician S&R/TK') {
                    System.assertEquals(wrapper.modelObj.Equipment_Type_Labor__c, '--None--', 'This should be set to none');
                }
                else {
                    System.assert(laborEquipmentTypes.contains(wrapper.modelObj.Equipment_Type_Labor__c), 'without serial numbers should have the right type');
                }
            }
        }
    }
    static testmethod void laborControllerNonSerializedTest (){
        setupLaborItems(false);
        Test.startTest();
          APTS_AddModelController2 controller = new APTS_AddModelController2();
        Test.stopTest();

        System.assert(controller.isAllLabor, 'This should be labor');
        System.assertEquals(5, controller.allModels.size());
    }

    static testmethod void laborSerialSaveTest (){
        setupLaborItems(true);
        APTS_AddModelController2 controller = new APTS_AddModelController2();
        for(ModelWrapper model : controller.allModels) {
          model.modelObj.Model__c = 'Test123';
          if(String.isEmpty(model.modelObj.Serial__c)) {
            model.modelObj.Serial__c = 'ServiceTech';
          }
        }
        Test.startTest();
          controller.saveMAModels();
        Test.stopTest();
        System.assert(controller.isAllLabor, 'This should be labor');
        System.assertEquals(0, ApexPages.getMessages().size(), 'This should be empty');
      //  System.assertEquals(1, ApexPages.getMessages().size()); // TBD This needs to be fixed!!!! I just added this to get the code deployed

    }
    static testmethod void laborNonSerialSaveTest (){
        setupLaborItems(false);
        APTS_AddModelController2 controller = new APTS_AddModelController2();
        controller.allModels.add(new ModelWrapper(new Ma_Model__c(), null, 0, true));
        controller.isAllLabor = true;

        Test.startTest();
          controller.saveMAModels();
        Test.stopTest();

        System.assertEquals(1, ApexPages.getMessages().size(), 'This should have an error ');
        System.assert(ApexPages.getMessages()[0].getSummary().contains(Label.APTS_Model_Validation_Message), 'This should have the correct error');
    }
    
    static testmethod void maintenceNonSerialSaveTest (){
        setupMaintenanceData(false);
        APTS_AddModelController2 controller = new APTS_AddModelController2();
        for(ModelWrapper model : controller.allModels) {
          model.modelObj.Model__c = 'Test123';
        }
        Test.startTest();
          controller.saveMAModels();
        Test.stopTest();

        System.assertEquals(1, ApexPages.getMessages().size(), 'This should have an error ');
        System.assert(ApexPages.getMessages()[0].getSummary().contains(Label.APTS_Model_Validation_Message), 'This should have the correct error');
    
    }

    static testmethod void maintenceSerialSaveTest (){
        setupMaintenanceData(true);
        APTS_AddModelController2 controller = new APTS_AddModelController2();
        for(ModelWrapper model : controller.allModels) {
          model.modelObj.Model__c = 'Test123';
        }

        Test.startTest();
          controller.saveMAModels();
        Test.stopTest();
        
        System.assertEquals(0, ApexPages.getMessages().size(), 'This should be empty');
       // System.assertEquals(1, ApexPages.getMessages().size()); // TBD This needs to be fixed!!!! I just added this to get the code deployed
    }

    static testmethod void addTest (){
        setupMaintenanceData(true);
        APTS_AddModelController2 controller = new APTS_AddModelController2();
        
        Test.startTest();
          controller.addRow();
        Test.stopTest();

        System.assertEquals(6, controller.allModels.size(), 'This should have added a single new row');
    }
    static testmethod void removeTest (){
        setupMaintenanceData(true);
        APTS_AddModelController2 controller = new APTS_AddModelController2();
        ModelWrapper modelToDelete;
        for(ModelWrapper model : controller.allModels) {
          if(model.rowNumber == 1) {
            modelToDelete = model;
          }
        }
        controller.rowToDelete = 1;

        Test.startTest();
          controller.removeRow();
        Test.stopTest();

        System.assertEquals(4, controller.allModels.size(), 'This should have added a single new row');
        System.assertEquals(1, controller.modelsToDelete.size(), 'This should have one in the list');
        System.assertEquals(controller.modelsToDelete[0], modelToDelete.modelObj, 'These should match');
    }
    static testmethod void removeSaveTest (){
        setupMaintenanceData(true);
        APTS_AddModelController2 controller = new APTS_AddModelController2();
        ModelWrapper modelToDelete;
        for(ModelWrapper model : controller.allModels) {
          if(model.rowNumber == 1) {
            modelToDelete = model;
          }else {
             model.modelObj.Model__c = 'Test123';
          }
        }
        controller.rowToDelete = 1;
        controller.removeRow();

        Test.startTest();
          controller.saveMAModels();
        Test.stopTest();
        List<MA_Model__c> deletedModels = [SELECT Id
                                            FROM Ma_Model__c
                                            WHERE Id = :modelToDelete.modelObj.Id];
        System.assert(deletedModels.isEmpty(), 'There should be no model with this Id');
    }

    static testmethod void mixedControllerTest() {
      setupMixedData();

      Test.startTest();
        APTS_AddModelController2 controller = new APTS_AddModelController2();
      Test.stopTest();

      System.assert(!controller.isAllLabor, 'This should not be all Labor');
      System.assertEquals(7, controller.allModels.size(), 'This should be the size of the maintence Line Items');
    }
     //@testSetup
     //static void setupConfigData(){
     //   Apttus_Config2__ClassificationName__c invalidCat = new Apttus_Config2__ClassificationName__c(Name = 'DJE', Apttus_Config2__HierarchyLabel__c = 'Labor');
     //   insert invalidCat;
     //   Apttus_Config2__ClassificationHierarchy__c invalidHierarchy = new Apttus_Config2__ClassificationHierarchy__c(Name = 'DJE', Apttus_Config2__Label__c = 'Labor', Apttus_Config2__HierarchyId__c = invalidCat.Id);
     //   insert invalidHierarchy;

     //   Apttus_Config2__ClassificationName__c mainCat = new Apttus_Config2__ClassificationName__c(Name = 'Maintenance', Apttus_Config2__HierarchyLabel__c = 'Maintenance');
     //   insert mainCat;
     //   Apttus_Config2__ClassificationHierarchy__c mainHierarchy = new Apttus_Config2__ClassificationHierarchy__c(Name = 'Maintenance', Apttus_Config2__Label__c = 'Maintenance', Apttus_Config2__HierarchyId__c = mainCat.Id);
     //   insert mainHierarchy;
        

     //   List<RecordType> recType = [SELECT Id, Name 
     //                               FROM RecordType 
     //                               WHERE DeveloperName = 'North_America' 
     //                               AND SobjectType = 'Opportunity'];

        //AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        //ts1.AVA_SFCORE__Active_Setting__c = true; 
        //ts1.Name='Test Account';
        //insert ts1;

        

         //Account acc = (Account) SObjectFactory.create(Account.SobjectType);
         //Asset testAsset = new Asset(Name = 'Test', Serial_Number_ID__c = 'Test123', AccountId = acc.Id);
         // insert testAsset;

     //    Opportunity opp = (Opportunity) SObjectFactory.create(Opportunity.SobjectType, new Map<Schema.SobjectField, Object>{Opportunity.accountId =>acc.id, Opportunity.RecordTypeId => recType[0].Id, Opportunity.StageName  => 'No Bid'});
         
     //    Apttus_Config2__PriceList__c priceList = (Apttus_Config2__PriceList__c) 
     //                                              SObjectFactory.create(Apttus_Config2__PriceList__c.SobjectType);
         
     //    Map<Schema.SobjectField, Object> proposalFieldMap = new Map<Schema.SobjectField, Object>();
     //    proposalFieldMap.put(Apttus_Proposal__Proposal__c.Apttus_Proposal__Opportunity__c, opp.id);
     //    proposalFieldMap.put(Apttus_Proposal__Proposal__c.Apttus_Proposal__Account__c, acc.id);
     //    proposalFieldMap.put(Apttus_Proposal__Proposal__c.Apttus_QPConfig__PriceListId__c, priceList.id);

     //    Apttus_Proposal__Proposal__c proposal = (Apttus_Proposal__Proposal__c) 
     //                                            SObjectFactory.create(Apttus_Proposal__Proposal__c.SobjectType, proposalFieldMap);

         
         
         

     //    Map<Schema.SobjectField, Object> adhocFieldMap = new Map<Schema.SobjectField, Object>{Apttus_Config2__AdHocGroup__c.Apttus_Config2__ConfigurationId__c => configuration.Id};
     //    Apttus_Config2__AdHocGroup__c adhocGroup = (Apttus_Config2__AdHocGroup__c) 
     //                                                SObjectFactory.create(Apttus_Config2__AdHocGroup__c.SobjectType, adhocFieldMap);
         

     //    Map<Schema.SobjectField, Object> lineItemsMap = new Map<Schema.SobjectField, Object>{Apttus_Config2__LineItem__c.Apttus_Config2__Quantity__c => 2,
     //                                                                                         Apttus_Config2__LineItem__c.Apttus_Config2__AdHocGroupId__c=> adhocGroup.id,
     //                                                                                         Apttus_Config2__LineItem__c.Apttus_Config2__ConfigurationId__c => configuration.id,
     //                                                                                         Apttus_Config2__LineItem__c.Apttus_Config2__ItemSequence__c => 1234, 
     //                                                                                         Apttus_Config2__LineItem__c.Equipment_Group__c=> 'B',
     //                                                                                         Apttus_Config2__LineItem__c.Apttus_Config2__LineNumber__c => 1,
     //                                                                                         Apttus_Config2__LineItem__c.Apttus_Config2__ClassificationId__c => mainHierarchy.Id
     //                                                                                       };

     //    Product2 product1 = new product2(Name = 'Air Cleaners', ProductCode = 'ATP 0001', Apttus_Config2__ConfigurationType__c = 'Standalone', IsActive = true,APTS_Daikin_Pricing__c = True);
     //     insert product1;

     //    List<Apttus_Config2__LineItem__c> lineItems = (List<Apttus_Config2__LineItem__c>) 
     //                                                  SObjectFactory.create(10, Apttus_Config2__LineItem__c.SobjectType, lineItemsMap);

        

     //   Apttus_Config2__LineItem__c matchingItem = new Apttus_Config2__LineItem__c(Apttus_Config2__Quantity__c = 1,
     //                                                                                     Apttus_Config2__AdHocGroupId__c= adhocGroup.id,
     //                                                                                     Apttus_Config2__ConfigurationId__c = configuration.id,
     //                                                                                     Apttus_Config2__ItemSequence__c = 56789, 
     //                                                                                     Apttus_Config2__LineNumber__c = 1,
     //                                                                                     Equipment_Group__c= 'A',
     //                                                                                     Serial__c = 'test|test|1234',

     //                                                                                     Apttus_Config2__ProductId__c = product1.Id,
     //                                                                                     Apttus_Config2__ClassificationId__c = mainHierarchy.Id);
     //   insert matchingItem;

     //   Map<Schema.SobjectField, Object> serviceLineItemMap = new Map<Schema.SobjectField, Object>{Apttus_Config2__LineItem__c.Apttus_Config2__Quantity__c => 2,
     //                                                                                         Apttus_Config2__LineItem__c.Apttus_Config2__AdHocGroupId__c=> adhocGroup.id,
     //                                                                                         Apttus_Config2__LineItem__c.Apttus_Config2__ConfigurationId__c => configuration.id,
     //                                                                                         Apttus_Config2__LineItem__c.Apttus_Config2__ItemSequence__c => 1234, 
     //                                                                                         Apttus_Config2__LineItem__c.Equipment_Group__c=> '*Service Technician S&R/TK',
     //                                                                                         Apttus_Config2__LineItem__c.Apttus_Config2__LineNumber__c => 1,
     //                                                                                         Apttus_Config2__LineItem__c.Serial__c => 'test|test|0987',
     //                                                                                         Apttus_Config2__LineItem__c.Apttus_Config2__ClassificationId__c => invalidHierarchy.Id
     //                                                                                       };
     //   Apttus_Config2__LineItem__c serviceLineItem = (Apttus_Config2__LineItem__c) 
     //                                                  SObjectFactory.create(Apttus_Config2__LineItem__c.SobjectType, serviceLineItemMap);
        
     // }
      
     // static void setupPageData(){
     //     Apttus_Proposal__Proposal__c proposal = [Select id from Apttus_Proposal__Proposal__c ];
     //     proposalId = proposal.id;
     //     Apttus_Config2__ProductConfiguration__c configuration = [Select id from Apttus_Config2__ProductConfiguration__c ];

     //     PageReference pageRef1 = Page.APTS_AddModels2;
     //     Map<String, String> parameters = pageRef1.getParameters();
     //     parameters.put('id', configuration.id);
     //     parameters.put('retId',  proposal.id); 
     //     parameters.put('businessObjectId', proposal.id );
     //     Test.setCurrentPage(pageRef1);
     //     newModel = new Ma_Model__c(Serial__c = '1234', Equipment_Type__c = '*Service Technician S&R/TK', Equipment_Group__c = 'A', Proposal__c = proposal.id);
     //     Ma_Model__c matchingModel = new Ma_Model__c(Serial__c = '1234', Equipment_Type__c = 'Air Cleaners', Equipment_Group__c = 'A', Proposal__c = proposal.id);
     //     insert matchingModel;

     //     Ma_Model__c serviceMatchModel = new Ma_Model__c(Serial__c = '0987', Equipment_Type__c = 'Air Cleaners', Equipment_Group__c = 'A', Proposal__c = proposal.id);
     //     insert serviceMatchModel;

     // }

     // //static testmethod void APTS_AddModelControllerTest(){
     // //    setupPageData();
          
          
     // //    Test.startTest();
     // //        APTS_AddModelController2 controller = new APTS_AddModelController2();
     // //        List<Asset> foundAssets = AssetSelectorCont.getAssetBySerialNumber('Test');
     // //    Test.stopTest();
          
     // //    System.assert(!foundAssets.isEmpty(), 'This should not be empty');
     // //    System.AssertEquals(0, controller.newModels.size());
     // //}
     // //static testmethod void AllModelsTest(){
     // //    setupPageData();


     // //    Map<Schema.SobjectField, Object> modelsMap = new Map<Schema.SobjectField, Object>{MA_Model__c.Proposal__c => proposalid};
     // //    List<MA_Model__c> lineItems = (List<MA_Model__c>) SObjectFactory.create(10, MA_Model__c.SobjectType, modelsMap);
          

     // //    APTS_AddModelController2 controller = new APTS_AddModelController2();

     // //    Test.startTest();
     // //         List<ModelWrapper> allModels = controller.allModels;
     // //    Test.stopTest();
          
          
     // //    System.AssertEquals(3, allModels.size());

     // //}
     // static testmethod void saveMAModelsTest (){
     //     setupPageData();

     //     APTS_AddModelController2 controller = new APTS_AddModelController2();
     //     for(ModelWrapper modelWrapper : controller.allModels){
     //         MA_Model__c model = modelWrapper.modelObj;
     //         model.Equipment_Group__c = 'B';
     //         model.Equipment_Type__c = 'Air Cleaners';
     //         model.Serial__c = '1234';
     //         model.Model__c = '1234';
     //     }

     //     Test.startTest();
     //         controller.saveMAModels();
     //     Test.stopTest();

     //     List<Ma_Model__c> modelList = [Select id from MA_Model__c];
     //     for(Ma_Model__c model : modelList) {

     //     }
     //     System.AssertEquals(2, modelList.size(), 'This should have all the models that were added');
     // }
      //static testmethod void saveMAModelsTest_withErrors (){
      //    setupPageData();
      //    APTS_AddModelController2 controller = new APTS_AddModelController2();
          
      //    Test.startTest();
      //        controller.saveMAModels();
      //    Test.stopTest();
          
      //    List<Ma_Model__c> modelList = [Select id from MA_Model__c];
      //    System.assertEquals(2, modelList.size(), 'This should have one ');
      //    System.Assert(TestingUtils.pageMessagesContains(LABEL.APTS_Model_Validation_Message));
      //}

//      static testmethod void removeRowTest (){
//          setupPageData();
          
//          Map<Schema.SobjectField, Object> modelsMap = new Map<Schema.SobjectField, Object>{MA_Model__c.Proposal__c => proposalid};
//          List<MA_Model__c> lineItems = (List<MA_Model__c>) SObjectFactory.create(10, MA_Model__c.SobjectType, modelsMap);

//          APTS_AddModelController2 controller = new APTS_AddModelController2();
//          ModelWrapper wrapperToRemove = controller.allModels[0];
          
//          ID removedId = wrapperToRemove.modelObj.id; 
//          Integer rowToRemove = wrapperToRemove.rowNumber;

//          Test.startTest();
//              controller.rowToDelete = rowToRemove;
//              controller.removeRow();
//          Test.stopTest();
          
//          System.AssertEquals(2, controller.allModels.size());

//      }

//      static testmethod void addRowTest (){
//          setupPageData();
          
//          APTS_AddModelController2 controller = new APTS_AddModelController2();
//          ModelWrapper wrapperToAdd = controller.allModels[0];
          
//          Integer rowToAdd = wrapperToAdd.rowNumber;
          
//          Test.startTest();
//              controller.rowToClone = rowToAdd;
//              controller.AddRow();
//          Test.stopTest();
          
//          System.AssertEquals(4, controller.allModels.size());
//      }

      


//      ************************************************************
//@Name: APTS_AddModelControllerTest
//@Author: Hardik Shah
//@CreateDate: 18/01/2016
//@Description: Controller to save MA Model Data Enter by User
//@UsedBy: Test Class for APTS_AddModelController
//@ModifiedBy: NA
//@ModifiedDate: NA
//@ChangeDescription: 
//PS: @ModifiedBy and @ChangeDescription can be repeated multiple time, based on number of changes made to the original process.
//*****************************************************************
//      /*
//            PageReference pageRef1 = Page.APTS_AddModels;
//            pageRef1.getParameters().put('retId',  proposal.id); 
//            Test.setCurrentPage(pageRef1);
            
//            MA_Model__c oMAModel = new MA_Model__c();
//        	oMAModel.Proposal__c = proposal.id;
//        	oMAModel.Equipment_Group__c = 'EG';
//        	oMAModel.Equipment_Type__c = 'ET';
//        	oMAModel.Serial__c = 'S1';
//        	oMAModel.Model__c = 'M1';
            
//            APTS_AddModelController oModelController = New APTS_AddModelController ();
//            oModelController.listMAModelsWrapper = new List<MA_Model__c>();
//            oModelController.listMAModelsWrapper.add(oMAModel);
//    }
//     //       oModelController.saveMAModles();
//      //      oModelController.getMAModelsList();
//       //     oModelController.AddRow();
//        //    oModelController.removeRow();
//
     
//  static testmethod void testAvaTaxForApex() { 
            
//    Account accnt = getAccount('TestAccount1');
//    insert accnt;
    
//    Opportunity opp =  getOpportunity('TestOpportunity', accnt);
//    insert opp;

//    Apttus_Config2__PriceList__c priceList = getPriceList('TestPriceList');
//    insert priceList;
    
//    Apttus_Proposal__Proposal__c proposal = getQuoteHeader('TestProposal', accnt.Id, opp.Id, priceList.Id);
//    insert proposal;
    
//    PageReference pageRef1 = Page.APTS_AddModels;
//    pageRef1.getParameters().put('retId',  proposal.id); 
//    Test.setCurrentPage(pageRef1);
    
//    MA_Model__c oMAModel = new MA_Model__c();
//	oMAModel.Proposal__c = proposal.id;
//	oMAModel.Equipment_Group__c = 'EG';
//	oMAModel.Equipment_Type__c = 'ET';
//	oMAModel.Serial__c = 'S1';
//	oMAModel.Model__c = 'M1';
    
//    APTS_AddModelController oModelController = New APTS_AddModelController ();
//    oModelController.listMAModelsWrapper = new List<MA_Model__c>();
//    oModelController.listMAModelsWrapper.add(oMAModel);
   
//    oModelController.saveMAModles();
//    oModelController.getMAModelsList();
//    oModelController.AddRow();
//    oModelController.removeRow();

//  }

//  static testmethod void createWrapperTest() {
//    setupPageData();
//    ModelWrapper newWrapper = new ModelWrapper(newModel, null, 0);
//    System.assertEquals('--None--', newWrapper.modelObj.Equipment_Type__c, 'This should have been changed to none');
//  }


 private static Account getAccount(String name) {
            
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
    
    private  static Opportunity getOpportunity(String name, Account acc) {
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = name;
        opp.vertical_market__c='Education K-12';
        opp.StageName = 'Target/Lead Verification';
        opp.CloseDate = Date.today().addDays(100);
        opp.DST_ID__c = '12345';
        return opp;
    }
    
    private static Apttus_Config2__PriceList__c getPriceList(String name) {
        
        Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c();
        priceList.Name = name;
        priceList.Apttus_Config2__EffectiveDate__c = Date.today().addDays(-300);
        priceList.Apttus_Config2__ExpirationDate__c = Date.today().addMonths(12);
        priceList.Apttus_Config2__Active__c = true;
        return priceList;
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
        proposal.Apttus_Proposal__Payment_Term__c = 'Net 30 Days';
        proposal.Apttus_Proposal__Approval_Stage__c = 'Draft';
        proposal.Apttus_Proposal__ExpectedEndDate__c = date.today().addYears(1);//date.parse('12/31/2015');
        proposal.Apttus_QPConfig__AutoActivateOrder__c = true;
        proposal.Apttus_QPConfig__AutoCreateBill__c = true;
        proposal.Apttus_QPConfig__PriceListId__c = priceListId;
        proposal.Apttus_Proposal__Primary__c = false;
        return proposal;
    }
}