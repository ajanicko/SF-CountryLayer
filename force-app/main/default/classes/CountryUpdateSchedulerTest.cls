@isTest
private class CountryUpdateSchedulerTest {
    @isTest
    static void testScheduleJob() {
        Test.setMock(HttpCalloutMock.class, new CountryServiceTest.MockHttpResponseGenerator());
        // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        String cron = '0 6 * * * ?';

        Test.startTest();
        String jobId = System.schedule('Scheduler Test', cron, new CountryUpdateScheduler());
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM CronTrigger WHERE id = :jobId], 'A job should be scheduled');
    }
}
