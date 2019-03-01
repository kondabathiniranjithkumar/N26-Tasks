global class n26_SendSurveyNotification_Batch implements Database.Batchable<sObject>, Schedulable
{    
    public n26_SendSurveyNotification_Batch()
    {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {                   
        // set the contacts limit to 5000 as the daily Email Limit is 5000
        return Database.getQueryLocator([select Id,FirstName,Language__c,Survey_Date__c,Email from Contact where Email!=null and Survey_Date__c < TODAY limit 5000]);        
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> listContacts) 
    {    
        List<Messaging.SingleEmailMessage> listMessages = new List<Messaging.SingleEmailMessage>();
        String germanNotificationMessage;
        for(Contact c: listContacts){
            List<String> toAddresses = new List<String>();
            toAddresses.add(c.Email);
            
            // Initialize the email
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);  
            mail.setReplyTo('noreply@salesforce.com');
            mail.setSenderDisplayName('N26 Survey'); 
            mail.setSubject('N26 Survey Link');  
            mail.setPlainTextBody('');
            
            String htmlString = String.valueOf(System.Label.N26_Survey_Notification);
            // get the text based on the contact language
            if(c.Language__c.equals('de')){
                if(germanNotificationMessage == null){
                    germanNotificationMessage = getLabelValueInGerman();
                }
                htmlString = germanNotificationMessage;
            }
            
            // set body for the email
            mail.setHtmlBody('Hey '+c.FirstName+', '+htmlString + ': '+'<a href="http://n26.com/survey/'+c.Id+'">http://n26.com/survey/'+c.Id+'</a>');            
            listMessages.add(mail);            
        }
        
        System.debug('You have ' + Limits.getEmailInvocations() + ' email calls out of ' + Limits.getLimitEmailInvocations() + ' allowed');
        
        if(Limits.getEmailInvocations() > 0){ // check if there are any Email invocations available
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(listMessages);
            List<Contact> listContactsToUpdate = new List<Contact>();                
            
            for(Integer i=0;i<results.size();i++){
                Messaging.SendEmailResult result = results[i];
                if(result.isSuccess()){ // update the contact records which were successful in sending the email
                    Contact contactToUpdate = listContacts[i];
                    contactToUpdate.Survey_Date__c = null;
                    listContactsToUpdate.add(contactToUpdate);
                }
            }        
            
            if(listContactsToUpdate.size()>0){
                Database.update(listContactsToUpdate,false);
            }
        }
        
        
    }
    
    global void execute(SchedulableContext sc) { // triggering the batch job from the scheduler
        n26_SendSurveyNotification_Batch b = new n26_SendSurveyNotification_Batch(); 
        database.executebatch(b);
    }
    
    global void finish(Database.BatchableContext ctx) 
    {
        SYSTEM.DEBUG('Limits.getHeapSize IN FINISH '+Limits.getHeapSize());
        SYSTEM.DEBUG('Limits.getLimitHeapSize IN FINISH '+Limits.getLimitHeapSize());
        SYSTEM.DEBUG('Batch finish method '+ctx.getJobId());
        system.debug('Email Limits: '+ Limits.getEmailInvocations());
    }
    
    public static String getLabelValueInGerman(){ // retrieve custom label by loading visualforce page with specified language
        Pagereference r = Page.n26_LanguagePage;
        r.getParameters().put('languageParam', 'de');
        r.getParameters().put('labelParam', 'N26_Survey_Notification');                     
        return Test.isRunningTest()?'Bitte füllen Sie die Umfrage aus':r.getContent().toString();
    }
}