@isTest(seeAllData = false)
public class n26_SendSurveyNotification_Test {
    
    @testSetup
    public static void createData(){ // creating test data
        List<Contact> cList = new List<Contact>();
        for(Integer i=0;i<10;i++){
            Contact c = new Contact();
            c.FirstName = 'Ranjith '+i;
            c.LastName = 'K';
            c.Email = 'kondabathiniranjithkumaar.ran@gmail.com';
            if(Math.mod(i,2)==0)
                c.Language__c = 'en';
            else
                c.Language__c = 'de';
            c.Survey_Date__c = System.Date.today().addDays(-1);
            cList.add(c);
        }
        insert cList;
    }
    
    public static testMethod void testBatchJob(){
        
        List<Contact> listContacts = [select Id from Contact where Email!=null and Survey_Date__c < TODAY];
        system.assertEquals(10, listContacts.size());
        
        Test.startTest();
        	String CRON_EXP = '0 0 0 15 3 ? *';
        	String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new n26_SendSurveyNotification_Batch());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
        
        listContacts = [select Id from Contact where Email!=null and Survey_Date__c < TODAY];
        system.assertEquals(0, listContacts.size());
        
        
    }
}