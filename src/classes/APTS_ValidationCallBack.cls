/*************************************************************************************************************
* Validation Callback Class
* @author - Apttus Support
* @CreatedDate  : 07-04-2017
***************************************************************************************************************/
global with sharing class APTS_ValidationCallBack implements Apttus_Config2.CustomClass.IValidationCallback2 {
    /**
* Callback to validate the line items in the cart
* @param cart the cart object to validate
* @return the validation result
*/
    global Apttus_Config2.CustomClass.ValidationResult validateCart(Apttus_Config2.ProductConfiguration cart) {
        Apttus_Config2.CustomClass.ValidationResult result = new Apttus_Config2.CustomClass.ValidationResult(true);
        
        Map<String, String> mapValues = Apttus_Config2.RuntimeContext.getParameters();
        System.debug('Hemant-->'+mapValues);
        System.debug('result-->'+result);
        String itenNums = mapValues.get('contextLineNumbers');
        String PageAction = mapValues.get('pageAction');
        
        System.debug('Hemant hjhjhj-->'+PageAction );
        if(PageAction =='Finalize'){
            System.debug('Hemant Inner hjhjhj-->'+PageAction );
            Apttus_Config2__ProductConfiguration__c configRecord = cart.getConfigSO();
            configRecord = [SELECT Id, Use_Tax_Calculated__c FROM Apttus_Config2__ProductConfiguration__c where Id = :configRecord.Id];
            
            if(configRecord.Use_Tax_Calculated__c == TRUE){
                configRecord.Use_Tax_Calculated__c = FALSE;
                update configRecord;
            }else
            {
                System.debug('Hemant ERROR');
                result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Calculate Use Tax first and then Finalize the Cart'));
                result.isSuccess = false; 
            }
        }
        return result;
    }
    
    /**
* Callback to validate the given list ramp line items
* @param cart the cart object associated with the ramp line items
* @param rampLineItems the list of ramp line items
* @return the validation result
*/
    global Apttus_Config2.CustomClass.ValidationResult validateRampLineItems(Apttus_Config2.ProductConfiguration cart, List<Apttus_Config2.LineItem> rampLineItems) {
        Apttus_Config2.CustomClass.ValidationResult result = new Apttus_Config2.CustomClass.ValidationResult(true);
        return result;
    }
    
    global Apttus_Config2.CustomClass.ValidationResult validateAssetItems(Apttus_Config2.ProductConfiguration cart, List<Apttus_Config2__TempRenew__c> assetItems) {
        Apttus_Config2.CustomClass.ValidationResult result = new Apttus_Config2.CustomClass.ValidationResult(true);
        result.isSuccess = true; 
        return result;
    }
    
}