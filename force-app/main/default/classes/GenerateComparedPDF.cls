public with sharing class GenerateComparedPDF {

    @InvocableMethod(label='Generate Compared PDF' description='Create a PDF file comparing properties based on the provided JSON array of Property__c objects.' category='Property Management')
    public static List<Response> generateComparedPDF(List<Request> requests) {

        String propertiesStr = requests[0].properties;

        List<Property__c> properties = (List<Property__c>)JSON.deserialize(propertiesStr, List<Property__c>.class);
        // Call the existing method to generate the PDF
        Id pdfId = generatePDF(properties);
        
        // Return the PDF ID as output
        String output = URL.getOrgDomainURL().toExternalForm() + '/' + pdfId;
        Response resp = new Response();
        resp.Prompt = output;

        return new List<Response>{resp};
    }

    public static Id generatePDF(List<Property__c> properties) {
        // Generate the PDF content
        String pdfContent = '<html><body>';
        pdfContent += '<table border="1"><tr><th>Location</th><th>Price</th><th>Bedrooms</th><th>Bathrooms</th><th>Parking Slots</th></tr>';
        for (Property__c prop : properties) {
            pdfContent += '<tr><td>' + prop.Location__c + '</td><td>' + prop.Current_Value__c + '</td><td>' + prop.Bedrooms__c + '</td><td>' + prop.Bathrooms__c + '</td><td>' + prop.Number_of_Parking_Slots__c + '</td></tr>';
        }
        pdfContent += '</table></body></html>';

        return uploadPDF('ComparedProperties', pdfContent);
    }

    public static Id uploadPDF(String fileName, String pdfContent) {

        Blob reportPdf;
        PageReference pdfPage = new PageReference(Site.getBaseUrl() + '/apex/ComparedPropertiesPDFPage?content=' + pdfContent);
        pdfPage.getParameters().put('content', pdfContent);

        // String htmlContent = pdfPage.getContent().toString();

        try {
            reportPdf = pdfPage.getContentAsPDF();
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            reportPdf = Blob.valueOf(e.getMessage());
        }

        // Create the ContentVersion object
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S'; // Specify that the file is in the database
        cv.VersionData = reportPdf; // Set the PDF content
        cv.Title = fileName; // Set the title of the PDF
        cv.PathOnClient = fileName + '.pdf'; // Set the file name

        // Insert the ContentVersion
        insert cv;

        // Retrieve the ContentDocumentId
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

        // Set the sharing access
        ContentDistribution cd = new ContentDistribution();
        cd.Name = fileName;
        cd.ContentVersionId = cv.id;
        cd.PreferencesAllowViewInBrowser= true;
        cd.PreferencesLinkLatestVersion=true;
        cd.PreferencesNotifyOnVisit=false;
        cd.PreferencesPasswordRequired=false;
        cd.PreferencesAllowOriginalDownload= true;
        insert cd;

        // Return the ContentDocumentId
        return contentDocumentId;
  }


    /** Variable names have to match with Prompt template (Case-sensitive) */
    public class Request {
        @InvocableVariable(required=true)
        public String properties;
    }

    public class Response {
        @InvocableVariable
        public String Prompt;
    }


}