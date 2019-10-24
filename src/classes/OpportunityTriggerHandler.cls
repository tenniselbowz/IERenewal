public class OpportunityTriggerHandler {

    //Retrieve Opportunity record types and hold in a map
    public static Map<Id, Schema.RecordTypeInfo> oppRTMap = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosById();
    public static final Set<String> SET_OPPORTUNITY_STAGES = new Set<String> {'Closed Lost' , 'Abandoned' };

    public static void handleAfterUpdate(Map<Id, Opportunity> opps, Map<Id, Opportunity> oldMap) {
        List<Opportunity> filterOpps = OpportunityTriggerServices.filterClosedWon(opps.values());
		system.debug('filterOpps ' + filterOpps);
        List<Opportunity> finalCreditApprovalOpps = new List<Opportunity>();
        for(Opportunity opp :filterOpps)
        {
            if(opp.Final_Credit_Approval__c)
            {
                finalCreditApprovalOpps.add(opp);    
            }
                
        }
        
        if(!finalCreditApprovalOpps.isEmpty()) 
        {
            List<Apttus_Proposal__Proposal__c> quoteProposals = OpportunityTriggerServices.getPrimaryQuoteProposal(filterOpps);
            system.debug('quoteProposals ' + quoteProposals);
            if(!quoteProposals.isEmpty()) {
                OpportunityTriggerServices.kickOffApprovalProcess(quoteProposals, opps);
            }
        }

        OpportunityTriggerServices.processOpportunitySplitsOnAmountChange(opps.values(),oldMap);
        OpportunityTriggerServices.processOpportunitySplits(opps.values());
    }

    public static void handleAfterUpdate(Map<Id, Opportunity> oppsp) {
    }


    public static void handleBeforeInsertUpdate(List<Opportunity> oppList) {
        /*
            Whenever an Opportunity with the Record type of 'North America Apttus' is created or edited, it should copy the Primary Billing
            Address fields over to the Opportunity. No error should be thrown if there is no Account attached to the Opportunity or if a Primary
            Bill To address is not specified on the Account.
        */

        // Check if the Record Type is 'North America Apttus'
        system.debug('oppList::'+oppList.size());
        Set<id> accID = new Set<Id>();
        for(Opportunity opp : oppList)
        {
            if(opp.RecordTypeId != null && oppRTMap.get(opp.RecordTypeId).getName().containsIgnoreCase('North America Apttus'))
            {
                if (opp.AccountId != null)
                {
                    accId.add(opp.AccountId);
                    System.debug('Account Id'+opp.AccountId);
                }
              }
        }
		
        List<Account_Address__c> acctAddrJunctionObjs = [Select Account__c, Active__c, Address_Name__c, Address__c, Bill_To__c, Mail_To__c, Name, Physical__c, Primary_Bill_To__c, Primary_Mail_To__c, Primary_Ship_To__c, Ship_To__c FROM Account_Address__c where Account__c IN:accId];
        System.debug('ACCOUNT aDDRESS ::'+acctAddrJunctionObjs);
        Map<Id,Account_Address__c> accAddrMap = new Map<Id,Account_Address__c>();
        Map<String,String> accountAddressMap = new Map<String,String>();
        for(Account_Address__c addressVar :[Select Account__c, Active__c, Address_Name__c, Address__c, Bill_To__c, Mail_To__c, Name, Physical__c, Primary_Bill_To__c, Primary_Mail_To__c, Primary_Ship_To__c, Ship_To__c FROM Account_Address__c where Account__c IN:accId and Primary_Bill_To__c = true])
        {
            accountAddressMap.put(addressVar.account__c, addressVar.Address__c);
            accAddrMap.put(addressVar.Address__c,addressVar);
        }
        Map<String,Address__c> addressMap = new Map<String,Address__c>();
        for(Address__c adrVar: [select id,Name, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Address_Line_4__c, Address_Name__c, Postal_Code__c, City__c, Country__c, State_Province__c FROM Address__c where Id IN :accAddrMap.keySet()])
        {
            addressMap.put(adrVar.Id,adrVar);
        }
        
        for(Opportunity opp : oppList) {
            if(opp.RecordTypeId != null && oppRTMap.get(opp.RecordTypeId).getName().containsIgnoreCase('North America Apttus')) {
                if (opp.AccountId != null) {
                    System.debug('Entered here Call');
                    // Get the associated account address records from the junction object (Account_Address__c) via the account id
						
                    // Loop through the list of account address records and grab the one whose 'Primary Bill To' field is TRUE
                    // Get the Address record for the given Id and set appropriate Opportunity address fields
                            //Address__c addr = [SELECT Id, Name, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Address_Line_4__c, Address_Name__c, Postal_Code__c, City__c, Country__c, State_Province__c FROM Address__c WHERE id = :aa.Address__c and Primary_Bill_To__c = true];
                            if(accountAddressMap.containsKey(opp.AccountId))
                            {
                    		Address__c addr = addressMap.get(accountAddressMap.get(opp.AccountId));
                                
                            opp.Bill_To_Address_Name__c = addr.Address_Name__c;
                            opp.Bill_To_Address_Line_1__c = addr.Address_Line_1__c;
                            opp.Bill_To_Address_Line_2__c = addr.Address_Line_2__c;
                            opp.Bill_To_Address_Line_3__c = addr.Address_Line_3__c;
                            opp.Bill_To_Address_Line_4__c = addr.Address_Line_4__c;
                            opp.Bill_To_City__c = addr.City__c;
                            opp.Bill_To_Country__c = addr.Country__c;
                            opp.Bill_To_State_Province__c = addr.State_Province__c;
                            opp.Bill_To_Zip_Postal_Code__c = addr.Postal_Code__c;
                            }
                }
            }
        }
    }
     public static void updateBidderDate(List<Opportunity> oppList){// Updates bidder date when opportunity Bidder date is set to future
        List<Bidder__c> bidderList = [SELECT Id, of_Follow_up_Attempts__c, Opportunity__r.Bid_Date__c FROM Bidder__c
                                     WHERE Opportunity__c IN :oppList];
        for(Bidder__c b :bidderList){
            if(b.Opportunity__r.Bid_Date__c > System.today()){
             	b.of_Follow_up_Attempts__c = 0;   
            }
        }
        if(!bidderList.isEmpty()){
            update bidderList;
        }
    }


}