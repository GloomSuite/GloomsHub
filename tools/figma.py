#!/usr/bin/env python3
"""Minimal MCP-over-HTTP client for the Figma desktop app's Dev Mode server (BACKLOG 16).

The Claude desktop app's figma-desktop connector reports "connected, 0 tools" even when the
server is up, so the redesign sessions read the mocks through this instead. Figma must be open
on the GloomSuite UI file; the server answers on 127.0.0.1:3845.

  python3 tools/figma.py tools/list
  python3 tools/figma.py tools/call '{"name":"get_metadata","arguments":{"nodeId":"674:13578"}}'
  python3 tools/figma.py tools/call '{"name":"get_screenshot","arguments":{"nodeId":"660:5703"}}'
  python3 tools/figma.py tools/call '{"name":"get_design_context","arguments":{"nodeId":"660:5703","clientLanguages":"lua","clientFrameworks":"none"}}'

get_metadata = the layer tree with positions; get_screenshot = a base64 PNG in the result's
content; get_design_context = the one that carries colours, fonts and pixel sizes (as React +
Tailwind you translate by hand). The session id is cached beside this file in .figma-session.
"""
import sys, json, urllib.request, os

URL = "http://127.0.0.1:3845/mcp"
SESS = os.path.join(os.path.dirname(os.path.abspath(__file__)), ".figma-session")
HDR = {"Content-Type": "application/json", "Accept": "application/json, text/event-stream"}

def post(payload, sid=None):
    h = dict(HDR)
    if sid: h["mcp-session-id"] = sid
    req = urllib.request.Request(URL, data=json.dumps(payload).encode(), headers=h, method="POST")
    with urllib.request.urlopen(req, timeout=120) as r:
        sid = r.headers.get("mcp-session-id", sid)
        body = r.read().decode()
    msgs = []
    if "data:" in body:
        i = body.index("data:")
        msgs.append(json.loads(body[i+5:].strip()))
    if not msgs and body.strip():
        msgs.append(json.loads(body))
    return sid, msgs

def session():
    if os.path.exists(SESS):
        return open(SESS).read().strip()
    sid, _ = post({"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"claude-code","version":"0"}}})
    post({"jsonrpc":"2.0","method":"notifications/initialized"}, sid)
    open(SESS,"w").write(sid)
    return sid

def call(method, params=None):
    sid = session()
    try:
        _, msgs = post({"jsonrpc":"2.0","id":2,"method":method,"params":params or {}}, sid)
    except urllib.error.HTTPError as e:
        if e.code in (400, 404):
            os.remove(SESS); sid = session()
            _, msgs = post({"jsonrpc":"2.0","id":2,"method":method,"params":params or {}}, sid)
        else: raise
    return msgs[-1]

if __name__ == "__main__":
    method = sys.argv[1]
    params = json.loads(sys.argv[2]) if len(sys.argv) > 2 else {}
    out = call(method, params)
    print(json.dumps(out, indent=1))
