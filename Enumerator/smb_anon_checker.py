import ftplib
from queue import Queue
from termcolor import colored
from threading import Thread, Lock
import ipaddress
import argparse


class FTPScanner(object):
    def __init__(self, target_queue, lock):
        self.target_queue = target_queue
        self.lock = lock

    def scan_host(self):
        while True:
            hostname = self.target_queue.get()
            try:
                with ftplib.FTP(hostname, timeout=5) as ftp:
                    ftp.login('anonymous', 'anonymous')
                    with self.lock:
                        print(colored(f"[*] {hostname} SMB Anonymous Logon Succeeded", 'green'))
            except ftplib.all_errors as e:
                with self.lock:
                    pass
            finally:
                self.target_queue.task_done()

def get_hosts_in_subnet(subnet):
    try:
        network = ipaddress.ip_network(subnet, strict=False)
        return [str(host) for host in network.hosts()]
    except ValueError as e:
        print(f"Error: Invalid subnet provided: {e}")
        return []

def main():
    target_queue = Queue()
    lock = Lock()

    # Get arguments using argparse (more user-friendly)
    parser = argparse.ArgumentParser(description='Scan for anonymous FTP access.')
    parser.add_argument('-H', '--host', help='Specify a single target host')
    parser.add_argument('-s', '--subnet', help='Specify a target subnet')
    parser.add_argument('-t', '--threads', type=int, default=4, help='Number of threads (default: 4)')
    args = parser.parse_args()

    if not (args.host or args.subnet):
        print("Please specify a target host or subnet.")
        exit(1)

    if args.host:
        target_queue.put(args.host)
    elif args.subnet:
        # Scan subnet
        hosts = get_hosts_in_subnet(args.subnet)
        for host in hosts:
            target_queue.put(host)

    # Create and start threads
    for _ in range(args.threads):
        worker = FTPScanner(target_queue, lock)
        worker_thread = Thread(target=worker.scan_host)
        worker_thread.daemon = True  # Threads terminate with main program
        worker_thread.start()

    # Wait for all tasks to finish
    target_queue.join()
    print("Scan completed.")


if __name__ == "__main__":
    main()

