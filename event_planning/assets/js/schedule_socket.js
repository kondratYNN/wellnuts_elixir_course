import { Socket } from "phoenix"

let socket = new Socket("/socket", { params: { token: window.userToken } })

socket.connect()

let channel = socket.channel("changes:lobby", {})
channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) })

let create_event = document.getElementById('add_btt');
let update_event = document.getElementById('update');
let delete_event = document.getElementById('delete');


if (create_event != null) {
    create_event.addEventListener('click', function(event) {
        let user_id = document.getElementById('user_id').textContent
        let { value: name } = document.querySelector('#name')
        let { value: repetition } = document.querySelector('#repetition')
        let { value: date_year } = document.querySelector('#date_year')
        let { value: date_month } = document.querySelector('#date_month')
        let { value: date_day } = document.querySelector('#date_day')
        let { value: date_hour } = document.querySelector('#date_hour')
        let { value: date_minute } = document.querySelector('#date_minute')
        channel.push('create', { data: { user_id, name, repetition, date_year, date_month, date_day, date_hour, date_minute } })
    })
}

channel.on('create', (msg) => {
    document.querySelector("#event").innerHTML += msg.html_event
})

if (update_event != null) {
    update_event.addEventListener('click', function(event) {
        let { value: name } = document.querySelector('#name')
        let { value: repetition } = document.querySelector('#repetition')
        let { value: date_year } = document.querySelector('#date_year')
        let { value: date_month } = document.querySelector('#date_month')
        let { value: date_day } = document.querySelector('#date_day')
        let { value: date_hour } = document.querySelector('#date_hour')
        let { value: date_minute } = document.querySelector('#date_minute')
        let { value: id } = document.querySelector('#event-from_id')
        channel.push('update', { data: { name, repetition, date_year, date_month, date_day, date_hour, date_minute, id } })
    })
}

channel.on('update', (msg) => {
    document.getElementById(msg.id).innerHTML = msg.html_event
})

if (delete_event != null) {
    delete_event.addEventListener('click', function(event) {
        let id = document.querySelector('#id_event').textContent
        channel.push('delete', { data: id })
    })
}

channel.on('delete', (msg) => {
    document.getElementById(msg.id.replace(/[^0-9]/g, "")).style.display = "none"
})

export default socket