from tapipy.tapis import Tapis
from tapipy.errors import BaseTapyException
import argparse
import os
import json
from SECRETS import TAPIS_CLIENT
#from SECRETS import CLIENT_CREDENTIALS


def system_manager(client, filepath, userlist, unshare):

    try:
        with open(filepath, 'r') as f:
            system_json = json.load(f)
    except:
        raise

    print('  id = {}'.format(system_json['id']))
    print('  description = {}'.format(system_json['description']))

    if unshare:
        try:
            print(f'  revoking permissions for {userlist}...')
            client.systems.unShareSystem(systemId=system_json['id'], users=userlist)
            response = client.systems.getShareInfo(systemId=system_json['id'])
            print('  system now shared with {}'.format(response.users))
        except BaseTapyException as e:
            if 'SYSLIB_NOT_FOUND' in e.message:
                print('  ERROR: systemId not recognized: {}'.format(system_json['id']))
            else:
                raise
    else:
        try:
            print(f'  sharing with {userlist}...')
            client.systems.shareSystem(systemId=system_json['id'], users=userlist)
            response = client.systems.getShareInfo(systemId=system_json['id'])
            print('  system now shared with {}'.format(response.users))
        except BaseTapyException as e:
            if 'SYSLIB_NOT_FOUND' in e.message:
                print('  ERROR: systemId not recognized: {}'.format(system_json['id']))
            else:
                raise


def main():
    parser = argparse.ArgumentParser(description='Share a system with a user')
    parser.add_argument('-u', '--unshare', action='store_true', help='use this flag to revoke pems')
    parser.add_argument('filepath', help='system.json file for system to share')
    parser.add_argument('username', help='tacc username(s) to share with (comma sep)')
    args = parser.parse_args()

    if len(args.filepath) >= 1:
        print(f'Opening {args.filepath}...')
    else:
        raise

    t = Tapis(**TAPIS_CLIENT, download_latest_specs=True) 
    #t = Tapis(base_url='https://portals.tapis.io', **CLIENT_CREDENTIALS)
    #t.get_tokens()
    system_manager(t, args.filepath, args.username.split(','), args.unshare)


if __name__ == "__main__":
    main()
