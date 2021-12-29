import { LightningElement, api, wire, track } from 'lwc';

export default class MessageBanner extends LightningElement {
    @api 
    get message() {
        return this._message;
    }
    set message(value) {
        this._message = value;
    }
    @track _message = null;

    @api 
    get bannerType() {
        return this._bannerType;
    }
    set bannerType(value) {
        this._bannerType = value;
    }
    @track _bannerType = null;

    @api 
    get bannerColour() {
        return this._bannerColour;
    }
    set (value) {
        this._bannerColour = value;
    }
    @track _bannerColour = null;
}