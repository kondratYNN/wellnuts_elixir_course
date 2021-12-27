import { Socket } from "phoenix"
// import $ from "jquery"

let socket = new Socket("/socket", { params: { token: window.userToken } })

socket.connect()

let channel = socket.channel("changes:lobby", {})
channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) })

let addBtt = document.querySelector("#add_btt")
console.log(addBtt)
    // let updateBtt = document.querySelector("#update")
    // let deleteBtt = document.querySelector("#delete")

addBtt.addEventListener('click', function(event) {
    console.log(123)
        // let { value: date } = document.querySelector('#date')
        // console.log(date)
    let { value: repetition } = document.querySelector('#repetition')
    console.log(repetition)
    channel.push('add', { body: { date, repetition } })
})

channel.on("add", (msg) => {
    document.querySelector("#event").innerHTML += msg.html_event
})


// updateBtt.click(() => {

// })

export default socket