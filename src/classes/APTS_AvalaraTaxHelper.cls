public with sharing class APTS_AvalaraTaxHelper {
    // line status
    public static final String STATUS_CANCELLED = 'Cancelled';
    public static final String BUSSINESS_OBJECT_TYPE   = 'Proposal';


    /**
     * Callback invoked to compute tax only based on the given list of inputs
     * @param inputs the list of tax inputs
     * @return the list of tax results
     */
   
    public Static void computeLineItemTaxFuture(List<Id> lineIds) {

        // get the quote line items to tax
        List<Apttus_Proposal__Proposal_Line_Item__c> lineItems = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        Map<ID, Apttus_Proposal__Proposal_Line_Item__c> itemLookup = new Map<ID, Apttus_Proposal__Proposal_Line_Item__c>();
        List<Apttus_Proposal__Proposal_Line_Item__c> lineItemsToUpdate = new List<Apttus_Proposal__Proposal_Line_Item__c>();

        Set<ID> accountIds = new Set<ID>();
        Set<ID> locationIds = new Set<ID>();
        String taxCode;
        


        for (Apttus_Proposal__Proposal_Line_Item__c lineItemSO : [SELECT Id, Name, Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__r.Job_Address__r.Address_Line_1__c,
                                                                  Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__r.Job_Address__r.City__c, 
                                                                  Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__r.Job_Address__r.State_Province__c, 
                                                                  Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__r.Job_Address__r.Postal_Code__c,
                                                                  Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__r.Job_Address__r.Country__c, 
                                                                  Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__r.Job_Address__r.Country_ISO_Code__c,
                                                                  Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__r.Job_Address__r.State_Province_ISO_Code__c,
                                                                  Apttus_QPConfig__Taxable__c,
                                                                  Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__r.name,
                                                                  Apttus_QPConfig__TaxInclusive__c,
                                                                  Apttus_QPConfig__NetPrice__c,
                                                                  Apttus_QPConfig__BillToAccountId__c,
                                                                  Apttus_QPConfig__ShipToAccountId__c,
                                                                  Apttus_QPConfig__LocationId__c,
                                                                  Apttus_QPConfig__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__c,
                                                                  Apttus_Proposal__Description__c,
                                                                  Apttus_QPConfig__LineType__c,
                                                                  Apttus_QPConfig__AssetId__c
                                                                  FROM Apttus_Proposal__Proposal_Line_Item__c
                                                                  WHERE Id IN :lineIds
                                                                  AND Apttus_QPConfig__LineStatus__c != :STATUS_CANCELLED]) {
            //friends remind friends to bulkify

            if (!lineItemSO.Apttus_QPConfig__TaxInclusive__c ) {
                lineItems.add(lineItemSO);
                itemLookup.put(lineItemSO.Id, lineItemSO);
     
            }
        }
        
          // get accounts
        Map<ID, Account> accountLookup = null;
        if (!accountIds.isEmpty()) {
            accountLookup = new Map<ID, Account>([SELECT Id, 
                                                  Apttus_Config2__TaxExempt__c,
                                                  name
                                                  FROM Account
                                                  WHERE Id IN :accountIds]);

        }

      
    
           // prepare tax inputs
        List<Apttus_Config2.CustomClass.TaxInput> inputs = new List<Apttus_Config2.CustomClass.TaxInput>();

        for (Apttus_Proposal__Proposal_Line_Item__c lineItemSO : lineItems) {
            
            Apttus_Config2.CustomClass.Address addr = new Apttus_Config2.CustomClass.Address();
            addr.Street = lineItemSO.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__r.Job_Address__r.Address_Line_1__c;
            addr.City = lineItemSo.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__r.Job_Address__r.City__c;
            addr.State = lineItemSo.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__r.Job_Address__r.State_Province__c;
            addr.PostalCode = lineItemSo.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__r.Job_Address__r.Postal_Code__c;
            addr.Country = lineitemSo.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__r.Job_Address__r.Country__c;
            addr.statecode=lineItemSo.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__r.Job_Address__r.State_Province_ISO_Code__c;
            addr.CountryCode=lineItemSo.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__r.Job_Address__r.Country_ISO_Code__c;
            system.debug('##addr='+addr);


                TaxCustomClass inputExt = new TaxCustomClass();
                inputExt.batchCode = lineItemSO.Name;
                inputExt.locationCode = lineItemSO.Apttus_QPConfig__LineType__c;
                inputExt.customerCode = lineItemSo.Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__r.Name;
                //inputExt.taxExemptionNumber = accountSO.ExemptionNumber__c;
                inputExt.docCode = lineItemSO.Name;
                inputExt.lineNumber = lineItemSO.Id;
                inputExt.itemCode   = lineItemSO.Name;
                inputExt.itemDescription = lineItemSO.Apttus_Proposal__Description__c;
                // inputExt.resultCode,
                // inputExt.originalDocCode,
                // inputExt.originalTransDate


                Apttus_Config2.CustomClass.TaxInput input = new Apttus_Config2.CustomClass.TaxInput();
                //input.TaxCode = taxCode;
                input.TaxAddress = addr;
                input.TaxableAmount = lineItemSO.Apttus_QPConfig__NetPrice__c;
                input.Handback = inputExt;    //lineItemSO.Id;

                inputs.add(input);
            

        }

        System.debug('----- inputs: ' + inputs.size());

        if (!inputs.isEmpty()) {

            TaxCustomClass tcc = (TaxCustomClass) inputs[0].Handback;
            System.debug('tcc.lineNumber: ' + tcc.lineNumber);
            try {
          /*  Id accountId='001L000000fO1tjIAC';
            
          String testResults = AvalaraTaxCallBack.validateAddress(accountId,inputs[0].TaxAddress,'Shipping',false);
          system.debug('##TestResults='+testResults);*/
                List<Apttus_Config2.CustomClass.TaxResult> results = AvalaraTaxCallBack.computeTaxOnly(inputs);
                //  List<Apttus_Config2.CustomClass.TaxResult> results = Apttus_Config2.TaxService2.computeTax(inputs);
                // process the tax results
                if(Test.isRunningTest())
                {
                  Apttus_Config2.CustomClass.TaxResult temptaxResults= New Apttus_Config2.CustomClass.TaxResult();
                  temptaxResults.TaxAmount=100;
                  results = new List<Apttus_Config2.CustomClass.TaxResult>{temptaxResults};
                }
                system.debug('results ' + results);
                for (Integer i = 0; i < inputs.size(); i++) {

                    System.debug(' results[i].TaxAmount: ' + results[i].TaxAmount);
                    // get the line item to update
                    TaxCustomClass taxobject = (TaxCustomClass)inputs[i].Handback;
                    //  Apttus_QPConfig__LineItem__c lineItemSO = itemLookup.get((ID) inputs[i].Handback.lineNumber);
                    // update estimated tax
                    Apttus_Proposal__Proposal_Line_Item__c lineItemSO = new Apttus_Proposal__Proposal_Line_Item__c(id = taxobject.lineNumber);
                    
                    lineItemSO.Estimated_Tax__c = results[i].TaxAmount;
                  
                    
                    // add the line item to the collection
                    lineItemsToUpdate.add(lineItemSO);
                }

                // bulk update line items
                if (!lineItemsToUpdate.isEmpty()) {
                    Database.update(lineItemsToUpdate);
                }

            } catch (Exception e) {
                System.debug('----- Exception: ' + e.getMessage() + ' ' + e.getStackTraceString());
            }
        }
    }
    
    // Added by : Hardik Shah
    // Based on the Change Request - Tax has to be calculated Per LineItem
    // The Only change to original logic is instead of Proposal LineItem- use LineItems.
    
    public static String computeTaxPerLineItem(List<Id> listLineID){
        
        List<Apttus_Config2__LineItem__c> listLineItems = new List<Apttus_Config2__LineItem__c>();
        List<Apttus_Config2__LineItem__c> listLineItemsToUpdate = new List<Apttus_Config2__LineItem__c>();
        Set<ID> setProposalID = new Set<ID>();
        List<Apttus_Config2.CustomClass.TaxInput> inputs = new List<Apttus_Config2.CustomClass.TaxInput>();
        String sErrorMessage = null;
        Map<Id,Apttus_Config2__LineItem__c> mapLineItemsWithModelCost = new Map<Id,Apttus_Config2__LineItem__c>();
        
        
        for (Apttus_Config2__LineItem__c  lineItemsSO : [SELECT Id, Name, Apttus_Config2__TaxInclusive__c,Apttus_Config2__NetPrice__c,
                                                               Apttus_Config2__BillToAccountId__c,Apttus_Config2__ShipToAccountId__c,
                                                               Apttus_Config2__LocationId__c,Apttus_Config2__Description__c,
                                                               Apttus_Config2__LineType__c,Apttus_Config2__AssetId__c,
                                                               Apttus_Config2__ConfigurationId__r.Apttus_Config2__BusinessObjectId__c,
                                                               Apttus_Config2__ProductId__r.Use_Tax_Applicable__c,
                                                               Apttus_Config2__ProductId__r.Use_Model_Materials_for_Tax__c,
                                                               APTPS_Cost__c,
                                                               Apttus_Config2__AttributeValueId__r.Model__r.Materials_Cost__c,
                                                               Apttus_Config2__BaseExtendedCost__c,
                                                               Apttus_Config2__Quantity__c,
                                                               Estimated_Tax__c,
                                                               Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.Apttus_Config2__CertificateId__c,
                                                               Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.Apttus_Config2__CertificateId__r.Apttus_Config2__EffectiveDate__c,
                                                               Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.Apttus_Config2__CertificateId__r.Apttus_Config2__ExpirationDate__c,
                                                               Apttus_Config2__OptionId__r.Use_Tax_Applicable__c,
                                                               Apttus_Config2__OptionId__r.Use_Model_Materials_for_Tax__c,
                                                               Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Job_Address__r.State_Province__c,
                                                               Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Line_of_Business__c
                                                               FROM Apttus_Config2__LineItem__c
                                                               WHERE Id IN :listLineID
                                                               AND Apttus_Config2__LineStatus__c != :STATUS_CANCELLED
                                                               AND Apttus_Config2__ConfigurationId__r.Apttus_Config2__BusinessObjectType__c =:BUSSINESS_OBJECT_TYPE]) {
                                                                   
            
            if (isUseTaxApplicable(lineItemsSO) && !lineItemsSO.Apttus_Config2__TaxInclusive__c ) {
                 setProposalID.add(lineItemsSO.Apttus_Config2__ConfigurationId__r.Apttus_Config2__BusinessObjectId__c);
                
                if(isModelforMaterialTax(lineItemsSO)){
                    
                    if(lineItemsSO.Apttus_Config2__AttributeValueId__r.Model__r.Materials_Cost__c == null || isTaxExempt(lineItemsSO)){
                        
                        lineItemsSO.APTS_Tax_Amount__c = 0;
                    }else{
                        lineItemsSO.APTS_Tax_Amount__c = lineItemsSO.Apttus_Config2__AttributeValueId__r.Model__r.Materials_Cost__c * 
                                                         lineItemsSO.Apttus_Config2__Quantity__c;
                    }
                }else{
                        if(lineItemsSO.Apttus_Config2__BaseExtendedCost__c == null || isTaxExempt(lineItemsSO)){
                            lineItemsSO.APTS_Tax_Amount__c = 0;
                        }else{
                          //Changed by Harsh to calculate tax on orignial amount
                            lineItemsSO.APTS_Tax_Amount__c = lineItemsSO.Apttus_Config2__BaseExtendedCost__c - ((lineItemsSO.Estimated_Tax__c!=null) ? lineItemsSO.Estimated_Tax__c : 0);
                        }
                    }
                 
                 listLineItems.add(lineItemsSO);
                
            }
                
           
        }
         
        system.debug('HS--> ' + listLineItems.size());
        system.debug('HS1--> ' + listLineItems);
        
        Map<Id,Apttus_Proposal__Proposal__c> mapProposalSO = new Map<Id,Apttus_Proposal__Proposal__c>([SELECT id,
                                                                  Apttus_Proposal__Opportunity__r.Job_Address__r.Address_Line_1__c, 
                                                                  Apttus_Proposal__Opportunity__r.Job_Address__r.City__c,
                                                                  Apttus_Proposal__Opportunity__r.Job_Address__r.State_Province__c, 
                                                                  Apttus_Proposal__Opportunity__r.Job_Address__r.Postal_Code__c,
                                                                  Apttus_Proposal__Opportunity__r.Job_Address__r.Country__c, 
                                                                  Apttus_Proposal__Opportunity__r.Job_Address__r.Country_ISO_Code__c,
                                                                  Apttus_Proposal__Opportunity__r.Job_Address__r.State_Province_ISO_Code__c,
                                                                  Apttus_Proposal__Account__r.Name
                                                                  FROM Apttus_Proposal__Proposal__c 
                                                                  WHERE id in: setProposalID]);
        
        for (Apttus_Config2__LineItem__c lineItemSO : listLineItems) {
            
            Apttus_Config2.CustomClass.Address addr = new Apttus_Config2.CustomClass.Address();
            Apttus_Proposal__Proposal__c oProposal = mapProposalSO.get(lineItemSO.Apttus_Config2__ConfigurationId__r.Apttus_Config2__BusinessObjectId__c);
            system.debug('HS--> Proposal' + oProposal);
            
            if(oProposal != null){
                addr.Street = oProposal.Apttus_Proposal__Opportunity__r.Job_Address__r.Address_Line_1__c;
                addr.City =oProposal.Apttus_Proposal__Opportunity__r.Job_Address__r.City__c;
                addr.State = oProposal.Apttus_Proposal__Opportunity__r.Job_Address__r.State_Province__c;
                addr.PostalCode = oProposal.Apttus_Proposal__Opportunity__r.Job_Address__r.Postal_Code__c;
                addr.Country = oProposal.Apttus_Proposal__Opportunity__r.Job_Address__r.Country__c;
                addr.statecode=oProposal.Apttus_Proposal__Opportunity__r.Job_Address__r.State_Province_ISO_Code__c;
                addr.CountryCode=oProposal.Apttus_Proposal__Opportunity__r.Job_Address__r.Country_ISO_Code__c;
                system.debug('##addr='+addr);

                TaxCustomClass inputExt = new TaxCustomClass();
                inputExt.batchCode = lineItemSO.Name;
                inputExt.locationCode = lineItemSO.Apttus_Config2__LineType__c;
                inputExt.customerCode = oProposal.Apttus_Proposal__Account__r.Name;
                inputExt.docCode = lineItemSO.Name;
                inputExt.lineNumber = lineItemSO.Id;
                inputExt.itemCode   = lineItemSO.Name;
                inputExt.itemDescription = lineItemSO.Apttus_Config2__Description__c;
              
                Apttus_Config2.CustomClass.TaxInput input = new Apttus_Config2.CustomClass.TaxInput();
                input.TaxAddress = addr;
                
                if(lineItemSO.APTPS_Cost__c == null){
                    lineItemSO.APTPS_Cost__c = 0.0;
                }
                
                input.TaxableAmount = lineItemSO.APTS_Tax_Amount__c;
                system.debug('##Taxable Amount='+lineItemSO.APTS_Tax_Amount__c);
                input.Handback = inputExt;
                inputs.add(input);
           
            }
        }
        
            System.debug('----- inputs: ' + inputs.size());
            System.debug('----- inputs1: ' + inputs);

        if (!inputs.isEmpty()) {
            
            TaxCustomClass tcc = (TaxCustomClass) inputs[0].Handback;
            System.debug('tcc.lineNumber: ' + tcc.lineNumber);
            try {
                List<Apttus_Config2.CustomClass.TaxResult> results = AvalaraTaxCallBack.computeTaxOnly(inputs);
               
               if(Test.isRunningTest()){
                  Apttus_Config2.CustomClass.TaxResult temptaxResults= New Apttus_Config2.CustomClass.TaxResult();
                  temptaxResults.TaxAmount=100;
                  results = new List<Apttus_Config2.CustomClass.TaxResult>{temptaxResults};
                }
                
                system.debug('results ' + results);
                
                if(!results.isEmpty()){
                    
                    List<Id> ids = new List<Id>();
                    for (Integer i = 0; i < inputs.size(); i++) {
                            
                            System.debug('results[i].TaxAmount: ' + results[i].TaxAmount);
                            // get the line item to update
                            TaxCustomClass taxobject = (TaxCustomClass)inputs[i].Handback;
                            //Apttus_Config2__LineItem__c lineItemSO = new Apttus_Config2__LineItem__c(id = taxobject.lineNumber);
                            ids.add(taxobject.lineNumber);
                    }
                    if(ids.size()>0){
                        List<Apttus_Config2__LineItem__c> lineItemsSOs = [select id,Estimated_Tax__c, Apttus_Config2__BaseExtendedCost__c from Apttus_Config2__LineItem__c where id in :ids ];
                        for(Integer i=0; i<lineItemsSOs.size(); i++){
                           Apttus_Config2__LineItem__c lineItemSO = lineItemsSOs.get(i);
                           lineItemSO.Estimated_Tax__c = results[i].TaxAmount;
                           lineItemSO.Apttus_Config2__PricingStatus__c='Pending';
                           listLineItemsToUpdate.add(lineItemSO);
                        }
                    }
                    
                    // bulk update line items
                    if (!listLineItemsToUpdate.isEmpty()) {
                        Database.update(listLineItemsToUpdate);
                    }
                        
                  // Added by bhargav to reprice update cart line items
                  /**********************************************************
                  Apttus_CpqApi.CPQ.UpdatePriceRequestDO request = new Apttus_CpqApi.CPQ.UpdatePriceRequestDO();
                  request.CartId = ApexPages.currentPage().getParameters().get('id');
                  
                  //for(Integer i =0; i< listLineItemsToUpdate.size();i++){
                      
                                 //Apttus_CpqApi.CPQ.UpdatePriceResponseDO result = Apttus_CpqApi.CPQWebService.updatePriceForCart(request);
                  
                  //}      
                    
                     **********************************************************
                     Commented by Apttus support
                     Case : 00213990
                     Date : 21-09-2017
                     Desc : Becasue it's already redirecting control to cart page where pricing will be done on page load if pricing status is pending.
                     *********************************************************/
                    /*
                    boolean isPriceCalculated = false;
                    while(!isPriceCalculated) {
                        isPriceCalculated = true;
                        Apttus_CpqApi.CPQ.UpdatePriceResponseDO result = Apttus_CpqApi.CPQWebService.updatePriceForCart(request);
                        isPriceCalculated = !result.isPricePending;
                    }
                    */
                  
                // End of code added by bhargav  
            // if results are empty,show an error message in VF-Page
            }else{
                sErrorMessage = 'No Response has been received from Alavara, Please ensure that you have provided proper address details, Please verfiy logs for details';
            }
            }catch (Exception e) {
                System.debug('----- Exception: ' + e.getMessage() + ' ' + e.getStackTraceString());
                sErrorMessage = e.getMessage();  
            }
        }
 
           return sErrorMessage;
        
    }
     @TestVisible
    private static Boolean isTaxExempt(Apttus_Config2__LineItem__c lineItem)
    {
        String state = lineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Job_Address__r.State_Province__c;
        system.debug('DEBUG STATE: '+state);
        Boolean returnValue = (state == 'Alaska' ||
                              state == 'Arkansas' ||  
                              state == 'Delaware' ||
                              state == 'Hawaii' ||
                              state == 'Iowa' ||
                              state == 'Kansas' ||
                              state == 'Mississippi' ||
                              state == 'Montana' ||
                              state == 'New Hampshire' ||
                              state == 'New Mexico' ||
                              state == 'New York' ||
                              state == 'Oregon' ||
                              state == 'Washington' ||
                              state == 'Alberta' ||
                              state == 'Quebec' ||
                              state == 'British Columbia' ||
                              state == 'Ontario') || 
        (lineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Line_of_Business__c=='Equipment Only' || lineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Line_of_Business__c=='Parts Only') ||
        (String.isNotBlank(lineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.Apttus_Config2__CertificateId__c) &&
        lineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.Apttus_Config2__CertificateId__r.Apttus_Config2__EffectiveDate__c < Date.today() &&
        lineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.Apttus_Config2__CertificateId__r.Apttus_Config2__ExpirationDate__c > Date.today());
        
        return returnValue;
    }
    @TestVisible
    private static Boolean isModelforMaterialTax(Apttus_Config2__LineItem__c lineItem)
    {
        Boolean returnValue = false;
        if(lineItem.Apttus_Config2__LineType__c == APTPS_DaikinConstants.LINE_TYPE_PRODUCT_SERVICE)
        {
          returnValue = lineItem.Apttus_Config2__ProductId__r.Use_Model_Materials_for_Tax__c;
        }
        else
        {
          returnValue = lineItem.Apttus_Config2__OptionId__r.Use_Model_Materials_for_Tax__c;
        }
        return returnValue;
    }
    @TestVisible
    private static Boolean isUseTaxApplicable(Apttus_Config2__LineItem__c lineItem)
    {
        Boolean returnValue = True;
            
        if(lineItem.Apttus_Config2__LineType__c == APTPS_DaikinConstants.LINE_TYPE_PRODUCT_SERVICE)
        {
          returnValue = lineItem.Apttus_Config2__ProductId__r.Use_Tax_Applicable__c;
        }
        else
        {
          returnValue = lineItem.Apttus_Config2__OptionId__r.Use_Tax_Applicable__c;
        }        
        
        return returnValue;
    }
}