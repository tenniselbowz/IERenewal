public class importCasePlanAssetsFromCSVController {
    public Blob csvFileBody{get;set;}
    public string csvAsString{get;set;}
    public String[] csvFileLines{get;set;}
    public List<Case_Plan_Asset__c> courlist{get;set;}
    public Integer snPosition{get;set;}
    
    private Case_Plan__c cp = null;
    
    public importCasePlanAssetsFromCSVController(ApexPages.StandardController controller){
        this.cp = (Case_Plan__c)controller.getRecord();
        snPosition=0;
    }
    
    public void importCSVFile(){
        csvFileLines = new String[]{};

        if(snPosition==null)
            snPosition=0;

        try{
            csvAsString = csvFileBody.toString();
            csvFileLines = csvAsString.split('\n'); 

            List<String> sns = new List<String>();    
            for(Integer i=1;i<csvFileLines.size();i++){
                //string[] csvRecordData = csvFileLines[i].split(',');
                //sns.add(csvRecordData[snPosition]);
                sns.add(csvFileLines[i].trim());
            }
            if(sns.size()>0){
                if(cp ==null)
                    cp = [select Id from Case_Plan__c Limit 1];
                List<Case_Plan_Asset__c> cpas = [select Asset__c from Case_Plan_Asset__c where Case_Plan__c =:cp.Id];
                List<Id> ids = new List<Id>();
                for(Case_Plan_Asset__c cpa :cpas){
                    ids.add(cpa.Asset__c);
                }
                List<Asset> ass = [select Id, SerialNumber from Asset where SerialNumber in:sns and Id not in:ids];
                if(ass.size()>0){
                    courlist = New List<Case_Plan_Asset__c>(); 
                    for(Asset a :ass){
                        Case_Plan_Asset__c cpa = new Case_Plan_Asset__c();
                        cpa.Asset__c=a.Id;
                        cpa.Case_Plan__c=cp.Id;
                        courlist.add(cpa);
                    }
                    if(courlist.size()>0){
                        insert courlist;
                    }
                }
            }
        }
        catch (Exception e)    
        {
            System.debug(e.getCause());
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importing data. Please make sure input csv file is correct');
            ApexPages.addMessage(errorMessage);
        }  
    }
}