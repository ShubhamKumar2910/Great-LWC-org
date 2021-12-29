import { LightningElement, api } from 'lwc';

export default class DatatablePicklist extends LightningElement {
    @api label;
    @api placeholder;
    @api options;
    @api value;
    @api context;
    @api columnname;

    handleChange(event) {
        //show the selected value on UI
        this.value = event.detail.value;
        console.log('-handleChange-this.context-', this.context);
        console.log('-handleChange-this.value-', this.value);
        console.log('-handleChange-this.label-', this.label);
        console.log('-handleChange-this.columnname-', this.columnname);

        //fire event to send context and selected value to the data table
        this.dispatchEvent(new CustomEvent('picklistchanged', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                data: { context: this.context, value: this.value, columnname: this.columnname }
            }
        }));
    }

}