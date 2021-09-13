public class DocuSignServiceOrderExt { 
	public Id quoteId { get; set; }
	public zqu__Quote__c quote { get; set; } 

	public DocuSignServiceOrderExt(ApexPages.StandardController controller) {
		controller.addFields(new List<String>{'Name', 'zqu__Opportunity__c', 'zqu__SoldToContact__r.Email', 'zqu__SoldToContact__r.FirstName', 'zqu__SoldToContact__r.LastName', 'Bill_From__c'});
		this.quoteId = controller.getId();
		this.quote = (zqu__Quote__c)controller.getRecord();
	}

	public PageReference saveServiceOrderAndOpenWithDocuSign(){
		// Delete old version of documents
		Set<Id> documentIds = new Set<Id>();
		List<ContentDocumentLink> existingDocLinks =  new List<ContentDocumentLink>([SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :this.quoteId]);
		for(ContentDocumentLink cdl : existingDocLinks) {
			documentIds.add(cdl.ContentDocumentId);
		}
		List<ContentDocument> existingContent = [SELECT Id FROM ContentDocument WHERE Id IN :documentIds];
		if(!existingContent.IsEmpty()) {
			try {
				delete existingContent;
			} catch(Exception e){}
		}

	  	PageReference pdf = Page.ServiceOrderPDF;
    	// add parent id to the parameters for standardcontroller
    	pdf.getParameters().put('id', this.quoteId);

    	Blob body;

    	try { 
    		body = pdf.getContent();
    	} catch (VisualforceException e) {
    		body = Blob.valueOf('There was an issue while generating Service Order. Please contact your Salesforce Administrator!');
    	}

    	ContentVersion content = new ContentVersion();
        content.versionData = body;
        content.title = quote.Name;
        content.pathOnClient = quote.Name + '.pdf';
        insert content;

		ContentVersion contentDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :content.Id LIMIT 1];

	    ContentDocumentLink docLink = new ContentDocumentLink();
		docLink.ContentDocumentId = contentDocId.ContentDocumentId;
		docLink.LinkedEntityId = this.quoteId;
		docLink.ShareType = 'I';
		docLink.Visibility = 'AllUsers';
		insert docLink;

		String contentful = quote.Bill_From__c == 'Contentful Inc.' ? Label.Inc_Signatory : Label.GmbH_Signatory;


		// Generate DocuSign envelope throygh link
	  	return new PageReference('https://contentful.my.salesforce.com/apex/dsfs__DocuSign_CreateEnvelope?DSEID=0&SourceID=' + quote.zqu__Opportunity__c  +  '&LA=0' + 
	  	'&RQD=' + quote.zqu__Opportunity__c + 
	  	'&RC=' + content.Id + '&CRL=' + contentful + 
	  	'Email~'+ quote.zqu__SoldToContact__r.Email + ';FirstName~' + quote.zqu__SoldToContact__r.FirstName + 
	  	';LastName~' + quote.zqu__SoldToContact__r.LastName + ';Role~Client;RoutingOrder~2,' +
	  	'Email~contracts@contentful.com;FirstName~Contract;LastName~Manager;Role~Contentful Contract Manager;' + 
	  	'RoutingOrder~3&CCRM=Client~Client;Contentful~Contentful;Contentful Contract Manager~Contentful Contract Manager&' + 
	  	'CCTM=Client~Signer;Contentful~Signer;Contentful Contract Manager~Carbon Copy&OCO=Tag');
	}
}