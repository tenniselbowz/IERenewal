public with sharing class InlineEditServiceCodeExt {
    public Id caseId {get; set;}
    public Id deletedCodeId {get; set;}
    public Id cloneCodeId {get; set;}
    public String newCodeUrl {get; set;}
    public List<Case_Service_Code__c> codesToBeDeleted = new List<Case_Service_Code__c>();
    public List<CaseServiceModel> serviceCodes {get; set;}
    public final String NEW_CODE_PAGE = '/apex/CaseServiceCodeEdit2?Id=';
    public final String SERVICE_CODE_TYPE = 'Business Unit';
    public Map<String, ServiceCodeModel> typeToModel;
    public static final String BUSINESS_UNIT = 'Business Unit';
    public static final Set<String> BUSINESS_TYPES = new Set<String>{
        'Business Unit',
        'Unit',
        'Mode',
        'Type',
        'Major',
        'Specific',
        'Warranty Class',
        'Responsibility'
    };
    public Map<Id, Case_Service_Code__c> idToCode = new Map<Id, Case_Service_Code__c>();
    public InlineEditServiceCodeExt(ApexPages.StandardController controller) {
        Case currentCase = [SELECT Business_Unit__c FROM Case WHERE Id =:controller.getRecord().Id LIMIT 1];

        this.caseId = currentCase.Id;
        List<Service_Code__c> businessCodeForCase = [SELECT Id FROM Service_Code__c WHERE Name =: currentCase.Business_Unit__c AND Type__c =: BUSINESS_UNIT LIMIT 1];
        String templateQuery = 'SELECT Business_Unit_Calc__c, UnitCode__c, TypeCode__c, MajorCode__c,ModeCode__c, SpecificCode__c, WarrantyClassCode__c, Responsibility__c, {0} FROM Case_Service_Code__c WHERE Case__c = {1}';
        List<String> fillers = new List<String>{serviceCodeFields(), '\'' + caseId + '\''};
        String query = String.format(templateQuery, fillers);
        this.typeToModel = ServiceCodeModel.generateModelsPerType(BUSINESS_TYPES);
        //for (Service_Code__c code : [SELECT Name, Label__c, Parent__c, Type__c, Unit_Code__c FROM Service_Code__c WHERE Type__c IN: BUSINESS_TYPES AND Active__c = true]) {
        //    typeToModel.get(code.Type__c).add(code);
        //}
        
        this.serviceCodes = new List<CaseServiceModel>();
        for(Case_Service_Code__c cs : Database.query(query)) {
            serviceCodes.add(new CaseServiceModel(cs, typeToModel, businessCodeForCase[0].Id));
        }

    }
    private String serviceCodeFields() {
        List<String> fieldNames = new List<String>{'Name'};
        Schema.FieldSet fieldSet = Schema.SObjectType.Case_Service_Code__c.fieldSets.getMap().get('In_Line_Edit');
        for (Schema.FieldSetMember field : fieldSet.getFields()) {
            fieldNames.add(field.getFieldPath());
        }
        return String.join(fieldNames, ',');
    }

    public void handleDelete() {
        for (Integer i = 0; i < serviceCodes.size(); i++ ) {
            if (serviceCodes[i].caseServiceCode.Id == deletedCodeId) {
                codesToBeDeleted.add(serviceCodes[i].caseServiceCode);
                serviceCodes.remove(i);
                break;
            }
        }
    }

    public void handleNew() {
        Case parentCase = [
            SELECT Business_Unit__c 
            FROM Case
            WHERE Id =: this.caseId
            LIMIT 1
        ];
        Case_Service_Code__c newCaseServiceCode = new Case_Service_Code__c(
            Case__c=parentCase.Id
        );
        try {
            insert newCaseServiceCode;
            newCodeUrl = NEW_CODE_PAGE + newCaseServiceCode.Id;
        } catch(DmlException e) {
            ApexPages.addmessage(
                new ApexPages.message(
                    ApexPages.severity.ERROR,
                    'There was an error contructing shell record for the new code page: ' + e.getMessage())
            );
            newCodeUrl = null;  
        }
    }

    public PageReference handleClone() {
        Case_Service_Code__c csc = [SELECT Id, Case__c, Description__c, 
            X3rd_Party_Parts_Amount_Approved__c, X3rd_Party_Parts_Amount_Requested__c, 
            Additional_Materials_Amount_Approved__c, Additional_Materials_Amount_Requested__c,  
            Daikin_Parts_Amount_Approved__c, Daikin_Parts_Amount_Requested__c, 
            Hours_Approved__c, Hours_Requested__c, 
            Labor_Amount_Approved__c, Labor_Amount_Requested__c, 
            MajorCode__c, ModeCode__c, 
            Responsibility__c, SpecificCode__c, 
            TypeCode__c, UnitCode__c, WarrantyClassCode__c
            FROM Case_Service_code__c
            WHERE Id =: cloneCodeId
            LIMIT 1
        ];
        Case_Service_Code__c newCaseServiceCode = csc.clone();
        try {
            insert newCaseServiceCode;
        } catch(DmlException e) {
            ApexPages.addmessage(
                new ApexPages.message(
                    ApexPages.severity.ERROR,
                    'There was an error contructing shell record for the new code page: ' + e.getMessage())
            );
        }
        PageReference pageRef = new PageReference('/apex/InlineEditServiceCode?Id='+csc.Case__c);
        pageRef.setRedirect(true);
        return pageRef;
    }

    public PageReference save() {
        Savepoint sp = Database.setSavepoint();
        List<Case_Service_Code__c> updatedCaseServiceCodes = new List<Case_Service_Code__c>();
        for(CaseServiceModel csm : serviceCodes) {
            updatedCaseServiceCodes.add(csm.caseServiceCode);
        }
        try {
            update updatedCaseServiceCodes;
            delete codesToBeDeleted;
        } catch(Exception e) {
            ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR,'There was an error saving records: ' + e.getMessage())
            );
            Database.rollback(sp);
            return null;
        }
        PageReference pr = new PageReference('/apex/InlineEditServiceCode?Id=' + caseId);
        pr.setRedirect(true);
        return pr;
    }

   public class CaseServiceModel{
        String businessUnitId;
        public Case_Service_Code__c caseServiceCode {get;set;}
        Map<String, ServiceCodeModel> scModel;
        public List<SelectOption> unitOptions {
            get{
                String type = 'Unit';
                this.scModel.get(type).removeAll();
                //for (Service_Code__c code : [SELECT Name, Label__c, Parent__c, Type__c, Unit_Code__c FROM Service_Code__c WHERE Type__c =:type AND Parent__c=:businessUnitId AND Active__c = true order by Label__c]) {
                //    this.scModel.get(type).add(code);
                //}
                for(Service_Code_Junction__c sc :[select Child__r.Id, Child__r.Name, Child__r.Label__c from Service_Code_Junction__c where Child__r.Type__c='Unit' and Child__r.Active__c=true and Parent__c=:businessUnitId order by Child__r.Label__c])
                    this.scModel.get(type).add(sc.Child__r);
                //return formatOptions(this.scModel.get(type).serviceCodesWithParent.get(businessUnitId));
                return formatOptions(this.scModel.get(type).all());
            }set;}
        public List<SelectOption> modeOptions{
            get{
                String type = 'Mode';
                this.scModel.get(type).removeAll();
                for (Service_Code__c code : [SELECT Name, Label__c, Parent__c, Type__c, Unit_Code__c FROM Service_Code__c WHERE Type__c =:type AND Active__c = true order by Label__c]) {
                    this.scModel.get(type).add(code);
                }
                return formatOptions(this.scModel.get(type).all());
            }set;}
        public List<SelectOption> typeOptions{
            get {
                String type = 'Type';
                this.scModel.get(type).removeAll();
                //for (Service_Code__c code : [SELECT Name, Label__c, Parent__c, Type__c, Unit_Code__c FROM Service_Code__c WHERE Type__c =:type AND Parent__c=:this.caseServiceCode.ModeCode__c AND Unit_Code__c=:this.caseServiceCode.UnitCode__c AND Active__c = true order by Label__c]) {
                //    this.scModel.get(type).add(code);
                //}
                for(Service_Code_Junction__c sc :[select Child__r.Id, Child__r.Name, Child__r.Label__c from Service_Code_Junction__c where Child__r.Type__c='Type' and Child__r.Active__c=true and Parent__c=:this.caseServiceCode.ModeCode__c and Unit__c=:this.caseServiceCode.UnitCode__c order by Child__r.Label__c])
                    this.scModel.get(type).add(sc.Child__r);
                //return formatOptions(this.scModel.get(type).fromParentAndUnit(this.caseServiceCode.ModeCode__c, this.caseServiceCode.UnitCode__c));
                return formatOptions(this.scModel.get(type).all());
            }set;}
        public List<SelectOption> majorOptions{
            get{
                String type = 'Major';
                this.scModel.get(type).removeAll();
                //for (Service_Code__c code : [SELECT Name, Label__c, Parent__c, Type__c, Unit_Code__c FROM Service_Code__c WHERE Type__c =:type AND Parent__c=:businessUnitId AND Unit_Code__c=:this.caseServiceCode.UnitCode__c AND Active__c = true order by Label__c]) {
                //    this.scModel.get(type).add(code);
                //}
                for(Service_Code_Junction__c sc :[select Child__r.Id, Child__r.Name, Child__r.Label__c from Service_Code_Junction__c where Child__r.Type__c='Major' and Child__r.Active__c=true and Parent__c=:businessUnitId and Unit__c=:this.caseServiceCode.UnitCode__c order by Child__r.Label__c])
                    this.scModel.get(type).add(sc.Child__r);
                //return formatOptions(this.scModel.get(type).fromParentAndUnit(businessUnitId, this.caseServiceCode.UnitCode__c));
                return formatOptions(this.scModel.get(type).all());
            }set;}
        public List<SelectOption> specificOptions{
            get{
                String type = 'Specific';
                this.scModel.get(type).removeAll();
                //for (Service_Code__c code : [SELECT Name, Label__c, Parent__c, Type__c, Unit_Code__c FROM Service_Code__c WHERE Type__c =:type AND Parent__c=:this.caseServiceCode.MajorCode__c AND Unit_Code__c=:this.caseServiceCode.UnitCode__c AND Active__c = true order by Label__c]) {
                //    this.scModel.get(type).add(code);
                //}
                for(Service_Code_Junction__c sc :[select Child__r.Id, Child__r.Name, Child__r.Label__c from Service_Code_Junction__c where Child__r.Type__c='Specific' and Child__r.Active__c=true and Parent__c=:this.caseServiceCode.MajorCode__c and Unit__c=:this.caseServiceCode.UnitCode__c order by Child__r.Name])
                    this.scModel.get(type).add(sc.Child__r);
                //return formatOptions(this.scModel.get(type).fromParentAndUnit(this.caseServiceCode.MajorCode__c, this.caseServiceCode.UnitCode__c));
                return formatOptions(this.scModel.get(type).all());
            }set;}
        public List<SelectOption> warrantyOptions{
            get{
                String type = 'Warranty Class';
                this.scModel.get(type).removeAll();
                //for (Service_Code__c code : [SELECT Name, Label__c, Parent__c, Type__c, Unit_Code__c FROM Service_Code__c WHERE Type__c =:type AND Parent__c=:businessUnitId AND Active__c = true order by Label__c]) {
                //    this.scModel.get(type).add(code);
                //}
                for(Service_Code_Junction__c sc :[select Child__r.Id, Child__r.Name, Child__r.Label__c from Service_Code_Junction__c where Child__r.Type__c='Warranty Class' and Child__r.Active__c=true and Parent__c=:businessUnitId order by Child__r.Label__c])
                    this.scModel.get(type).add(sc.Child__r);
                //return formatOptions(this.scModel.get(type).serviceCodesWithParent.get(businessUnitId));
                return formatOptions(this.scModel.get(type).all());
            }set;}
        public List<SelectOption> respOptions{
            get{
                String type = 'Responsibility';
                this.scModel.get(type).removeAll();
                //for (Service_Code__c code : [SELECT Name, Label__c, Parent__c, Type__c, Unit_Code__c FROM Service_Code__c WHERE Type__c =:type AND Parent__c=:businessUnitId AND Active__c = true order by Label__c]) {
                //    this.scModel.get(type).add(code);
                //}
                for(Service_Code_Junction__c sc :[select Child__r.Id, Child__r.Name, Child__r.Label__c from Service_Code_Junction__c where Child__r.Type__c='Responsibility' and Child__r.Active__c=true and Parent__c=:businessUnitId order by Child__r.Name])
                    this.scModel.get(type).add(sc.Child__r);
                //return formatOptions(this.scModel.get(type).serviceCodesWithParent.get(businessUnitId));
                return formatOptions(this.scModel.get(type).all());
            }set;}
        public CaseServiceModel(Case_Service_Code__c caseServiceCode, Map<String, ServiceCodeModel> typeToModel, String businessUnitId) {
            this.caseServiceCode = caseServiceCode;
            this.scModel = typeToModel;
            this.businessUnitId = businessUnitId;
        }
        private List<SelectOption> formatOptions(List<Service_Code__c> serviceCodes) {
            if (serviceCodes == null) {
                return null;
            }
            List<SelectOption> options = new List<SelectOption>{new SelectOption('', '')};
            for(Service_Code__c code :(List<Service_Code__c>)serviceCodes) {
                String optionLabel = '';
                if (code.Name != null) {
                    optionLabel = code.Name;
                }
                if (code.Label__c != null) {
                    optionLabel = code.Label__c;
                }

                options.add(new SelectOption(code.Id, optionLabel));
            }
            return options;
        }
   }
}