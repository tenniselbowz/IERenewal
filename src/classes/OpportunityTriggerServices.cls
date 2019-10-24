public class OpportunityTriggerServices {
    public static final String CLOSED_WON = 'Closed Won-Pending Credit Approval';
    public static List<Opportunity> filterClosedWon(List<Opportunity> opps) {
        List<Opportunity> closedWonOpps = new List<Opportunity>();
        for(Opportunity opp : opps) {
            if(opp.StageName == CLOSED_WON) {
                closedWonOpps.add(opp); 
            }
        }
        return closedWonOpps;
    }
    
    public static List<Apttus_Proposal__Proposal__c> getPrimaryQuoteProposal(List<Opportunity> opps) {
        return [SELECT Id, Apttus_Proposal__Primary__c, Credit_Approvals__c, Apttus_Proposal__Opportunity__c
                FROM Apttus_Proposal__Proposal__c
                WHERE Apttus_Proposal__Opportunity__c IN :Pluck.ids(opps)
                AND Apttus_Proposal__Primary__c = true];
    }
    
    public static void processOpportunitySplits(List<Opportunity> opps){
        Map<Id, Opportunity> idToOpps =new Map<Id, Opportunity>([select Id, StageName, (SELECT Id,OpportunityId, SplitAmount, Closed_Won_Amount__c, Pipeline_Amount__c FROM OpportunitySplits) FROM Opportunity WHERE Id IN :opps]);
        List<OpportunitySplit> oppSplits = getOpportunitySplits(idToOpps.values());
        if(!oppSplits.isEmpty()) {
            OpportunitySplitServices.filterOpportunitySplits(oppSplits, idToOpps, true);
        }
    }
    
    public static void processOpportunitySplitsOnAmountChange(List<Opportunity> opportunityList,Map<Id, Opportunity> oldMap){
        Map<Id, Opportunity> idToOpps = new Map<Id, Opportunity>([SELECT Id FROM Opportunity WHERE Id IN :opportunityList]);
        
        List<Opportunity> oppsWithUpdatedAmount = new List<Opportunity>();
        for(Opportunity updatedOpp : opportunityList){
            if(oldMap.get(updatedOpp.Id).Amount != updatedOpp.Amount){
                oppsWithUpdatedAmount.add(updatedOpp);
            }
        }
        
        List<OpportunitySplit> opportunitySplitList = [SELECT Id,OpportunityId, SplitAmount, Closed_Won_Amount__c, Pipeline_Amount__c FROM OpportunitySplit WHERE OpportunityId IN :oppsWithUpdatedAmount];
        
        for(OpportunitySplit oppSplit : opportunitySplitList){
            OpportunitySplitServices.stampFields(oppSplit, false);
        }
        
        OpportunitySplitServices.updateOpportunitySplitList(opportunitySplitList,idToOpps);
    }
    
    private static List<OpportunitySplit> getOpportunitySplits(List<Opportunity> opps) {
        List<OpportunitySplit> oppSplits = new List<OpportunitySplit>();
        for(Opportunity opp : opps) {
            oppSplits.addALL(opp.OpportunitySplits);
        }
        return oppSplits;
    }
    
    public static void kickOffApprovalProcess (List<Apttus_Proposal__Proposal__c> quoteProposals, Map<Id,Opportunity> opps) {
        try{
            for(Apttus_Proposal__Proposal__c quoteProposal : quoteProposals) {
                Id quoteId = quoteProposal.Id;
                if(!Approval.isLocked(quoteId)) {
                    if(quoteProposal.Credit_Approvals__c == true) {
                        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                        req.setProcessDefinitionNameOrId('Credit_Approval_Process');
                        req.setObjectId(quoteId);
                        Approval.ProcessResult result = Approval.process(req);
                        if(!result.isSuccess()) {
                            opps.get(quoteProposal.Apttus_Proposal__Opportunity__c).addError(result.getErrors()[0].getMessage());
                        }
                    }
                    else {
                        opps.get(quoteProposal.Apttus_Proposal__Opportunity__c).addError('Credit Approval is not Required');
                    }
                }
            }
        }
        catch(Exception e){
            System.debug('Exception IN OpportunityTriggerServices '+e.getMessage()+e.getLineNumber());    
        }
         finally{
        	updateFinalCreditApproval(opps.keyset());    
        }
    }
        @future
    public static void updateFinalCreditApproval(set<Id> oppIds)
    {
        List<Opportunity> opplist = [SELECT Id, Final_credit_Approval__c FROM Opportunity WHERE Id IN :oppIds];
        for(Opportunity opp : oppList){
            opp.Final_credit_Approval__c = false;
        }
        update opplist;
    }
    public static void updateRollupFields(List<Opportunity> newOpps){
        set<String> accountIds = new set<String>();
        set<String> userIds = new set<String>();
        
        for(Opportunity opp :newOpps){
            accountIds.add(opp.AccountId); 
            accountIds.add(opp.Consulting_Engineer__c); 
            accountIds.add(opp.Owner_End_Client_Name__c);
            accountIds.add(opp.Architect__c);
            accountIds.add(opp.General_Contractor__c);
            accountIds.add(opp.Mechanical_Contractor__c);
            accountIds.add(opp.Active_Bidder__c);
            
            userIds.add(opp.OwnerId);
            userIds.add(opp.Take_Off__c);
            userIds.add(opp.Consulting_Engineer__r.ownerId);
            userIds.add(opp.Project_Engineer__c);
            userIds.add(opp.Job_Captain_CE__c);
            userIds.add(opp.Job_Captain_Sales__c);
            
        }
        
        
        Map<Id, Account> accObj = new Map<Id, Account>([Select id,name, Owner.Name, Owner.User_Department__c 
                                                        from Account WHERE Id IN  :accountIds]);
        
        Map<Id, User> userObj = new Map<Id, User>([SELECT Id, Name,User_Department__c from User WHERE id IN :userIds]);
        system.debug('accObj'+accObj);
        system.debug('userObj'+userObj);
        
        for(opportunity opp : newOpps){
            opp.Daikin_Players_Rollup__c = '';
            if(userObj.containsKey(opp.OwnerId)){
                opp.OpportunityOwner__c = 'Oppty Owner :'+userObj.get(opp.OwnerId).Name
                    +' ('+userObj.get(opp.OwnerId).User_Department__c+')';    
            }else{
                opp.OpportunityOwner__c = '';
            }
            if(userObj.containsKey(opp.Job_Captain_CE__c)){
                opp.Job_Captain_CE_Owner__c ='Job Captain CE Owner :'+userObj.get(opp.Job_Captain_CE__c).Name
                    +' ('+userObj.get(opp.Job_Captain_CE__c).User_Department__c+')';    
               system.debug('opp.Job_Captain_CE_Owner__c::'+'Job Captain CE Owner :'+userObj.get(opp.Job_Captain_CE__c).Name
                    +' ('+userObj.get(opp.Job_Captain_CE__c).User_Department__c+')'); 
            }else{
                opp.Job_Captain_CE_Owner__c = '';
            }
            if(userObj.containsKey(opp.Job_Captain_Sales__c)){
                opp.Job_Captain_Sales_Owner__c ='Job Captain Sales Owner: '+userObj.get(opp.Job_Captain_Sales__c).Name
                    +' ('+userObj.get(opp.Job_Captain_Sales__c).User_Department__c+')';
                system.debug('opp.Job_Captain_Sales_Owner__c::'+'Job Captain Sales Owner: '+userObj.get(opp.Job_Captain_Sales__c).Name
                    +' ('+userObj.get(opp.Job_Captain_Sales__c).User_Department__c+')');
            }else{
                
                opp.Job_Captain_Sales_Owner__c = '';    
                
            }
            if(userObj.containsKey(opp.Project_Engineer__c)){
                opp.Project_Engineer_Owner__c ='Project Engineer Owner: '+userObj.get(opp.Project_Engineer__c).Name
                    +' ('+userObj.get(opp.Project_Engineer__c).User_Department__c+')';  
                system.debug('opp.Project_Engineer_Owner__c::'+'Project Engineer Owner: '+userObj.get(opp.Project_Engineer__c).Name
                    +' ('+userObj.get(opp.Project_Engineer__c).User_Department__c+')');
            }else{
                opp.Project_Engineer_Owner__c = '';
            }
            if(accObj.containsKey(opp.AccountId)){
                opp.Account_Owner__c = 'Account Owner: '+accObj.get(opp.AccountId).Owner.Name
                    +' ('+accObj.get(opp.AccountId).Owner.User_Department__c+')';    
            }else{
                opp.Account_Owner__c = '';
            }
            
            if(accObj.containsKey(opp.Consulting_Engineer__c)){
                opp.Consulting_Engineer_Owner__c ='Consulting Engineer Owner: '+ accObj.get(opp.Consulting_Engineer__c).Owner.Name+' ('+
                    accObj.get(opp.Consulting_Engineer__c).Owner.User_Department__c +')';    
            }else{
                opp.Consulting_Engineer_Owner__c = '';
            }
            if(userObj.containsKey(opp.Take_Off__c)){
                opp.TakeoffOwner__c = 'Take Off Owner: '+userObj.get(opp.Take_Off__c).Name
                    +' ('+userObj.get(opp.Take_Off__c).User_Department__c+')';
            }else{
                opp.TakeoffOwner__c = '';
            }
            if(accObj.ContainsKey(opp.Architect__c)){
                
                opp.Architect_Owner__c = 'Architect Owner: '+accObj.get(opp.Architect__c).Owner.Name+'  ('+accObj.get(opp.Architect__c).Owner.User_Department__c+')';
                
            }else{
                opp.Architect_Owner__c = '';
            }
            if(accObj.containsKey(opp.General_Contractor__c)){
                opp.General_Contract_Owner__c =  'General Contractor Owner: '+accObj.get(opp.General_Contractor__c).Owner.Name  
                    +' ('+accObj.get(opp.General_Contractor__c).Owner.User_Department__c+')';   
            }else{
                opp.General_Contract_Owner__c = '';
            }
            if(accObj.containsKey(opp.Mechanical_Contractor__c)){
                
                opp.Mechanical_Contract_Owner__c = 'Mechanical Contractor Owner: '+accObj.get(opp.Mechanical_Contractor__c).Owner.Name
                    +' ('+accObj.get(opp.Mechanical_Contractor__c).Owner.User_Department__c+')';
            }else{
                opp.Mechanical_Contract_Owner__c = '';
            }
            if(accObj.containsKey(opp.Owner_End_Client_Name__c)){
                opp.Owner_End_User_Info__c  ='Owner/End User:'+accObj.get(opp.Owner_End_Client_Name__c).Owner.Name
                    +' ('+accObj.get(opp.Owner_End_Client_Name__c).Owner.user_Department__c+')';
            }else{
                opp.Owner_End_User_Info__c  = '';
            }
            
            //Fields for concatenating
            
            String takeOffOwner = opp.TakeoffOwner__c ;
            if(!String.isBlank(takeOffOwner)){
                System.debug('Entered');
                takeOffOwner +=',';
            }
            String ArchitectOwner = opp.Architect_Owner__c;
            if(!String.isBlank(ArchitectOwner)){
                ArchitectOwner += ',';
            }
            String OpportunityOwner = opp.OpportunityOwner__c;
            if(!String.isBlank(OpportunityOwner)){
                OpportunityOwner += ',';
            }
            String AccountOwner = opp.Account_Owner__c;
            if(!String.isBlank(AccountOwner)){
                AccountOwner += ',';
            } 
            String jobCaptainCEOwner = opp.Job_Captain_CE_Owner__c;
            if(!String.isBlank(jobCaptainCEOwner)){
                jobCaptainCEOwner += ',';
            } 
            String jobCaptainSalesOwner = opp.Job_Captain_Sales_Owner__c;
            if(!String.isBlank(jobCaptainSalesOwner)){
                jobCaptainSalesOwner += ',';
            }
            String ProjectOwner = opp.Project_Engineer_Owner__c;
            if(!String.isBlank(ProjectOwner)){
                ProjectOwner += ',';
            }
            String ConsultingEngineerOwner = opp.Consulting_Engineer_Owner__c;
            if(!String.isBlank(ConsultingEngineerOwner)){
                ConsultingEngineerOwner += ',';
            }
            String GeneralContractOwner = opp.General_Contract_Owner__c;
            if(!String.isBlank(GeneralContractOwner)){
                GeneralContractOwner += ',';
            }
            String OwnerEndUserInfo = opp.Owner_End_User_Info__c;
            if(!String.isBlank(OwnerEndUserInfo)){
                OwnerEndUserInfo += ',';
            }
            String BidderInfo = opp.Active_Bidder__c;
            if(String.isBlank(BidderInfo)){
                BidderInfo = '';
            }else{
                BidderInfo += ', ';    
            }
            String OpportnitySplitInfo = opp.Opportunity_Split_Owner__c;
            if(String.isBlank(OpportnitySplitInfo)){
                OpportnitySplitInfo = '';
            }
            
            opp.Daikin_Players_Rollup__c = OpportunityOwner+AccountOwner+jobCaptainCEOwner+jobCaptainSalesOwner+ProjectOwner+takeOffOwner+ArchitectOwner+
                ConsultingEngineerOwner+GeneralContractOwner+OwnerEndUserInfo+BidderInfo+OpportnitySplitInfo;
            opp.Daikin_Players_Rollup__c = opp.Daikin_Players_Rollup__c.removeEnd(',');
            
        }
    }
    
}