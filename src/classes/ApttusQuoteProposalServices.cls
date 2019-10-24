public class ApttusQuoteProposalServices {
    
    public static Map<String, Apttus_Config2__PriceList__c> mapPriceListNameToRecord = new Map<String, Apttus_Config2__PriceList__c>();
    public static Map<Id, Schema.RecordTypeInfo> quoteRTMap = Schema.getGlobalDescribe().get('Apttus_Proposal__Proposal__c').getDescribe().getRecordTypeInfosById(); 
    
    public static void setQuoteDefaults(List<Apttus_Proposal__Proposal__c> quoteList) {
        User currentUser = [SELECT DM_District_Manager__c, ROSM_Regional_Owner_Sales_Manager__c, 
                            RSM_Regional_Service_Manager__c, RGM_Regional_General_Manager__c, 
                            Legal_Approver__c, Service_Coordinator__c, Regional_Contract_Coordinator_RCC__c,
                            Operations_Manager__c, Service_Center_Manager__c, Project_Development_Personnel__c,
                            DSO_General_Manager__c, ROM_Regional_Operations_Manager__c, Senior_RGM__c,
                            Director_of_Operations__c, VP_Owner_Sales__c
                            FROM User WHERE Id = :UserInfo.getUserId()];
        //call method to populate price list map
        buildUpPriceListMapForNorthAmericaQuotes(quoteList);
        //get map of opp ids with opportunity records
        Map<Id, Opportunity> mapIdToOpportunity =  getMapOfOppIdToOpportunity(quoteList);
        for(Apttus_Proposal__Proposal__c quote : quoteList) {
            if(quote.RecordTypeId != null && quoteRTMap.get(quote.RecordTypeId).getName().containsIgnoreCase('Latin America Proposal')) {
                continue;
            }
            
            if(mapIdToOpportunity.get(quote.Apttus_Proposal__Opportunity__c) != null) { 
                quote.Line_of_Business__c = mapIdToOpportunity.get(quote.Apttus_Proposal__Opportunity__c).Line_of_Business__c;
                quote.Estimated_Close_Date__c = mapIdToOpportunity.get(quote.Apttus_Proposal__Opportunity__c).CloseDate;  
            }
            quote.DM_District_Manager__c = currentUser.DM_District_Manager__c;
            quote.ROSM_Regional_Owner_Sales_Manager__c = currentUser.ROSM_Regional_Owner_Sales_Manager__c;
            quote.RSM_Regional_Service_Manager__c = currentUser.RSM_Regional_Service_Manager__c;
            quote.RGM_Regional_General_Manager__c = currentUser.RGM_Regional_General_Manager__c;
            quote.Legal_Approver__c = currentUser.Legal_Approver__c;
            quote.Service_Coordinator__c = currentUser.Service_Coordinator__c;
            quote.Regional_Contract_Coordinator_RCC__c = currentUser.Regional_Contract_Coordinator_RCC__c;

            quote.Operations_Manager__c = currentUser.Operations_Manager__c;
            quote.Service_Center_Manager__c = currentUser.Service_Center_Manager__c;
            quote.Project_Development_Personnel__c = currentUser.Project_Development_Personnel__c;
            quote.DSO_General_Manager__c = currentUser.DSO_General_Manager__c;
            quote.ROM_Regional_Operations_Manager__c = currentUser.ROM_Regional_Operations_Manager__c;
            quote.Senior_RGM__c = currentUser.Senior_RGM__c;
            quote.Director_of_Operations__c = currentUser.Director_of_Operations__c;
            quote.VP_Owner_Sales__c = currentUser.VP_Owner_Sales__c;

            if(quote.RecordTypeId != null && quoteRTMap.get(quote.RecordTypeId).getName().containsIgnoreCase('North America Proposal')) {
                APTPS_Configurable_Variables__c northAmericaQuoteCS = APTPS_Configurable_Variables__c.getValues('North_America_Quote_Price_List');
                String northAmericaPLName;
                if(northAmericaQuoteCS != null) {
                    northAmericaPLName = northAmericaQuoteCS.APTPS_Variable_Value__c;
                }
                
                if(!String.isBlank(northAmericaPLName) && mapPriceListNameToRecord != null && !mapPriceListNameToRecord.isEmpty() &&
                   mapPriceListNameToRecord.get(northAmericaPLName) != null)
                    quote.Apttus_QPConfig__PriceListId__c = mapPriceListNameToRecord.get(northAmericaPLName).Id;
                
            }
        }
    }
    
    public static void buildUpPriceListMapForNorthAmericaQuotes(List<Apttus_Proposal__Proposal__c> quoteList) {
        List<Apttus_Proposal__Proposal__c> northAmericaQuotes = new List<Apttus_Proposal__Proposal__c>();
        for(Apttus_Proposal__Proposal__c quote : quoteList) {
            if(quote.RecordTypeId != null && quoteRTMap.get(quote.RecordTypeId).getName().containsIgnoreCase('North America Proposal')) {
                northAmericaQuotes.add(quote);
            }
        }
        if(!northAmericaQuotes.isEmpty()) {
            List<Apttus_Config2__PriceList__c> listPriceList = [Select Name from Apttus_Config2__PriceList__c 
                                                                WHERE Name != null AND Apttus_Config2__Active__c = TRUE limit 2000];
            if(listPriceList != null && !listPriceList.isEmpty()) {
                for(Apttus_Config2__PriceList__c pList : listPriceList) {
                    mapPriceListNameToRecord.put(pList.Name, pList);
                }
            }
        }              
        
    }
    
    public static Map<Id, Opportunity> getMapOfOppIdToOpportunity(List<Apttus_Proposal__Proposal__c> quoteList) {
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
        if(quoteList == null) return opportunityMap;
        Set<Id> oppIds = new Set<Id>();
        for(Apttus_Proposal__Proposal__c quote : quoteList) {
            if(quote.Apttus_Proposal__Opportunity__c != null) oppIds.add(quote.Apttus_Proposal__Opportunity__c);
        }
        if(oppIds != null && oppIds.size() > 0) {
            return new Map<Id, Opportunity>([Select Id, Pricebook2Id,  Name, CloseDate, Line_of_Business__c, 
                                             (Select Product2Id, DST_ID__c from OpportunityLineItems) from Opportunity 
                                             WHERE Id in :oppIds]);
        }
        return opportunityMap;                           
        
    }
    
    public static void makeOnlyPrimaryQuote(List<Apttus_Proposal__Proposal__c> quoteList) {      
        Set<Id> oppIds = new Set<Id>(); 
        for(Apttus_Proposal__Proposal__c quote : quoteList) {   
            if(quote.Apttus_Proposal__Opportunity__c != null && quote.Apttus_Proposal__Primary__c == true) {
                oppIds.add(quote.Apttus_Proposal__Opportunity__c);
            }
        }
        if(oppIds.isEmpty()) return;    
        
        List<Apttus_Proposal__Proposal__c> listProposal = [Select Id, Apttus_Proposal__Opportunity__c, Apttus_Proposal__Primary__c from Apttus_Proposal__Proposal__c
                                                           where Apttus_Proposal__Opportunity__c in :oppIds and Id not in :quoteList AND Apttus_Proposal__Primary__c = true];
        List<Apttus_Proposal__Proposal__c> quotesToUpdate = new List<Apttus_Proposal__Proposal__c>();  
        for(Apttus_Proposal__Proposal__c quote : listProposal) {
            quote.Apttus_Proposal__Primary__c  = false;
            quotesToUpdate.add(quote);
        } 
        try {
            if(!quotesToUpdate.isEmpty()) {
                update quotesToUpdate;
            }
        } catch(DMLException e) {
            System.debug('***Upadate failed. ' + e.getMessage());
            throw new APTPS_DaikinGlobalException(e.getMessage());
        }
    }
    
    
    public static void synchronizeOpportunityLineItems(List<Apttus_Proposal__Proposal__c> quoteList, Map<Id, Apttus_Proposal__Proposal__c> oldQuoteMap) {
        List<Apttus_Proposal__Proposal__c> quotes = APTPS_QuoteTriggerHandler.getQuotsForSyncOperation(quoteList, oldQuoteMap);
        if(quotes.isEmpty()) return;
        
        APTPS_QuoteTriggerHandler.deleteOppLineItemsWithDST(quoteList, oldQuoteMap);
        APTPS_QuoteTriggerHandler.deleteOppLinesWithoutDSTIds(quotes);
        APTPS_QuoteTriggerHandler.updateOpportunitiesWithPricebook(quotes);
        Map<Id, Opportunity> mapIdToOpportunity =  APTPS_QuoteTriggerHandler.getMapOfOppIdToOpportunity(quotes);
        Map<Id, List<OpportunityLineItem>> mapOpptyWithLineItemsDST = new Map<Id, List<OpportunityLineItem>>();
        for(Opportunity opp : mapIdToOpportunity.values()) {
            if(opp.OpportunityLineItems != null && !opp.OpportunityLineItems.isEmpty()) {
                for(OpportunityLineItem oppLineItem : opp.OpportunityLineItems) {
                    if(!String.isBlank(oppLineItem.DST_ID__c)) {
                        if(mapOpptyWithLineItemsDST.containsKey(opp.Id)) {
                            mapOpptyWithLineItemsDST.get(opp.Id).add(oppLineItem);
                        } else {
                            mapOpptyWithLineItemsDST.put(opp.Id, new List<OpportunityLineItem>{oppLineItem});
                        }
                    }
                }
            }
        }
        
        
        Map<Id, Apttus_Proposal__Proposal__c> quoteMap = new Map<Id, Apttus_Proposal__Proposal__c>(quotes);
        Set<Id> quoteIds = quoteMap.keyset();
        List<Apttus_Proposal__Proposal_Line_Item__c> quoteLineItems = APTPS_QuoteTriggerHandlerSupport.getLineItemsForQuotes(quoteIds);
        if(quoteLineItems.isEmpty()) return;
        
        Set<Id> productIds = new Set<Id>();
        Map<Id, Apttus_Proposal__Proposal_Line_Item__c> mapProductIdTOQuoteLine = new Map<Id, Apttus_Proposal__Proposal_Line_Item__c>();
        for(Apttus_Proposal__Proposal_Line_Item__c quoteLineItem : quoteLineItems) {
            if(quoteLineItem.Apttus_Proposal__Product__c != null) {
                productIds.add(quoteLineItem.Apttus_Proposal__Product__c);
                mapProductIdTOQuoteLine.put(quoteLineItem.Apttus_Proposal__Product__c, quoteLineItem);
            }
        }
        List<Opportunity> finalOpptyList = [Select Id, Pricebook2Id from Opportunity where id in :mapIdToOpportunity.keySet()];
        Map<Id, Opportunity> mapFinalOpptyList = new Map<Id, Opportunity>(finalOpptyList);
        Set<Id> opptyPBIds = new Set<Id>();
        for(Opportunity oppty : finalOpptyList) {
            if(oppty.Pricebook2Id != null) {
                opptyPBIds.add(oppty.Pricebook2Id);
            }
        }
        List<Id> listOpptyPBId = new List<Id>(); listOpptyPBId.addAll(opptyPBIds);
        Map<Id, PricebookEntry> mapPriceBookToEntry = buildUpMapOfPriceBookWithEntry(productIds, listOpptyPBId);
        List<OpportunityLineItem> newOppLineItems = new List<OpportunityLineItem>();
        List<OpportunityLineItem> oppLineItemsToBeUpdated = new List<OpportunityLineItem>();
        Opportunity oppty;
        for(Apttus_Proposal__Proposal__c quote : quotes) {
            OpportunityLineItem oppLineItem;   
            for(Apttus_Proposal__Proposal_Line_Item__c quoteLineItem : quoteLineItems) {
                oppLineItem = new OpportunityLineItem();
                if(quoteLineItem.Apttus_Proposal__Proposal__c != quote.Id) continue;
                oppLineItem.APTPS_Product_Id__c = quoteLineItem.Apttus_Proposal__Product__c; 
                if(String.isBlank(quoteLineItem.DST_ID__c) && quoteLineItem.Alternate__c == false) {
                    oppty = mapIdToOpportunity.get(quote.Apttus_Proposal__Opportunity__c);
                    //assign pricebook entry to opp line item
                    if(mapPriceBookToEntry != null && !mapPriceBookToEntry.isEmpty()) {
                        if(mapPriceBookToEntry.get(quoteLineItem.Apttus_Proposal__Product__c) != null) {
                            PriceBookEntry pbE1 = mapPriceBookToEntry.get(quoteLineItem.Apttus_Proposal__Product__c);
                            Id pbEntryId = mapPriceBookToEntry.get(quoteLineItem.Apttus_Proposal__Product__c).Id;
                            if(pbE1 != null) {
                                oppLineItem.priceBookEntryId = pbE1.Id; 
                            }
                            
                        } else {
                            System.debug('*** no error : price book will be assigned : ' + quoteLineItem.Apttus_Proposal__Product__c);
                            
                        }
                        
                    }
                    
                    oppLineItem.opportunityId = oppty.Id;
                    oppLineItem = APTPS_QuoteTriggerHandlerSupport.populateOppLineItem(oppLineItem, quoteLineItem);
                    if(String.isBlank(oppLineItem.Item_Number__c)) oppLineItem.Item_Number__c = '1';
                    oppLineItem.Exchange_Rate__c = 1; //This can't be blank
                    newOppLineItems.add(oppLineItem);
                } else if(!String.isBlank(quoteLineItem.DST_ID__c)) {
                    if(mapOpptyWithLineItemsDST != null && !mapOpptyWithLineItemsDST.isEmpty()) {
                        oppty = mapIdToOpportunity.get(quote.Apttus_Proposal__Opportunity__c);
                        List<OpportunityLineItem> oppLineItems = mapOpptyWithLineItemsDST.get(oppty.Id);
                        if(oppLineItems != null && !oppLineItems.isEmpty()) {
                            for(OpportunityLineItem oppLineItem1 : oppLineItems) {
                                if(oppLineItem1.Product2Id == quoteLineItem.Apttus_Proposal__Product__c) {
                                    oppLineItem1 = APTPS_QuoteTriggerHandlerSupport.populateOppLineItem(oppLineItem1, quoteLineItem);
                                    oppLineItem1.APTPS_Product_Id__c = quoteLineItem.Apttus_Proposal__Product__c;
                                    oppLineItemsToBeUpdated.add(oppLineItem1);
                                    
                                }
                            }
                        }
                    }
                } else {
                    //do nothing    
                }
            }
        }
        
        APTPS_QuoteTriggerHandler.saveOppLineItems(newOppLineItems);
        
        APTPS_QuoteTriggerHandler.saveOppLineItems(oppLineItemsToBeUpdated);
        
    }
    public static Map<Id, PricebookEntry> buildUpMapOfPriceBookWithEntry(Set<Id> productIds, List<Id> opptyPricebookIds) 
    {
        
        List<PricebookEntry> pricebookEntries = [select Id, Name, IsActive, Pricebook2Id, Product2Id, ProductCode,
                                                 UnitPrice, UseStandardPrice from PricebookEntry WHERE 
                                                 Product2Id in :productIds AND  
                                                 Pricebook2Id in :opptyPricebookIds];
        
        
        if(pricebookEntries.isEmpty())  return null;
        
        Map<Id, PricebookEntry> mapPriceBookToEntry = new Map<Id, PricebookEntry>();
        for(PricebookEntry pbEntry : pricebookEntries) {
            mapPriceBookToEntry.put(pbEntry.Product2Id , pbEntry);
        }
        return mapPriceBookToEntry;
    }
    
    public static void setTotalNetPriceInWords(List<Apttus_Proposal__Proposal__c> quoteList)
    {
        for (Apttus_Proposal__Proposal__c apt: quoteList) {
            if (apt.LA_Total_Net_Price_for_Contract__c!= null && apt.LA_Total_Net_Price_for_Contract__c >= 0) {
                apt.Total_Net_Price_In_Words__c = NumberToWord.New_english_number(apt.LA_Total_Net_Price_for_Contract__c);
            } else {
                apt.Total_Net_Price_In_Words__c = null;
            }            
            if (apt.Turnkey_Contingency_Amount__c!= null && apt.Turnkey_Contingency_Amount__c >= 0) {
                System.debug('           *** calculating net price');
                apt.Turnkey_Contingency_Amount_in_words__c = NumberToWord.New_english_number(apt.Turnkey_Contingency_Amount__c);
                System.debug('        *** after caluclating ' + apt.Turnkey_Contingency_Amount_in_words__c);  

            } else {
                apt.Turnkey_Contingency_Amount_in_words__c = null;
            }
            
        }
        
    }
}