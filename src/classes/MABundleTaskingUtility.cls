public class MABundleTaskingUtility {

    public static Set<String> specialProductSet 
    {
        get
        {
            if(specialProductSet == null)
            {
                List<MA_Bundle_Task_Product_Code__mdt> specialProductCodes = [SELECT Product_Code__c 
                                                                              FROM MA_Bundle_Task_Product_Code__mdt];
                if(!specialProductCodes.isEmpty())
                {
                    specialProductSet = Pluck.strings('Product_Code__c',specialProductCodes);
                }
            }
            return specialProductSet;
        }
        set;
    }

    //retreive maintenance quote line items as per passed quote id
    public static List<Apttus_Proposal__Proposal_Line_Item__c> getQuoteLineItems(Id quoteId) {
        List<Apttus_Proposal__Proposal_Line_Item__c> allQuoteLineItems = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        List<Apttus_Proposal__Proposal_Line_Item__c> maintenanceQuoteLineItems = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        Apttus_Config2__ClassificationHierarchy__c classHierarchy = null;
        Apttus_Config2__ClassificationName__c className = null;
        
        try {
            allQuoteLineItems = [select Id, APTPS_Attribute_Description__c, Apttus_Proposal__Product__r.Name, Apttus_Proposal__Product__r.ProductCode, Manufacturer_Model_Serial__c, Apttus_QPConfig__Quantity2__c, Program__c, Option_Group__c, Apttus_QPConfig__LineType__c,
                              Apttus_QPConfig__ItemSequence__c, Apttus_QPConfig__LineNumber__c, Apttus_QPConfig__OptionId__r.Name,  Capacity_Tons__c, Annual__c, Operational__c,
                              Apttus_QPConfig__OptionId__r.ProductCode, Apttus_QPConfig__AttributeValueId__r.Task_Frequency__c, Serial__c, Apttus_QPConfig__ClassificationId__c,
                              Apttus_QPConfig__ClassificationId__r.Apttus_Config2__HierarchyId__r.Name, Apttus_QPConfig__ClassificationId__r.Apttus_Config2__HierarchyId__r.Apttus_Config2__Active__c,
                              Apttus_QPConfig__OptionId__r.Description, Equipment_Group__c, Apttus_QPConfig__AttributeValueId__r.Emergency_Coverage_Response__c, Site_Location_Text__c, Attribute_of_Hours__c, Attribute_Task_Frequency__c, Apttus_Proposal__Description__c,
							  French_Product_Name__c
                              from Apttus_Proposal__Proposal_Line_Item__c where Apttus_Proposal__Proposal__c = :quoteId ];
            
            for (Apttus_Proposal__Proposal_Line_Item__c pli: allQuoteLineItems) {
                //classHierarchy = [SELECT Id, Name, Apttus_Config2__HierarchyId__c FROM Apttus_Config2__ClassificationHierarchy__c where Id = :pli.Apttus_QPConfig__ClassificationId__c];
                //className = [SELECT Id, Name, Apttus_Config2__Active__c FROM Apttus_Config2__ClassificationName__c where Id = :classHierarchy.Apttus_Config2__HierarchyId__c];
                if ((specialProductSet != null && specialProductSet.contains(pli.Apttus_Proposal__Product__r.ProductCode)) ||
                    (pli.Apttus_QPConfig__ClassificationId__r.Apttus_Config2__HierarchyId__r.Name == 'Maintenance' && 
                     pli.Apttus_QPConfig__ClassificationId__r.Apttus_Config2__HierarchyId__r.Apttus_Config2__Active__c)) {
                    // add the proposal line item object to the filtered list of proposal line items whose category is Maintenance
                    maintenanceQuoteLineItems.add(pli);
                }
                else {
                    System.debug('          **** excluded ' + pli.Id);
                }
            }
            
        } catch(QueryException e) {
            System.debug('QueryException : ' + e.getMessage());
        }
        return maintenanceQuoteLineItems;
    }
    
     //retreive MABundle Items as per passed quote id
    public static List<Proposal_MA_Bundle__c> getMABundleItems(Id quoteId) {
        List<Proposal_MA_Bundle__c> MABundleItems = new List<Proposal_MA_Bundle__c>();
        try {
            MABundleItems = [select Id from Proposal_MA_Bundle__c where Quote_Proposal__c = :quoteId];
        } catch(QueryException e) {
            System.debug('MABundleItems : ' + e.getMessage());
        }
        return MABundleItems;
    }
    
    public static void deleteMABundleItems(List<Proposal_MA_Bundle__c> MABundleItems) {
        if(MABundleItems.isEmpty()) return;
        Set<Id> MABundleItemsIds = new Map<Id, Proposal_MA_Bundle__c>(MABundleItems).keySet(); 
        try {
            delete [Select Id from Proposal_MA_Bundle__c where Id in :MABundleItemsIds];
        } catch(DMLException e) {
            System.debug('Delete Operation Failed. ' + e.getMessage());
        }
    }

}