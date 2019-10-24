/* 
    Class : APTS_SummaryGroupTotal
    Description : This class rolls-up custom field estimated Tax for all those lineItems that have Category != null
    			  2) It also rolls up LineItem with Total Summary.
    Author : Hardik Shah, @Apttus
    
******************************************************************/

public with sharing class APTS_SummaryGroupTotal {

	public static final String GROUP_TOTAL = 'Total';
	public static final String GRAND_TOTAL = 'Grand Total';
	public static final String BUNDLE_PRODUCT = 'Product/Service';


	public void computeSummaryTotal(Id productConfigID){
	    // Map of Summary-ClassificationId and SummaryGroupWrapper - Based on Category
		Map<Id,APTS_SummaryGroupTotalWrapper> mapSummaryIDToLineItem = new Map<Id,APTS_SummaryGroupTotalWrapper>();
		// List of SummaryGroups - Group based on Category
		List<Apttus_Config2__SummaryGroup__c> listCategorySummaryGroup = new List<Apttus_Config2__SummaryGroup__c>();
		// List of SummaryGroups - Group based on LineType = Total/Grand Total
		List<Apttus_Config2__SummaryGroup__c> listTotalSummaryGroup = new List<Apttus_Config2__SummaryGroup__c>();
		// List of SummaryGroup - SummaryGroup Items that needs to be updated
		List<Apttus_Config2__SummaryGroup__c> listSummaryGroupToUpdate = new List<Apttus_Config2__SummaryGroup__c>();
		// Instnace of Summary-Group.
		APTS_SummaryGroupTotalWrapper oSummaryGroupTotal = null;
		Decimal dTotalEstimatedCategoryTax = 0.0;
		Decimal dTotalEstimatedTax = 0.0;
			
		for(Apttus_Config2__SummaryGroup__c oSummaryGroup : [SELECT Id,Name,Apttus_Config2__ClassificationId__c ,Apttus_Config2__LineType__c,
																	   (SELECT Id,Estimated_Tax__c FROM Apttus_Config2__LineItems__r WHERE Apttus_Config2__LineType__c =:APTS_SummaryGroupTotal.BUNDLE_PRODUCT ) 
																	    FROM Apttus_Config2__SummaryGroup__c 
																	    WHERE Apttus_Config2__ConfigurationId__c =: productConfigID]){
            system.debug('I1**' + oSummaryGroup);																	    	
			// Since classfication id is null, its not any of total group.
			if(oSummaryGroup.Apttus_Config2__ClassificationId__c != null){
				oSummaryGroupTotal = new APTS_SummaryGroupTotalWrapper(oSummaryGroup.id,oSummaryGroup.Apttus_Config2__LineItems__r);
		    	mapSummaryIDToLineItem.put(oSummaryGroup.Apttus_Config2__ClassificationId__c,oSummaryGroupTotal);
					
			}else if(oSummaryGroup.Apttus_Config2__LineType__c.equals(APTS_SummaryGroupTotal.GROUP_TOTAL) || 
					 oSummaryGroup.Apttus_Config2__LineType__c.equals(APTS_SummaryGroupTotal.GRAND_TOTAL)){
				listTotalSummaryGroup.add(oSummaryGroup);
			}							    	
		
		}// End of For-Loop
		system.debug('H1***' + mapSummaryIDToLineItem);
		system.debug('H2*** ' + listTotalSummaryGroup);															    
	    try{
		   	for(Id key : mapSummaryIDToLineItem.keySet()) {
		    	APTS_SummaryGroupTotalWrapper oSummaryGroupTotalWrapper =  mapSummaryIDToLineItem.get(key);
		    	// Re-Inialize the Variable
		        dTotalEstimatedCategoryTax = 0.0;
		    	Apttus_Config2__SummaryGroup__c oSummaryGroup = null;
		    	
		    	for(Apttus_Config2__LineItem__c lineItem : oSummaryGroupTotalWrapper.getListLineItems()){
		    		if(lineItem.Estimated_Tax__c != null){
		    			dTotalEstimatedCategoryTax  = dTotalEstimatedCategoryTax + lineItem.Estimated_Tax__c;
		    		}
		        }
		    	system.debug('H2***' + dTotalEstimatedCategoryTax);
		    	oSummaryGroup = new Apttus_Config2__SummaryGroup__c(Id = oSummaryGroupTotalWrapper.getSummaryGroupId());
		    	oSummaryGroup.APTS_Estimated_Tax_Summary__c = dTotalEstimatedCategoryTax;
		    	// List of Items based on Category
		    	listCategorySummaryGroup.add(oSummaryGroup);
		    	// List of Items to update
		    	listSummaryGroupToUpdate.add(oSummaryGroup);
		    	system.debug('H3***' + listCategorySummaryGroup);
		     }// End of outer For Loop
		     
		     // Re-Inialize the Variable
		     dTotalEstimatedTax = 0.0;
		     
		     for(Apttus_Config2__SummaryGroup__c oSummaryGroup : listCategorySummaryGroup){
		     		dTotalEstimatedTax = dTotalEstimatedTax + oSummaryGroup.APTS_Estimated_Tax_Summary__c;
		     }
		     system.debug('Total Estimated Tax ' + dTotalEstimatedTax);
		     
		     for(Apttus_Config2__SummaryGroup__c oSummaryGroup :listTotalSummaryGroup){
		     	oSummaryGroup = new Apttus_Config2__SummaryGroup__c(Id = oSummaryGroup.id);
		     	oSummaryGroup.APTS_Estimated_Tax_Summary__c = dTotalEstimatedTax;
		     	listSummaryGroupToUpdate.add(oSummaryGroup);
		     }
		     		    
		     if (!listSummaryGroupToUpdate.isEmpty()) {
		         Database.update(listSummaryGroupToUpdate);
		     }
		}catch(exception ex){
			system.debug('Exception while Updating SummaryGroup ' + ex.getMessage());
			
		}
	
	}
}