// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket,
// and connect at the socket path in "lib/web/endpoint.ex".
//
// Pass the token on params as below. Or remove it
// from the params if you are not using authentication.
import { Socket } from "phoenix"

let socket = new Socket("/socket", { params: { token: window.userToken } })

socket.connect()

let channel = socket.channel('room:lobby', {});
channel.join(); 

channel.on('create_event', function (payload) {
    console.log(payload)
});

let create_event = document.getElementById('create_event');    
console.log(create_event)

if (create_event != null) {
    create_event.addEventListener('click', function (event) {
        let { value: repetition } = document.querySelector('#repetition')
        let { value: date_year } = document.querySelector('#date_year')
        let { value: date_month } = document.querySelector('#date_month')
        let { value: date_day } = document.querySelector('#date_day')
        let { value: date_hour } = document.querySelector('#date_hour')
        let { value: date_minute } = document.querySelector('#date_minute')
        channel.push('create_event', { data: { repetition, date_year, date_month, date_day, date_hour, date_minute } })
    })
}


export default socket
