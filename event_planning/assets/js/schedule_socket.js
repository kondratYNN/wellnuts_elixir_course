import { Socket } from "phoenix"
// import $ from "jquery"

let socket = new Socket("/socket", { params: { token: window.userToken } })

socket.connect()

let channel = socket.channel("changes:lobby", {})
channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) })

let create_event = document.getElementById('add_btt');
console.log(create_event)
    // let updateBtt = document.querySelector("#update")
    // let deleteBtt = document.querySelector("#delete")


if (create_event != null) {
    create_event.addEventListener('click', function(event) {
        let { value: repetition } = document.querySelector('#repetition')
        let { value: date_year } = document.querySelector('#date_year')
        let { value: date_month } = document.querySelector('#date_month')
        let { value: date_day } = document.querySelector('#date_day')
        let { value: date_hour } = document.querySelector('#date_hour')
        let { value: date_minute } = document.querySelector('#date_minute')
        channel.push('create', { data: { repetition, date_year, date_month, date_day, date_hour, date_minute } })
    })
}

channel.on('create', (msg) => {
    document.querySelector("#event").innerHTML += msg.html_event
})


// updateBtt.click(() => {

// })

export default socket

// channel.on('create_event', function (payload) {
//     console.log(payload)
// });

// let create_event = document.getElementById('create_event');    
// console.log(create_event)

// if (create_event != null) {
//     create_event.addEventListener('click', function (event) {
//         let { value: repetition } = document.querySelector('#repetition')
//         let { value: date_year } = document.querySelector('#date_year')
//         let { value: date_month } = document.querySelector('#date_month')
//         let { value: date_day } = document.querySelector('#date_day')
//         let { value: date_hour } = document.querySelector('#date_hour')
//         let { value: date_minute } = document.querySelector('#date_minute')
//         channel.push('create_event', { data: { repetition, date_year, date_month, date_day, date_hour, date_minute } })
//     })
// }


// export default socket