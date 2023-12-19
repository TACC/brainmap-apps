from tapipy.tapis import Tapis
from tapipy.errors import BaseTapyException
import argparse
import os
import json
from SECRETS import TAPIS_CLIENT
#from SECRETS import CLIENT_CREDENTIALS


def profile_manager(client, filepath, username, delete):

    if username:
        try:
            print(f'Listing profiles for user {username}...')
            output=client.systems.getSchedulerProfiles()
            for item in output:
                if item.owner == username:
                    print(item)
            if username == 'all':
                for item in output:
                    print(item)
        except:
            raise
        exit

    if filepath:
        try:
            with open(filepath, 'r') as f:
                print(f'Opening {filepath}...')
                profile_json = json.load(f)
        except:
            raise

        print('  profile = {}'.format(profile_json['name']))
        print('  description = {}'.format(profile_json['description']))

        if delete:
            try:
                client.systems.deleteSchedulerProfile(name=profile_json['name'])
                print('  deleted scheduler profile {}'.format(profile_json['name']))
            except BaseTapyException as e:
                raise
            exit

        else:
            try:
                client.systems.createSchedulerProfile(**profile_json)
                print('  added scheduler profile {}'.format(profile_json['name']))
            except BaseTapyException as e:
                if 'SYSAPI_PRF_EXISTS' in e.message:
                    print('  a profile called {} already exists, delete it first'.format(profile_json['name']))
                else:
                    raise
            exit


def main():
    parser = argparse.ArgumentParser(description='Create or edit a scheduler profile')
    parser.add_argument('-u', '--username', type=str, help='list existing profiles for username and exit')
    parser.add_argument('-f', '--filepath', type=str, help='profile.json file for scheduler profile')
    parser.add_argument('-d', '--delete', action='store_true', help='use this flag with filepath to delete a scheduler profile')
    args = parser.parse_args()

    t = Tapis(**TAPIS_CLIENT, download_latest_specs=True) 
    #t = Tapis(base_url='https://portals.tapis.io', **CLIENT_CREDENTIALS)
    #t.get_tokens()
    profile_manager(t, args.filepath, args.username, args.delete)


if __name__ == "__main__":
    main()
