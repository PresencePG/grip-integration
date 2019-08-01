using ZMQ
using JSON

ctx = Context()

connection_uri = ENV["SERVER_LISTEN_URI"]

reciever = Socket(ctx, PAIR)
ZMQ.bind(reciever, connection_uri)

println("Listening . . .")

while true
    raw_msq = recv(reciever, String)
    msg = JSON.parse(raw_msq)
    # Do work here
    sent_at = msg["at"]
    message = msg["message"]
    send(reciever, "Recieved message sent at '$(sent_at)'")
    println("$(sent_at): $(message)")
end

close(reciever)
