from tapipy.tapis import Tapis
from tapipy.errors import BaseTapyException
import argparse
import os
import json
from SECRETS import TAPIS_CLIENT
#from SECRETS import CLIENT_CREDENTIALS


def system_manager(client, filepath):

    try:
        with open(filepath, 'r') as f:
            system_json = json.load(f)
    except:
        raise

    print('  id = {}'.format(system_json['id']))
    print('  description = {}'.format(system_json['description']))

    try:
        client.systems.createSystem(**system_json)
        print('  system created: {}'.format(system_json['id']))
    except BaseTapyException as e:
        if 'SYSAPI_SYS_EXISTS' in e.message:
            client.systems.putSystem(systemId=system_json['id'], **system_json)
            print('  system updated: {}'.format(system_json['id']))
        else:
            raise


def main():
    parser = argparse.ArgumentParser(description='Add a new system or update an existing system')
    parser.add_argument('filepath', help='system.json file for system to be added or updated')
    args = parser.parse_args()

    if len(args.filepath) >= 1:
        print(f'Opening {args.filepath}...')
    else:
        raise

    t = Tapis(**TAPIS_CLIENT, download_latest_specs=True) 
    #t = Tapis(base_url='https://portals.tapis.io', **CLIENT_CREDENTIALS)
    #t.get_tokens()
    system_manager(t, args.filepath)


if __name__ == "__main__":
    main()
