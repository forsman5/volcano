import http.server
import socket
import os

PORT = 8080
EXPORT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "exports", "web")


class GodotWebHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        super().end_headers()

    def log_message(self, format, *args):
        pass  # suppress per-request noise


if __name__ == "__main__":
    if not os.path.isdir(EXPORT_DIR):
        print(f"Export folder not found: {EXPORT_DIR}")
        print("Run export_and_serve.ps1 first to build the web export.")
        raise SystemExit(1)

    os.chdir(EXPORT_DIR)

    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
        try:
            s.connect(("8.8.8.8", 80))
            lan_ip = s.getsockname()[0]
        except Exception:
            lan_ip = "unknown"

    print(f"Serving Godot web export:")
    print(f"  Local:   http://localhost:{PORT}")
    print(f"  Network: http://{lan_ip}:{PORT}")
    print("Press Ctrl+C to stop.\n")

    http.server.HTTPServer(("0.0.0.0", PORT), GodotWebHandler).serve_forever()
