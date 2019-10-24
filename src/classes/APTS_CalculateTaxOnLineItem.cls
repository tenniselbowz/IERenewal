/*************************************************************
@Name: APTS_CalculateTaxOnLineItem
@Author: Hardik Shah
@CreateDate: 20/01/2016
@Description: Controller to compute Tax Per LineItem
@UsedBy: VF-Page - APTS_CalculateTaxOnLineItem.page
@ModifiedBy: NA
@ModifiedDate: NA
@ChangeDescription: 
PS: @ModifiedBy and @ChangeDescription can be repeated multiple time, based on number of changes made to the original process.
******************************************************************/
public class APTS_CalculateTaxOnLineItem {

     // list of LineItem Ids
    private List<Id> listIDs = new List<Id>();
    // Product Configuration Id to fetch LineItesm
    private String sProductConFigId {get; set;}
    // Config-Request -id - This Parameter is use when a Page is Redirected
    private String sConfigRequestID = null;
    
    
   
   
    // Constructor
    public APTS_CalculateTaxOnLineItem () {
        sProductConFigId = ApexPages.currentPage().getParameters().get('id');
        sConfigRequestID =  Apexpages.currentPage().getParameters().get('configRequestId');
        system.debug('Config-id' + sProductConFigId);
        
        for(Apttus_Config2__LineItem__c item : [SELECT id FROM Apttus_Config2__LineItem__c 
                                                WHERE Apttus_Config2__ConfigurationId__c = :sProductConFigId]) {
            listIDs.add(item.id);
        }
        
        system.debug('HS' + listIDs.size());
     }
     
      // Calculate Tax 
      public PageReference computeTax() {
          PageReference pageRef  = null;
          String sErrorMessage = APTS_AvalaraTaxHelper.computeTaxPerLineItem(listIDs);
          APTS_SummaryGroupTotal oSummaryGroupTotal = new APTS_SummaryGroupTotal();
          oSummaryGroupTotal.computeSummaryTotal(sProductConFigId);
            
          if(sErrorMessage != null){
                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,sErrorMessage));  
           }else{
               Apttus_Config2__ProductConfiguration__c configRecord = [SELECT Id, Use_Tax_Calculated__c, RePriced__c FROM Apttus_Config2__ProductConfiguration__c where Id =:sProductConFigId];
               if(configRecord.RePriced__c ==TRUE){
                   configRecord.Use_Tax_Calculated__c = TRUE;
                   configRecord.RePriced__c = FALSE;
                   update configRecord;
                   pageRef =  reDirectPage();
               } else{
                   Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,'Cart must be Repriced after making changes'));
               }
           }
          
         return pageRef;
      }
      
      // Redirect the page back to Cart, once user presses cancel button
      public PageReference cancel() {
            return reDirectPage();
      }
      
      // Redirect Page to Cart
      private PageReference reDirectPage(){
//          PageReference pageRef = Page.Apttus_Config2__CartDetailView; 
          //Changed By Harsh to make redirection to cart page dynamic(based on flow)
          String currentFlow = ApexPages.currentPage().getParameters().get('flow');
          
          PageReference pageRef = null;
          Apttus_Config2__ConfigFlow__c configSetting = getFlowOrDefaultSetting(currentFlow);
          if(configSetting!=null && configSetting.Apttus_Config2__CartPage__c!=null)
          {
              pageRef = new PageReference('/apex/'+configSetting.Apttus_Config2__CartPage__c);
              pageRef.getParameters().put('id', sProductConFigId);
              pageRef.getParameters().put('configRequestId',sConfigRequestID);
              pageRef.setredirect(true);
          }
          else {
              Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,'No Cart Page found for current flow'));
          }
          
          return pageRef;
          
      }

      private Apttus_Config2__ConfigFlow__c getFlowOrDefaultSetting(String flowname) {
          Apttus_Config2__ConfigFlow__c configSetting = Apttus_Config2__ConfigFlow__c.getValues(flowname);
          if(configSetting == null) {
              configSetting = Apttus_Config2__ConfigFlow__c.getValues('Default');
          }
          return configSetting;
      }

    // Redirect Page to Cart
      private PageReference reDirectPage2(){
          ID proposalId = ApexPages.currentPage().getParameters().get('businessObjectId');
          PageReference pageRef = Page.Apttus_Config2__CartDetailView; 
          
          pageRef.getParameters().put('id', sProductConFigId);
          pageRef.getParameters().put('configRequestId',sConfigRequestID);
          pageRef.setredirect(true);
          return pageRef;
          
      }
    
    

}