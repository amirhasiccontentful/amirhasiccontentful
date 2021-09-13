@isTest
public with sharing class CF_EmbeddLooker_Controller_Test {
 
    @isTest 
    static void testGetGenerateIframeUrl() {

        //Arrange
        CF_EmbeddLooker_Controller cntrl = new CF_EmbeddLooker_Controller();
        cntrl.embed_path = 'a';
        cntrl.looker_access_filters = '{"test":1}';
        cntrl.looker_models = 'test';
        cntrl.looker_permissions = 'test';

        //Act 

        Test.startTest();  
     
        cntrl.getGenerateIframeUrl(); 

        Test.stopTest(); 

        //Assert   
        
    }

}