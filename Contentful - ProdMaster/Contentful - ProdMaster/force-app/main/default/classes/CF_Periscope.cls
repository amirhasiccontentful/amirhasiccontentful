public with sharing class CF_Periscope {
    public static String dashboardUrlForOrganization(CF_Organization__c org) {
		JSONGenerator generator = JSON.createGenerator(true);
		generator.writeStartObject();

		generator.writeNumberField('dashboard', 21564);
		generator.writeStringField('embed', 'v2');
		generator.writeStringField('border', 'off');
		//generator.writeStringField('tv_mode_frame', 'true');
		//"aggregation": "daily"
		
		generator.writeFieldName('filters');
		generator.writeStartArray();
	
			generator.writeStartObject();

    		generator.writeStringField('name', 'Organization');
    		generator.writeStringField('value', String.valueOf(org.gk_id__c)); 		
			
			generator.writeEndObject();
		
		generator.writeEndArray();
		
		generator.writeEndObject();

		String d = generator.getAsString();
    	
    	return urlWithSignatureForData(d);
    }
    
    public static String urlWithSignatureForData(String json) {
    	String baseUrl = '/api/embedded_dashboard?';
    	String urlEncodedJson = EncodingUtil.urlEncode(json,'UTF-8');
		String urlWithoutSignature = baseUrl + 'data=' + urlEncodedJson;
		String signature = '';
		
		Periscope__c p = Periscope__c.getOrgDefaults();
    	String signatureKey = p.key__c;
    	
    	if (signatureKey != null) {	
	    	Blob blobSignature = Crypto.generateMac('hmacSHA256', Blob.valueOf(urlWithoutSignature), Blob.valueOf(signatureKey));
	    	signature = EncodingUtil.convertToHex(blobSignature);    		
    	}
    	
		String url = 'https://www.periscopedata.com' + urlWithoutSignature + '&signature=' + signature;	
	    return url;
    }
    
}


//{
//    "dashboard": 7863,
//    "embed": "v2",
//    "filters": [{"name": "Filter1", "value": "value1"}, {"name": "Filter2", "value": "1234"}]
//}