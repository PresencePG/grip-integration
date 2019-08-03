using ZMQ
using JSON

ctx = Context()

connection_uri = ENV["SERVER_LISTEN_URI"]

receiver = Socket(ctx, PAIR)
ZMQ.bind(receiver, connection_uri)

println("Julia ready . . .")

while true
    raw_msq = recv(receiver, String)
    msg = JSON.parse(raw_msq)
    # Do work here
    sent_at = msg["at"]
    message = msg["message"]
    if message == "ping"
        send(receiver, "pong")
        continue
    end
    send(receiver, "Recieved message sent at '$(sent_at)'")
    println("$(sent_at): $(message)")
end
