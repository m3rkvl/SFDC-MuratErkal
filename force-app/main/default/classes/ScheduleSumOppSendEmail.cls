/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Schedule class to schedule the "SumOppSendEmail" batch class.
* Daily, weekly, and monthly scheduling methods are provided.
* Example: To schedule "SumOppSendEmail" on a weekly basis:
* Open developer console and call as ScheduleSumOppSendEmail.scheduleWeekly()
──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Murat Erkal   <murat-erkal@outlook.com>
* @version        1.0
* @created        01-03-2023
* @modified       01-03-2023
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

global with sharing class ScheduleSumOppSendEmail implements Schedulable {
    // Cron Expression for 10 AM daily.
    public static String CRON_EXP_DAILY = '0 0 10 * * ? *';
    // Cron Expression for 1 PM weekly.
    public static String CRON_EXP_WEEKLY = '0 0 13 ? * FRI *';
    // Cron Expression for 6 PM monthly.
    public static String CRON_EXP_MONTHLY = '0 0 18 ? * FRIL *';

    // Schedule daily.
    global static String scheduleDaily() {
        ScheduleSumOppSendEmail daily = new ScheduleSumOppSendEmail();
        return System.schedule('SumOppSendEmail Daily', CRON_EXP_DAILY, daily);
    }

    // Schedule weekly.
    global static String scheduleWeekly() {
        ScheduleSumOppSendEmail weekly = new ScheduleSumOppSendEmail();
        return System.schedule('SumOppSendEmail Weekly', CRON_EXP_WEEKLY, weekly);
    }

    // Schedule monthly.
    global static String scheduleMonthly() {
        ScheduleSumOppSendEmail monthly = new ScheduleSumOppSendEmail();
        return System.schedule('SumOppSendEmail Monthly', CRON_EXP_MONTHLY, monthly);
    }

    // execute method.
    global void execute(SchedulableContext sc) {
        SumOppSendEmail myBatch = new SumOppSendEmail();
        Id batchId = Database.executeBatch(myBatch);
    }
}