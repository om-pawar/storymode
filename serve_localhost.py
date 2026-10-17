import http.server
import socketserver
import os
import sys

# Ensure UTF-8 output on Windows console
if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except Exception:
        pass

PORT = 8080
DIRECTORY = os.path.join(os.path.dirname(os.path.abspath(__file__)), "web")

class CustomHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def end_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Cache-Control", "no-cache, no-store, must-revalidate")
        super().end_headers()

def run_server():
    os.chdir(DIRECTORY)
    with socketserver.TCPServer(("", PORT), CustomHandler) as httpd:
        print("==================================================")
        print(" AFTER THE RAIN - LOCALHOST WEB SERVER ACTIVE")
        print("==================================================")
        print(f" Playable URL (PC & Browser): http://localhost:{PORT}")
        print(f" Network URL (Local Network): http://127.0.0.1:{PORT}")
        print(f" Serving directory: {DIRECTORY}")
        print(" Press Ctrl+C in terminal to stop.")
        print("==================================================")
        sys.stdout.flush()
        httpd.serve_forever()

if __name__ == "__main__":
    run_server()
