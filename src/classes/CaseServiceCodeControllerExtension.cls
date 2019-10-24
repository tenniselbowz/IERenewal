public class CaseServiceCodeControllerExtension {

    private final Case_Service_Code__c csc;
    private final Case c;
    private String buId;
    
    public CaseServiceCodeControllerExtension (ApexPages.StandardController stdController) {
        this.csc = (Case_Service_Code__c)stdController.getRecord();
        c = [select Id, Serial_Number__c, Model__c, Product_Class__c, Startup_Date__c, Ship_Date__c, Business_Unit__c from Case where Id=:csc.Case__c limit 1];
        Service_Code__c sc = [select Id, Name, Type__c, Active__c from Service_Code__c where Type__c='Business Unit' and Active__c=true and Name=:c.Business_Unit__c limit 1];
        buId = sc.Id;        
    }

    public String getSerialNumber(){
        return c.Serial_Number__c;
    }

    public String getStartupDate(){
        Datetime dte = (Datetime)c.Startup_Date__c;
        if(dte==null)
            return '';
        return dte.format('yyyy-MM-dd');
    }

    public String getShipDate(){
        Datetime dte = (Datetime)c.Ship_Date__c;
        if(dte==null)
            return '';
        return dte.format('yyyy-MM-dd');
    }

    public String getPCL(){
        return c.Product_Class__c;
    }

    public String getModel(){
        return c.Model__c;
    }

    public String getCaseBusinessUnit() {
        return c.Business_Unit__c;
    }

    public String getCaseBusinessUnitId() {
        return buId;
    }

    public List<SelectOption> getBusinessUnits() {
        List<SelectOption> lst = new List<SelectOption>();

        List<Service_Code__c> scs = [select Id, Name, Label__c from Service_Code__c where Type__c='Business Unit' and Active__c=true order by Label__c];
        for(Service_Code__c sc :scs)
            lst.add(new SelectOption(sc.Id, sc.Label__c));

        //lst.sort();
        return lst;
    }

    @RemoteAction
    public static List<String[]> getUnits(String buId) {
        List<String[]> lst = new List<String[]>();

        List<Service_Code__c> scs = [select Id, Name, Label__c from Service_Code__c where Type__c='Unit' and Active__c=true and Parent__c=:buId order by Label__c];
        for(Service_Code__c sc :scs)
            lst.add(new String[]{sc.Id, sc.Name, sc.Label__c});
            
        //lst.sort();
        return lst;
    }

    public List<SelectOption> getModes() {
        List<SelectOption> lst = new List<SelectOption>();

        List<Service_Code__c> scs = [select Id, Name, Label__c from Service_Code__c where Type__c='Mode' and Active__c=true order by Label__c];
        for(Service_Code__c sc :scs)
            lst.add(new SelectOption(sc.Id, sc.Label__c));
            
        //lst.sort();
        return lst;
    }

    @RemoteAction
    public static List<String[]> getTypes(String modeId, String unitId) {
        List<String[]> lst = new List<String[]>();

        List<Service_Code__c> scs = [select Id, Name, Label__c from Service_Code__c where Type__c='Type' and Active__c=true and Parent__c=:modeId and Unit_Code__c=:unitId order by Label__c];
        for(Service_Code__c sc :scs)
            lst.add(new String[]{sc.Id, sc.Name, sc.Label__c});
            
        //lst.sort();
        return lst;
    }

    @RemoteAction
    public static List<String[]> getMajors(String buId, String unitId) {
        List<String[]> lst = new List<String[]>();

        List<Service_Code__c> scs = [select Id, Name, Label__c from Service_Code__c where Type__c='Major' and Active__c=true and Parent__c=:buId and Unit_Code__c=:unitId order by Label__c];
        for(Service_Code__c sc :scs)
            lst.add(new String[]{sc.Id, sc.Name, sc.Label__c});
            
        //lst.sort();
        return lst;
    }

    @RemoteAction
    public static List<String[]> getSpecifics(String majorId, String unitId) {
        List<String[]> lst = new List<String[]>();

        List<Service_Code__c> scs = [select Id, Name, Label__c from Service_Code__c where Type__c='Specific' and Active__c=true and Parent__c=:majorId and Unit_Code__c=:unitId order by Name];
        for(Service_Code__c sc :scs)
            lst.add(new String[]{sc.Id, sc.Name, sc.Label__c});
            
        //lst.sort();
        return lst;
    }

    @RemoteAction
    public static List<String[]> getClassifications(String buId) {
        List<String[]> lst = new List<String[]>();

        List<Service_Code__c> scs = [select Id, Name, Label__c from Service_Code__c where Type__c='Warranty Class' and Active__c=true and Parent__c=:buId order by Label__c];
        for(Service_Code__c sc :scs)
            lst.add(new String[]{sc.Id, sc.Name, sc.Label__c});
           
        //lst.sort();
        return lst;
   }

    @RemoteAction
    public static List<String[]> getResponsibility(String buId) {
        List<String[]> lst = new List<String[]>();

        List<Service_Code__c> scs = [select Id, Name, Label__c from Service_Code__c where Type__c='Responsibility' and Active__c=true and Parent__c=:buId order by Name];
        for(Service_Code__c sc :scs)
            lst.add(new String[]{sc.Id, sc.Name, sc.Label__c});
           
        //lst.sort();
        return lst;
   }
}