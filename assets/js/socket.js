import { Socket } from 'phoenix';

let socket = new Socket('/socket', { params: { token: window.token } });
socket.connect();

export default socket;
