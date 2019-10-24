/*
    Class : GenerateMABundleTaskingControllerTest
    Description : This method contains test method which covers code of below classes
                1. GenerateMABundleTaskingController 
                2. MABundleTaskingUtility
*/

@isTest
public class GenerateMABundleTaskingControllerTest {
    static Set<String> excludedProductCodes;
    static Integer size = 40;
    static Id propId;
    static void setup() {
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;

        Apttus_Config2__PriceList__c apttusPB = (Apttus_Config2__PriceList__c)SobjectFactory.create(Apttus_Config2__PriceList__c.SobjectType, new Map<Schema.SobjectField, Object>{Apttus_Config2__PriceList__c.Apttus_Config2__Active__c => true});

        UnitTest.addData((List<Account>) SObjectFactory.create(1, Account.SObjectType))
                .tag('All Accounts');
    
        UnitTest.addData((List<Opportunity>) SObjectFactory.build(1, Opportunity.SObjectType))
                .property('AccountId').assignFrom('All Accounts')
                .assign('Vertical_Market__c',Opportunity.Vertical_Market__c.getDescribe().getPicklistValues()[0].getValue())
                .assign('StageName','No Bid')
                .tag('All Opportunities')
                .insertall();

        UnitTest.addData((List<Apttus_Proposal__Proposal__c>) SObjectFactory.build(1, Apttus_Proposal__Proposal__c.SObjectType))
            .property('Apttus_Proposal__Opportunity__c').assignFrom('All Opportunities')
            .tag('All Quote/Proposals')
            .insertAll();
        propId = UnitTest.get('All Quote/Proposals').getList()[0].Id;

        UnitTest.addData((List<Apttus_Config2__ClassificationName__c>) SObjectFactory.build(1, Apttus_Config2__ClassificationName__c.SObjectType, new Map<Schema.SobjectField, Object>{Apttus_Config2__ClassificationName__c.Apttus_Config2__Active__c => true}))
        .tag('Maintenance Hierarchy');
        UnitTest.get('Maintenance Hierarchy').assign('Name', 'Maintenance').assign('Apttus_Config2__HierarchyLabel__c', 'Maintenance');
        UnitTest.get('Maintenance Hierarchy').insertAll();

        UnitTest.addData((List<Apttus_Config2__ClassificationName__c>) SObjectFactory.build(1, Apttus_Config2__ClassificationName__c.SObjectType, new Map<Schema.SobjectField, Object>{Apttus_Config2__ClassificationName__c.Apttus_Config2__Active__c => true}))
        .tag('Operational Hierarchy');
        UnitTest.get('Operational Hierarchy').assign('Name', 'Operational Inspection:').assign('Apttus_Config2__HierarchyLabel__c', 'Operational Inspection:');
        UnitTest.get('Operational Hierarchy').insertAll();

        UnitTest.addData((List<Apttus_Config2__ClassificationHierarchy__c>) SObjectFactory.build(1, Apttus_Config2__ClassificationHierarchy__c.SObjectType, new Map<Schema.SobjectField, Object>{Apttus_Config2__ClassificationHierarchy__c.Apttus_Config2__Label__c => 'Offering'}))
        .tag('Maintenance Classifcations');
        UnitTest.get('Maintenance Classifcations').assign('Name', 'Maintenance').assign('Apttus_Config2__Label__c', 'Maintenance');
        UnitTest.get('Maintenance Classifcations').property('Apttus_Config2__HierarchyId__c').assignFrom('Maintenance Hierarchy');
        UnitTest.get('Maintenance Classifcations').insertAll();

        UnitTest.addData((List<Apttus_Config2__ClassificationHierarchy__c>) SObjectFactory.build(1, Apttus_Config2__ClassificationHierarchy__c.SObjectType, new Map<Schema.SobjectField, Object>{Apttus_Config2__ClassificationHierarchy__c.Apttus_Config2__Label__c => 'Offering'}))
        .tag('Operational Inspection Classifcation');
        UnitTest.get('Operational Inspection Classifcation').assign('Name', 'Operational Inspection:').assign('Apttus_Config2__Label__c', 'Operational Inspection:');
        UnitTest.get('Operational Inspection Classifcation').property('Apttus_Config2__HierarchyId__c').assignFrom('Operational Hierarchy');
        UnitTest.get('Operational Inspection Classifcation').insertAll();

        UnitTest.addData((List<Apttus_Config2__ProductOptionGroup__c>) SObjectFactory.build(1, Apttus_Config2__ProductOptionGroup__c.SObjectType, new Map<Schema.SobjectField, Object>{Apttus_Config2__ProductOptionGroup__c.Apttus_Config2__Sequence__c => 0}))
        .tag('Operational Inspection Product Option');
        UnitTest.get('Operational Inspection Product Option').property('Apttus_Config2__OptionGroupId__c').assignFrom('Operational Inspection Classifcation');
        UnitTest.get('Operational Inspection Product Option').insertAll();

        UnitTest.addData((List<Apttus_Config2__ProductOptionComponent__c>) SObjectFactory.build(1, Apttus_Config2__ProductOptionComponent__c.SObjectType, new Map<Schema.SobjectField, Object>{Apttus_Config2__ProductOptionComponent__c.Apttus_Config2__Sequence__c => 0}))
        .tag('Operational Inspection Product Option Component');
        UnitTest.get('Operational Inspection Product Option Component').property('Apttus_Config2__ProductOptionGroupId__c').assignFrom('Operational Inspection Product Option');
        UnitTest.get('Operational Inspection Product Option Component').insertAll();

        UnitTest.addData((List<Apttus_Config2__ProductConfiguration__c>) SObjectFactory.build(1, Apttus_Config2__ProductConfiguration__c.SObjectType))
            .property('Apttus_QPConfig__Proposald__c').assignFrom('All Quote/Proposals')
            .tag('Apttus Product Config')
            .insertAll();

        UnitTest.addData((List<Apttus_Config2__LineItem__c>) SObjectFactory.build(1, Apttus_Config2__LineItem__c.SObjectType, new Map<Schema.SobjectField, Object>{Apttus_Config2__LineItem__c.Apttus_Config2__ItemSequence__c => 0, Apttus_Config2__LineItem__c.Apttus_Config2__LineNumber__c => 0, Apttus_Config2__LineItem__c.Apttus_Config2__PrimaryLineNumber__c => 0}))
        .tag('Operational Inspection Line Item');
        UnitTest.get('Operational Inspection Line Item').property('Apttus_Config2__ProductOptionId__c').assignFrom('Operational Inspection Product Option Component');
        UnitTest.get('Operational Inspection Line Item').property('Apttus_Config2__ConfigurationId__c').assignFrom('Apttus Product Config');
        UnitTest.get('Operational Inspection Line Item').insertAll();

        excludedProductCodes = Pluck.strings('MasterLabel',[SELECT MasterLabel FROM Excluded_Product_Code__mdt]);
    }
    public testmethod static void createBundleAndTaskTest(){
        setup();
        List<String> specialProductCodes = new List<String>{'B8118','T45A4','TI83'};
        UnitTest.addData((List<Product2>)SobjectFactory.build(size,Product2.SobjectType))
            .tag('All Products')
            .branch('Tasking PriceList Items|Non Tasking PriceList Items|Excluded Product|Included Product|Special Product');
        UnitTest.get('Tasking PriceList Items').property('ProductCode').assignFrom(new List<String>(excludedProductCodes));
        UnitTest.get('Non Tasking PriceList Items').assign('ProductCode','T1001');
        UnitTest.get('Excluded Product').assign('Name','Not The Operational Inspection'); 
        UnitTest.get('Excluded Product').assign('ProductCode','T1000');
        UnitTest.get('Included Product').assign('Name','The Operational Inspection'); 
        UnitTest.get('Included Product').assign('ProductCode','T1001');
        UnitTest.get('Special Product').assign('Name','The Special Product'); 
        UnitTest.get('Special Product').property('ProductCode').assignFrom(specialProductCodes);
        UnitTest.get('All Products').insertAll();

        UnitTest.addData((List<Apttus_Proposal__Proposal_Line_Item__c>)SobjectFactory.build(size, Apttus_Proposal__Proposal_Line_Item__c.SobjectType, new Map<Schema.SobjectField, Object>{Apttus_Proposal__Proposal_Line_Item__c.Apttus_QPConfig__LineNumber__c => 1000}))
            .property('Apttus_Proposal__Proposal__c').assignFrom('All Quote/Proposals')
            .tag('All qlis')
            .branch('Bundle qli|Task qli');

        UnitTest.get('Bundle qli')
                .branch('Product Service Bundle| Special Product Bundle');


        UnitTest.get('Task qli')
            .branch('Excluded Tasks|Included Tasks|Do not make Tasks|Make Tasks');
        UnitTest.get('All qlis').property('Apttus_QPConfig__ClassificationId__c').assignFrom('Maintenance Classifcations');
        UnitTest.get('Product Service Bundle').assign('Apttus_QPConfig__LineType__c', 'Product/Service');
        UnitTest.get('Special Product Bundle').property('Apttus_Proposal__Product__c').assignFrom('Special Product');
        UnitTest.get('Special Product Bundle').assign('Apttus_QPConfig__LineType__c', 'Option');
        UnitTest.get('Task qli').assign('Apttus_QPConfig__LineType__c', 'Option');
        UnitTest.get('Excluded Tasks').property('Apttus_QPConfig__OptionId__c').assignFrom('Tasking PriceList Items');
        UnitTest.get('Do not make Tasks').property('Apttus_QPConfig__DerivedFromId__c').assignFrom('Operational Inspection Line Item');
        UnitTest.get('Do not make Tasks').property('Apttus_QPConfig__OptionId__c').assignFrom('Excluded Product');
        UnitTest.get('Make Tasks').property('Apttus_QPConfig__DerivedFromId__c').assignFrom('Operational Inspection Line Item');
        UnitTest.get('Make Tasks').property('Apttus_QPConfig__OptionId__c').assignFrom('Included Product');
        UnitTest.get('Included Tasks').property('Apttus_QPConfig__OptionId__c').assignFrom('Non Tasking PriceList Items');
        UnitTest.get('All qlis').insertAll();

        PageReference pageRef = Page.GenerateMABundleTaskingItems;
        test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', propId); 

        GenerateMABundleTaskingController controller = new GenerateMABundleTaskingController();
        controller.specialProductSet = Pluck.strings('ProductCode',UnitTest.get('Special Product').getList());
        
        Test.startTest();
            controller.generateMABundleTaskingItems();
        Test.stopTest();

        List<Proposal_MA_Bundle__c> bundles = [SELECT Id, MA_Bundle_Name__c, Annual__c, Quote_Proposal__c, The_Seasonal_Inspection_Spring__c, The_Seasonal_Inspection_Fall__c, The_Annual_Inspection__c, The_Operational_Inspection__c, Coils_Services__c FROM Proposal_MA_Bundle__c];
        List<Proposal_MA_Tasking__c> tasks = [SELECT Id, MA_Tasking_Line_Number__c FROM Proposal_MA_Tasking__c];

        System.assertEquals((size/4), bundles.size()/2, 'This should be the correct number of bundles made');
        System.assertEquals(UnitTest.get('Included Tasks').getList().size(), tasks.size()/3, 'This should be the correct number of bundles made');
    
        for(Proposal_MA_Bundle__c bundle : bundles) {
            System.assertEquals(propId, bundle.Quote_Proposal__c, 'This should be related to the correct Quote');
            System.assert(!bundle.The_Seasonal_Inspection_Fall__c, 'This should not be checked');
            System.assert(!bundle.The_Seasonal_Inspection_Spring__c, 'This should not be checked');
            System.assert(!bundle.The_Annual_Inspection__c, 'This should not be checked');
            System.assert(!bundle.The_Operational_Inspection__c, 'This should not be checked');
            if(bundle.MA_Bundle_Name__c == 'Not The Operational Inspection') {
                System.assertEquals(1, bundle.Annual__c, 'This should be set to the frequency');
            }
        }

        for(Proposal_MA_Tasking__c task : tasks) {
            System.assertEquals(1000, task.MA_Tasking_Line_Number__c, 'This should be copied over to the tasking item');
        }
    }

}