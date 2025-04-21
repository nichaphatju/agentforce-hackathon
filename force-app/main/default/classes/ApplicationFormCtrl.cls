public with sharing class ApplicationFormCtrl {

    @AuraEnabled
    public static void submitApplication(String firstName, String lastName, String email, String phone, String propertyId, String contactId){
        Lead newLead = new Lead(
            FirstName = firstName,
            LastName = lastName,
            Email = email,
            Phone = phone,
            Company = 'Property Inquiry'
        );
        insert newLead;

        Application__c application = new Application__c(
            Property__c = propertyId,
            Requested_By__c = contactId
        );
        insert application;
    }
}