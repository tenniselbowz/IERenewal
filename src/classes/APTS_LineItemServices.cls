public with sharing class APTS_LineItemServices {
	public static void updatePrice(List<Apttus_Config2__LineItem__c> lineItems) {
		Map<Id, Apttus_Config2__ProductAttributeValue__c> attributes = new Map<Id, Apttus_Config2__ProductAttributeValue__c>([SELECT Price_Calc__c FROM Apttus_Config2__ProductAttributeValue__c WHERE Id IN :Pluck.ids('Apttus_Config2__AttributeValueId__c', trigger.new)]);
    	for(Apttus_Config2__LineItem__c li : lineItems){  
	        /*DPL 7/6/2017 No longer needed. Replaced with Average_Center_Rate__c on Quote.
	        //Converted Process Builder - Calculate Estimated Blended Rate || Date : 20-04-2017 || Case : 00209292
	        if(li.Estimated_Blended_Rate__c!=li.Estimated_Blended_Rate_Calc__c){
	            li.Estimated_Blended_Rate__c = li.Estimated_Blended_Rate_Calc__c;
	        }
	        */
	        //Converted Workflow : Line Item Cost = Price Calc Attribute || Date : 20-04-2017 || Case : 00209292
	        if(li.APTPS_Product_Name__c=='Vehicle Mileage/Mile' && attributes.containsKey(li.Apttus_Config2__AttributeValueId__c)){
	        	Apttus_Config2__ProductAttributeValue__c prodAttribute = attributes.get(li.Apttus_Config2__AttributeValueId__c);
	        	if(prodAttribute.Price_Calc__c != li.APTPS_Cost__c){
	            	li.APTPS_Cost__c = prodAttribute.Price_Calc__c;
	            }
	        }
	    }
	}
}