import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createPropertyInquiry from '@salesforce/apex/ApplicationFormCtrl.submitApplication';

export default class ApplicationFormLWC extends LightningElement {

    @track firstName = '';
    @track lastName = '';
    @track email = '';
    @track phone = '';
    @track propertyId = '';
    @track contactId = '';
    @track propertyFields = 'Name';
    @track contactFields = 'Name';

    handleInputChange(event) {
        const field = event.target.name;
        this[field] = event.target.value;
    }

    handlePropertyChange(event) {
        this.propertyId = event.detail.recordId;
    }

    handleContactChange(event) {
        this.contactId = event.detail.recordId;
    }

    handleSubmit() {
        if (this.firstName &&
            this.lastName &&
            this.email &&
            this.phone &&
            this.propertyId &&
            this.contactId) {
            const formData = {
                firstName: this.firstName,
                lastName: this.lastName,
                email: this.email,
                phone: this.phone,
                propertyId: this.propertyId,
                contactId: this.contactId
            };

            createPropertyInquiry({ inputData: formData })
                .then(() => {
                    this.showToast('Success', 'Property Inquiry created successfully!', 'success');
                    this.resetForm();
                })
                .catch(error => {
                    this.showToast('Error', error.body.message, 'error');
                });
        } else {
            this.showToast('Error', 'Please fill all required fields.', 'error');
        }
    }

    resetForm() {
        this.firstName = '';
        this.lastName = '';
        this.email = '';
        this.phone = '';
        this.propertyId = '';
        this.contactId = '';
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}