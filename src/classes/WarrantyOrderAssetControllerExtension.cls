global class WarrantyOrderAssetControllerExtension implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([select Id, Order__r.Id from Asset where Id in :lst]);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Asset> assets = (List<Asset>)scope;
        processAssets(assets, pcase);
    }
    
    global void finish(Database.BatchableContext BC){
    }    
    
    private void processAssets(List<Asset> assets, Case pcase){
        List<Case> cases = new List<Case>();
        for(Asset a :assets){
            Case c = pcase.clone();
            c.ParentId = pcase.Id;
            c.AssetId = a.Id;
            c.Case_Category__c = 'Claim';
            c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Warranty').getRecordTypeId();//'0122F0000008acg';
            cases.add(c);
        }
        if(cases.size()>0)
            insert cases;
    
    }

    private Case pcase;
    private List<String> lst;
    
    public WarrantyOrderAssetControllerExtension () {
        String pcaseId = ApexPages.currentPage().getParameters().get('id');
        if(pcaseId != null)
            pcase = [select Id, Order__c from Case where Id=:pcaseId];        
        else
            pcase = null;
    }
    public WarrantyOrderAssetControllerExtension (List<String> lst, Case pcase) {
        this.pcase = pcase;
        this.lst = lst;
    }

    public Id getId(){
        if(pcase != null)
            return pcase.Id;
        return null;
    }
    
    public List<Asset> getOrderAssets() {
        if(pcase==null)
            return null;
        if(pcase.Order__c==null){return new List<Asset>();
        }
        return [select Id, Name, SerialNumber, SO_Line_Number__c, Product2.DW_Product_Business_Unit__c, Product2.ProductCode from Asset where Order__c=:pcase.Order__c and Id not in (select AssetId from Case where Parent.Id=:pcase.Id) order by Product2.DW_Product_Business_Unit__c, SO_Line_Number__c, SerialNumber LIMIT 1000];
    }
    
    @RemoteAction
    public static Integer createOrderAssets(String pId, List<String> lst) {
        Case pcase = [select Id, Order__r.Id, RecordTypeId, AccountId, ContactId, Origin, Priority, Date_of_Failure__c, Date_Received__c, Subject, Case_Category__c, Type, Status, Reason_For_Authorization_Request__c, Pay_To__c/*, Business_Unit_Multi__c*/, OwnerId from Case where Id=:pId];        
        String l = '(';
        for(String ls : lst){l+='\''+ls+'\', ';
        }
        if(l.endsWith(', ')){l = l.substring(0, l.length()-2);
        }
        l+=')';
        System.debug(l);
        Integer origcount = 0;
        if(l!='()'){
            origcount = Database.countQuery('select count() from Asset where Id in '+l);
            if(origcount>50)
                Database.executeBatch(new WarrantyOrderAssetControllerExtension(lst, pcase));
            else
                new WarrantyOrderAssetControllerExtension(lst, pcase).execute(null, [select Id, Order__r.Id from Asset where Id in :lst]);
        }
        return origcount;
    }
    
    public PageReference save() {
        PageReference redirectSuccess = new ApexPages.StandardController(pcase).view();
        return (redirectSuccess);
    }
    public PageReference cancel() {
        PageReference redirectSuccess = new ApexPages.StandardController(pcase).view();
        return (redirectSuccess);
    }
    public PageReference close() {
        PageReference redirectSuccess = new ApexPages.StandardController(pcase).view();
        return (redirectSuccess);
    }
}