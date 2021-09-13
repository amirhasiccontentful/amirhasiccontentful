public with sharing class CF_Intercom {
	@future(callout=true)
	public static void updateLeadFuture(id leadId) { // only async callouts allowed in triggers
		updateLead(leadId);
	}
	
	public static void updateLead(id leadId) { 
		if (CF_Slack.isSandbox()) {
			return;
		}
		
		if (Test.isRunningTest()) {
			return;
		}		
		
		Lead l = [SELECT id, classification__c, leadsource, CF_User__r.gk_email__c, CF_User__r.gk_key__c FROM Lead WHERE id = :leadId LIMIT 1][0];
		HttpRequest req = new HttpRequest();
		HttpResponse res = new HttpResponse();
		Http http = new Http();
		
     	String username = 'k62e90m5';
     	String password = '67423c8e177b1490eb86323b7d5b4c2ae468a067';
  
     	Blob headerValue = Blob.valueOf(username + ':' + password);
     	String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
     	
     	req.setHeader('Authorization', authorizationHeader);

		String body = CF_Intercom.leadToString(l);
		
		//System.debug('Body: ' + body);
		
		req.setEndpoint('https://api.intercom.io/users');
		
		req.setMethod('POST');
		req.setHeader('Content-Type', 'application/json'); 
		req.setHeader('Accept', 'application/json');  
		
		req.setCompressed(false);
		req.setBody(body);
		
				
		//try {
		    res = http.send(req);

		//} catch(System.CalloutException e) {
		//    System.debug('Callout error: '+ e);
		//}		
	}
	
	public static String leadToString(Lead l) {
		JSONGenerator gen = JSON.createGenerator(true);
		gen.writeStartObject();
		
		if (l.CF_User__r != null) {
			gen.writeStringField('user_id', l.CF_User__r.gk_key__c);	
		}
				
		gen.writeFieldName('custom_attributes');
		gen.writeStartObject();
		
		if (l.leadsource != null) {
			gen.writeObjectField('sfdc_lead_source', l.leadsource);	
		}				
		       
		//if (l.first_class__c == true) {
		//	gen.writeObjectField('sfdc_first_class', true);
		//}
		//else {
		//	gen.writeObjectField('sfdc_first_class', false);
		//}
		
		if (l.classification__c != null) {
			gen.writeObjectField('sfdc_classification', l.classification__c);	
		}	
		else {
			gen.writeObjectField('sfdc_classification', ''); 
		}
		
		gen.writeEndObject();
		
		return gen.getAsString();
	}
}