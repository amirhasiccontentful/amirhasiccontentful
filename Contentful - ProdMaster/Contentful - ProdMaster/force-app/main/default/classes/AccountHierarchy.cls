public with sharing class AccountHierarchy {

    /* Variables */ 

    private Boolean accountsLoaded = false;
    private Boolean hierarchyLoaded = false;
    private Id refId;
    private Set<String> queryFields = new Set<String>();
    private static Set<String> alwaysQueryFields = new Set<String>{ 'name', 'parentid' }; 

    /* Properties */

    private List<Account> accounts { 
        get {
            if(!accountsLoaded) {
                loadAccounts(); 
            }
            return accounts;
        }
        set;
    }

    public Integer limitAmt { get; set; }

    public String whereClause { 
        get;
        set {
            if(whereClause != value) {
                whereClause = value;
                accountsLoaded = false;
                hierarchyLoaded = false;
            }
        } 
    }

    public Node root {
        get {
            if(whereClause != null) {
                root = null;
            } else if(!hierarchyLoaded) {
                buildHierarchy();
            }
            return root;
        }
        private set;
    }

    /* Constructor */

    public AccountHierarchy(Id refId) {
        this.refId = refId;
    }

    /* Public Methods */

    public void addQueryField(String field) {
        if(field != null) {
            Boolean newField = queryFields.add(field.toLowerCase());
            if(newField) {
                accountsLoaded = false; 
                hierarchyLoaded = false;
            }   
        }
    }

    // returns by value
    public Set<String> getQueryFields() {
        return queryFields.clone();
    }

    public List<Account> toAccountList() {
        return (root == null) ? accounts : root.toAccountList();
    }

    public List<Id> toIdList() {
        List<Id> idList = new List<Id>();
        if(root == null) {
            Map<Id, Account> tempMap = new Map<Id, Account>(accounts);
            idList.addAll(tempMap.keySet());
        } else {
            idList = root.toIdList();
        }
        return idList;
    }

    public List<Node> toList() {
        return (root == null) ? new List<Node>() : root.toList();
    }

    // returns true if value present, false if value not found
    public Boolean removeQueryField(String field) {
        if(field != null) {
            field = field.toLowerCase();
            if(queryFields.contains(field)) {
                queryFields.remove(field);
                return true;
            }
        }
        return false;
    }

    public void setRefToTop() {
        refId = getTopId(refId);
    }

    /* Static Public Methods */

    public static Id getTopId(Id startId) {
        Account account = [
            select
                  parentId
                , parent.parentId
                , parent.parent.parentId
                , parent.parent.parent.parentId
                , parent.parent.parent.parent.parentId
                , parent.parent.parent.parent.parent.parentId
            from Account
            where id = :startId
        ];
        if(account.parent.parent.parent.parent.parent.parentId != null) {
            return account.parent.parent.parent.parent.parent.parentId;
        } else if(account.parent.parent.parent.parent.parentId != null) {
            return account.parent.parent.parent.parent.parentId;
        } else if(account.parent.parent.parent.parentId != null) {
            return account.parent.parent.parent.parentId;
        } else if(account.parent.parent.parentId != null) {
            return account.parent.parent.parentId;
        } else if(account.parent.parentId != null) {
            return account.parent.parentId;
        } else if(account.parentId != null) {
            return account.parentId;
        } else {
            return account.id;
        }
    }

    /* Support Methods */

    private void buildHierarchy() {
        hierarchyLoaded = true;

        // bail if we don't have any accounts to build
        if(accounts.isEmpty()) return;

        // query all accounts down the hierarchy and organize by their parent
        Map<Id, List<Node>> nodeByParent = new Map<Id, List<Node>>();
        for(Account account : accounts) {
            if(!nodeByParent.containsKey(account.parentId))
                nodeByParent.put(account.parentId, new List<Node>());
            Node accountNode = new Node(account);
            if(account.id == refId)
                root = accountNode; 
            nodeByParent.get(account.parentId).add(new Node(account));
        }

        // build the hierarchy one level at a time
        root.depth = 1;
        recursiveNodeBuild(root, nodeByParent);
    }

    private String buildQuery() {
        String selectFields = '';
        Set<String> allFields = new Set<String>();
        allFields.addAll(alwaysQueryFields);
        allFields.addAll(queryFields);
        for(String field : allFields) {
            selectFields += ', ' + field;
        }
        selectFields = selectFields.substring(2);
        String innerWhereClause = ''
            + ' where (id = \'' + refId + '\''
            + ' or parentId = \'' + refId + '\''
            + ' or parent.parentId = \'' + refId + '\''
            + ' or parent.parent.parentId = \'' + refId + '\''
            + ' or parent.parent.parent.parentId = \'' + refId + '\''
            + ' or parent.parent.parent.parent.parentId = \'' + refId + '\''
            + ' or parent.parent.parent.parent.parent.parentId = \'' + refId + '\')';

        String queryString = 'select ' + selectFields + ' from Account' + innerWhereClause;

        if(whereClause != null) {
            whereClause = whereClause.toLowerCase();
            whereClause = whereClause.replace('where', '');
            queryString += ' and (' + whereClause + ')';
        }

        queryString += ' order by name asc';

        if(limitAmt != null) {
            queryString += ' limit ' + limitAmt;
        }

        return queryString;
    }

    private void loadAccounts() {
        accountsLoaded = true;
        accounts = (List<Account>) Database.query(buildQuery());
    }

    private void recursiveNodeBuild(Node currentNode, Map<Id, List<Node>> nodesByParent) {
        if(nodesByParent.containsKey(currentNode.id)) {
            for(Node child : nodesByParent.get(currentNode.id)) {
                child.depth = currentNode.depth + 1;
                currentNode.children.add(child);
                recursiveNodeBuild(child, nodesByParent);
            }
        }
    }

    /* Inner Classs */

    public class Node {

        // variables
        public Integer depth { get; set; } // root node has depth of 1
        public String name { get; private set; }
        public String id { get; private set; }
        public Account record { get; set; }
        public List<Node> children { get; set; }

        // constructor
        public Node(Account record) {
            this.record = record;
            name = record.name;
            id = record.id;
            depth = -1; // -1 indicates depth has not been set
            children = new List<Node>();
        }

        // methods
        public List<Account> toAccountList() {
            List<Account> accountList = new Account[] { record };
            for(Node child : children) {
                accountList.addAll(child.toAccountList());
            }   
            return accountList;
        }

        public List<Id> toIdList() {
            List<Id> toIdList = new Id[] { id };
            for(Node child : children) {
                toIdList.addAll(child.toIdList());
            }
            return toIdList;
        }

        public List<Node> toList() {
            List<Node> nodeList = new Node[] { this };
            for(Node child : children) {
                nodeList.addAll(child.toList());
            }
            return nodeList;
        }
    }
}