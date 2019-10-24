/*
 * Company      : Apttus Inc.
 * Description  : This class contains unit tests for validating the behavior of Product Attribute Callback class.
 * History      :
 * [08 Feb.2016] Hardik Shah    : Created Class 
 * 
 * This class contains unit tests for validating the behavior of Product Attribute Callback class.
 */

@isTest
private class APTS_DaikinProductAttributeCallBackTest {
    
    static testMethod void testDefaultProductAttribute() {
        
         // Create Custom Settings
         Apttus_Config2__ConfigCustomClasses__c configSetting = new Apttus_Config2__ConfigCustomClasses__c();
         configSetting.Name = 'Custom Classes';
         configSetting.Apttus_Config2__ProductAttributeCallbackClass__c = 'APTS_DaikinProductAttributeCallBack';
         insert configSetting;
         
         AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c(); 
         ts1.AVA_SFCORE__Active_Setting__c = true; 
         ts1.Name='Test Account';
         insert ts1;
        
         // Create Account
         Account acc = APTPS_DaikinTestDataUtility.getAccount('Account1');
         insert acc;  
        
         Contact contact = APTPS_DaikinTestDataUtility.getContact(acc);
         insert contact;
        
         // Create Opportunity
         Opportunity opp = APTPS_DaikinTestDataUtility.getOpp(acc);
         insert opp;
        
         // Create Price List
         Apttus_Config2__PriceList__c PL= APTPS_DaikinTestDataUtility.getPriceList('PriceList1');
         insert PL;
        
         // Get Product
         List<Product2> prods = APTPS_DaikinTestDataUtility.getProductList();
         
         // Create PLI
         List<Apttus_Config2__PriceListItem__c> pli = APTPS_DaikinTestDataUtility.CreatePLI(prods, PL);
         insert pli;
                 
         // Create Proposal
         Apttus_Proposal__Proposal__c prop = APTPS_DaikinTestDataUtility.getQuote(acc, contact, opp,PL);
         insert prop;
         
         // Create configuration
         Apttus_Config2__ProductConfiguration__c configu = APTPS_DaikinTestDataUtility.GetConfiguration(prop, PL);
         insert configu;
            
         // Create Line Item
         List<Apttus_Config2__LineItem__c> lineItems =  APTPS_DaikinTestDataUtility.GetLineItem(prods, pli, configu);
         insert lineItems;
        
         TEST.startTest();
           
         Apttus_Config2.CustomClass.IProductAttributeCallback attrCallback = new APTS_DaikinProductAttributeCallBack();            
         Apttus_Config2.CallbackTester.testProductAttributeCallback(configu.Id, lineItems[0], attrCallback);
                    
         TEST.stopTest();
    }

}