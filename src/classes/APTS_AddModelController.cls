/*************************************************************
@Name: APTS_AddModelController
@Author: Hardik Shah
@CreateDate: 18/01/2016
@Description: Controller to save MA Model Data Enter by User
@UsedBy: VF-Page/APTS_AddModel.page
@ModifiedBy: NA
@ModifiedDate: NA
@ChangeDescription: 
PS: @ModifiedBy and @ChangeDescription can be repeated multiple time, based on number of changes made to the original process.
******************************************************************/

public class APTS_AddModelController {
   
   // List of Original MA Models
   public List<MA_Model__c> listOriginalMAModels {get;set;}
   // List of Wrapper  MA Models
   public List<MA_Model__c> listMAModelsWrapper {get;set;}
   // Proposal-Id
   private String sProposalId = null;
   // Unique number associate with each MA-Model
   public String sUniqueNumber {get;set;}
   // Config-Request -id - This Parameter is use when a Page is Redirected
   private String sConfigRequestID = null;
   // Id - This Parameter is use when a Page is Redirected
   private String sID = null;
   
   private Integer iRowCount = 30;
   
    // Constructor 
    // Intializes variables after reterieving from URL
    public APTS_AddModelController(){
       sProposalId =  Apexpages.currentPage().getParameters().get('retId');
       sConfigRequestID =  Apexpages.currentPage().getParameters().get('configRequestId');
       sID =  Apexpages.currentPage().getParameters().get('id');
       iRowCount = getRowCount();
       system.debug('PS-->' + sProposalId + ' PS1--> ' +sConfigRequestID + ' PS2-->' + sID + 'Row-Count' + iRowCount );
       
    }
   
   // ApexPages.StandardSetController must be instantiated
   public ApexPages.StandardSetController setCon {
        get {
            List<MA_Model__c> listMAModel = new List<MA_Model__c>();
            MA_Model__c oMAModel = new MA_Model__c();
            oMAModel.UniqueNumber__c = 'Model' + getUniqueNumber();
            system.debug('HS--> ' + oMAModel.UniqueNumber__c);
            oMAModel.Proposal__c = sProposalId;
            listMAModel.add(oMAModel);
            setCon = new ApexPages.StandardSetController(listMAModel);
            return setCon;
        }
        set;
    }
   
    // getList of MA Models.
    public List<MA_Model__c> getMAModelsList() {
        if (listOriginalMAModels == null){ 
                listOriginalMAModels = setCon.getRecords(); 
                listMAModelsWrapper =  new List<MA_Model__c>();
                listMAModelsWrapper.addAll(listOriginalMAModels);
        }  
        
        return listMAModelsWrapper ;
    }
    
    // SAve the MA Models entered by User on VF page and Redirect 
    // the Page back to cart
    public Pagereference saveMAModles(){
       PageReference pageRef = null;
       
       for(MA_Model__c oModel : listMAModelsWrapper){
           if(String.isEmpty(oModel.Equipment_Group__c) || String.isEmpty(oModel.Equipment_Type__c)
                                                        || String.isEmpty(oModel.Serial__c) || String.isEmpty(oModel.Model__c)){
                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, LABEL.APTS_Model_Validation_Message));
                return null;
            }
       }
       
       try{
            if(listMAModelsWrapper != null && listMAModelsWrapper.size() >= 1){
                upsert listMAModelsWrapper;
                system.debug('Upsert Successful');
            }
            pageRef = Page.Apttus_Config2__CartDetailView;  
            pageRef.getParameters().put('configRequestId',sConfigRequestID);
            pageRef.getParameters().put('id', sID);
            pageRef.setredirect(true);
                    
       }
       catch(Exception ex){
            system.debug('HS-->' + ex.getMessage());
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, ex.getMessage()));  
       }
       return pageRef;
    }
    
     // Add a row - Associate Proposal-Id,Unique-Number
     // Unique Number field is used to associate with MA Model Object.
     public PageReference AddRow(){
        
        if(listMAModelsWrapper != null && listMAModelsWrapper.size() >= iRowCount){
             Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, LABEL.APTPS_No_More_Rows));
             return null;
        }
        
        MA_Model__c oMAModel = new MA_Model__c();
        oMAModel.Proposal__c = sProposalId;
        oMAModel.UniqueNumber__c = 'Model' + getUniqueNumber();
        system.debug('HS--> ' + oMAModel.UniqueNumber__c);
        listMAModelsWrapper.add(oMAModel);
        return null;
        
     }
     
     // Delete a row - Associate Proposal-Id,Unique-Number
     // Unique Number field is used to associate with MA Model Object.
      public Pagereference removeRow(){
        
        system.debug('Inside Remove row' + sUniqueNumber);
        
        if(listMAModelsWrapper.size() == 1){
            listMAModelsWrapper.remove(listMAModelsWrapper.size() - 1);
            return null;
        }
        Integer iCount = 0;
        for(Integer i = 0;i<listMAModelsWrapper.size(); i++){
             MA_Model__c oModel = listMAModelsWrapper.get(i);
             if(oModel.UniqueNumber__c.equals(sUniqueNumber)) {
                 iCount = i;
                 system.debug('HS-->' + oModel);
             } 
        }
        listMAModelsWrapper.remove(iCount);
        return null;
        
     }
     
     // Generate q Unique Number
     private Long getUniqueNumber(){
         Long x =  System.currentTimeMillis() / 1000;
         return x;
     }
     
     // Get the Maximum row count - Maximum-Number of rows that needs to be Displayed in VF Page
     private Integer getRowCount(){
         
         try{
            APTPS_Configurable_Variables__c code = APTPS_Configurable_Variables__c.getInstance('North_America_Quote_Price_List');
            system.debug(code.APTPS_RowCount__c);
            Decimal dValue =  code.APTPS_RowCount__c;
            iRowCount = dValue.intValue();
         // In-Case of Exception,Default Row-Count will be used.
         }catch(Exception ex){
             system.debug('Exception while fetching row-count from custom-setting' + ex.getMessage());
         }
         return IRowCount;
     }
    
}