public class TestPrompt {

    @InvocableMethod
    public static List<Response> testPrompt(List<Request> requests) {
        List<Response> response = new List<Response>();
        // response.add(new Response('Test'));
        return response;
    }

    public class Request {
        @InvocableVariable
        public Account location;
    }

    public class Response {
        @InvocableVariable
        public String propertyId;

    }
}