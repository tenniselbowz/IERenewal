global class Batch_Sync_IE_Unit_Schedular implements Schedulable {
  
  
  global void execute(SchedulableContext SC) 
  {
	Datetime currDateTime = Datetime.now(); // current date and time in the GMT time zone

	// If the current time in GMT is between 5am and 10am then skip processing since this is when the ETL will be running!
	// This is midnight to 5am CST when CST = GMT-5 (March to Nov) => processing resumes at 6:07am
	// or 11pm to 4am when CST = GMT-6 (Nov to March) => processing resumes at 5:07am
	if ((currDateTime.hourGmt() < 5) || (currDateTime.hourGmt() > 10))
	{
		integer bsize = 1;
    
		Database.executeBatch(new Batch_Sync_IE_Unit('Pending'), bsize);
	}

  }

}