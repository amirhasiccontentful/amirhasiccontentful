// curl -X POST --data-urlencode 'payload={"channel": "#biz-salesforce-bot", "text": "message"}' https://hooks.slack.com/services/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
 
public with sharing class CF_Slack {
	
	/* Commented Out On 15th of May so that it does not send messages anymore to Slack START
	public static void postMessageFuture(String channel, String message) { // only async callouts allowed in triggers
		//postMessage(channel, message); Commented Out On 15th of May so that it does not send messages anymore to Slack
	}
	
	
	public static void postMessage(String channel, String message) { 
		if (Test.isRunningTest()) {
			return;
		}
		
		HttpRequest req = new HttpRequest();
		HttpResponse res = new HttpResponse();
		Http http = new Http();
		
		if (CF_Slack.isSandbox()) {
			message = '[Sandbox] ' + message;
			channel = '#biz-bot-sandbox';	
		}		
		
		// if channel ==
		
		String body = 'payload={"channel": "' + channel + '", "text": "' + message + '"}';
		// System.debug('Body: ' + body);
		
		// Slack Webhook Integration
		
		if (channel == '#biz-bot-leads') {
			req.setEndpoint('https://hooks.slack.com/services/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');	
		}
		else if (channel == '#biz-bot-subscriptions' ) {
			req.setEndpoint('https://hooks.slack.com/services/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');
		}
		else if (channel == '#biz-bot-sandbox') {
			req.setEndpoint('https://hooks.slack.com/services/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');
		}
		
		
		req.setMethod('POST');
		req.setCompressed(false);
		req.setBody(body);
		req.setHeader('Content-Type', 'application/x-www-form-urlencoded');  
		
		//try {
		    res = http.send(req);
		//} catch(System.CalloutException e) {
		//    System.debug('Callout error: '+ e);
		//}		
	}
	Commented Out On 15th of May so that it does not send messages anymore to Slack END */

	public static String objectUrl(id objectId) {
		return URL.getSalesforceBaseUrl().toExternalForm() + '/' + objectId;
	} 

	
	public static String objectLink(id objectId, String text) {
		String result = '<' + objectUrl(objectId) + '|' + text + '>';
		return result;
	}
	
	
    public Static Boolean isSandbox(){

        String host = URL.getSalesforceBaseUrl().getHost();
        String server = host.substring(0,host.indexOf('.'));

        // It's easiest to check for 'my domain' sandboxes first 
        // even though that will be rare
        if(server.contains('--'))
            return true;

        // tapp0 is a unique "non-cs" server so we check it now
        if(server == 'tapp0')
            return true;

        // If server is 'cs' followed by a number it's a sandbox
        if(server.length()>2){
            if(server.substring(0,2)=='cs'){
                try{
                    Integer.valueOf(server.substring(2,server.length()));
                }
                catch(exception e){
                    //started with cs, but not followed by a number
                    return false;
                }

                //cs followed by a number, that's a hit
                return true;
            }
        }

        // If we made it here it's a production box
        return false;
    }	
}