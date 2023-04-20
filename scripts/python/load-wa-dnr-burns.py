#!/usr/bin/env python3

import datetime
import urllib.request


API_ENDPOINT = "https://api.burnportal.dnr.wa.gov/api/v1/BurnRequests/Search?PlannedIgnitionStartDate={ignition_date}&PlannedIgnitionEndDate={ignition_date}"

def load():
    today_str = datetime.datetime.now().strftime('%Y-%m-%d')
    url = API_ENDPOINT.format(ignition_date=today_str)
    api_data = json.loads(urllib.request.urlopen(endpoint).read())
    print api_data

if __name__ == '__main__':
    load()
