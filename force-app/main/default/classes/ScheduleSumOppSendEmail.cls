global with sharing class ScheduleSumOppSendEmail implements Schedulable {
    public static String CRON_EXP_DAILY = '0 0 10 * * ? *';
    public static String CRON_EXP_WEEKLY = '0 0 13 ? * FRI *';
    public static String CRON_EXP_MONTHLY = '0 0 18 ? * FRIL *';

    global static String scheduleDaily() {
        ScheduleSumOppSendEmail daily = new ScheduleSumOppSendEmail();
        return System.schedule('SumOppSendEmail Daily', CRON_EXP_DAILY, daily);
    }

    global static String scheduleWeekly() {
        ScheduleSumOppSendEmail weekly = new ScheduleSumOppSendEmail();
        return System.schedule('SumOppSendEmail Weekly', CRON_EXP_WEEKLY, weekly);
    }

    global static String scheduleMonthly() {
        ScheduleSumOppSendEmail monthly = new ScheduleSumOppSendEmail();
        return System.schedule('SumOppSendEmail Monthly', CRON_EXP_MONTHLY, monthly);
    }

    global void execute(SchedulableContext sc) {
        SumOppSendEmail myBatch = new SumOppSendEmail();
        Id batchId = Database.executeBatch(myBatch);
    }
}