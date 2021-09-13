public with sharing class CF_EmbeddLooker_Controller {

    private String looker_host = 'contentful.eu.looker.com';
    private String looker_secret = Label.CF_Looker_SSO_Secret;
    public String embed_path {get; set;}
    public String looker_models {get; set;}
    public String looker_permissions {get; set;}
    public String looker_access_filters {get; set;}

    public class LookerInstance{
        String host {get;set;}
        String secret {get;set;}

        public LookerInstance(string host, string secret){
            this.host = host;
            this.secret = secret;
        }
    }

    public class LookerUser {
        String external_user_id {get;set;}
        String first_name {get;set;}
        String last_name {get;set;}
        String models {get;set;}
        String permissions {get;set;}
        String access_filters {get;set;}

        public LookerUser(String email, String first_name, String last_name, String[] models, String[] permissions, Object access_filters){
            this.external_user_id = json.serialize(email);
            this.first_name = json.serialize(first_name);
            this.last_name = json.serialize(last_name);
            this.models = json.serialize(models);
            this.permissions = json.serialize(permissions);
            this.access_filters = json.serialize(access_filters);
        }
    }

    public class LookerUrl {
        LookerInstance looker_instance {get;set;}
        LookerUser user {get;set;}
        String current_time {get;set;}
        String path {get;set;}
        String session_length {get;set;}
        String force_logout_login {get;set;}
        String nonce {get;set;}
        String signature {get;set;}

        public LookerUrl(LookerUser user, LookerInstance looker_instance, Integer session_length, String embed_url, Boolean force_logout_login){
            this.looker_instance = looker_instance;
            this.user = user;
            this.path = '/login/embed/' + EncodingUtil.urlEncode(embed_url, 'UTF-8');
            this.session_length = String.valueOf(session_length);
            this.force_logout_login = String.valueOf(force_logout_login);
        }

        private String generateRandomString(Integer len) {
            final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
            String randStr = '';
            while (randStr.length() < len) {
               Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
               randStr += chars.substring(idx, idx+1);
            }
            return randStr;  
        }

        private String sign(){
            String sign = '';
            sign += this.looker_instance.host   + '\n';
            sign += this.path                   + '\n';
            sign += this.nonce                  + '\n';
            sign += this.current_time           + '\n';
            sign += this.session_length         + '\n';
            sign += this.user.external_user_id  + '\n';
            sign += this.user.permissions       + '\n';
            sign += this.user.models            + '\n';
            sign += this.user.access_filters;
            Blob encrypted_sign = Crypto.generateMac('HMacSHA1',Blob.valueOf(sign), Blob.valueOf(this.looker_instance.secret)); 
            return EncodingUtil.base64Encode(encrypted_sign); // returns the Sign In signature 
        } 

        public String generateUrl(){
            this.nonce = json.serialize(generateRandomString(16));
            this.current_time = json.serialize(datetime.now().getTime()/1000);
            this.signature = this.sign();
            string query = '';
            query += 'nonce=' + EncodingUtil.urlEncode(this.nonce,'UTF-8');
            query += '&time=' + EncodingUtil.urlEncode(this.current_time,'UTF-8');
            query += '&session_length=' + EncodingUtil.urlEncode(this.session_length,'UTF-8');
            query += '&external_user_id=' + EncodingUtil.urlEncode(this.user.external_user_id,'UTF-8');
            query += '&permissions=' + EncodingUtil.urlEncode(this.user.permissions,'UTF-8');
            query += '&models=' + EncodingUtil.urlEncode(this.user.models,'UTF-8');
            query += '&access_filters=' + EncodingUtil.urlEncode(this.user.access_filters,'UTF-8');
            query += '&signature=' + EncodingUtil.urlEncode(this.signature,'UTF-8');
            query += '&first_name=' + EncodingUtil.urlEncode(this.user.first_name,'UTF-8');
            query += '&last_name=' + EncodingUtil.urlEncode(this.user.last_name,'UTF-8');
            query += '&force_logout_login=' + EncodingUtil.urlEncode(this.force_logout_login,'UTF-8');
            return 'https://' + this.looker_instance.host + this.path + '?' + query;
        }
    }

    public String getGenerateIframeUrl() {
        LookerInstance looker = new LookerInstance(this.looker_host, this.looker_secret);
        LookerUser user = new LookerUser(UserInfo.getUserEmail(), UserInfo.getFirstName(), UserInfo.getLastName(), 
                                             this.looker_models.split(','), this.looker_permissions.split(','), 
                                             json.deserializeUntyped(this.looker_access_filters.replaceAll('\'', '"')));
        LookerUrl url = new LookerUrl(user, looker, (24 * 60 * 60), this.embed_path, false); //sesion lenght = 1 day
        return url.generateUrl();
    }
 
}