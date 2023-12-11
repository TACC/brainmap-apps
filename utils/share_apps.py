from tapipy.tapis import Tapis
from tapipy.errors import BaseTapyException
import argparse
import os
import json
from SECRETS import TAPIS_CLIENT
#from SECRETS import CLIENT_CREDENTIALS


def app_manager(client, filepath, userlist, unshare):

    try:
        with open(filepath, 'r') as f:
            app_json = json.load(f)
    except:
        raise

    print('  appId = {}'.format(app_json['id']))
    print('  appVer = {}'.format(app_json['version']))

    if unshare:
        try:
            print(f'  revoking permissions for {userlist}...')
            client.apps.unShareApp(appId=app_json['id'], users=userlist)
            response = client.apps.getShareInfo(appId=app_json['id'])
            print('  app now shared with {}'.format(response.users))
        except BaseTapyException as e:
            if 'APPLIB_NOT_FOUND' in e.message:
                print('  ERROR: appId not recognized: {}'.format(app_json['id']))
            else:
                raise
    else:
        try:
            print(f'  sharing with {userlist}...')
            client.apps.shareApp(appId=app_json['id'], users=userlist)
            response = client.apps.getShareInfo(appId=app_json['id'])
            print('  app now shared with {}'.format(response.users))
        except BaseTapyException as e:
            if 'APPLIB_NOT_FOUND' in e.message:
                print('  ERROR: appId not recognized: {}'.format(app_json['id']))
            else:
                raise


def main():
    parser = argparse.ArgumentParser(description='Share an app with a user')
    parser.add_argument('-u', '--unshare', action='store_true', help='use this flag to revoke pems')
    parser.add_argument('filepath', help='app.json file for app to share')
    parser.add_argument('username', help='tacc username(s) to share with (comma sep)')
    args = parser.parse_args()

    if len(args.filepath) >= 1:
        print(f'Opening {args.filepath}...')
    else:
        raise

    t = Tapis(**TAPIS_CLIENT, download_latest_specs=True) 
    #t = Tapis(base_url='https://portals.tapis.io', **CLIENT_CREDENTIALS)
    #t.get_tokens()
    app_manager(t, args.filepath, args.username.split(','), args.unshare)


if __name__ == "__main__":
    main()
