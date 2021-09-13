public with sharing class CF_Base {
	public static Boolean runOnce = true;
	
	public static String filterDomains(String domain) {
		if (CF_Base.isPublicDomain(domain) || domain == null || domain == '') {
			return 'thisdomainwillnotbefound.com';
		}
		else {
			return domain;
		}
	}
	
	public static String filterCompanyName(String name) {
		if (CF_Base.isGenericCompanyName(name) || name == null) {
			return 'thisnamewillnotbefound';
		}
		else {
			return name;
		}		
	}
	
	public static boolean isGenericCompanyName(String name) {
		String normalized = name.toLowerCase();
		
		Set<String> genericCompanyNames = new Set<String>();
		genericCompanyNames.add('');
		genericCompanyNames.add('none');
		genericCompanyNames.add('test');
		genericCompanyNames.add('contentful');
		genericCompanyNames.add('-');	
		
		if (genericCompanyNames.contains(normalized)) {
			return true;
		}
		else {
			return false;
		}			
	}
	
	public static boolean isPublicDomain(String domain) {
		Set<String> publicEmailDomains = new Set<String>();
		publicEmailDomains.add('gmail.com');
		publicEmailDomains.add('yahoo.com');
		publicEmailDomains.add('hotmail.com');
		publicEmailDomains.add('me.com');
		//publicEmailDomains.add('contentful.com');
		publicEmailDomains.add('outlook.com');
		publicEmailDomains.add('googlemail.com');
		publicEmailDomains.add('live.com');
		publicEmailDomains.add('gmx.de');
		publicEmailDomains.add('mailinator.com');
		publicEmailDomains.add('icloud.com');
		publicEmailDomains.add('mac.com');
		publicEmailDomains.add('aol.com');
		publicEmailDomains.add('yahoo.co.uk');
		publicEmailDomains.add('web.de');
		publicEmailDomains.add('msn.com');
		publicEmailDomains.add('mail.ru');
		publicEmailDomains.add('hotmail.fr');
		publicEmailDomains.add('qq.com');
		publicEmailDomains.add('hotmail.co.uk');
		publicEmailDomains.add('ymail.com');
		publicEmailDomains.add('yahoo.fr');
		publicEmailDomains.add('yahoo.com.br');
		publicEmailDomains.add('yahoo.de');
		publicEmailDomains.add('gmx.ch');
		publicEmailDomains.add('yopmail.com');
		publicEmailDomains.add('yahoo.es');
		publicEmailDomains.add('yahoo.co.in');	
		
		if (publicEmailDomains.contains(domain)) {
			return true;
		}
		else {
			return false;
		}
	}
	
	public static Task taskForOrder(String subject, String description, String team, Order ord, id ownerId, Date activityDate) {
        Task t = new Task(); 
		t.RecordTypeId = [Select Id, SobjectType, Name From RecordType Where Name ='Todo' and SobjectType ='Task'  limit 1].Id;        
        
        t.OwnerId = ownerId;
        
        
        t.Subject = subject;
        t.Description = description;
        t.WhatId = ord.id;
        t.Team__c = team;
        
        t.Priority = 'Normal';
        t.Status = 'Open';
        
        t.ActivityDate = activityDate;
        
		return t;
	}		
	
	public static String formatCurrency(String cur, Decimal i) {
		String result = cur + ' ';
		
    	if (i == null) {
    		 result = result + '0.00';
    	}
    	else {
	    	i = Decimal.valueOf(Math.roundToLong(i * 100)) / 100;
	    	String s = (i.setScale(2) + (i >= 0 ? 0.001 : -0.001)).format();
	    	result = result + s.substring(0, s.length() - 1);    		
    	}

		return result;
	}
	
	//Commented out due to Ticket BIZSYS-112
	/*
	public static void sendOwnerChangeEmails(String objectType, List<sObject> oldObjects, List<sObject> newObjects, List<String> fieldNames) {
		
		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		Schema.SObjectType objectSchema = schemaMap.get(objectType);
		Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();
		
		OrgWideEmailAddress owa = [select id, DisplayName, Address from OrgWideEmailAddress where address = 'salesforce@contentful.com' limit 1];
		
		Set<Id> userIds = new Set<Id>();
		
		List<sObject> allObjects = new List<sObject>();
		if (oldObjects != null) {
			allObjects.addAll(oldObjects);	
		}
		
		allObjects.addAll(newObjects);
		
		for (sObject o : allObjects) {
			for (String key : fieldNames) {
				Id userId = (Id)o.get(key);
				if (userId != null) {
					userIds.add(userId);	
				}
			}
		}
		
		List<User> users = [SELECT id, name, email FROM User WHERE id IN :userIds];
		
		Map<Id, User> idToUser = new Map<Id, User>();
		for (User u : users) {
			idToUser.put(u.id, u); 
		}			
		
		Integer i = 0;
		
		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
		
		for (sObject obj : newObjects) {
			Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
			Set<String> sendingTo = new Set<String>();
			String name = null;
			
			if (objectType == 'Lead') {
				name = obj.get('firstname') + ' ' + obj.get('lastname') + ' (' + obj.get('company') + ')';
			}
			else {
				name = (String)obj.get('name');	
			}			
			
			String subject = objectType + ' key owners changed: ' + name;
			String body = '** KEY OWNERS CHANGED **\n\n';
			
			body += 'Name: ' + name + '\n\n';
						
			sObject oldObj = null;
			if (oldObjects != null) {
				oldObj = oldObjects[i];	
			}
			
			Integer changes = 0;
			
			for (String key : fieldNames) {
				String label = fieldMap.get(key).getDescribe().getLabel();
				
				body += label + ': ';
				
				id newUserId = (Id)obj.get(key);
				User newUser = (User)idToUser.get(newUserId);
				
				id oldUserId = null;
				User oldUser = null;
				
				if (oldObj != null) {
					oldUserId = (Id)oldObj.get(key);
					oldUser = (User)idToUser.get(oldUserId);					
				}
				 
				if (newUser != null) {
					body += newUser.name;
					
					if (newUser.email != 'salesforce-bot@contentful.com' && newUser.id != UserInfo.getUserId()) {
						sendingTo.add(newUser.email);	
					}
				}
				else {
					body += '(blank)';
				}
				
				
				if (oldUser != newUser) {
					if (oldUser != null) {
						body += ' [ before: ' + oldUser.name + ' ]';
						
						if (oldUser.email != 'salesforce-bot@contentful.com' && oldUser.id != UserInfo.getUserId()) {
							sendingTo.add(oldUser.email);
						}	
					}
					else {
						body +=  ' [ before: blank ]';
					}
					
					changes += 1;
				}
				
				body += '\n';
			}		
			
			body += '\n\n';
			body += 'Link: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + obj.id;
			
			
			email.setToAddresses(new List<String>(sendingTo));
			email.setSubject(subject);
			email.setPlainTextBody(body);
			email.setOrgWideEmailAddressId(owa.id);
  			email.setBccSender(true);
  			email.setBccAddresses(new List<String>{'email-bcc-receiver@contentful.com'});			
			
			i += 1;
			
			if (changes > 0 && sendingTo.size() > 0) {
				emails.add(email);	
			}
		}
		try {
			Messaging.sendEmail(emails);	
		} catch (Exception e) { }
	}
	*/
	
}