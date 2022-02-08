module vnats
import time

fn on_nats_message(conn &Connection, sub &C.natsSubscription, msg &Msg, user_data voidptr)
{
	subj := msg.get_subject()
	data := msg.get_data()
	reply := msg.get_reply()
	println("Received msg: $subj $data $reply")
	msg.destroy()
}


fn test_conn() {
	url := "nats://localhost:4222"
	print("connecting to $url\n")
	status, conn := connect(url)

	if status == .ok {
		println("connected")
		conn.qsub(">", "q", on_nats_message, voidptr(0))
		conn.publish_string("cn.ok", "ok")
	}

	time.sleep(1000 * time.millisecond)
}

fn test_request() {
	url := "nats://localhost:4222"
	print("connecting to $url\n")
	status, conn := connect(url)

	if status == .ok {
		println("connected")
		conn.qsub(">", "q", on_nats_message, voidptr(0))
		conn.request("cn.test.request", "request", 1)
	}
}
