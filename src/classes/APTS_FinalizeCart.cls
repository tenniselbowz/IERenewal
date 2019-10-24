public class APTS_FinalizeCart {

           
    //Product Configuration Id or Cart Id
    private String ProductConFigId = Null;
    
    //Proposal Id
    Private String ProposalId= Null;
    
    //ConfigRequestId
    Private String sConfigRequestID = Null;
    
    Public APTS_FinalizeCart(){
        ProductConFigId = ApexPages.currentPage().getParameters().get('id');
        ProposalId = Apexpages.currentPage().getParameters().get('retId');
        sConfigRequestID =  Apexpages.currentPage().getParameters().get('configRequestId');
    }
    
    
    
    public PageReference finalizeCart(){
        Apttus_Config2__ProductConfiguration__c configRecord = [SELECT Id, Use_Tax_Calculated__c FROM Apttus_Config2__ProductConfiguration__c where Id =:ProductConFigId];
        if(configRecord.Use_Tax_Calculated__c == TRUE){
        configRecord.Use_Tax_Calculated__c = FALSE;
        update configRecord;
        ID cartID = Apexpages.currentPage().getParameters().get('Id');
        system.debug('This is Cart Id:'+ cartId);
        Apttus_CpqApi.CPQ.FinalizeCartRequestDO request = new Apttus_CpqApi.CPQ.FinalizeCartRequestDO();
        request.CartId = cartID;
        Apttus_CpqApi.CPQ.FinalizeCartResponseDO response = Apttus_CpqApi.CPQWebService.finalizeCart(request);
        Pagereference pagereference = New Pagereference('/'+ProposalId);
        pagereference.setRedirect(true);
        return pagereference;
        } else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please Calculate Use Tax first and then Finalize the Cart'));
            return null;
        }
    }
    
    private Apttus_Config2__ConfigFlow__c getFlowOrDefaultSetting(String flowname) {
      Apttus_Config2__ConfigFlow__c configSetting = Apttus_Config2__ConfigFlow__c.getValues(flowname);
      if(configSetting == null) {
          configSetting = Apttus_Config2__ConfigFlow__c.getValues('Default');
      }
      return configSetting;
  }
    
    Public PageReference ReturntoCart(){
    
    //Pagereference pageRef = Page.Apttus_Config2__CartDetailView;  
    //Changed By Harsh to make redirection to cart page dynamic(based on flow)
      String currentFlow = ApexPages.currentPage().getParameters().get('flow');
      
      PageReference pageRef = null;
      Apttus_Config2__ConfigFlow__c configSetting = getFlowOrDefaultSetting(currentFlow);
      if(configSetting!=null && configSetting.Apttus_Config2__CartPage__c!=null)
      {
          pageRef = new PageReference('/apex/'+configSetting.Apttus_Config2__CartPage__c);
          pageRef.getParameters().put('configRequestId',sConfigRequestID);
         pageRef.getParameters().put('id', ProductConFigId);
         pageRef.setredirect(true);
      }
      else {
          Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,'No Cart Page found for current flow'));
      }
             
             return pageRef;
    }
    
}