public with sharing class SearchProperties {

    @InvocableMethod
    public static List<Response> searchProperties(List<Request> requests) {

        String searchOppRecType = requests[0].oppType == 'Rent' ? 'Rent_Property' : 'Sell_Property';

        List<Opportunity> opportunities = [SELECT Id, Name, Amount, CloseDate, StageName, Type, 
                                                Property__r.Property_Type__c, 
                                                Property__r.Current_Value__c, 
                                                Property__r.Bedrooms__c, 
                                                Property__r.Bathrooms__c, 
                                                Property__r.Number_of_Parking_Slots__c,
                                                Property__r.Location__c, 
                                                Property__r.Location__City__s, 
                                                Property__r.Location__StateCode__s, 
                                                Property__r.Location__Street__s, 
                                                Property__r.Location__PostalCode__s, 
                                                Property__r.Name, 
                                                Property__r.Id, 
                                                Property__r.Features__c, 
                                                Property__r.Additional_Description__c, 
                                                Property__r.Property_Link__c
                FROM Opportunity 
                WHERE RecordType.DeveloperName = :searchOppRecType
                AND IsClosed = false
                AND Property__r.Status__c = 'Available'];

        List<Property__c> propResults = new List<Property__c>();

        List<PropertyResponse> properties = new List<PropertyResponse>();
        for (Opportunity opp : opportunities) {
            properties.add(new PropertyResponse(opp.Property__r));

            propResults.add(opp.Property__r);
        }

        List<Response> responses = new List<Response>();

        Response res = new Response();
        res.prompt = JSON.serialize(propResults);
        responses.add(res);

        return responses;
    }

    /** Variable names have to match with Prompt template (Case-sensitive) */
    public class Request {
        @InvocableVariable(required=true)
        public String oppType;
    }
    
    /** The method output has a List<Response> type containing a single string member named Prompt that’s annotated with InvocableVariable. */
    public class Response {
        @InvocableVariable
        public String Prompt;
    }
    

    public class PropertyResponse {
        @InvocableVariable
        public String propertyId;
        @InvocableVariable
        public String propertyName;
        @InvocableVariable
        public String propertyLocation;
        @InvocableVariable
        public String propertyType;
        @InvocableVariable
        public String propertyPrice;
        @InvocableVariable
        public Integer bedrooms;
        @InvocableVariable
        public Integer bathrooms;
        @InvocableVariable
        public Integer parkingSlots;
        @InvocableVariable
        public String features;
        @InvocableVariable
        public String propertyLink;

        public PropertyResponse(Property__c property) {
            this.propertyId = property.Id;
            this.propertyName = property.Name;
            this.propertyLocation = property.Location__Street__s + ',' + property.Location__City__s + ', ' + property.Location__StateCode__s + ', ' + property.Location__PostalCode__s;
            this.propertyType = property.Property_Type__c;
            this.propertyPrice = property.Current_Value__c;
            this.bedrooms = (Integer) property.Bedrooms__c;
            this.bathrooms = (Integer) property.Bathrooms__c;
            this.parkingSlots = (Integer) property.Number_of_Parking_Slots__c;
            this.features = property.Features__c;
            this.propertyLink = property.Property_Link__c;
        }
    }

}