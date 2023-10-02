import http.server
import socketserver
import argparse

def run_server(port):
    class MyRequestHandler(http.server.SimpleHTTPRequestHandler):
        def do_PUT(self):
            # Get the file name from the request
            filename = self.path.strip('/')

            # Open the file in binary write mode
            with open(filename, 'wb') as f:
                # Read the data from the request and write it to the file
                content_length = int(self.headers['Content-Length'])
                data = self.rfile.read(content_length)
                f.write(data)

            self.send_response(201, 'Created')
            self.end_headers()

    with socketserver.TCPServer(("", port), MyRequestHandler) as httpd:
        print(f"Serving on port {port}")
        httpd.serve_forever()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Simple Python upload server with PUT method")
    parser.add_argument("--port", type=int, default=80, help="Port number to listen on (default: 80)")
    args = parser.parse_args()
    
    run_server(args.port)
