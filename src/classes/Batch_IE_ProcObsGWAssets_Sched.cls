global class Batch_IE_ProcObsGWAssets_Sched implements Schedulable {
    global void execute(SchedulableContext sc) {
		/* Here I ensure a maximum of 1 record is passed to the execute method (to avoid callout timeouts)
		since several web service callouts (ie, AT&T and Coherant IE web service api calls) are made per record.
		It breaks the work up into defined size blocks that are each processed in their own transaction
		and so each get their own set of governor limits.

		Scope parameter specifies the number of records to pass into the execute method.
		Use this parameter when you have many operations for each record being passed in and are running into governor limits.
		By limiting the number of records, you are limiting the operations per transaction. This value must be greater than zero.
		If no size is specified with the optional scope parameter of Database.executeBatch, Salesforce chunks the records returned
		by the start method into batches of 200. The system then passes each batch to the execute method. Apex governor limits
		are reset for each execution of execute.

		Governor Limits:
		Total number of callouts (HTTP requests or Web services calls) in a transaction = 100
		Maximum cumulative timeout for all callouts (HTTP requests or Web services calls) in a transaction = 120 seconds */

        integer batchSize = 1;
        Batch_IE_ProcObsGWAssets bpogwa = new Batch_IE_ProcObsGWAssets();
        Database.executeBatch(bpogwa, batchSize);
    }
}