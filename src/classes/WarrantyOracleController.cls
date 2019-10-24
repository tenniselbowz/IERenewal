public class WarrantyOracleController{

    public ApexPages.StandardController WarrantyOracleController{get; set;}
    public WarrantyOracleController(ApexPages.StandardController controller){
        WarrantyOracleController = controller;
    }

    public void getWarrantyInfo(){
        //String aId = ApexPages.currentPage().getParameters().get('Id');
        SObject sobj = WarrantyOracleController.getRecord();
        Id aId;
        if(sobj instanceof Case)
            aId = [select Id, AssetId from Case where Id=:((Case)sobj).Id].AssetId;
        else
            aId = ((Asset)sobj).Id;
        WarrantyOracleHandler.updateWarrantyInfo(aId);
    }
    
    public List<WarrantyItem> getItems(){
        //String aId = ApexPages.currentPage().getParameters().get('Id');
        SObject sobj = WarrantyOracleController.getRecord();
        String jsn;
        if(sobj instanceof Case)
            jsn = [select Id, Asset.Warranty_Items__c from Case where Id = :((Case)sobj).Id].Asset.Warranty_Items__c;
        else 
            jsn = [select Id, Warranty_Items__c from Asset where Id = :((Asset)sobj).Id].Warranty_Items__c;
        if(jsn == null || jsn == ''){jsn = '{"warranty_items":[]}';
        }   
        System.debug('JSON: '+jsn);
        List<WarrantyItem> witms = new List<WarrantyItem>();
        JSONParser parser = JSON.createParser(jsn);
        WarrantyItem i = null;
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)) {
                String name = parser.getText();
                parser.nextToken();
                String val = parser.getText();
                System.debug('DEBUG: '+name+' = '+val);
                if(name == 'Description'){
                    if(i != null){witms.add(i);}
                    i = new WarrantyItem();
                    i.Description=val;
                } else if(name == 'Start_Date'){
                    i.StartDate=val;
                } else if(name == 'End_Date'){
                    i.EndDate=val;
                } else if(name == 'Status'){
                    i.Status=val;
                } else if(name == 'Item'){
                    i.Item=val;
                } else if(name == 'Item_Type'){
                    i.ItemType=val;
                } else if(name == 'Type'){
                    i.Type=val;
                } else if(name == 'Sub_Type'){
                    i.SubType=val;
                }
            }
        }
        if(i != null)
            witms.add(i);
        System.debug('Items: '+witms.size());
        return witms;
    }
    
    public class WarrantyItem{
        public String Description{get;set;}
        public String StartDate{get;set;}
        public String EndDate{get;set;}
        public String Status{get;set;}
        public String Item{get;set;}
        public String ItemType{get;set;}
        public String Type{get;set;}
        public String SubType{get;set;}
    }
}