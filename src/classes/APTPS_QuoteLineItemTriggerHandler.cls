/**    original
 * Class: APTPS_QuoteLineItemTriggerHandler
 * Description : Quote/Proposal Line Item Trigger Helper. This class will have trigger utility methods.
 * Author : Parth Sevak, @Apttus
 **/
public class APTPS_QuoteLineItemTriggerHandler {
    
    //Retrieve quote line item record types and hold in map to find out Quote line item with Latin America
    public static Map<Id, Schema.RecordTypeInfo> quoteLineItemRTMap = Schema.getGlobalDescribe().get('Apttus_Proposal__Proposal_Line_Item__c').getDescribe().getRecordTypeInfosById();
    public static Map<String, Schema.RecordTypeInfo> quoteLineItemRTMapByName = 
        Schema.getGlobalDescribe().get('Apttus_Proposal__Proposal_Line_Item__c').getDescribe().getRecordTypeInfosByName();

    
    /*
        Method : assignRecordTypeOnQuoteLineFromParentQuote , parameter : set_qf_quote_line
        Description : This should be called form before insert context of trigger. It sets the record type as per parent quote's RT
    */
    public static void assignRecordTypeOnQuoteLineFromParentQuote(List<Apttus_Proposal__Proposal_Line_Item__c> quoteLineItems) {
        //record types 
        String latinAmericaRTQuote = 'Latin_America_Proposal'; //APTPS_DaikinConstants.APTPS_Quote_RT_Latin_America ;
        String northAmericaRTQuote = 'North_America_Proposal'; //APTPS_DaikinConstants.APTPS_Quote_RT_North_America ;
        String latinAmericaRTQuoteLine = 'Latin America Proposal'; //APTPS_DaikinConstants.APTPS_QuoteLineItem_RT_Latin_America ;
        String northAmericaRTQuoteLine = 'North America Proposal'; //APTPS_DaikinConstants.APTPS_QuoteLineItem_RT_North_America ;
        //Id latinAmericaRTIdForQL = Schema.SObjectType.Account.getRecordTypeInfosByName().get(latinAmericaRTQuote).getRecordTypeId();
        //Id northAmericaRTIdForQL = Schema.SObjectType.Account.getRecordTypeInfosByName().get(northAmericaRTQuote).getRecordTypeId();
     
        Set<Id> quoteIds = new Set<Id>();
 
        for(Apttus_Proposal__Proposal_Line_Item__c quoteLineItem : quoteLineItems) {
            quoteIds.add(quoteLineItem.Apttus_Proposal__Proposal__c); 
        }
        Map<Id, Apttus_Proposal__Proposal__c> quoteMap = new map<Id, Apttus_Proposal__Proposal__c>([Select RecordType.DeveloperName, RecordType.Name from 
            Apttus_Proposal__Proposal__c where Id in :quoteIds]);
        //assign record type
        for(Apttus_Proposal__Proposal_Line_Item__c quoteLineItem : quoteLineItems) {
            System.debug('Quote RT - Developer Name ' + quoteMap.get(quoteLineItem.Apttus_Proposal__Proposal__c).RecordType.DeveloperName);
            if(quoteMap.get(quoteLineItem.Apttus_Proposal__Proposal__c).RecordType.DeveloperName.equalsIgnoreCase(latinAmericaRTQuote)) {
                quoteLineItem.RecordTypeId = quoteLineItemRTMapByName.get(latinAmericaRTQuoteLine).getRecordTypeId();
            } else if(quoteMap.get(quoteLineItem.Apttus_Proposal__Proposal__c).RecordType.DeveloperName.equalsIgnoreCase(northAmericaRTQuote)) {
                quoteLineItem.RecordTypeId = quoteLineItemRTMapByName.get(northAmericaRTQuoteLine).getRecordTypeId();
            } else {
                //do nothing
            }
        } 
        
    } 
    
    
    /*
        Method : setConfigFinalizedDateOnQuotes , parameter : list_of_quote_line_item
        Description : Method is supposed to be called form after update/delete context of Quote Line Item trigger.
            This method contains logic to set Config Finalized Date on Quote specifically for Latin America Proposal only
    */
    public static void setConfigFinalizedDateOnQuotes(List<Apttus_Proposal__Proposal_Line_Item__c> quoteLineItems,Boolean isDelete) {
        Set<Id> quoteIds = new Set<Id>();
        List<Apttus_Proposal__Proposal__c> finalQuoteList = new List<Apttus_Proposal__Proposal__c>();
        
        for(Apttus_Proposal__Proposal_Line_Item__c qLineItem : quoteLineItems) {
            if(qLineItem.Apttus_Proposal__Proposal__c != null && 
                quoteLineItemRTMap.get(qLineItem.RecordTypeId).getName().containsIgnoreCase('Latin America Proposal'))
                quoteIds.add(qLineItem.Apttus_Proposal__Proposal__c);
            
            if(qLineItem.Apttus_Proposal__Proposal__c != null && qLineItem.Apttus_QPConfig__LineType__c =='Product/Service')
                quoteIds.add(qLineItem.Apttus_Proposal__Proposal__c);
        }
        
        List<Apttus_Proposal__Proposal__c> quoteListToBeUpdated = new List<Apttus_Proposal__Proposal__c>();
            
        if(quoteIds != null && !quoteIds.isEmpty()) {
            List<Apttus_Proposal__Proposal__c> listQuote = [Select Id, Apttus_QPConfig__ConfigurationFinalizedDate__c,Risk__c,Risk_Amt__c,Contingency_Amt__c,Contingency_pct__c,Warranty_Equipment_Amt__c,Warranty_Equipment__c,Warranty_Parts_Material_Amt__c,Warranty_Parts_Material__c from 
                Apttus_Proposal__Proposal__c where Id in :quoteIds];
            Map<Id, Apttus_Proposal__Proposal__c> mapIdToQuote = new Map<Id, Apttus_Proposal__Proposal__c>(listQuote);
            
            Apttus_Proposal__Proposal__c quote = new Apttus_Proposal__Proposal__c();
            
            for(Apttus_Proposal__Proposal_Line_Item__c qLineItem : quoteLineItems) {
                quote = mapIdToQuote.get(qLineItem.Apttus_Proposal__Proposal__c);
                
                if(quoteLineItemRTMap.get(qLineItem.RecordTypeId).getName().containsIgnoreCase('Latin America Proposal') && quote.Apttus_QPConfig__ConfigurationFinalizedDate__c != System.Now()){
                    quote.Apttus_QPConfig__ConfigurationFinalizedDate__c = System.Now();
                    //quote.APTPS_Run_Validation_Rules__c = false; //avoid validation rule execution withour user updates
                    quoteListToBeUpdated.add(quote);
                }
                
                // converted Process Builder - "Quote/Proposal WRC Field Updates" to trigger || Case : 00209292 || Date : 17-04-2017
                if(qLineItem.Apttus_QPConfig__LineType__c =='Product/Service' && !isDelete){
                                        
                    if(qLineItem.Apttus_QPConfig__ClassificationHierarchy__c == 'Risk' && (quote.Risk_Amt__c!= qLineItem.Apttus_QPConfig__BaseExtendedCost__c || quote.Risk_Amt__c!= qLineItem.Apttus_QPConfig__AdjustmentAmount__c)){
                        quote.Risk_Amt__c= qLineItem.Apttus_QPConfig__BaseExtendedCost__c;
                        quote.Risk__c= qLineItem.Apttus_QPConfig__AdjustmentAmount__c;
                        quoteListToBeUpdated.add(quote);
                    }
                    system.debug('Apttus_QPConfig__ClassificationHierarchy__c::'+qLineItem.Apttus_QPConfig__ClassificationHierarchy__c+'quote.Contingency_Amt__c ::'+quote.Contingency_Amt__c+'qLineItem.Apttus_QPConfig__BaseExtendedCost__c::'+qLineItem.Apttus_QPConfig__BaseExtendedCost__c);
                    if(qLineItem.Apttus_QPConfig__ClassificationHierarchy__c == 'Contingency' && (quote.Contingency_Amt__c != qLineItem.Apttus_QPConfig__BaseExtendedCost__c || quote.Contingency_pct__c != qLineItem.Apttus_QPConfig__AdjustmentAmount__c)){
                        quote.Contingency_Amt__c = qLineItem.Apttus_QPConfig__BaseExtendedCost__c;
                        quote.Contingency_pct__c = qLineItem.Apttus_QPConfig__AdjustmentAmount__c;
                        quoteListToBeUpdated.add(quote);
                    }
                    if(qLineItem.Apttus_QPConfig__ClassificationHierarchy__c == 'Warranty (Equipment)' && (quote.Warranty_Equipment_Amt__c != qLineItem.Apttus_QPConfig__BaseExtendedCost__c || quote.Warranty_Equipment__c != qLineItem.Apttus_QPConfig__AdjustmentAmount__c)){
                        quote.Warranty_Equipment_Amt__c = qLineItem.Apttus_QPConfig__BaseExtendedCost__c;
                        quote.Warranty_Equipment__c = qLineItem.Apttus_QPConfig__AdjustmentAmount__c;
                        quoteListToBeUpdated.add(quote);
                    }
                    if(qLineItem.Apttus_QPConfig__ClassificationHierarchy__c == 'Warranty (Parts & Material)' && (quote.Warranty_Parts_Material_Amt__c != qLineItem.Apttus_QPConfig__BaseExtendedCost__c || quote.Warranty_Parts_Material__c != qLineItem.Apttus_QPConfig__AdjustmentAmount__c)){
                        quote.Warranty_Parts_Material_Amt__c = qLineItem.Apttus_QPConfig__BaseExtendedCost__c;
                        quote.Warranty_Parts_Material__c = qLineItem.Apttus_QPConfig__AdjustmentAmount__c;
                        quoteListToBeUpdated.add(quote);
                    }
                    
                System.debug('*********'+qLineItem.Name);
                }  
                  
            }  
        }
        
        if(quoteListToBeUpdated != null && !quoteListToBeUpdated.isEmpty()) {
            Set<Apttus_Proposal__Proposal__c> quoteSet = new Set<Apttus_Proposal__Proposal__c>();
            quoteSet.addAll(quoteListToBeUpdated);
            
            finalQuoteList.addAll(quoteSet);
            update finalQuoteList;
        }
        
      /* GS: Disabled due to errors with duplicate line ID's      
            if(quoteListToBeUpdated != null && !quoteListToBeUpdated.isEmpty()) {
                update quoteListToBeUpdated;
            }
      */   
    } 
    
    public static void setBlendedRateOnQuotes(List<Apttus_Proposal__Proposal_Line_Item__c> quoteLineItems) {
        //Get the quotes for the lineitems to be updated
        Set<Id> quoteIds = new Set<Id>();    
        for(Apttus_Proposal__Proposal_Line_Item__c qLineItem : quoteLineItems) {
            quoteIds.add(qLineItem.Apttus_Proposal__Proposal__c);
        }
        system.debug('run::');
        //Set the blended rate values on the quotes
        List<Apttus_Proposal__Proposal__c> quoteListToBeUpdated = new List<Apttus_Proposal__Proposal__c>();
        Map<String,AggregateResult> ratesMap = new Map<String,AggregateResult>();
        if(quoteIds != null && !quoteIds.isEmpty()) {
            //Get the avg rates for each Center
            /*AggregateResult[] rates = [select Apttus_Config2__Dimension1Value__c, AVG(Apttus_Config2__AdjustmentAmount__c) brate 
                                       from Apttus_Config2__PriceRuleEntry__c group by Apttus_Config2__Dimension1Value__c];*/
            for(AggregateResult rate:[select Apttus_Config2__Dimension1Value__c, AVG(Apttus_Config2__AdjustmentAmount__c) brate 
                                       from Apttus_Config2__PriceRuleEntry__c group by Apttus_Config2__Dimension1Value__c])
            {
                string key =string.valueOf(rate.get('Apttus_Config2__Dimension1Value__c'));
                ratesMap.put(key,rate);
            }
            if(!ratesMap.isEmpty())
            {
                List<Apttus_Proposal__Proposal__c> listQuote = [select Id, Center_Avg_Rate__c 
                                                                from Apttus_Proposal__Proposal__c where Id in :quoteIds FOR UPDATE];
                system.debug('listQuote::'+listQuote);
                Map<String,list<String>> centersMap = new Map<String,list<String>>();
               AggregateResult[] centers = [select Apttus_QPConfig__LineItemId__r.Apttus_Proposal__Proposal__c,Center__c, count(Id) cnt from Apttus_QPConfig__ProposalProductAttributeValue__c
                                            where Center__c !=null and Apttus_QPConfig__LineItemId__r.Apttus_Proposal__Proposal__c IN:quoteIds
                                            group by Apttus_QPConfig__LineItemId__r.Apttus_Proposal__Proposal__c,Center__c];
                system.debug('centers::'+centers);
                for(AggregateResult center :  centers)
                {
                    system.debug('center::'+center);
                    String key = string.valueOf(center.get('Apttus_Proposal__Proposal__c'));
                    string value = string.valueOf(center.get('Center__c'));
                    list<String> centersVar = new list<String>();
                    if(centersMap.containsKey(key))
                        {
                           centersVar = centersMap.get(key);
                            centersVar.add(value);
                           centersMap.put(key,centersVar); 
                        }
                    else {
                        centersVar.add(value);
                        centersMap.put(key,centersVar);
                    }
                }
                system.debug('centersMap::'+centersMap);
                if(listQuote != null && !centersMap.isEmpty()){
                      Double amt = 0.00;
                    for(Apttus_Proposal__Proposal__c quote : listQuote) {
                        if(centers != null){
                          list<String> quoteRelatedCenters = centersMap.get(quote.Id);
                            for(String center : quoteRelatedCenters){
                                  if(ratesMap.containskey(center))
                                {
                                    AggregateResult rate = ratesMap.get(center);
                                    amt += (Double)rate.get('brate');
                                }
                            }
                        }
                        if(amt>0.00){
                                quote.Center_Avg_Rate__c = amt/centers.size();
                                quoteListToBeUpdated.add(quote);
                            }
                        //Get line item product attribute value Center__c and match that with Price Rule Entry Dimmension1Value
                 /*        AggregateResult[] centers = [select Center__c, count(Id) cnt from Apttus_QPConfig__ProposalProductAttributeValue__c
                                                     where Center__c !=null and Apttus_QPConfig__LineItemId__r.Apttus_Proposal__Proposal__c=:quote.Id 
                                                     group by Center__c];
                       system.debug('centers::'+centers);
                        if(centers != null){
                            Double amt = 0.00;
                            for(AggregateResult center : centers){
                                system.debug('center::'+center);
                                system.debug('rates::'+rates);
                                for(AggregateResult rate : rates){
                                    if(rate.get('Apttus_Config2__Dimension1Value__c')==center.get('Center__c')){
                                        amt += (Double)rate.get('brate');
                                        break;
                                    }
                                }
                            }                
                            if(amt>0.00){
                                quote.Center_Avg_Rate__c = amt/centers.size();
                                quoteListToBeUpdated.add(quote);
                            }
}*/
                    }                 
                }
            }                     
        }
        
        //Update the quotes
        if(quoteListToBeUpdated != null && !quoteListToBeUpdated.isEmpty()) {
            Set<Apttus_Proposal__Proposal__c> quoteSet = new Set<Apttus_Proposal__Proposal__c>();
            quoteSet.addAll(quoteListToBeUpdated);
            List<Apttus_Proposal__Proposal__c> finalQuoteList = new List<Apttus_Proposal__Proposal__c>();
            finalQuoteList.addAll(quoteSet);
            update finalQuoteList;
        }        
    }    
}