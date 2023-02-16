import requests
import sys
import socket
import json
from pygments import highlight, lexers, formatters

# API key for ipinfo.io
ipinfo_api_key = "" 
# API key for viewdns.info
viewdns_api_key = ""                                     

def requesturl(i, key):
    url = requests.get(f"https://ipinfo.io/{i}?token={key}")
    r = url.text
    # code to colour
    obj = json.loads(r)
    json_formatted_str = json.dumps(obj, indent=4)
    # colourful output
    colorful_json = highlight(json_formatted_str, lexers.JsonLexer(), formatters.TerminalFormatter())
    print(colorful_json)


def get_ip_address(domain_name):
    try:
        ip_address = socket.gethostbyname(domain_name)
        return ip_address
    except socket.gaierror:
        return None


def viewdns(i, key):
    # requesting reverse IP lookup from viewdns.info
    url = requests.get(f"https://api.viewdns.info/reverseip/?host={i}&apikey={key}&output=json")
    r = str(url.text)
    obj = json.loads(r)
    json_formatted_str = json.dumps(obj, indent=4)
    # colourful output
    colorful_json = highlight(json_formatted_str, lexers.JsonLexer(), formatters.TerminalFormatter())
    print(colorful_json)


# for converting domain name into IP
ip = get_ip_address(sys.argv[1])

# gathering IP information
requesturl(ip, ipinfo_api_key)

# executing function for reverse IP lookup
viewdns(sys.argv[1], viewdns_api_key)
