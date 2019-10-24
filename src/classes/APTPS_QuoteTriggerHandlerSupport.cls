/*
  Class : APTPS_QuoteTriggerHandlerSupport
  Description : This class contains generic abstract methods to use in Quote Trigger Handler class. 
*/
public abstract class APTPS_QuoteTriggerHandlerSupport {
        
        //Retrieve quote record types and hold in map to find out Quote with Latin America
        public static Map<Id, Schema.RecordTypeInfo> proposalLineItemRTMap = Schema.getGlobalDescribe().get('Apttus_Proposal__Proposal_Line_Item__c').getDescribe().getRecordTypeInfosById();
           
        /*
            Method : populateOppLineItem , parameter : quote_line_item
            Description : it returns oppurtunity line item records with updated field values from quote line item
        */
        public static OpportunityLineItem populateOppLineItem(OpportunityLineItem oppLineItem, Apttus_Proposal__Proposal_Line_Item__c qLineItem) {
            System.debug('In populateOppLineItem: Proposal Id = ' + qLineItem.Apttus_Proposal__Proposal__c);
            
            oppLineItem.TAG__c = qLineItem.TAG_ID__c;
            //oppLineItem.Vendor_Supplier__c = qLineItem.Supplier__c; field is not writteable
            //oppLineItem.ListPrice = qLineItem.Apttus_QPConfig__ListPrice__c;
            //oppLineItem.ProductCode = qLineItem.Model__c;
            //oppLineItem.Quantity = qLineItem.Apttus_Proposal__Quantity__c;
            //oppLineItem.Discount= qLineItem.Discount;
            //oppLineItem.Description = qLineItem.Description; 
            //oppLineItem. = qLineItem.LineNumber;
            //oppLineItem.ListPrice = qLineItem.ListPrice;
            //oppLineItem.SubTotal = qLineItem.SubTotal;
            
            System.debug('                      ***** populate that oli');
            
            if(proposalLineItemRTMap.get(qLineItem.RecordTypeId).getName().containsIgnoreCase('North America Proposal')){
                if(qLineItem.Apttus_QPConfig__LineType__c == 'Option') {
                    oppLineItem.TotalPrice = 0;
                    oppLineItem.Option_Selling_Price__c = qLineItem.Net_Term_Price__c;
                }
                else {
                   oppLineItem.TotalPrice = qLineItem.Net_Term_Price__c;//qLineItem.Net_Term_Price__c; //this is required field so must be included
                }
               
            } else {
               oppLineItem.TotalPrice = qLineItem.Apttus_QPConfig__NetPrice__c; //this is required field so must be included
            }
                
            if(oppLineItem.TotalPrice == null) {
                oppLineItem.TotalPrice = 0.0;
            } 
            oppLineItem.ServiceDate = qLineItem.Estimated_Shipping_Date__c;
            //oppLineItem.Quantity = qLineItem.Apttus_Proposal__Quantity__c;
            //if(oppLineItem.Quantity == null) { 
            oppLineItem.Quantity = qLineItem.Apttus_QPConfig__Quantity2__c; 
            if(oppLineItem.Quantity > 0) {
                
            } else {
                oppLineItem.Quantity = qLineItem.Apttus_Proposal__Quantity__c; 
            }
            
            //oppLineItem.UnitPrice = qLineItem.Selling_Price_Per_Unit__c; Can't specify both unit price and total price : SFDC Limitation
            //oppLineItem.UnitPrice = qLineItem.Apttus_QPConfig__NetPrice__c;
            oppLineItem.List_Price__c = qLineItem.List_price_Per_Unit__c;
            oppLineItem.Net_Cost__c = qLineItem.Cost_Net_per_Unit__c;
            oppLineItem.Cost__c = qLineItem.Cost_per_unit__c;
            oppLineItem.Custom_Description__c = qLineItem.Additional_Description_Info__c;
            if(qLineItem.Item_Number__c != null) {
                oppLineItem.Item_Number__c = String.valueOf(qLineItem.Item_Number__c);
            }
            oppLineItem.Multiplier_PAR__c = qLineItem.Multiplier__c;
            oppLineItem.Margin_Percent__c = qLineItem.Margin__c;
            oppLineItem.Gross_Margin_Percent__c = qLineItem.Actual_GM__c;
            oppLineItem.Gross_Margin_Amount__c = qLineItem.GM_USD__c;
            oppLineItem.Apttus_Discount_Percent__c = qLineItem.Discount__c;
            oppLineItem.Apttus_Discount_Amount__c = qLineItem.Discount_USD__c;
            oppLineItem.TAG__c = qLineItem.TAG_ID__c;
            oppLineItem.Misc_Add_On_One_Type__c = qLineItem.Misc_I__c;
            oppLineItem.Misc_Add_On_One_Amount__c = qLineItem.Misc_Cost_I__c;
            oppLineItem.Misc_Add_On_Two_Type__c = qLineItem.Misc_II__c;
            oppLineItem.Misc_Add_On_Two_Amount__c = qLineItem.Misc_Cost_II__c;
            oppLineItem.Misc_Add_On_Three_Type__c = qLineItem.Misc_III__c;
            oppLineItem.Misc_Add_On_Three_Amount__c = qLineItem.Misc_Cost_III__c;
            oppLineItem.Apttus_QPConfig_LineType__c = qLineItem.Apttus_QPConfig__LineType__c;
            
            
            System.debug('*** Opplineitem *** - ' + oppLineItem);
            
            //UpdateWarrantyRiskContingencyDollarAmountsOnProposal(qLineItem);
            
            return oppLineItem;
        }
    
    
    	/*
    	private static void UpdateWarrantyRiskContingencyDollarAmountsOnProposal(Apttus_Proposal__Proposal_Line_Item__c proposalLineItem)
        {
            // Get the Product Name for the line item and see if it is equal to Warranty, Risk or Contingency.
            // If it is equal to any of them then set the corresponding $ value field on the Proposal object to the product net price.
            System.debug('In UpdateWarrantyRiskContingencyDollarAmountsOnProposal');
            
            Product2 prodTemp = null;
            prodTemp = [Select p.Id, p.Name From Product2 p Where Id = :proposalLineItem.Apttus_Proposal__Product__c];
            
            if (prodTemp.Name == 'Warranty')  //the == operator performs case-insensitive string comparisons
            {
                Apttus_Proposal__Proposal__c p = [Select Id, Name, Warranty_LineItem__c from Apttus_Proposal__Proposal__c where Id = :proposalLineItem.Apttus_Proposal__Proposal__c];
                p.Warranty_LineItem__c = proposalLineItem.Apttus_QPConfig__NetPrice__c;
                update p;
                System.debug('UpdateWarrantyRiskContingencyDollarAmountsOnProposal: updated Warranty$');
            }
            else if (prodTemp.Name == 'Risk') {
                Apttus_Proposal__Proposal__c p = [Select Id, Name, Risk_LineItem__c from Apttus_Proposal__Proposal__c where Id = :proposalLineItem.Apttus_Proposal__Proposal__c];
                p.Risk_LineItem__c = proposalLineItem.Apttus_QPConfig__NetPrice__c;
                update p;
                System.debug('UpdateWarrantyRiskContingencyDollarAmountsOnProposal: updated Risk$');
            }
            else if (prodTemp.Name == 'Contingency') {
                Apttus_Proposal__Proposal__c p = [Select Id, Name, Contingency_LineItem__c from Apttus_Proposal__Proposal__c where Id = :proposalLineItem.Apttus_Proposal__Proposal__c];
                p.Contingency_LineItem__c = proposalLineItem.Apttus_QPConfig__NetPrice__c;
                update p;
                System.debug('UpdateWarrantyRiskContingencyDollarAmountsOnProposal: updated Contingency$');
            }
            
        }*/
        
    
        /*
            Method : deleteOpportunityLineItems , parameter : set_of_Id
            Description : It deletes the opportunity line item records
        */
        public static void deleteOpportunityLineItems(Set<Id> lineItemIds) {
            try {
                delete [Select Id from OpportunityLineItem where Id in :lineItemIds];
            } catch(DMLException e) {
                System.debug('*** Delete Failed  ' + e.getMessage());
            }
        }
        
        
        /*
            Method : getLineItemsForQuoteOrProposal , parameter : quote Id 
            Description : it returns the list of quote line item. 
        */
        public static List<Apttus_Proposal__Proposal_Line_Item__c> getLineItemsForQuotes(Set<Id> quoteIds) {
            String soqlQuery = prepareDynamicQuery('Apttus_Proposal__Proposal_Line_Item__c') + ' Where Apttus_Proposal__Proposal__c IN ';
            soqlQuery += ' :quoteIds ';
            System.debug('*** soqlQuery - ' + soqlQuery);
            List<Apttus_Proposal__Proposal_Line_Item__c> lineItems = Database.query(soqlQuery);
            System.debug('*** quote line item size ' + lineItems.size());
            return lineItems;    
        }
        
        
                
        /*
            Method : prepareDynamicQuery , parameter : object api name
            Description : This method will prepare query for retrieving all fields of Proposal Line Item and Opportunity Line Item
        */
        public static String prepareDynamicQuery(String objectAPIName) {
            if(String.isBlank(objectAPIName)) return null;
            Map<String, Schema.SObjectField> schemaMapQuoteLine;
            if(objectAPIName == 'Apttus_Proposal__Proposal_Line_Item__c') {
                schemaMapQuoteLine = Schema.SObjectType.Apttus_Proposal__Proposal_Line_Item__c.fields.getMap();
            } else if(objectAPIName == 'OpportunityLineItem') {
                schemaMapQuoteLine = Schema.SObjectType.OpportunityLineItem.fields.getMap();
            }
            
            String theQuery = 'SELECT Apttus_Proposal__Product__r.Name, ';
            for(Schema.SObjectField s : schemaMapQuoteLine.values())
            {
               String theLabel = s.getDescribe().getLabel(); // Perhaps store this in another map
               String theName = s.getDescribe().getName();
               
               // Continue building your dynamic query string
               theQuery += theName + ',';
            }
            
            // Trim last comma
            theQuery = theQuery.subString(0, theQuery.length() - 1);
            
            // Finalize query string
            theQuery += ' FROM ' + objectAPIName;
            
            return theQuery;
        
        }
        
        /*
            Method : getOpportunityPriceBookId , parameter : opportunity Id
            Description : it returns the id of the opportunity price book
        */ 
        public static ID getOpportunityPriceBookId(ID opptyId) {
            
            // get the opportunity price book id
            List<Opportunity> opportunities = [SELECT Pricebook2Id
                                               FROM Opportunity
                                               WHERE Id = :opptyId 
                                               LIMIT 1];
                    
            return (!opportunities.isEmpty() ? opportunities[0].Pricebook2Id : null);
        }
            
            
        /*
            Method : getStandardPriceBookId , no parameter
            Description : it returns the if of the standard price book
        */ 
        public static ID getStandardPriceBookId() {
            // get the standard price book id
            List<Pricebook2> books = [SELECT Id FROM Pricebook2 WHERE IsStandard = TRUE LIMIT 1];
            return (!books.isEmpty() ? books[0].Id : null);
        }
               
        /*
            Method : getCustomFieldNames, parameter : sobjectType
            Description : it returns the list of custom field names
        */ 
        public static List<String> getCustomFieldNames(Schema.SObjectType sobjectType) {
            
            // get custom field names from the object 
            List<String> fieldNames = new List<String>();
            
            // get the field metadata
            Schema.DescribesObjectResult metadata = sobjectType.getDescribe();
            for (Schema.SObjectField field : metadata.fields.getMap().values()) {
                // use the fully qualified field name as the key
                Schema.DescribeFieldResult fldMetadata = field.getDescribe();
    
                if (fldMetadata.isCustom()) {
                    // add the custom field
                    fieldNames.add(fldMetadata.getName());
                }
            }
            
            return fieldNames;
        }
    
}