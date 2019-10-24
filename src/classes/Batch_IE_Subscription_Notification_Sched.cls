global class Batch_IE_Subscription_Notification_Sched implements Schedulable {
	global void execute(SchedulableContext SC) 
    {
        integer batchSize = 500;
        Batch_IE_Subscription_Notification bsn = new Batch_IE_Subscription_Notification();
		Database.executeBatch(bsn, batchSize);
    }
}