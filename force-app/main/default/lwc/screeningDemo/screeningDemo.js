import { LightningElement, wire, api, track } from 'lwc';
import getScreenings from '@salesforce/apex/scrn_ScreeningsMetadataController.getScreenings'

export default class Basic extends LightningElement {
    @api recordId;
    @track mapData= [];
    @wire(getScreenings, {oppId: '$recordId'})
    wiredScreenings({error,data}) {
        if (data) {
            for (let key in data) {
               this.mapData.push({value:data[key], key:key});
            }
        } else if (error) {
            window.console.log(error);
        }
    }
}