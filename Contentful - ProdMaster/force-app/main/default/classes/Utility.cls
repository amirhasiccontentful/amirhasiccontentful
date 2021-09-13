public with sharing class Utility {
    private static boolean run = true;
    public static boolean runOnce(){
        if(run){
            run=false;
            return true;
        } else {
            return run;
        }
    }

    private static Integer five = 8;
    public static boolean run5(){
        if(five > 0){
            five -= 1;
            return true;
        } else {
            return false;
        }
    }

    public static boolean IsExecutedFromCFUserOrOrg = false;
}