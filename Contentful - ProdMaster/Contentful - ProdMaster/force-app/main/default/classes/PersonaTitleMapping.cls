public with sharing class PersonaTitleMapping {

	public void assignPersonaTitleMapping(String scopedObject, List<sObject> scopedRecords, Map<Id, sObject> oldRecordsMap){

		SObjectType objToken = Schema.getGlobalDescribe().get(scopedObject); 
		DescribeSObjectResult objDef = objToken.getDescribe();
		SObjectField personaFiled = objDef.fields.getMap().get('Persona__c');

		Boolean executeSetting = false;

		List<ExecuteSetting__c> personaTitleMapSetting = [SELECT Id, Name, Execute__c FROM ExecuteSetting__c WHERE Name = 'Persona Title Mapping'];

		if(personaTitleMapSetting.size()>0 && personaTitleMapSetting[0].Execute__c == true){
			executeSetting = true;
		}

		List<sObject> scopedRecordsForProcessing = new List<sObject>();

		for(sObject rec : scopedRecords){

			if ((Trigger.isUpdate && (rec.get('Title') != oldRecordsMap.get(rec.Id).get('Title') || rec.get('Job_Function__c') != oldRecordsMap.get(rec.Id).get('Job_Function__c'))) || executeSetting) {
		        scopedRecordsForProcessing.add(rec);      
		    } else if (Trigger.isInsert){
		    	scopedRecordsForProcessing.add(rec);
		    }
		}
		
		if(scopedRecordsForProcessing.size() == 0) return;
		
		List<Persona_Title_Mapping__c> personaTitleMappingList = [SELECT Id, Job_Title__c, Job_Function__c, Positive__c, Negative__c, Equals__c, Not_Equals__c, Persona__c 
																	FROM Persona_Title_Mapping__c ORDER BY Priority_Level__c];
        
		for(sObject p : scopedRecordsForProcessing){

			String pTitle = '';

			if((String) p.get('Title') != null){
				pTitle = (String) p.get('Title');
			}
			 
			String pJobFunction = (String) p.get('Job_Function__c');
			
			if(pJobFunction != null && pJobFunction!=''){

				p.put(personaFiled, 'Other');
                
				for(Persona_Title_Mapping__c ptm : personaTitleMappingList){

                    Boolean positive = false;
					Boolean negative = false;

					if(ptm.Job_Title__c != null && ptm.Job_Function__c != null) {

                    	Boolean isTitleMatched = false;
                    	Boolean isJobFunctionMatched = false;

                    	ptm.Job_Title__c = ptm.Job_Title__c.replace(';\r\n', '; ').replace(';\n', '; ');
                        for(String equalsTitle : ptm.Job_Title__c.split('; ')) {
                            if(pTitle.equalsIgnoreCase(equalsTitle)){
                                isTitleMatched = true;
                            }
                            
                        }

                        ptm.Job_Function__c = ptm.Job_Function__c.replace(';\r\n', '; ').replace(';\n', '; ');
                        for(String equalsJobFunction : ptm.Job_Function__c.split('; ')) {
                            if(pJobFunction.equalsIgnoreCase(equalsJobFunction)){
                                isJobFunctionMatched = true;
                            }
                            
                        }

                        if(isTitleMatched && isJobFunctionMatched){
                        	positive = true;
                        }
                    }

                    if(ptm.Equals__c != null) {
                    	ptm.Equals__c = ptm.Equals__c.replace(';\r\n', '; ').replace(';\n', '; ');
                        for(String equalsTitle : ptm.Equals__c.split('; ')) {
                            if(pJobFunction.equalsIgnoreCase(equalsTitle)){
                                positive = true;
                            }
                            
                        }
                    }

                    if(ptm.Positive__c != null) {
                    	ptm.Positive__c = ptm.Positive__c.replace(';\r\n', '; ').replace(';\n', '; ');
                        for(String positiveTitle : ptm.Positive__c.split('; ')) {
                            if(pJobFunction.containsIgnoreCase(positiveTitle)){
                                positive = true;
                            }
                        }
                    }
	
                    if(ptm.Negative__c != null) {
                    	ptm.Negative__c = ptm.Negative__c.replace(';\r\n', '; ').replace(';\n', '; ');
                        for(String negativeTitle : ptm.Negative__c.split('; ')) {
                            if(pJobFunction.containsIgnoreCase(negativeTitle)){
                                negative = true;
                            }
                        }
                    }
	
                    if(ptm.Not_Equals__c != null) {
                   		ptm.Not_Equals__c = ptm.Not_Equals__c.replace(';\r\n', '; ').replace(';\n', '; ');
                        for(String notEqualsTitle : ptm.Not_Equals__c.split('; ')) {
                            if(pJobFunction.equalsIgnoreCase(notEqualsTitle)){
                                negative = true;
                            }
                            
                        }
                    }

			        if(!negative && positive) 
			         	p.put(personaFiled, ptm.Persona__c);
				}
			} else {
				p.put(personaFiled, '');
			}
		}
	}
}