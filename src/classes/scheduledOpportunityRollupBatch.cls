global class scheduledOpportunityRollupBatch implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        OpportunityRollupsBatch b = new OpportunityRollupsBatch(); 
        database.executebatch(b);
    //    start();
    }
 /*   public void start(){
        Datetime sysTime = System.now().addSeconds(60);      
        String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' +         sysTime.year();
        scheduledOpportunityRollupBatch reminder = new scheduledOpportunityRollupBatch();
        System.schedule( 'OpportunityRollupsBatch'+sysTime, chronExpression, reminder);
    }*/
}