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
import argparse
import time

async def logger(x):
    str(x)


class Client:
    def __init__(self, port=8888, ip='127.0.0.1', name='client', message_max_length=1e6, logging=True):
        """
        127.0.0.1 is the localhost
        port could be any port
        """
        self.ip = ip
        self.port = port
        self.name = name
        self.logging = logging
        self.message_max_length = int(message_max_length)

    async def tcp_echo_client(self, message, server_name):
        """
        on client side send the message for echo
        """
        reader, writer = await asyncio.open_connection(self.ip, self.port)
        if self.logging:
            logging.info(f'Connection to {server_name} opened\n')
        writer.write(message.encode())
        if self.logging:
            logging.info(f'Sending {message} to {server_name}\n')
        data = await reader.read(self.message_max_length)
        if self.logging:
            logging.info(f'Connection to {server_name} closed\n\n')

        # The following lines closes the stream properly
        # If there is any warning, it's due to a bug o Python 3.8: https://bugs.python.org/issue38529
        # Please ignore it
        writer.close()

    def run_until_quit(self):
        # start the loop
        while True:
            # collect the message to send
            message = input("Please input the next message to send: ")
            if message in ['quit', 'exit', ':q', 'exit;', 'quit;', 'exit()', '(exit)']:
                break
            else:
                asyncio.run(self.tcp_echo_client(message, ''))


if __name__ == '__main__':
    parser = argparse.ArgumentParser('CS131 project example argument parser')
    parser.add_argument('port_no', type=int,
                        help='required port number input')
    args = parser.parse_args()
    print(time.time())
    client = Client(args.port_no, logging=False)  # using the default settings
    client.run_until_quit()
