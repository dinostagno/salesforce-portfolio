import { LightningElement, track } from 'lwc';
import callExternalService from '@salesforce/apex/IntegrationLwcController.callExternalService';

export default class IntegrationCallout extends LightningElement {

    @track loading = false;
    @track response;
    @track error;

    async handleCallout() {
        this.loading = true;
        this.response = null;
        this.error = null;

        try {
            const result = await callExternalService();

            if (result.success) {
                this.response = result;
            } else {
                this.error = result.errorMessage || 'Error desconocido';
            }

        } catch (e) {
            this.error = e.body?.message || e.message;
        } finally {
            this.loading = false;
        }
    }
}
