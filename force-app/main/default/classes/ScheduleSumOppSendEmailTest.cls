  /**
  * ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * Test class for the ScheduleSumOppSendEmail schedule class
  * Asserts that there are no async jobs,
  * Schedules with the class 3 times, using three methods defined
  in the class
  * Asserts that the Cron Expressions are all accurate,
  * Asserts that 3 ScheduledApex jobs are enqueued, and that
  their class name matches.
  ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Murat Erkal   <murat-erkal@outlook.com>
* @version        1.0
* @created        01-03-2023
* @modified       01-03-2023
  ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */

@isTest
private class ScheduleSumOppSendEmailTest {
    public static String CRON_EXP_DAILY = '0 0 10 * * ? *';
    public static String CRON_EXP_WEEKLY = '0 0 13 ? * FRI *';
    public static String CRON_EXP_MONTHLY = '0 0 18 ? * FRIL *';

    @isTest static void testScheduledJob() {
        List<AsyncApexJob> jobsBefore = [SELECT Id, ApexClassID, ApexClass.Name, Status, JobType FROM AsyncApexJob];
        
        System.assertEquals(0, jobsBefore.size(), 'not expecting any asyncjobs');

        Test.startTest();
        String jobIdDaily = ScheduleSumOppSendEmail.scheduleDaily();
        String jobIdWeekly = ScheduleSumOppSendEmail.scheduleWeekly();
        String jobIdMonthly = ScheduleSumOppSendEmail.scheduleMonthly();

        // Verify the cron expressions are valid
        CronTrigger ctDaily = [SELECT Id, CronExpression FROM CronTrigger WHERE Id = :jobIdDaily];
        CronTrigger ctWeekly = [SELECT Id, CronExpression FROM CronTrigger WHERE Id = :jobIdWeekly];
        CronTrigger ctMonthly = [SELECT Id, CronExpression FROM CronTrigger WHERE Id = :jobIdMonthly];

        System.assertEquals(CRON_EXP_DAILY, ctDaily.CronExpression);
        System.assertEquals(CRON_EXP_WEEKLY, ctWeekly.CronExpression);
        System.assertEquals(CRON_EXP_MONTHLY, ctMonthly.CronExpression);

        Test.stopTest();

       // Check schedulables are in the job list
        List<AsyncApexJob> jobsScheduled = [SELECT Id, ApexClassID, ApexClass.Name, Status, JobType FROM AsyncApexJob WHERE JobType = 'ScheduledApex'];
        System.assertEquals(3, jobsScheduled.size(), 'expecting one scheduled job');
        for (Integer i = 0; i < 3; i++) {
            System.assertEquals('ScheduleSumOppSendEmail', jobsScheduled[i].ApexClass.Name, 'expecting specific scheduled job');
        }

        
    }
}