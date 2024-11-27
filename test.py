import os
import platform
import sys

def app(environ, start_response):
    body = [platform.python_version()]
    start_response('200 OK', [])

    body.extend(sys.path)
    return "\n".join(body).encode()
