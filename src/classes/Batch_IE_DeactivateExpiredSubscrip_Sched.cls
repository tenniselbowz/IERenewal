global class Batch_IE_DeactivateExpiredSubscrip_Sched implements Schedulable {
    global void execute(SchedulableContext SC) 
    {
        integer batchSize = 200;
        Batch_IE_DeactivateExpiredSubscriptions bdes = new Batch_IE_DeactivateExpiredSubscriptions();
        Database.executeBatch(bdes, batchSize);
    }
}