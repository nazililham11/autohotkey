import re
import sys
import requests
import subprocess
from time import sleep

import pyttsx3

speaker = pyttsx3.init()
voices = speaker.getProperty('voices')

speaker.setProperty('voice', voices[1].id)
speaker.setProperty('rate', 165)


ssid_name = "AP"
base_url = "http://10.10.10.1/"
relay_count = 3
connect_wait_s = 10


def speaker_say(message):
        speaker.say(message)
        speaker.runAndWait()


# TODO: implement state conditions
def switch_relay(id, state: bool | None = None):

        if not isinstance(id, int) or id >= relay_count:
                raise ValueError("invalid relay id")

        response = requests.get(url=f"{base_url}relay?id={id}", timeout=1)

        if response.status_code != 200:
                raise ConnectionError("unable to connect to device")

        data = response.json()
        current_state = data.get("relay", [])[id]
        state_str = "off" if current_state == 0 else "on"

        speaker_say(f"turn {state_str} relay {id + 1}, Done")


def is_connected(ssid_name: str | None = None):
        output = subprocess.getoutput("netsh wlan show interfaces")

        if ssid_name is None:
                pattern = r"State\s*:\s*connected"
        else:
                pattern = r"Profile\s*:\s*" + ssid_name

        match = re.search(pattern, output)

        return True if match else False


def connect_to_wifi(ssid_name):
        subprocess.getoutput(f"netsh wlan connect {ssid_name}")


def second_try():
        is_connected_wifi = is_connected()

        if is_connected_wifi:
                speaker_say("already connected to other wifi")
                return

        connect_to_wifi(ssid_name)
        speaker_say("try connecting to wifi")

        sleep(connect_wait_s)

        if is_connected(ssid_name):
                speaker_say("done.. do the second try")
                switch_relay(int(sys.argv[1]))

        else:
                speaker_say("failed")


if __name__ == "__main__":

        try:
                # first try
                switch_relay(int(sys.argv[1]))

        except (ConnectionError, requests.ReadTimeout):
                speaker_say("switch relay failed, unable to connect to device")
                second_try()

        except ValueError as e:
                print(f"switch relay failed. {e}")
