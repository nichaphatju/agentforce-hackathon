public with sharing class ComparedPropertiesPDFCtrl {
    
    public String content { get; set; }  // Send to this email

    public ComparedPropertiesPDFCtrl(){}

    public ComparedPropertiesPDFCtrl(String content){
        this.content = content;
    }

}