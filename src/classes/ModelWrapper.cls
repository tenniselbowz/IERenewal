public class ModelWrapper {
    final public String SERVICE_TECH = '*Service Technician S&R/TK';
    public Integer rowNumber {get; set;}
    private Apttus_Config2__LineItem__c lineItem;
    public Ma_Model__c modelObj {get; set;}

    public ModelWrapper(Ma_Model__c model, Apttus_Config2__LineItem__c line, Integer rowCount, Boolean isLabor) {
        lineItem = line;
        if(isLabor) {
            model.Equipment_Type_Labor__c = model.Equipment_Type__c;
        }
        if(model != null && model.Equipment_Type__c == SERVICE_TECH) {
            model.Equipment_Type_Labor__c = '--None--';
        }
        modelObj = model;
        rowNumber = rowCount;
    }
}