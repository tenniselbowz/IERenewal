/*************************************************************
@Name: APTS_DaikinProductAttributeCallBack
@Author: Hardik Shah
@CreateDate: 08/02/2016
@Description: Product-Attribute-CallBack to set default values
@UsedBy: NA
@ModifiedBy: NA
@ModifiedDate: NA
@ChangeDescription: 
******************************************************************/


global with sharing class APTS_DaikinProductAttributeCallBack implements Apttus_Config2.CustomClass.IProductAttributeCallback {

	Id proposalId;
	String sServiceLocation = null;

	global void setDefaults(Apttus_Config2.LineItem parentItem, Apttus_Config2__ProductAttributeValue__c attrValueSO){
		attrValueSO.Center__c = sServiceLocation;
		system.debug('attrValueSO ' + attrValueSO.Center__c );
	}

	global void start(Apttus_Config2.ProductConfiguration cart){
		system.debug('============ Call back Start============');
		Apttus_Config2__ProductConfiguration__c proConfig = cart.getConfigSO();
		proposalId = proConfig.Apttus_QPConfig__Proposald__c;
		Apttus_Proposal__Proposal__c oProposal = [SELECT APTS_Service_Location__c  from Apttus_Proposal__Proposal__c where Id =:proposalId];
		sServiceLocation = oProposal.APTS_Service_Location__c;
		system.debug('ServiceDistrict ' + sServiceLocation);
	}

	global void finish(){}

}