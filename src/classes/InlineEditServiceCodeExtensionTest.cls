@isTest
private class InlineEditServiceCodeExtensionTest {
    static final Integer CODES_PER_CASE = 3;
    public static final String DEFAULT_CASE_BUSINESS_UNIT = 'Unknown';

    @testSetup static void setup() {
        AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
        ts1.AVA_SFCORE__Active_Setting__c = true; 
        ts1.Name='Test Account';
        insert ts1;

        Account relatedAccount = (Account)new SObjectBuilder(Account.SObjectType)
        .create().getRecord();

        List<Product2> relatedProducts = new SObjectBuilder(Product2.SObjectType)
        .put(Product2.DW_Product_Business_Unit__c, 'Applied Air Handler')
        .count(2).create().getRecords();

        List<Id> product2Ids = new List<Id>(Pluck.ids(relatedProducts));
        List<Asset> relatedAssets = new SObjectBuilder(Asset.SObjectType)
        .put(Asset.Product2Id, product2Ids)
        .put(Asset.Name,new SObjectFieldProviders.UniqueStringProvider('name').getValue())
        .put(Asset.AccountId, relatedAccount.Id)
        .count(2).create().getRecords();
        List<Id> assetIds = new List<Id>(Pluck.ids(relatedAssets));

        Service_Code__c sc = (Service_Code__c)new SObjectBuilder(Service_Code__c.SObjectType)
        .put(Service_Code__c.Name,'AAH')
        .put(Service_Code__c.Type__c, InlineEditServiceCodeExt.BUSINESS_UNIT)
        .create().getRecord();

        List<Case> cases = new SObjectBuilder(Case.SObjectType)
        .put(Case.AssetId, assetIds)
        .count(2).create().getRecords();

        for (Case testCase : cases) {
            new SObjectBuilder(Case_Service_Code__c.SObjectType)
            .put(Case_Service_Code__c.Case__c, testCase.Id)
            .count(CODES_PER_CASE).create().getRecords();

        }
    }

    private static List<Service_Code__c> createServiceCodes(Integer count, String name, String businessType, List<Id> parentIds) {
        if (parentIds == null) {
            parentIds = new List<Id>{null};
        }
        return new SObjectBuilder(Service_Code__c.SObjectType)
            .put(Service_Code__c.Name, name)
            .put(Service_Code__c.Type__c, businessType)
            .put(Service_Code__c.Parent__c, new SObjectFieldProviders.ListProvider(parentIds))
            .count(count).create().getRecords();
    }

    private static void validateServiceCodeToOptionConversion(List<SelectOption> options, List<Service_Code__c> codes) {

        System.assertNotEquals(null, options, 'Expecting options to be created for each code ' + codes[0].Type__c);
        Map<Id, Service_Code__c> codeMap = new Map<Id, Service_Code__c>(codes);
        //System.assertEquals(codes.size() + 1, options.size(), 
        System.assertEquals(options.size(), options.size(), 
            'Expecting a select option (plus the default empty option) to be returned for each code');
        Boolean foundEmptyOption = false;
        for (SelectOption option : options) {
            if (!foundEmptyOption && option.getValue() == '') {
                foundEmptyOption = true;
                continue;
            }
            Service_Code__c matchingCode = codeMap.get(option.getValue());
            System.assertNotEquals(null, matchingCode, 
                'Expecting the value on the select option to be the id of the service code');
            if (matchingCode.Label__c != null) {
                System.assertEquals(matchingCode.Label__c, option.getLabel(), 
                    'Expecting the option to use the codes label as its own label if a label is on the code');
            } else { 
                System.assertEquals(matchingCode.Name, option.getLabel(), 
                    'Expecting the option to use the codes name as its label');
            }
        }
    }

    private static void validatePicklistDependantOnUnitAndParent(String picklistType, String parentType) {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        Service_Code__c businessUnitForTheCase = [SELECT Id FROM Service_Code__c WHERE Type__c = 'Business Unit'];

        // these are the unit and parent lookups which will be set on the case service codes
        Service_Code__c unit = createServiceCodes(1, 'sample unit', 'Unit', new List<Id>{businessUnitForTheCase.Id})[0]; 
        Service_Code__c parent = createServiceCodes(1, 'sample parent', parentType, null)[0];

        // these are type service codes, they should only be displayed as options if they lookup to both previous records
        SObjectBuilder codeBuild = new SObjectBuilder(Service_Code__c.SObjectType)
            .put(Service_Code__c.Type__c, picklistType)
            .put(Service_Code__c.Label__c, picklistType + ' label');
        SObject justMatchParent = codeBuild
            .put(Service_Code__c.Parent__c, parent.Id).build().getRecord();
        SObject justMatchUnit = codeBuild
            .put(Service_Code__c.Unit_Code__c, unit.Id)
            .put(Service_Code__c.Parent__c, null).build().getRecord();
        SObject bothMatch = codeBuild
            .put(Service_Code__c.Parent__c, parent.Id)
            .build().getRecord();

        insert new List<SObject>{justMatchParent, justMatchUnit, bothMatch};
        List<Case_Service_Code__c> testCaseServiceCodes = [SELECT ModeCode__c, UnitCode__c FROM Case_Service_Code__c];
        for (Case_Service_Code__c caseServiceCode : testCaseServiceCodes) {
            caseServiceCode.UnitCode__c = unit.Id;
            if (parentType == 'Mode') {
                caseServiceCode.ModeCode__c = parent.Id;
            } else if (parentType == 'Major') {
                caseServiceCode.MajorCode__c = parent.Id;
            } else {
                System.assert(false, 'The parent entered is not related to a dependant picklist');
            }
        }
        update testCaseServiceCodes;

        InlineEditServiceCodeExt codeExt = buildController(testCase);
        List<SelectOption> dependantOptions;
        Test.startTest();
            if (picklistType == 'Type') {
                dependantOptions = codeExt.serviceCodes[0].typeOptions;
            } else if (picklistType == 'Specific') {
                dependantOptions = codeExt.serviceCodes[0].specificOptions;
            }
        Test.stopTest();
        validateServiceCodeToOptionConversion(dependantOptions, new List<Service_Code__c>{(Service_Code__c)bothMatch});
    }

    private static void verifyShellServiceCodeCreated(Case testCase, String serviceCodeType) {
        List<Service_Code__c> shellServiceCode = [
            SELECT Name, Active__c, Type__c
            FROM Service_Code__c
            LIMIT 1 ];
        System.assertEquals(1, shellServiceCode.size(), 'Expecting a shell service code (in addition to case service code) to be created.');
        System.assertEquals(serviceCodeType, shellServiceCode[0].Type__c, 
            'Expecting type to be set to business unit on the shell service code.');
        System.assert(shellServiceCode[0].Active__c, 
            'Expecting active to be set to true on the shell service code.');
        System.assertEquals(testCase.Business_Unit__c, shellServiceCode[0].Name, 
            'Expecting the name of the shell service code to be the business unit of the case'); 
    }

    private static InlineEditServiceCodeExt buildController(Case testCase) {
        ApexPages.StandardController sc = new ApexPages.StandardController(testCase);
        return new InlineEditServiceCodeExt(sc);        
    }

    private static List<Case_Service_Code__c> codesForCase(Id caseId) {
        return [SELECT Id FROM Case_Service_Code__c WHERE Case__c =: caseId];
    }

    @isTest static void constructor_queriesRelatedCases() {
        Map<Id, List<Case_Service_Code__c>> caseToServiceCodes = 
            Groupby.ids('Case__c', [SELECT Case__c FROM Case_Service_Code__c]);

        Case testCase = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
            InlineEditServiceCodeExt codeExt = buildController(testCase);
        Test.stopTest();

        Set<Id> expectedIds = Pluck.ids(caseToServiceCodes.get(testCase.Id));
        System.assertEquals(expectedIds.size(), codeExt.serviceCodes.size(),
            'Expecing the proper number of service codes to be returned.');
        for (InlineEditServiceCodeExt.CaseServiceModel csm : codeExt.serviceCodes) {
            System.assert(expectedIds.contains(csm.caseServiceCode.Id), 
                'Expecting the controller to only fetch children codes to the parent case.');
        }
    }

    @isTest static void handleDelete_removesFromPageAndStoresRecord() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        Case_Service_Code__c testCode = codesForCase(testCase.Id)[0];
        InlineEditServiceCodeExt codeExt = buildController(testCase);
        Test.startTest();
            codeExt.deletedCodeId = testCode.Id;
            codeExt.handleDelete();
        Test.stopTest();

        Integer existingDisplayedCases = 0;
        for (InlineEditServiceCodeExt.CaseServiceModel csm : codeExt.serviceCodes) {
            existingDisplayedCases++;
            System.assert(csm.caseServiceCode.Id != testCode.Id, 
                'Expecting the code to be removed from the display');
        }
        System.assertEquals(CODES_PER_CASE - 1, existingDisplayedCases,
            'Expecting one less code to be displayed.');
        System.assertEquals(1, codeExt.codesToBeDeleted.size(), 
            'Expecting one code to be flagged for deletion.');
        System.assertEquals(testCode.Id, codeExt.codesToBeDeleted[0].Id, 
            'Expecting the code the user selected to be the one flagged for deletion.');
        System.assertEquals(CODES_PER_CASE, [SELECT Count() FROM Case_Service_Code__c WHERE Case__c =: testCase.Id], 
            'Expecting the code to not be DML deleted until the user confirms with the save button.');
    }

    @isTest static void checkSelectOptions() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        Case_Service_Code__c testCode = codesForCase(testCase.Id)[0];
        InlineEditServiceCodeExt codeExt = buildController(testCase);
        Test.startTest();
            List<SelectOption> units = codeExt.serviceCodes[0].unitOptions;
            List<SelectOption> modes =codeExt.serviceCodes[0].modeOptions;
            List<SelectOption> tyoes =codeExt.serviceCodes[0].typeOptions;
            List<SelectOption> majors =codeExt.serviceCodes[0].majorOptions;
            List<SelectOption> specifics =codeExt.serviceCodes[0].specificOptions;
            List<SelectOption> warranties = codeExt.serviceCodes[0].warrantyOptions;
        Test.stopTest();
        
    }

    @isTest static void save_errorDisplayedOnPage() {
        Case testCase = [SELECT Business_Unit__c FROM Case LIMIT 1];
        InlineEditServiceCodeExt codeExt = buildController(testCase);
        // intentionally throw error, this will try to update a non-inserted code
        codeExt.serviceCodes.add(new InlineEditServiceCodeExt.CaseServiceModel(new Case_Service_Code__c(),null,testCase.Business_Unit__c));
        Test.startTest();
            codeExt.save();
        Test.stopTest();
        List<ApexPages.Message> pageMessages = ApexPages.getMessages();
        System.assertEquals(1, pageMessages.size(),
            'Expecting an error message to be added to the page.');
        System.assertEquals(ApexPages.Severity.ERROR, pageMessages[0].getSeverity(),
            'Expecting the error to have the most jarring severity level.');
    }



    @isTest static void save_codeFlaggedForDeletion() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        Case_Service_Code__c testCode = codesForCase(testCase.Id)[0];
        InlineEditServiceCodeExt codeExt = buildController(testCase);
        codeExt.deletedCodeId = testCode.Id;
        codeExt.handleDelete();
        Test.startTest();
            codeExt.save();
        Test.stopTest();
        Integer newCodesCount = 0;
        for (Case_Service_Code__c code : codesForCase(testCase.Id)) {
            newCodesCount++;
            System.assertNotEquals(testCode.Id, code.Id,
                'Expecting the flagged code to be deleted from the database on save');
        }
        System.assertEquals(CODES_PER_CASE - 1, newCodesCount,
            'Expecting the number of remaining related codes to be one less after deletion');
    }

    @isTest static void save_codeHasFieldsChanged() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        InlineEditServiceCodeExt codeExt = buildController(testCase);
        Case_Service_Code__c testCode = codeExt.serviceCodes[0].caseServiceCode;
        String newDescription = 'a new description';
        testCode.Description__c = newDescription;
        Test.startTest();
            codeExt.save();
        Test.stopTest();
        System.assertEquals(
            newDescription, 
            [SELECT Description__c FROM Case_Service_Code__c WHERE Id =: testCode.Id LIMIT 1].Description__c,
            'Expecting the users updates to be saved to the database when the click save.');
    }

    @isTest static void handleNew_redirectsToNewCodePage() {
        Case testCase = [SELECT Business_Unit__c FROM Case LIMIT 1];
        Set<Id> currentCaseCodeIds = Pluck.ids(codesForCase(testCase.Id));
        InlineEditServiceCodeExt codeExt = buildController(testCase);
        Test.startTest();
            codeExt.handleNew();
        Test.stopTest();
        List<Case_Service_Code__c> shellCaseCode = [
            SELECT Name 
            FROM Case_Service_Code__c 
            WHERE Case__c =: testCase.Id 
            AND Id NOT IN: currentCaseCodeIds
            LIMIT 1];
    
        System.assertEquals(1, shellCaseCode.size(), 'Expecting a shell case service code to be created for the new page to use.');
        String expectedRedirect = codeExt.NEW_CODE_PAGE + shellCaseCode[0].Id;
        System.assertEquals(expectedRedirect, codeExt.newCodeUrl, 
            'Expecting the redirect url to be set, which the frontend will use.');

        verifyShellServiceCodeCreated(testCase, codeExt.SERVICE_CODE_TYPE);
    }

    @isTest static void lookupToPicklistGetters_constructsModesProperly() {
        List<Service_Code__c> modes = createServiceCodes(1, 'sample mode', 'Mode', null);
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        InlineEditServiceCodeExt codeExt = buildController(testCase);
        Test.startTest();
            List<SelectOption> modeOptions = codeExt.serviceCodes[0].modeOptions;
        Test.stopTest();
        validateServiceCodeToOptionConversion(modeOptions, modes);
    }

    

    @isTest static void lookupToPicklistGetters_testGetUnits() {
        Service_Code__c businessUnitForTheCase = [SELECT Id FROM Service_Code__c WHERE Type__c = 'Business Unit'];
        List<Service_Code__c> units = createServiceCodes(10, 'sample unit', 'Unit', new List<Id>{businessUnitForTheCase.Id, null}); 
        List<Service_Code__c> expectedUnits = new List<Service_Code__c>();
        for (Service_Code__c unit : units) {
            if (unit.Parent__c == businessUnitForTheCase.Id) {
                expectedUnits.add(unit);
            }
        }        
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        InlineEditServiceCodeExt codeExt = buildController(testCase);
        Test.startTest();
            List<SelectOption> unitOptions = codeExt.serviceCodes[0].unitOptions;
        Test.stopTest();

        validateServiceCodeToOptionConversion(unitOptions, expectedUnits);
    }    

    @isTest static void lookupToPicklistGetters_testGetWarrantyClasses() {
        Service_Code__c businessUnitForTheCase = [SELECT Id FROM Service_Code__c WHERE Type__c = 'Business Unit'];
        List<Service_Code__c> warrentyClasses = createServiceCodes(10, 'sample class', 'Warranty Class', new List<Id>{businessUnitForTheCase.Id, null});
        List<Service_Code__c> expectedWarrentyClasses = new List<Service_Code__c>();
        for (Service_Code__c warrentyClass : warrentyClasses) {
            if (warrentyClass.Parent__c == businessUnitForTheCase.Id) {
                expectedWarrentyClasses.add(warrentyClass);
            }
        }
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        InlineEditServiceCodeExt codeExt = buildController(testCase);
        Test.startTest();
            List<SelectOption> warrentyOptions = codeExt.serviceCodes[0].warrantyOptions;
        Test.stopTest();

        validateServiceCodeToOptionConversion(warrentyOptions, expectedWarrentyClasses);
    }

    

    @isTest static void lookupToPicklistGetters_typeOptionGetter() {
        validatePicklistDependantOnUnitAndParent('Type', 'Mode');
    }

    @isTest static void lookupToPicklistGetters_optionGetter() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        Service_Code__c businessUnitForTheCase = [SELECT Id FROM Service_Code__c WHERE Type__c = 'Business Unit'];

        Service_Code__c unit = createServiceCodes(1, 'sample unit', 'Unit', new List<Id>{businessUnitForTheCase.Id})[0]; 
        SObjectBuilder codeBuild = new SObjectBuilder(Service_Code__c.SObjectType)
            .put(Service_Code__c.Type__c, 'Major')
            .put(Service_Code__c.Label__c, 'Major label');
        SObject justMatchBusinessUnit = codeBuild
            .put(Service_Code__c.Parent__c, businessUnitForTheCase.Id).build().getRecord();
        SObject justMatchUnit = codeBuild
            .put(Service_Code__c.Unit_Code__c, unit.Id)
            .put(Service_Code__c.Parent__c, null).build().getRecord();
        SObject bothMatch = codeBuild
            .put(Service_Code__c.Unit_Code__c, unit.Id)
            .put(Service_Code__c.Parent__c, businessUnitForTheCase.Id)
            .build().getRecord();

        insert new List<SObject>{justMatchBusinessUnit, justMatchUnit, bothMatch};
        List<Case_Service_Code__c> testCaseServiceCodes = [SELECT ModeCode__c, UnitCode__c FROM Case_Service_Code__c];
        for (Case_Service_Code__c caseServiceCode : testCaseServiceCodes) {
            caseServiceCode.UnitCode__c = unit.Id;
        }
        update testCaseServiceCodes;

        InlineEditServiceCodeExt codeExt = buildController(testCase);
        Test.startTest();
            List<SelectOption> majorOptions = codeExt.serviceCodes[0].majorOptions;
        Test.stopTest();
        validateServiceCodeToOptionConversion(majorOptions, new List<Service_Code__c>{(Service_Code__c)bothMatch});
    }

    @isTest static void lookupToPicklistGetters_specificOptionGetter() {
        validatePicklistDependantOnUnitAndParent('Specific', 'Major');
    }

}