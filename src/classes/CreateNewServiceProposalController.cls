public with sharing class CreateNewServiceProposalController {
    public Apttus_Proposal__Proposal__c Proposal{get; set;}
    
    public User currentUser{get; set;}
    public String oppId{get; set;}
    public String oppId2{get;set;}
    
    public CreateNewServiceProposalController(ApexPages.StandardController controller) {
        this.Proposal = (Apttus_Proposal__Proposal__c)controller.getRecord();
        
        oppId = ApexPages.currentPage().getParameters().get('retURL');
        //oppId = this.Proposal.Apttus_Proposal__Opportunity__c;
        oppId2 = oppId.replace('/', '');

        system.debug('This is the OppId2:' + oppId2);
        currentUser = new User();
        currentUser = [SELECT Id, Name, Country, Legal_Approver__c, RGM_Regional_General_Manager__c, ROSM_Regional_Owner_Sales_Manager__c, RSM_Regional_Service_Manager__c, DM_District_Manager__c FROM User WHERE Id =: userinfo.getuserId()];
        
        if(currentUser.country == 'United States'){
            Proposal.T_C_Country__c  = 'USA';
            Proposal.Local_Currency__c  = 'USD';
        } else if(currentUser.country == 'Canada') {
            Proposal.T_C_Country__c  = 'Canada - English';
            Proposal.Local_Currency__c  = 'CAD';
        }
        
        Opportunity Opp = [SELECT Id, Name, AccountId, CloseDate, Line_of_Business__c, Bid_Date__c  FROM Opportunity WHERE Id = :oppId2];
        if(opp !=NULL) {
            Proposal.Apttus_Proposal__Proposal_Name__c = opp.Name;
            Proposal.Apttus_Proposal__Account__c = opp.AccountId;
            Proposal.Line_of_Business__c = opp.Line_of_Business__c;
            Proposal.Estimated_Close_Date__c = opp.CloseDate;
            Proposal.Opportunity_Bid_Date__c = opp.Bid_Date__c;
        }
        
    }
       

}