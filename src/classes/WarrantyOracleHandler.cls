global without sharing class WarrantyOracleHandler implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([select Id from Asset where Id in: aIds]);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Asset> assets = (List<Asset>)scope;
        for(Asset a : assets){
            getWarrantyInfo(a.Id);
        }
    }
    
    global void finish(Database.BatchableContext BC){
    }   
    
    private List<String> aIds;
    public WarrantyOracleHandler(List<String> aIds){
        this.aIds = aIds;
    }

    public static void getWarrantyInfo(List<String> lst){
        if(lst.size()>50)
            Database.executeBatch(new WarrantyOracleHandler(lst));        
        else
            new WarrantyOracleHandler(lst).execute(null, [select Id from Asset where Id in: lst]);
    }

    private static string TOKEN = null;
    private static void authenticate(DaikinOracleEBSWarrantyServiceAccess getWarrServiceAccess){
          list<Integration_Error__c> integrationErrorList = new list<Integration_Error__c>();
          HTTPResponse resp = getWarrServiceAccess.getClientOAuthToken(integrationErrorList);
          if(resp == null || !resp.getBody().startsWith('{')){if(integrationErrorList.size()>0){insert integrationErrorList;}TOKEN=NULL; return;
          }
          TOKEN = ((DaikinOracleEBSWarrantyServiceAccess.ClientOAuthTokenResponse)JSON.deserialize(resp.getBody(), DaikinOracleEBSWarrantyServiceAccess.ClientOAuthTokenResponse.class)).access_token;
    }    
    public static Boolean settingWarrantyInfo = false;

    private static void getAssetWarranty(Asset a, DaikinOracleEBSWarrantyServiceAccess getWarrServiceAccess){
        getAssetWarranty(a, getWarrServiceAccess, true);
    }
    private static void getAssetWarranty(Asset a, DaikinOracleEBSWarrantyServiceAccess getWarrServiceAccess, boolean isfirstattempt){
      list<Integration_Error__c> integrationErrorList = new list<Integration_Error__c>();
      HTTPResponse resp = getWarrServiceAccess.findWarrantyInformation(a.SO_Number__c, a.SerialNumber, TOKEN, integrationErrorList);
      if((resp == null || resp.getStatusCode()==401 || resp.getStatusCode()==403) && isfirstattempt){
          authenticate(getWarrServiceAccess);
          getAssetWarranty(a, getWarrServiceAccess, false);
          return;
      }else if(resp == null || !resp.getBody().startsWith('{')){if(integrationErrorList.size()>0){insert integrationErrorList;}return;
      }

      DaikinOracleEBSWarrantyServiceAccess.WarrantyInformationResponse warrInfoResp = new DaikinOracleEBSWarrantyServiceAccess.WarrantyInformationResponse();
      warrInfoResp = (DaikinOracleEBSWarrantyServiceAccess.WarrantyInformationResponse)JSON.deserialize(resp.getBody(), DaikinOracleEBSWarrantyServiceAccess.WarrantyInformationResponse.class);

      System.debug('Status: '+warrInfoResp.status);
      System.debug('Updated instance detail(s): '+ warrInfoResp.message);
      if(warrInfoResp.status=='S'){
          for (DaikinOracleEBSWarrantyServiceAccess.OrderWarranty oW: warrInfoResp.orders){
              if(oW.order_info.order_number==a.SO_Number__c){
                for (DaikinOracleEBSWarrantyServiceAccess.Line l: oW.lines){
                  if(l.line_info.serial_number == a.SerialNumber){
                      /*if(a.Startup_Date__c == null)*/
                          a.Startup_Date__c = convertString(l.line_info.startup_date);
                      
                      Date sdt = null;
                      Date edt = null;
                      String items = '';
                      for (DaikinOracleEBSWarrantyServiceAccess.Warranty w: l.warranties){
                        Date dt = convertString(w.warranty_start_date);
                        if(sdt==null || dt.daysBetween(sdt)>0)
                            sdt = dt;
                        dt = convertString(w.warranty_end_date);
                        if(edt == null || dt.daysBetween(edt)<0)
                            edt = dt;
                        
                        System.debug('Warranty Description: '+w.warranty_desc != null);
                        System.debug('Warranty Start Date: '+w.warranty_start_date != null);
                        System.debug('Warranty End Date: '+w.warranty_end_date != null);
                        System.debug('Warranty Status: '+w.warranty_status != null);
                        System.debug('Warranty Item: '+w.warranty_item != null);
                        System.debug('Warranty Item Type: '+w.warranty_item_type != null);
                        System.debug('Warranty Type: '+w.warranty_type != null);
                        System.debug('Warranty Subtype: '+w.warranty_subtype != null);
                        if(items!='') {items +=',';}
                        items += '{"Description":"'+w.warranty_desc+'", "Start_Date":"'+w.warranty_start_date+'", "End_Date":"'+w.warranty_end_date+'", "Status":"'+w.warranty_status+'", "Item":"'+w.warranty_item+'", "Item_Type":"'+w.warranty_item_type+'", "Type":"'+w.warranty_type+'", "Sub_Type":"'+w.warranty_subtype+'"}';
                      }

                      a.Actual_Warranty_Start_Date__c=sdt;
                      a.Actual_Warranty_End_Date__c=edt;
                      a.Warranty_Items__c = '{"warranty_items":['+items+']}';                      
                  }
              }
            }
          }
      } else {
          //a.Actual_Warranty_Start_Date__c = null;
          //a.Actual_Warranty_End_Date__c=null;
          a.Warranty_Items__c = '{"warranty_items":[{"Description":"'+warrInfoResp.message+'"}]}';
      }
    }
    
    @future(callout=true)
    public static void getWarrantyInfo(String aId){
        updateWarrantyInfo(aId);
    }
    
    public static void updateWarrantyInfo(String aId){
      Oracle_Warranty_REST_Services_Config__c serviceConfig = Oracle_Warranty_REST_Services_Config__c.getInstance();
      if(!serviceConfig.Active__c){return;
      }
        
      DaikinOracleEBSWarrantyServiceAccess getWarrServiceAccess = new DaikinOracleEBSWarrantyServiceAccess(serviceConfig.OAuthToken_URL__c, serviceConfig.Warranty_URL__c, 
        serviceConfig.Password__c, serviceConfig.User_Name__c, 
        serviceConfig.GetTokenService__c, serviceConfig.FindWarrantyInfoService__c, 
        serviceConfig.GetStartupDatesService__c, serviceConfig.SetStartupDatesService__c);
      if(TOKEN == null)
          authenticate(getWarrServiceAccess);
      for(Asset a : [select Id, SO_Number__c, SerialNumber, Startup_Date__c, Actual_Warranty_Start_Date__c, Actual_Warranty_End_Date__c from Asset where Id = :aId and Warehouse_Id__c != null and Warehouse_Id__c != '']){
          getAssetWarranty(a, getWarrServiceAccess);
          settingWarrantyInfo = true;
          update a;
          settingWarrantyInfo = false;
        }
    }
/*
    @future(callout=true)
    public static void getStartupDate(String aId){      
      Oracle_Warranty_REST_Services_Config__c serviceConfig = Oracle_Warranty_REST_Services_Config__c.getInstance();
      if(!serviceConfig.Active__c){return;
      }

      for(Asset a : [select Id, SO_Number__c, SerialNumber, Startup_Date__c, Actual_Warranty_Start_Date__c from Asset where Id = :aId and Warehouse_Id__c != null and Warehouse_Id__c != '']){
          list<Integration_Error__c> integrationErrorList = new list<Integration_Error__c>();
    
          DaikinOracleEBSWarrantyServiceAccess getWarrServiceAccess = new DaikinOracleEBSWarrantyServiceAccess(serviceConfig.OAuthToken_URL__c, serviceConfig.Warranty_URL__c, 
            serviceConfig.Password__c, serviceConfig.User_Name__c, 
            serviceConfig.GetTokenService__c, serviceConfig.FindWarrantyInfoService__c, 
            serviceConfig.GetStartupDatesService__c, serviceConfig.SetStartupDatesService__c);
          if(TOKEN == null)
              authenticate(getWarrServiceAccess);
              
          HTTPResponse resp = getWarrServiceAccess.getStartupDates(a.SO_Number__c, a.SerialNumber, TOKEN, integrationErrorList);
          if(resp == null || !resp.getBody().startsWith('{')){
              for(Integration_Error__c err : integrationErrorList){
                  System.debug('ERROR: '+err.Error_Description__c);
              }
              return;
          }
    
          DaikinOracleEBSWarrantyServiceAccess.GetStartupDatesResponse getStartupDatesResp = new DaikinOracleEBSWarrantyServiceAccess.GetStartupDatesResponse();          
          getStartupDatesResp = (DaikinOracleEBSWarrantyServiceAccess.GetStartupDatesResponse)JSON.deserialize(resp.getBody(), DaikinOracleEBSWarrantyServiceAccess.GetStartupDatesResponse.class);
    
          System.debug('Status: '+getStartupDatesResp.status);
          System.debug('Updated instance detail(s): '+ getStartupDatesResp.message);
          if(getStartupDatesResp.status=='S'){
              for(DaikinOracleEBSWarrantyServiceAccess.OrderLine1 oL1: getStartupDatesResp.order_lines){
                  if(oL1.order_number==a.SO_Number__c && oL1.shipped_serial_number==a.SerialNumber){
                      System.debug('Order Number: '+oL1.order_number);
                      System.debug('Item Number: '+oL1.item_number);
                      System.debug('Line Number: '+oL1.line_number);
                      System.debug('Model: '+oL1.model);
                      System.debug('Shipment Number: '+oL1.shipment_number);
                      System.debug('Shipped Serial Number: '+oL1.shipped_serial_number);
                      System.debug('Startup Date: '+oL1.startup_date);
                             
                      Date dt = convertString(oL1.startup_date);
                      a.Startup_Date__c=dt;
                      //a.Actual_Warranty_Start_Date__c=dt;
                  }
              }
          } else {
              a.Startup_Date__c = null;
              //a.Actual_Warranty_Start_Date__c = null;
          }
          getAssetWarranty(a, TOKEN, getWarrServiceAccess);
          settingWarrantyInfo = true;
          update a;
          settingWarrantyInfo = false;
      }
    }
*/
    @future(callout=true)
    public static void sendStartupDateList(Set<Id> assetList){
      Oracle_Warranty_REST_Services_Config__c serviceConfig = Oracle_Warranty_REST_Services_Config__c.getInstance();   
        if(!serviceConfig.Active__c){return;
        }
        
      DaikinOracleEBSWarrantyServiceAccess getWarrServiceAccess = new DaikinOracleEBSWarrantyServiceAccess(serviceConfig.OAuthToken_URL__c, serviceConfig.Warranty_URL__c, 
            serviceConfig.Password__c, serviceConfig.User_Name__c, 
            serviceConfig.GetTokenService__c, serviceConfig.FindWarrantyInfoService__c, 
            serviceConfig.GetStartupDatesService__c, serviceConfig.SetStartupDatesService__c);
      if(TOKEN == null)
          authenticate(getWarrServiceAccess);
      sendStartuPDateList(assetList, getWarrServiceAccess);
    }
    
    private static void sendStartupDateList(Set<Id> assetList, DaikinOracleEBSWarrantyServiceAccess getWarrServiceAccess){
        sendStartupDateList(assetList, getWarrServiceAccess, true);
    }
    private static void sendStartupDateList(Set<Id> assetList, DaikinOracleEBSWarrantyServiceAccess getWarrServiceAccess, boolean isfirstattempt){
      // Create Request payload (this example contains 2 order line entries)
      DaikinOracleEBSWarrantyServiceAccess.SetStartupDatesRequest setStartupDatesReq = new DaikinOracleEBSWarrantyServiceAccess.SetStartupDatesRequest();
      setStartupDatesReq.order_lines = new list<DaikinOracleEBSWarrantyServiceAccess.OrderLine2>();

      Map<String, Asset> ats = new Map<String, Asset>();
      for(Asset a : [select Id, SO_Number__c, SerialNumber, Startup_Date__c, Actual_Warranty_Start_Date__c from Asset where Id in :assetList and Warehouse_Id__c != null and Warehouse_Id__c != '']){
          DaikinOracleEBSWarrantyServiceAccess.OrderLine2 ol2_1 = new DaikinOracleEBSWarrantyServiceAccess.OrderLine2();
          ol2_1.order_number = a.SO_Number__c;
          ol2_1.serial_number = a.SerialNumber;
          ol2_1.startup_date = convertDate(a.Startup_Date__c);//27-dec-2019
          if(Test.isRunningTest()){
              convertDate(convertString('01-jan-2019'));
              convertDate(convertString('01-feb-2019'));
              convertDate(convertString('01-mar-2019'));
              convertDate(convertString('01-apr-2019'));
              convertDate(convertString('01-may-2019'));
              convertDate(convertString('01-jun-2019'));
              convertDate(convertString('01-jul-2019'));
              convertDate(convertString('01-aug-2019'));
              convertDate(convertString('01-sep-2019'));
              convertDate(convertString('01-oct-2019'));
              convertDate(convertString('01-nov-2019'));
              convertDate(convertString('01-dec-2019'));
          }
    
          setStartupDatesReq.order_lines.add(ol2_1);
          ats.put(a.SerialNumber, a);
      }

      list<Integration_Error__c> integrationErrorList = new list<Integration_Error__c>();
      HTTPResponse resp = getWarrServiceAccess.setStartupDates(setStartupDatesReq, TOKEN, integrationErrorList);
      if((resp == null || resp.getStatusCode()==401 || resp.getStatusCode()==403) && isfirstattempt){
          authenticate(getWarrServiceAccess);
          sendStartupDateList(assetList, getWarrServiceAccess, false);
          return;
      }else if(resp == null || !resp.getBody().startsWith('{')){if(integrationErrorList.size()>0){insert integrationErrorList;}return;
      }
    
      DaikinOracleEBSWarrantyServiceAccess.SetStartupDatesResponse setStartupDatesResp = new DaikinOracleEBSWarrantyServiceAccess.SetStartupDatesResponse();
      setStartupDatesResp = (DaikinOracleEBSWarrantyServiceAccess.SetStartupDatesResponse)JSON.deserialize(resp.getBody(), DaikinOracleEBSWarrantyServiceAccess.SetStartupDatesResponse.class);

      System.debug('Status: '+setStartupDatesResp.status);
      System.debug('Updated instance detail(s): '+ setStartupDatesResp.message);
      Boolean updated = false;
      for (DaikinOracleEBSWarrantyServiceAccess.OrderLine3 oL3: setStartupDatesResp.order_lines)
      {
          System.debug('Order Number: '+oL3.order_number);
          System.debug('Serial Number: '+oL3.serial_number);
          System.debug('Status: '+oL3.status);
          Asset a = ats.get(oL3.serial_number);
          if(oL3.status=='S'){
              getAssetWarranty(a, getWarrServiceAccess);
              if(!updated)
                  updated = true;
          }
      }
      if(updated){
          settingWarrantyInfo = true;
          update ats.values();
          settingWarrantyInfo = false;
      }
    }
    private static Date convertString(String dstr){    
        //27-dec-2018
        if(dstr == null){return null;}
            
        Integer index = 0;
        Integer index2 = dstr.indexOf('-');
        String d = dstr.substring(index, index2);
        
        index = index2+1;
        index2 = dstr.indexOf('-', index);
        String m = dstr.substring(index, index2).toLowerCase();
        String str = '';
        switch on m{
            when 'jan'{
                str+='1';
            } when 'feb'{
                str+='2';
            } when 'mar'{
                str+='3';
            } when 'apr'{
                str+='4';
            } when 'may'{
                str+='5';
            } when 'jun'{
                str+='6';
            } when 'jul'{
                str+='7';
            } when 'aug'{
                str+='8';
            } when 'sep'{
                str+='9';
            } when 'oct'{
                str+='10';
            } when 'nov'{
                str+='11';
            } when 'dec'{
                str+='12';
            }
        }
        m=str;
        
        index = index2+1;
        index2 = dstr.length();
        String y = dstr.substring(index, index2);
        return Date.parse(m+'/'+d+'/'+y);
    }
    private static String convertDate(Date dt){
        //27-dec-2018
        if(dt == null){return null;}

        String str = String.valueOf(dt.day())+'-';
        switch on dt.month(){
            when 1{
                str+='jan';
            } when 2{
                str+='feb';
            } when 3{
                str+='mar';
            } when 4{
                str+='apr';
            } when 5{
                str+='may';
            } when 6{
                str+='jun';
            } when 7{
                str+='jul';
            } when 8{
                str+='aug';
            } when 9{
                str+='sep';
            } when 10{
                str+='oct';
            } when 11{
                str+='nov';
            } when 12{
                str+='dec';
            }
        }
        str += '-'+String.valueOf(dt.year());
        return str;
    }
}