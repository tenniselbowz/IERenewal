trigger FollowUpAttempts on Bidder__c (before update) {
    
  /*  map<id, Opportunity> OppMap = new map<id,opportunity>();
   // list<opportunity>  Oppvalues = [SELECT id,Name,Bid_Date__c from opportunity limit 5000];
    
    system.debug('Oppvalues::'+Oppvalues);
    for(opportunity opp : Oppvalues){
        OppMap.put(opp.id, opp);
    }
*/
    set<String> oppIds = new set<String>();
    for(Bidder__c b: Trigger.new){
        oppIds.add(b.opportunity__c);
    }
    Map<String, opportunity> oppBidDates = new Map<String, Opportunity>([select id, bid_date__c FROM Opportunity WHERE Id In :oppIds]);
    for (Bidder__c b: Trigger.new) {
        Bidder__c oldbidder = Trigger.oldMap.get(b.ID);
        if(b.of_Follow_up_Attempts__c == null){
            b.of_Follow_up_Attempts__c = 0;    
        }
        if((b.Bidder_Outcome_Feedback__c != oldbidder.Bidder_Outcome_Feedback__c ||
           b.Daikin_Outcome_Feedback__c != oldbidder.Daikin_Outcome_Feedback__c ||
           b.Apparent_Winning_Bidder__c != oldbidder.Apparent_Winning_Bidder__c ||
           b.Inactive__c != oldbidder.Inactive__c ||
           b.Note__c != oldbidder.Note__c) && oppBidDates.get(b.opportunity__c).bid_date__c <= system.today())
        {
            System.debug('Bidder_Outcome_Feedback__c is changed:::');
            System.debug('Old  Feedback :'+oldbidder.Bidder_Outcome_Feedback__c);
            System.debug('New  Feedback :'+b.Bidder_Outcome_Feedback__c);
            b.of_Follow_up_Attempts__c += 1;
            system.debug('b.of_Follow_up_Attempts__c::'+b.of_Follow_up_Attempts__c);
        }
        
        /*if(OppMap.get(b.Opportunity__c).Bid_Date__c > System.today()){
            system.debug(b.of_Follow_up_Attempts__c);
            b.of_Follow_up_Attempts__c = 0;
        }*/
    }
    
    
    
}