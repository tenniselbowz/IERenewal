/* 
    Class : APTS_SummaryGroupTotalWrapper
    Description : Wrapper Class to hold summary-group id and List of LineItem assocaited with that summary-group
    Author : Hardik Shah, @Apttus
    
******************************************************************/

public with sharing class APTS_SummaryGroupTotalWrapper {

	private ID summaryGroupId;
	private List<Apttus_Config2__LineItem__c> listLineItems = null;
		
	public APTS_SummaryGroupTotalWrapper (Id summaryID, List<Apttus_Config2__LineItem__c> lineItems){
		this.summaryGroupId = summaryID;
		this.listLineItems = lineItems;
	}
	
	public ID getSummaryGroupId(){
		return summaryGroupId;
	}
	
	public List<Apttus_Config2__LineItem__c> getListLineItems(){
		return listLineItems;
	}
	
}