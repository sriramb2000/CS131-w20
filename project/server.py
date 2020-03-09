"""
Note that this piece of code is (of course) only a hint
you are not required to use it
neither do you have to use any of the methods mentioned here
The code comes from
https://asyncio.readthedocs.io/en/latest/tcp_echo.html

To run:
1. start the echo_server.py first in a terminal
2. start the echo_client.py in another terminal
3. follow print-back instructions on client side until you quit
"""

import asyncio
import async_timeout
import argparse
import json
import time
import aiohttp

# from config import PORT_NUMBERS, PORT_NUMBERS, LINKS
import config
import echo_client
import keys

def getLatLon(latlon):
	ind = 0
	count = 0
	lat = ''
	lon = ''
	for c in latlon:
		if c == '+' or c == '-':
			count = count + 1
			if count == 2:
				lat = latlon[:(ind-1)]
				lon = latlon[ind:]
		ind = ind + 1
	return (lat, lon)

def create_places_req(coordinates, radius):
    lat, lon = getLatLon(coordinates)
    return f"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location={lat},{lon}&radius={radius*1000}&key={keys.GOOGLE_API_KEY}"

async def fetch(session, url):
    async with async_timeout.timeout(10):
        async with session.get(url) as res:
            return await res.json()

class ServerMessage:
    history = dict()

    def __init__(self, server_name, logfile):
        self.server_name = server_name
        self.known_command = ["WHATSAT", "IAMAT", "AT"]
        self.links = config.LINKS[server_name]
        self.logfile = logfile
        print(self.links)

    def __call__(self, message):
        return self.parse_message(message) if len(message) else "ERROR: empty message"

    async def log(self, message):
        if message == None:
            return
        else:
            try:
                self.logfile.write(message)
            except:
                print("Log Error: ", message)

    async def parse_message(self, message):
        command_table = {
            "IAMAT": self.handle_i_am_at,
            "WHATSAT": self.handle_whats_at,
            "UPDATE": self.handle_update
        }
        message_list = [msg for msg in message.strip().split() if len(msg)]
        if len(message_list) != 4 and message_list[0] != "UPDATE":
            log("ERROR invalid command: " + message)
            return "ERROR: invalid command length"
        cmd = command_table.get(message_list[0], lambda x, y, z: f"ERROR: command name {message_list[0]} unrecognized")
        if message_list[0] == "UPDATE":
            res = await cmd(message.strip()[len("UPDATE"):])
            await self.flood(*res)
            return "ACK"
        return await cmd(*message_list[1:])

    async def handle_i_am_at(self, client_id, coords, ts):
        td = time.time() - float(ts)
        sign = "+"
        if td < 0:
            sign = ""
        msg = f"AT {self.server_name} {sign}{td} {client_id} {coords} {ts}"
        ServerMessage.history[client_id] = {"server": self.server_name, "client": client_id, "coordinates": coords, "timestamp": ts, "delta": td, "delta_sign": sign, "message": msg}
        print(json.dumps(ServerMessage.history[client_id]))
        await self.flood(self.server_name, json.dumps(ServerMessage.history[client_id]))
        await self.log("IAMAT response:\n" + msg + "\n\n")
        return msg

    async def handle_whats_at(self, client_id, radius, max_results):
        if client_id in ServerMessage.history:
            url = create_places_req(ServerMessage.history[client_id]["coordinates"], float(radius))
            async with aiohttp.ClientSession() as session:
                await self.log(f'QUERYING PLACES API FOR LOCATION={ServerMessage.history[client_id]["coordinates"]}, RADIUS={radius}\n\n')
                res = await fetch(session, url)
                #print(res)
                res["results"] = res["results"][:int(max_results)]
                google_api_feedback = json.dumps(res, indent=4)
                print(res)
                msg = ServerMessage.history[client_id]["message"] + "\n" + google_api_feedback
                await self.log("WHATSAT response:\n" + msg[:200] + "\n...\n\n")
                return msg
        await self.log("AT? invalid client")
        return "AT? Invalid client"
    
    async def handle_update(self, entry):
        print(entry)
        data = json.loads(entry)
        if not data["client"] in ServerMessage.history or float(data["timestamp"]) > float(ServerMessage.history[data["client"]]["timestamp"]):
            old = data.copy()
            server_origin = data["server"]
            msg = data["message"].replace(server_origin, self.server_name)
            data["message"] = msg
            data["server"] = self.server_name
            ServerMessage.history[data["client"]] = data
            await self.log("UPDATE processed:\n" + json.dumps(data) + "\n\n")
            return (server_origin, json.dumps(old))
        self.log("UPDATE redundant\n\n")
        return ("", "")
    
    async def flood(self, origin, message):
        if not origin == "":
            temp = self.links.copy()
            if origin in temp:
                temp.remove(origin)
                print(origin, temp)
            return asyncio.gather(*(echo_client.Client(config.PORT_NUMBERS[link]).tcp_echo_client('UPDATE ' + message, link, self.log) for link in temp))


class Server:
    ACCEPTED_MESSAGES = ["IAMAT", "WHATSAT", "UPDATE"]

    def __init__(self, name, port=8888, ip='127.0.0.1', message_max_length=1e6):
        self.name = name
        self.ip = ip
        self.port = port
        self.message_max_length = int(message_max_length)
        self.logfile = open(name+"-log.txt", "a+")
        self.msg_handler = ServerMessage(name, self.logfile)

    # This is going to be handle_message
    async def handle_message(self, reader, writer):
        """
        on server side
        """
        data = await reader.read(self.message_max_length)
        message = data.decode()
        addr = writer.get_extra_info('peername')
        print("{} received {} from {}".format(self.name, message, addr))

        sendback_message = await self.msg_handler(message)

        print("{} send: {}".format(self.name, sendback_message))
        writer.write(sendback_message.encode())
        await writer.drain()

        print("close the client socket")
        writer.close()
    
    async def handle_iamat(self):
        print("b")
    
    async def handle_whatsat(self):
        print("b")


    async def run_forever(self):
        server = await asyncio.start_server(self.handle_message, self.ip, self.port)

        self.logfile.write(f"Starting up {self.name} at {time.time()}\n\n")

        # Serve requests until Ctrl+C is pressed
        print(f'serving on {server.sockets[0].getsockname()}')
        async with server:
            await server.serve_forever()
        
        self.logfile.write(f"Shutting down {self.name} at {time.time()}\n\n")
        # Close the server
        server.close()


def main():
    parser = argparse.ArgumentParser('CS131 project example argument parser')
    parser.add_argument('server_name', type=str,
                        help='required server name input')
    args = parser.parse_args()

    print("Hello, welcome to server {} running on port {}".format(args.server_name, config.PORT_NUMBERS[args.server_name]))

    server = Server(args.server_name, config.PORT_NUMBERS[args.server_name])
    try:
        asyncio.run(server.run_forever())
    except KeyboardInterrupt:
        pass


if __name__ == '__main__':
    main()

#IAMAT kiwi.cs.ucla.edu +34.068930-118.445127 1520023934.918963997
#WHATSAT kiwi.cs.ucla.edu 10 5
