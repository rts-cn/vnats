module vnats

#include <nats/nats.h>
#flag -lnats

type Connection = C.natsConnection
type Options = C.natsOptions
type Msg = C.natsMsg
type Subscription = C.natsSubscription
type MessageCallback = fn (conn &Connection, sub &C.natsSubscription, msg &Msg, user_data voidptr)

struct Client {
	opts &Options
	conn &Connection
}

[typedef]
struct C.natsOptions {
}

[typedef]
struct C.natsConnection {
}

[typedef]
struct C.natsMsg {
}

[typedef]
struct C.natsSubscription {
}

struct C.__natsSubscription {
}

pub enum Status {
	ok = C.NATS_OK
	err = C.NATS_ERR                           ///< Generic error
	protocol_error = C.NATS_PROTOCOL_ERROR                ///< Error when parsing a protocol message,
										///  or not getting the expected message.
	io_error = C.NATS_IO_ERROR                      ///< IO Error (network communication).
	line_too_long = C.NATS_LINE_TOO_LONG                 ///< The protocol message read from the socket
										///  does not fit in the read buffer.

	connection_closed = C.NATS_CONNECTION_CLOSED             ///< Operation on this connection failed because
										///  the connection is closed.
	no_server = C.NATS_NO_SERVER                     ///< Unable to connect, the server could not be
										///  reached or is not running.
	stale_connection = C.NATS_STALE_CONNECTION              ///< The server closed our connection because it
										///  did not receive PINGs at the expected interval.
	secure_connection_wanted = C.NATS_SECURE_CONNECTION_WANTED      ///< The client is configured to use TLS, but the
										///  server is not.
	secure_connection_required = C.NATS_SECURE_CONNECTION_REQUIRED    ///< The server expects a TLS connection.
	connection_disconnected = C.NATS_CONNECTION_DISCONNECTED       ///< The connection was disconnected. Depending on
										///  the configuration, the connection may reconnect.

	connection_auth_failed = C.NATS_CONNECTION_AUTH_FAILED        ///< The connection failed due to authentication error.
	not_permitted = C.NATS_NOT_PERMITTED                 ///< The action is not permitted.
	not_found = C.NATS_NOT_FOUND                     ///< An action could not complete because something
										///  was not found. So far, this is an internal error.

	address_missing = C.NATS_ADDRESS_MISSING               ///< Incorrect URL. For instance no host specified in
										///  the URL.

	invalid_subject = C.NATS_INVALID_SUBJECT               ///< Invalid subject, for instance NULL or empty string.
	invalid_arg = C.NATS_INVALID_ARG                   ///< An invalid argument is passed to a function. For
										///  instance passing NULL to an API that does not
										///  accept this value.
	invalid_subscription = C.NATS_INVALID_SUBSCRIPTION          ///< The call to a subscription function fails because
										///  the subscription has previously been closed.
	invalid_timeout = C.NATS_INVALID_TIMEOUT               ///< Timeout must be positive numbers.

	illegal_state = C.NATS_ILLEGAL_STATE                 ///< An unexpected state, for instance calling
										///  #natsSubscription_NextMsg() on an asynchronous
										///  subscriber.

	slow_consumer = C.NATS_SLOW_CONSUMER                 ///< The maximum number of messages waiting to be
										///  delivered has been reached. Messages are dropped.

	max_payload = C.NATS_MAX_PAYLOAD                   ///< Attempt to send a payload larger than the maximum
										///  allowed by the NATS Server.
	max_delivered_msgs = C.NATS_MAX_DELIVERED_MSGS            ///< Attempt to receive more messages than allowed, for
										///  instance because of #natsSubscription_AutoUnsubscribe().

	insufficient_buffer = C.NATS_INSUFFICIENT_BUFFER           ///< A buffer is not large enough to accommodate the data.

	no_memory = C.NATS_NO_MEMORY                     ///< An operation could not complete because of insufficient
										///  memory.

	sys_error = C.NATS_SYS_ERROR                     ///< Some system function returned an error.

	timeout = C.NATS_TIMEOUT                       ///< An operation timed-out. For instance
										///  #natsSubscription_NextMsg().

	failed_to_initialize = C.NATS_FAILED_TO_INITIALIZE          ///< The library failed to initialize.
	not_initialized = C.NATS_NOT_INITIALIZED               ///< The library is not yet initialized.

	ssl_error = C.NATS_SSL_ERROR                     ///< An SSL error occurred when trying to establish a
										///  connection.

	no_server_support = C.NATS_NO_SERVER_SUPPORT             ///< The server does not support this action.

	not_yet_connected = C.NATS_NOT_YET_CONNECTED             ///< A connection could not be immediately established and
										///  #natsOptions_SetRetryOnFailedConnect() specified
										///  a connected callback. The connect is retried asynchronously.

	draining = C.NATS_DRAINING                      ///< A connection and/or subscription entered the draining mode.
										///  Some operations will fail when in that mode.

	invalid_queue_name = C.NATS_INVALID_QUEUE_NAME            ///< An invalid queue name was passed when creating a queue subscription.
}

fn C.natsOptions_Create(&&Options) Status
fn C.natsOptions_SetURL(&Options, &byte)
fn C.natsOptions_SetPingInterval(&Options, int)
fn C.natsOptions_SetMaxPingsOut(&Options, int)
fn C.natsOptions_SetAllowReconnect(&Options, bool)
fn C.natsOptions_SetDisconnectedCB()
fn C.natsOptions_SetReconnectedCB()
fn C.natsOptions_SetDiscoveredServersCB()
fn C.natsOptions_Destroy(&Options)
fn C.natsConnection_Connect(&&Connection, &Options) Status
fn C.natsConnection_Publish(&Connection, &byte, &byte, int) Status
fn C.natsConnection_PublishString(&Connection, &byte, &byte) Status
fn C.natsConnection_Destroy(&Connection)
fn C.natsMsg_GetSubject(&Msg) charptr
fn C.natsMsg_GetData(&Msg) charptr
fn C.natsMsg_GetReply(&Msg) charptr
fn C.natsMsg_Destroy(&Msg)
fn C.natsConnection_Subscribe(&&Subscription, &Connection, &byte, voidptr, voidptr)
fn C.natsConnection_QueueSubscribe(&&Subscription, &Connection, &byte, &byte, MessageCallback, voidptr)
fn C.natsConnection_Request(&&Msg, &Connection, &byte, &byte, int, int) Status
fn C.natsSubscription_Unsubscribe(&Subscription)
fn C.natsSubscription_Destroy(&Subscription)

pub fn connect(url string) (Status, &Connection) {
	client := Client{
		opts: voidptr(0)
		conn: voidptr(0)
	}

	mut status := C.natsOptions_Create(&client.opts)
	if status != .ok {
		return status, &Connection(voidptr(0))
	}

	C.natsOptions_SetURL(client.opts, url.str)
	C.natsOptions_SetPingInterval(client.opts, 1000)
	C.natsOptions_SetMaxPingsOut(client.opts, 3)
	C.natsOptions_SetAllowReconnect(client.opts, true)
	// C.natsOptions_SetDisconnectedCB(client.opts, disconnectedCB, NULL);
	// C.natsOptions_SetReconnectedCB(client.opts, reconnectedCB, NULL);
	// C.natsOptions_SetDiscoveredServersCB(client->opts, discoveredServersCB, NULL);
	status = C.natsConnection_Connect(&client.conn, client.opts)
	C.natsOptions_Destroy(client.opts)

	if status != .ok {
		println("failed")
		return status, &Connection(voidptr(0))
	}

	// subj := "cn.xswitch.blah"
	// data := "blah"
	// C.natsConnection_Publish(client.conn, subj.str, data.str, data.len)

	return Status.ok, client.conn
}

[inline]
pub fn (conn &Connection) publish(subj string, data string) Status {
	return C.natsConnection_Publish(conn, subj.str, data.str, data.len)
}

[inline]
pub fn (conn &Connection) publish_string(subj string, data string) Status {
	return C.natsConnection_PublishString(conn, subj.str, data.str)
}

[inline]
pub fn (conn &Connection) request(subj string, data string, timeout int) (Status, &Msg) {
	msg := &Msg(voidptr(0))

	status := C.natsConnection_Request(&msg, conn, subj.str, data.str, data.len, timeout)

	if status != .ok {
		return status, C.NULL
	}

	return status, msg
}

[inline]
pub fn (conn &Connection) str() string {
	return "vnats.Connection"
}

[inline]
pub fn (conn &Connection) sub(subj string, cb MessageCallback, user_data voidptr) {
	sub := &C.natsSubscription(voidptr(0))
	C.natsConnection_Subscribe(&sub, conn, subj.str, cb, user_data)
}

[inline]
pub fn (conn &Connection) qsub(subj string, queue string, cb MessageCallback, user_data voidptr) &Subscription{
	sub := &C.natsSubscription(voidptr(0))
	C.natsConnection_QueueSubscribe(&sub, conn, subj.str, queue.str, cb, user_data)
	return sub
}

pub fn (conn &Connection) close() {
	C.natsConnection_Destroy(conn)
}

pub fn (sub &Subscription) unsub() {
	C.natsSubscription_Unsubscribe(sub)
}

pub fn (sub &Subscription) destroy() {
	C.natsSubscription_Destroy(sub)
}

pub fn (msg &Msg) get_subject() string {
	r := C.natsMsg_GetSubject(msg)
	if isnil(r) {
		return ""
	}
	return unsafe{r.vstring()}
}

pub fn (msg &Msg) get_data() string {
	r := C.natsMsg_GetData(msg)
	if isnil(r) {
		return ""
	}
	return unsafe{r.vstring()}
}

pub fn (msg &Msg) get_reply() string {
	r := C.natsMsg_GetReply(msg)
	if isnil(r) {
		return ""
	}
	return unsafe{r.vstring()}
}

pub fn (msg &Msg) destroy() {
	C.natsMsg_Destroy(msg)
}
