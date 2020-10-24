import json
import os
import sys


def main():
    volumeSet = {}
    for volumeListFile in sys.argv[2:]:
        volume_list_handle = open(volumeListFile, "r")
        volume_list = json.loads(volume_list_handle.read())
        for volume in volume_list["items"]:
            volumeSet[volume["metadata"]["name"]] = volume
    for volumeName in volumeSet:
        volume_out = open(os.path.join(sys.argv[1], volumeName + ".json"), "w")
        json.dump(volumeSet[volumeName], indent=4, fp=volume_out)
        volume_out.close()


if __name__ == "__main__":
    main()
