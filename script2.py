# !/usr/bin/python

from os import listdir, system
from os.path import isfile, join, exists
import subprocess

PATH = "Geolife/Data"

for f in listdir(PATH):
    if not isfile(f) and f.isdigit():
        USER_ID = f
        INPUT_PATH = join(PATH, f)
        OUTPUT_PATH = "JSON/" + f
        command = "pig -x local "
        param1 = "-param USER_ID={} ".format(USER_ID)
        param2 = "-param INPUT_PATH={} ".format(INPUT_PATH)
        param3 = "-param OUTPUT_PATH={} ".format(OUTPUT_PATH)
        command += param1 + param2 + param3
        if exists(join(INPUT_PATH, "labels.txt")):
            script = "TrayectoriesToJSON.pig"
            os.system(command + script)
