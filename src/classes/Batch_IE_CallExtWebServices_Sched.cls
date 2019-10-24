global class Batch_IE_CallExtWebServices_Sched implements Schedulable {
	global void execute(SchedulableContext sc) {
		/*
		The following exception:
		FATAL_ERROR|System.LimitException: Too many callouts: 101
		means that a transaction has attempted to make more than the allowed 100 callouts (Governor limit).

		---
		Exceptions that Can’t be Caught

		Some special types of built-in exceptions can’t be caught.
		Those exceptions are associated with critical situations in the Force.com platform.
		These situations require the abortion of code execution and don’t allow for execution to resume through exception handling.
		One such exception is the limit exception (System.LimitException) that the runtime throws if a governor limit
		has been exceeded, such as when the maximum number of SOQL queries issued has been exceeded.
		Other examples are exceptions thrown when assertion statements fail (through System.assert methods) or license exceptions.

		When exceptions are uncatchable, catch blocks, as well as finally blocks if any, aren’t executed.

		Solution to handle this situation:
		While processing records, monitor our query count and throw a custom exception to allow us to move the 
		processing into a batch job
   			public static void checkGovenorLimits() { 
   				if (Limits.getQueries() +  limit_queries >= Limits.getLimitQueries() ) {
   					throw new KseLimitException();
   				}
   				if(Limits.getDmlRows() + limit_dmlrows>= Limits.getLimitDmlRows()){
   					throw new KseLimitException();
   				}
			}
		---

		Here I ensure a maximum of 1 TechReadWrite or Standard record is passed to the execute method (to avoid callout timeouts)
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
		Maximum cumulative timeout for all callouts (HTTP requests or Web services calls) in a transaction = 120 seconds
		*/


		Datetime currDateTime = Datetime.now(); // current date and time in the GMT time zone

		// If the current time in GMT is between 5am and 10am then skip processing since this is when the ETL will be running!
		// This is midnight to 5am CST when CST = GMT-5 (March to Nov) => processing resumes at 5:15am
		// or 11pm to 4am when CST = GMT-6 (Nov to March) => processing resumes at 4:15am
		if ((currDateTime.hourGmt() < 5) || ((currDateTime.hourGmt() == 10) && (currDateTime.minuteGmt() >= 15))
			|| (currDateTime.hourGmt() > 10))
		{
			integer batchSize = 1;
			Batch_IE_CallExtWebServices bcews = new Batch_IE_CallExtWebServices();
			Database.executeBatch(bcews, batchSize);
		}
	}
}